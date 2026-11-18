# A01: Mini Job Scheduler

> **Level:** ADVANCED | **Estimated time:** 40-50 hours | **Components:** Bash + C

---

## Description

Job scheduler similar to at/cron but with advanced features: prioritisation, dedicated resources, fair scheduling and a C component for efficient queue management with shared memory and POSIX semaphores.

---

## Why C?

The C component provides:
- **Efficient queue management** (heap-based priority queue)
- **Shared memory** for fast IPC between scheduler and workers
- **POSIX semaphores** for correct synchronisation
- **Performance** - O(log n) operations for insert/extract

---

## Learning Objectives

- Priority queue implementation (min-heap)
- IPC with POSIX shared memory (`shm_open`, `mmap`)
- Synchronisation with POSIX semaphores (`sem_open`)
- Bash-C integration (shared libraries, CLI tools)
- Scheduling algorithms (FIFO, priority, fair-share)

---

## Functional Requirements

### Mandatory (Bash)
1. **Job submission** - submit job with priority and resources
2. **Scheduling policies** - FIFO, priority, fair-share
3. **Resource limits** - CPU time, memory, nice value
4. **Job states** - pending, running, completed, failed
5. **Queue management** - list, cancel, modify
6. **Persistence** - jobs survive restart
7. **Logging** - complete for debugging

### C Component (Mandatory for ADVANCED)
8. **Priority queue** - heap implementation in shared memory
9. **Shared memory segment** - for queue state
10. **CLI tool** - `jobctl` for fast interaction

### Optional
11. **Resource tracking** - actual vs. requested usage
12. **Job dependencies** - run after job X completes
13. **Quotas** - per user limits

---

## Architecture

```
┌─────────────────┐      ┌──────────────────┐
│   jobctl (C)    │◄────►│  Shared Memory   │
└────────┬────────┘      │  /dev/shm/jobs   │
         │               └────────▲─────────┘
         │                        │
┌────────┴────────┐      ┌────────┴─────────┐
│ scheduler.sh    │◄────►│  libjobqueue.so  │
│ (main daemon)   │      │  (C library)     │
└────────┬────────┘      └──────────────────┘
         │
         ▼
┌─────────────────┐
│  Worker Pool    │
│  (bash workers) │
└─────────────────┘
```

---

## Project Structure

```
A01_Mini_Job_Scheduler/
├── README.md
├── Makefile                     # Complete build system
├── src/
│   ├── bash/
│   │   ├── scheduler.sh         # Main daemon
│   │   ├── submit.sh            # Job submission
│   │   └── lib/
│   │       ├── config.sh
│   │       ├── logging.sh
│   │       └── worker.sh
│   └── c/
│       ├── jobqueue.h           # Public header
│       ├── jobqueue.c           # Queue implementation
│       ├── jobctl.c             # CLI tool
│       ├── shm_helpers.h        # Shared memory helpers
│       └── shm_helpers.c
├── tests/
│   ├── test_queue.c
│   └── test_integration.sh
└── docs/
    ├── ARCHITECTURE.md
    └── C_INTEGRATION.md
```

---

## C Component - Detailed Implementation

This is a teaching scaffold, not a completed scheduler. Ellipsised queue functions
and the persistent job ledger are student work. `queue_pop` currently removes an
item from the pending heap: a completed implementation must record a durable
RUNNING reservation before exposing it and reconcile interrupted workers. The CLI
below defines NUL-framed pop output and a completion command against that ledger;
it does not turn the omitted ledger into an implemented feature.

`init` exclusively creates a per-user, per-instance queue; ordinary restarts attach.
Set `JOBQUEUE_INSTANCE` to an agreed instance name for all participants. Shared
memory can survive process restarts on the same boot, but it is not disk/reboot
persistence. Recovery from a dead semaphore owner is an explicit administrative
operation after all participants stop; the two-second acquisition timeout reports
unavailability and never resets live state. `destroy` is separate from `make clean`.
A durable journal, crash recovery, multi-user permissions and ABI migration remain
student design requirements.

### Main Header (jobqueue.h)

```c
#ifndef JOBQUEUE_H
#define JOBQUEUE_H

#include <time.h>
#include <stdint.h>

#define MAX_JOBS 1024
#define MAX_CMD_LEN 256
#define QUEUE_MAGIC UINT32_C(0x4a515631)
#define QUEUE_VERSION 1

/* Job states */
typedef enum {
    JOB_PENDING = 0,
    JOB_RUNNING = 1,
    JOB_COMPLETED = 2,
    JOB_FAILED = 3,
    JOB_CANCELLED = 4
} JobState;

/* Job structure */
typedef struct {
    int32_t job_id;
    int32_t priority;        /* Lower = higher priority */
    int32_t nice_value;
    int32_t max_memory_mb;
    int32_t max_cpu_seconds;
    int32_t owner_uid;
    JobState state;
    time_t submit_time;
    time_t start_time;
    time_t end_time;
    int32_t exit_code;
    char command[MAX_CMD_LEN];
} Job;

/* Shared memory structure; same ABI/build required for all participants. */
typedef struct {
    uint32_t magic;
    uint32_t version;
    int32_t size;
    int32_t next_job_id;
    int32_t total_submitted;
    int32_t total_completed;
    int32_t total_failed;
    Job heap[MAX_JOBS];      /* Min-heap by priority */
} JobQueue;

/* Initialisation */
int queue_init(void);
int queue_attach(void);
void queue_detach(void);
int queue_destroy(void);

/* Queue operations */
int queue_push(const Job *job);
int queue_pop(Job *job);
int queue_peek(Job *job);
int queue_size(void);
int queue_get_by_id(int job_id, Job *job);
int queue_cancel(int job_id);
int queue_update_state(int job_id, JobState state, int exit_code);

/* Iteration */
int queue_list(Job *jobs, int max_jobs, JobState filter);

/* Statistics */
void queue_stats(int *pending, int *running, int *completed, int *failed);

#endif /* JOBQUEUE_H */
```

### Queue Implementation (jobqueue.c)

```c
#include "jobqueue.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <semaphore.h>
#include <unistd.h>
#include <errno.h>
#include <ctype.h>
#include <limits.h>

static JobQueue *queue = NULL;
static sem_t *sem = NULL;
static char shm_name[128], sem_name[128];

static int queue_names(void) {
    const char *instance = getenv("JOBQUEUE_INSTANCE");
    if (!instance || !*instance) instance = "default";
    if (strlen(instance) > 48) { errno = EINVAL; return -1; }
    for (const unsigned char *p = (const unsigned char *)instance; *p; ++p)
        if (!isalnum(*p) && *p != '_' && *p != '-') { errno = EINVAL; return -1; }
    snprintf(shm_name, sizeof shm_name, "/jobqueue_%lu_%s", (unsigned long)getuid(), instance);
    snprintf(sem_name, sizeof sem_name, "/jobsem_%lu_%s", (unsigned long)getuid(), instance);
    return 0;
}

static int queue_lock(void) {
    if (!queue || !sem) { errno = EINVAL; return -1; }
    struct timespec deadline;
    if (clock_gettime(CLOCK_REALTIME, &deadline) < 0) return -1;
    deadline.tv_sec += 2;
    int rc;
    do { rc = sem_timedwait(sem, &deadline); } while (rc < 0 && errno == EINTR);
    return rc; /* Timeout/error does not confer ownership of the semaphore. */
}

static int queue_unlock(void) { return sem_post(sem); }

/* Heap helpers */
static void heap_swap(Job *a, Job *b) {
    Job tmp = *a;
    *a = *b;
    *b = tmp;
}

static void heap_sift_up(int idx) {
    while (idx > 0) {
        int parent = (idx - 1) / 2;
        if (queue->heap[idx].priority < queue->heap[parent].priority) {
            heap_swap(&queue->heap[idx], &queue->heap[parent]);
            idx = parent;
        } else {
            break;
        }
    }
}

static void heap_sift_down(int idx) {
    int size = queue->size;
    while (1) {
        int smallest = idx;
        int left = 2 * idx + 1;
        int right = 2 * idx + 2;
        
        if (left < size && 
            queue->heap[left].priority < queue->heap[smallest].priority) {
            smallest = left;
        }
        if (right < size && 
            queue->heap[right].priority < queue->heap[smallest].priority) {
            smallest = right;
        }
        
        if (smallest != idx) {
            heap_swap(&queue->heap[idx], &queue->heap[smallest]);
            idx = smallest;
        } else {
            break;
        }
    }
}

/* Explicit creation: never truncates or resets an existing queue. */
int queue_init(void) {
    if (queue || sem) { errno = EALREADY; return -1; }
    if (queue_names() < 0) return -1;
    int fd = shm_open(shm_name, O_CREAT | O_EXCL | O_RDWR, 0600);
    if (fd < 0) return -1;
    int made_sem = 0, saved;
    if (ftruncate(fd, sizeof(JobQueue)) < 0) goto fail;
    void *mapped = mmap(NULL, sizeof(JobQueue), PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
    if (mapped == MAP_FAILED) goto fail;
    queue = mapped;
    sem_t *opened = sem_open(sem_name, O_CREAT | O_EXCL, 0600, 0);
    if (opened == SEM_FAILED) goto fail;
    sem = opened; made_sem = 1;
    memset(queue, 0, sizeof *queue);
    queue->version = QUEUE_VERSION; queue->next_job_id = 1;
    queue->magic = QUEUE_MAGIC;
    if (queue_unlock() < 0) goto fail; /* Publish readiness only after initialisation. */
    close(fd);
    return 0;
fail:
    saved = errno;
    queue_detach(); close(fd);
    if (made_sem) sem_unlink(sem_name);
    shm_unlink(shm_name); /* Only the object created with O_EXCL by this call. */
    errno = saved;
    return -1;
}

/* Normal restart: attach; an absent/incomplete/incompatible queue is an error. */
int queue_attach(void) {
    if (queue || sem) { errno = EALREADY; return -1; }
    if (queue_names() < 0) return -1;
    int fd = shm_open(shm_name, O_RDWR, 0);
    if (fd < 0) return -1;
    struct stat st;
    if (fstat(fd, &st) < 0 || st.st_uid != getuid() || (st.st_mode & 0777) != 0600 ||
        st.st_size != (off_t)sizeof(JobQueue)) {
        close(fd); errno = EINVAL; return -1;
    }
    void *mapped = mmap(NULL, sizeof(JobQueue), PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
    close(fd);
    if (mapped == MAP_FAILED) return -1;
    queue = mapped;
    sem_t *opened = sem_open(sem_name, 0);
    if (opened == SEM_FAILED) { queue_detach(); return -1; }
    sem = opened;
    if (queue_lock() < 0) { int saved = errno; queue_detach(); errno = saved; return -1; }
    int valid = queue->magic == QUEUE_MAGIC && queue->version == QUEUE_VERSION &&
                queue->size >= 0 && queue->size <= MAX_JOBS && queue->next_job_id > 0;
    int unlock_rc = queue_unlock();
    if (!valid || unlock_rc < 0) { queue_detach(); errno = EINVAL; return -1; }
    return 0;
}

void queue_detach(void) {
    if (queue) { munmap(queue, sizeof *queue); queue = NULL; }
    if (sem) { sem_close(sem); sem = NULL; }
}

/* Explicit administrative operation; all workers must already be stopped. */
int queue_destroy(void) {
    if (queue_names() < 0) return -1;
    int fd = shm_open(shm_name, O_RDWR, 0);
    if (fd < 0) return -1;
    struct stat st;
    int owned = fstat(fd, &st) == 0 && st.st_uid == getuid() && (st.st_mode & 0777) == 0600;
    close(fd);
    if (!owned) { errno = EPERM; return -1; }
    queue_detach();
    int rc = shm_unlink(shm_name);
    if (sem_unlink(sem_name) < 0 && errno != ENOENT) rc = -1;
    return rc;
}

/* Push job to queue */
int queue_push(const Job *job) {
    if (!queue || !sem || !job) { errno = EINVAL; return -1; }
    
    if (queue_lock() < 0) return -1;
    
    if (queue->size >= MAX_JOBS || queue->next_job_id == INT32_MAX || queue->total_submitted == INT32_MAX) {
        queue_unlock();
        return -1;
    }
    
    /* Copy job and assign ID */
    Job new_job = *job;
    new_job.job_id = queue->next_job_id++;
    new_job.state = JOB_PENDING;
    new_job.submit_time = time(NULL);
    
    /* Insert at end and sift up */
    int idx = queue->size++;
    queue->heap[idx] = new_job;
    heap_sift_up(idx);
    
    queue->total_submitted++;
    
    if (queue_unlock() < 0) return -1;
    return new_job.job_id;
}

/* Pop highest priority job */
int queue_pop(Job *job) {
    if (!queue || !sem || !job) { errno = EINVAL; return -1; }
    
    if (queue_lock() < 0) return -1;
    
    if (queue->size == 0) {
        queue_unlock();
        return -1;
    }
    
    /* Get root (highest priority) */
    *job = queue->heap[0];
    
    /* Move last to root and sift down */
    queue->heap[0] = queue->heap[--queue->size];
    heap_sift_down(0);
    
    return queue_unlock();
}

int queue_peek(Job *job) {
    if (!queue || !sem || !job) { errno = EINVAL; return -1; }
    
    if (queue_lock() < 0) return -1;
    
    if (queue->size == 0) {
        queue_unlock();
        return -1;
    }
    
    *job = queue->heap[0];
    
    return queue_unlock();
}

int queue_size(void) {
    if (!queue || !sem) return -1;
    
    if (queue_lock() < 0) return -1;
    int size = queue->size;
    if (queue_unlock() < 0) return -1;
    return size;
}

/* ... (additional queue functions) ... */
```

### CLI Tool (jobctl.c)

```c
#include "jobqueue.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <getopt.h>
#include <errno.h>
#include <limits.h>
#include <unistd.h>

static int parse_number(const char *text, int minimum, int maximum, int *result) {
    char *end; errno = 0;
    long value = strtol(text, &end, 10);
    if (errno || end == text || *end || value < minimum || value > maximum) return -1;
    *result = (int)value; return 0;
}

static void print_usage(const char *prog) {
    printf("Usage: %s [options] <command> [arguments]\n\n", prog);
    printf("Commands:\n");
    printf("  init              Create a new queue (existing queue is an error)\n");
    printf("  destroy           Destroy job queue\n");
    printf("  submit <cmd>      Submit a job\n");
    printf("  list              List pending jobs\n");
    printf("  status <id>       Show job status\n");
    printf("  cancel <id>       Cancel a job\n");
    printf("  stats             Show queue statistics\n");
    printf("  pop               Reserve a job; --format=nul is required\n");
    printf("  complete ID CODE  Record completion in the student-supplied job ledger\n");
    printf("\nOptions:\n");
    printf("  -p, --priority N  Job priority (default: 10)\n");
    printf("  -m, --memory MB   Max memory in MB\n");
    printf("  -t, --time SEC    Max CPU time in seconds\n");
}

static const char *state_str(JobState state) {
    switch (state) {
        case JOB_PENDING: return "PENDING";
        case JOB_RUNNING: return "RUNNING";
        case JOB_COMPLETED: return "COMPLETED";
        case JOB_FAILED: return "FAILED";
        case JOB_CANCELLED: return "CANCELLED";
        default: return "UNKNOWN";
    }
}

static void print_job(const Job *job) {
    printf("Job #%d\n", job->job_id);
    printf("  Command: %s\n", job->command);
    printf("  State: %s\n", state_str(job->state));
    printf("  Priority: %d\n", job->priority);
    printf("  Submitted: %s", ctime(&job->submit_time));
    
    if (job->state == JOB_RUNNING || job->state == JOB_COMPLETED) {
        printf("  Started: %s", ctime(&job->start_time));
    }
    if (job->state == JOB_COMPLETED || job->state == JOB_FAILED) {
        printf("  Ended: %s", ctime(&job->end_time));
        printf("  Exit code: %d\n", job->exit_code);
    }
}

int main(int argc, char *argv[]) {
    if (argc < 2) {
        print_usage(argv[0]);
        return 1;
    }
    
    int priority = 10;
    int max_memory = 0;
    int max_time = 0;
    const char *format = NULL;
    
    /* Parse options */
    static struct option long_opts[] = {
        {"priority", required_argument, 0, 'p'},
        {"memory", required_argument, 0, 'm'},
        {"time", required_argument, 0, 't'},
        {"help", no_argument, 0, 'h'},
        {"format", required_argument, 0, 'f'},
        {0, 0, 0, 0}
    };
    
    int opt;
    while ((opt = getopt_long(argc, argv, "+p:m:t:hf:", long_opts, NULL)) != -1) {
        switch (opt) {
            case 'p': if (parse_number(optarg, 0, INT_MAX, &priority) < 0) return 2; break;
            case 'm': if (parse_number(optarg, 0, INT_MAX/1024, &max_memory) < 0) return 2; break;
            case 't': if (parse_number(optarg, 0, INT_MAX, &max_time) < 0) return 2; break;
            case 'f': format = optarg; break;
            case 'h':
            default:
                print_usage(argv[0]);
                return opt == 'h' ? 0 : 1;
        }
    }
    
    if (optind >= argc) { print_usage(argv[0]); return 2; }
    const char *cmd = argv[optind];
    if (format && (strcmp(cmd, "pop") != 0 || strcmp(format, "nul") != 0)) return 2;
    
    /* Handle commands */
    if (strcmp(cmd, "init") == 0) {
        if (queue_init() == 0) {
            printf("Queue initialised\n");
            queue_detach();
            return 0;
        } else {
            fprintf(stderr, "Failed to initialise queue\n");
            return 1;
        }
    }
    
    if (strcmp(cmd, "destroy") == 0) {
        if (queue_destroy() < 0) { perror("queue_destroy"); return 1; }
        printf("Queue destroyed\n");
        return 0;
    }
    
    /* Other commands need attached queue */
    if (queue_attach() != 0) {
        fprintf(stderr, "Failed to attach to queue. Run 'jobctl init' first.\n");
        return 1;
    }
    
    atexit(queue_detach);
    if (strcmp(cmd, "submit") == 0) {
        if (optind + 2 != argc || strlen(argv[optind+1]) >= MAX_CMD_LEN) {
            fprintf(stderr, "Usage: submit <command>\n");
            return 1;
        }
        
        Job job = {0};
        job.priority = priority;
        job.max_memory_mb = max_memory;
        job.max_cpu_seconds = max_time;
        job.owner_uid = getuid();
        strncpy(job.command, argv[optind + 1], MAX_CMD_LEN - 1);
        
        int job_id = queue_push(&job);
        if (job_id > 0) {
            printf("Job submitted: #%d\n", job_id);
        } else {
            fprintf(stderr, "Failed to submit job\n");
            return 1;
        }
    }
    else if (strcmp(cmd, "list") == 0) {
        printf("Pending jobs: %d\n\n", queue_size());
        
        Job jobs[MAX_JOBS];
        int count = queue_list(jobs, MAX_JOBS, JOB_PENDING);
        
        for (int i = 0; i < count; i++) {
            print_job(&jobs[i]);
            printf("\n");
        }
    }
    else if (strcmp(cmd, "status") == 0) {
        if (optind + 1 >= argc) {
            fprintf(stderr, "Usage: status <job_id>\n");
            return 1;
        }
        
        int job_id;
        if (parse_number(argv[optind + 1], 1, INT_MAX, &job_id) < 0) return 2;
        Job job;
        
        if (queue_get_by_id(job_id, &job) == 0) {
            print_job(&job);
        } else {
            fprintf(stderr, "Job #%d not found\n", job_id);
            return 1;
        }
    }
    else if (strcmp(cmd, "cancel") == 0) {
        if (optind + 1 >= argc) {
            fprintf(stderr, "Usage: cancel <job_id>\n");
            return 1;
        }
        
        int job_id;
        if (parse_number(argv[optind + 1], 1, INT_MAX, &job_id) < 0) return 2;
        
        if (queue_cancel(job_id) == 0) {
            printf("Job #%d cancelled\n", job_id);
        } else {
            fprintf(stderr, "Failed to cancel job #%d\n", job_id);
            return 1;
        }
    }
    else if (strcmp(cmd, "pop") == 0) {
        if (!format || strcmp(format, "nul") != 0 || optind+1 != argc) return 2;
        Job job;
        if (queue_pop(&job) < 0) return 3; /* Empty/unavailable: no metadata emitted. */
        printf("%d%c%s%c%d%c%d%c", job.job_id, 0, job.command, 0,
               job.max_cpu_seconds, 0, job.max_memory_mb, 0);
        if (ferror(stdout)) return 1;
    }
    else if (strcmp(cmd, "complete") == 0) {
        int id, code;
        if (optind+3 != argc || parse_number(argv[optind+1], 1, INT_MAX, &id) < 0 ||
            parse_number(argv[optind+2], 0, 255, &code) < 0) return 2;
        if (queue_update_state(id, code == 0 ? JOB_COMPLETED : JOB_FAILED, code) < 0) return 1;
    }
    else if (strcmp(cmd, "stats") == 0) {
        int pending, running, completed, failed;
        queue_stats(&pending, &running, &completed, &failed);
        
        printf("Queue Statistics:\n");
        printf("  Pending:   %d\n", pending);
        printf("  Running:   %d\n", running);
        printf("  Completed: %d\n", completed);
        printf("  Failed:    %d\n", failed);
    }
    else {
        fprintf(stderr, "Unknown command: %s\n", cmd);
        print_usage(argv[0]);
        return 1;
    }
    
    queue_detach();
    return 0;
}
```

---

## Makefile for the completed student implementation

```makefile
CC = gcc
CFLAGS = -std=c11 -D_POSIX_C_SOURCE=200809L -Wall -Wextra -O2 -fPIC
LDFLAGS = -lpthread -lrt

SRC_DIR = src/c
BUILD_DIR = build
BIN_DIR = bin

SOURCES = $(SRC_DIR)/jobqueue.c
LIB_TARGET = $(BUILD_DIR)/libjobqueue.so
CLI_TARGET = $(BIN_DIR)/jobctl

.PHONY: all clean install test

all: $(LIB_TARGET) $(CLI_TARGET)

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

$(BIN_DIR):
	mkdir -p $(BIN_DIR)

# Shared library
$(LIB_TARGET): $(SRC_DIR)/jobqueue.c $(SRC_DIR)/jobqueue.h | $(BUILD_DIR)
	$(CC) $(CFLAGS) -shared -o $@ $< $(LDFLAGS)

# CLI tool
$(CLI_TARGET): $(SRC_DIR)/jobctl.c $(LIB_TARGET) | $(BIN_DIR)
	$(CC) $(CFLAGS) -o $@ $< -L$(BUILD_DIR) -ljobqueue -Wl,-rpath,'$$ORIGIN/../build' $(LDFLAGS)

# Tests
test: $(LIB_TARGET)
	$(CC) $(CFLAGS) -o $(BUILD_DIR)/test_queue tests/test_queue.c \
		-L$(BUILD_DIR) -ljobqueue -Wl,-rpath,$(BUILD_DIR) $(LDFLAGS)
	./$(BUILD_DIR)/test_queue

clean:
	rm -rf $(BUILD_DIR) $(BIN_DIR)

install: all
	cp $(LIB_TARGET) /usr/local/lib/
	cp $(CLI_TARGET) /usr/local/bin/
	ldconfig
```

---

## Bash-C Integration

### Calling from Bash

```bash
#!/usr/bin/env bash
# Integration scaffold: the student must supply a durable job ledger, reservation
# recovery, queue_list/cancel/update/stats and the complete scheduler policies.
set -euo pipefail
PROJECT_ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)
JOBCTL="$PROJECT_ROOT/bin/jobctl"
# The CLI uses its ORIGIN rpath. No empty LD_LIBRARY_PATH component is added.
MAX_WORKERS=${MAX_WORKERS:-4}
[[ $MAX_WORKERS =~ ^[1-9][0-9]*$ ]] || exit 2

submit_job() { "$JOBCTL" -p "${2:-10}" submit "$1"; }

run_worker() (
    local id="$1" command="$2" cpu="$3" memory="$4" status
    # Zero means no additional limit. A requested limit that fails stops this job.
    if ((cpu > 0)); then ulimit -t "$cpu" || return 1; fi
    if ((memory > 0)); then ulimit -v "$((memory*1024))" || return 1; fi
    # Submitted commands are explicitly authorised shell programs. Metadata is data.
    if bash -c "$command"; then status=0; else status=$?; fi
    "$JOBCTL" complete "$id" "$status" || return 1
    return "$status"
)

main() (
    local workspace record pid failed=0
    workspace=$(mktemp -d) || return 1
    trap 'rm -rf -- "$workspace"' EXIT
    # Attach/inspect on startup; creation is a separate explicit jobctl init step.
    "$JOBCTL" stats || return 1
    local -a workers=() fields=()
    while true; do
        if ((${#workers[@]} >= MAX_WORKERS)); then
            if ! wait "${workers[0]}"; then failed=1; fi
            workers=("${workers[@]:1}")
        fi
        record="$workspace/job.nul"
        if "$JOBCTL" --format=nul pop > "$record"; then
            mapfile -d '' -t fields < "$record"
            [[ ${#fields[@]} -eq 4 && ${fields[0]} =~ ^[1-9][0-9]*$ && ${fields[2]} =~ ^[0-9]+$ && ${fields[3]} =~ ^[0-9]+$ ]] || return 1
            run_worker "${fields[@]}" & workers+=("$!")
        else
            local status=$?
            ((status == 3)) || return "$status"
            sleep 1
        fi
    done
)
# Intentionally not invoked: this is a scaffold until reservation/recovery and
# orderly shutdown are implemented and tested. Do not label it a complete daemon.
```

---

## Debugging Tips

### Verifying Shared Memory

```bash
# List shared memory segments
ls -la /dev/shm/

# Inspect with hexdump
hexdump -C /dev/shm/jobqueue_"$(id -u)"_"${JOBQUEUE_INSTANCE:-default}" | head

# Check semaphore
ls -la /dev/shm/sem.jobsem_"$(id -u)"_"${JOBQUEUE_INSTANCE:-default}"
```

### Debugging with GDB

```text
# Compile with debug symbols
gcc -g -Wall -o jobctl_debug jobctl.c -L. -ljobqueue -lpthread -lrt

# Run with gdb
gdb ./jobctl_debug
(gdb) break queue_push
(gdb) run submit "echo test"
```

### Valgrind for Memory Leaks

```bash
valgrind --leak-check=full ./jobctl submit "echo test"
```

---

## Specific Evaluation Criteria

| Criterion | Weight | Description |
|-----------|--------|-------------|
| Correct scheduling | 20% | FIFO, priority, fair-share |
| Functional C component | 25% | Heap, shared mem, semaphore |
| Bash-C integration | 15% | Correct communication |
| Job management | 15% | Submit, cancel, status |
| Code quality | 15% | Clean, documented, no leaks |
| Tests | 5% | Unit + integration |
| Documentation | 5% | README, architecture |

---

## Resources

- `man shm_open`, `man mmap` - Shared memory
- `man sem_open` - POSIX semaphores
- "The Linux Programming Interface" - M. Kerrisk
- Seminar 2-3 - Processes, IPC

---

*ADVANCED Project | Operating Systems | ASE-CSIE*
