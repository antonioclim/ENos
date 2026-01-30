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

### Main Header (jobqueue.h)

```c
#ifndef JOBQUEUE_H
#define JOBQUEUE_H

#include <time.h>
#include <stdint.h>

#define MAX_JOBS 1024
#define MAX_CMD_LEN 256
#define SHM_NAME "/jobscheduler_queue"
#define SEM_NAME "/jobscheduler_sem"

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

/* Shared memory structure */
typedef struct {
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
void queue_destroy(void);

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

static JobQueue *queue = NULL;
static sem_t *sem = NULL;

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

/* Initialise shared memory and semaphore (call once) */
int queue_init(void) {
    /* Create shared memory */
    int fd = shm_open(SHM_NAME, O_CREAT | O_RDWR, 0666);
    if (fd == -1) {
        perror("shm_open");
        return -1;
    }
    
    if (ftruncate(fd, sizeof(JobQueue)) == -1) {
        perror("ftruncate");
        close(fd);
        return -1;
    }
    
    queue = mmap(NULL, sizeof(JobQueue), PROT_READ | PROT_WRITE,
                 MAP_SHARED, fd, 0);
    close(fd);
    
    if (queue == MAP_FAILED) {
        perror("mmap");
        return -1;
    }
    
    /* Create semaphore */
    sem = sem_open(SEM_NAME, O_CREAT, 0666, 1);
    if (sem == SEM_FAILED) {
        perror("sem_open");
        munmap(queue, sizeof(JobQueue));
        return -1;
    }
    
    /* Initialise queue */
    sem_wait(sem);
    memset(queue, 0, sizeof(JobQueue));
    queue->next_job_id = 1;
    sem_post(sem);
    
    return 0;
}

/* Attach to existing shared memory */
int queue_attach(void) {
    int fd = shm_open(SHM_NAME, O_RDWR, 0666);
    if (fd == -1) {
        return -1;
    }
    
    queue = mmap(NULL, sizeof(JobQueue), PROT_READ | PROT_WRITE,
                 MAP_SHARED, fd, 0);
    close(fd);
    
    if (queue == MAP_FAILED) {
        return -1;
    }
    
    sem = sem_open(SEM_NAME, 0);
    if (sem == SEM_FAILED) {
        munmap(queue, sizeof(JobQueue));
        return -1;
    }
    
    return 0;
}

void queue_detach(void) {
    if (queue) {
        munmap(queue, sizeof(JobQueue));
        queue = NULL;
    }
    if (sem) {
        sem_close(sem);
        sem = NULL;
    }
}

void queue_destroy(void) {
    queue_detach();
    shm_unlink(SHM_NAME);
    sem_unlink(SEM_NAME);
}

/* Push job to queue */
int queue_push(const Job *job) {
    if (!queue || !sem) return -1;
    
    sem_wait(sem);
    
    if (queue->size >= MAX_JOBS) {
        sem_post(sem);
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
    
    sem_post(sem);
    return new_job.job_id;
}

/* Pop highest priority job */
int queue_pop(Job *job) {
    if (!queue || !sem) return -1;
    
    sem_wait(sem);
    
    if (queue->size == 0) {
        sem_post(sem);
        return -1;
    }
    
    /* Get root (highest priority) */
    *job = queue->heap[0];
    
    /* Move last to root and sift down */
    queue->heap[0] = queue->heap[--queue->size];
    heap_sift_down(0);
    
    sem_post(sem);
    return 0;
}

int queue_peek(Job *job) {
    if (!queue || !sem) return -1;
    
    sem_wait(sem);
    
    if (queue->size == 0) {
        sem_post(sem);
        return -1;
    }
    
    *job = queue->heap[0];
    
    sem_post(sem);
    return 0;
}

int queue_size(void) {
    if (!queue) return -1;
    
    sem_wait(sem);
    int size = queue->size;
    sem_post(sem);
    
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
#include <unistd.h>

static void print_usage(const char *prog) {
    printf("Usage: %s <command> [options]\n\n", prog);
    printf("Commands:\n");
    printf("  init              Initialise job queue\n");
    printf("  destroy           Destroy job queue\n");
    printf("  submit <cmd>      Submit a job\n");
    printf("  list              List pending jobs\n");
    printf("  status <id>       Show job status\n");
    printf("  cancel <id>       Cancel a job\n");
    printf("  stats             Show queue statistics\n");
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
    
    /* Parse options */
    static struct option long_opts[] = {
        {"priority", required_argument, 0, 'p'},
        {"memory", required_argument, 0, 'm'},
        {"time", required_argument, 0, 't'},
        {"help", no_argument, 0, 'h'},
        {0, 0, 0, 0}
    };
    
    int opt;
    while ((opt = getopt_long(argc, argv, "p:m:t:h", long_opts, NULL)) != -1) {
        switch (opt) {
            case 'p': priority = atoi(optarg); break;
            case 'm': max_memory = atoi(optarg); break;
            case 't': max_time = atoi(optarg); break;
            case 'h':
            default:
                print_usage(argv[0]);
                return opt == 'h' ? 0 : 1;
        }
    }
    
    const char *cmd = argv[optind];
    
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
        queue_destroy();
        printf("Queue destroyed\n");
        return 0;
    }
    
    /* Other commands need attached queue */
    if (queue_attach() != 0) {
        fprintf(stderr, "Failed to attach to queue. Run 'jobctl init' first.\n");
        return 1;
    }
    
    if (strcmp(cmd, "submit") == 0) {
        if (optind + 1 >= argc) {
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
        
        int job_id = atoi(argv[optind + 1]);
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
        
        int job_id = atoi(argv[optind + 1]);
        
        if (queue_cancel(job_id) == 0) {
            printf("Job #%d cancelled\n", job_id);
        } else {
            fprintf(stderr, "Failed to cancel job #%d\n", job_id);
            return 1;
        }
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

## Complete Makefile

```makefile
CC = gcc
CFLAGS = -Wall -Wextra -O2 -fPIC
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
	rm -f /dev/shm/jobscheduler_*

install: all
	cp $(LIB_TARGET) /usr/local/lib/
	cp $(CLI_TARGET) /usr/local/bin/
	ldconfig
```

---

## Bash-C Integration

### Calling from Bash

```bash
#!/bin/bash
# scheduler.sh - Uses C library

LIB_PATH="$(dirname "$0")/../build"
export LD_LIBRARY_PATH="$LIB_PATH:$LD_LIBRARY_PATH"

JOBCTL="$(dirname "$0")/../bin/jobctl"

# Initialisation at startup
init_queue() {
    "$JOBCTL" init || {
        echo "Failed to initialise job queue" >&2
        exit 1
    }
}

# Submit job via C tool
submit_job() {
    local cmd="$1"
    local priority="${2:-10}"
    
    "$JOBCTL" submit -p "$priority" "$cmd"
}

# Get next job
get_next_job() {
    # For operations requiring direct queue access,
    # use a C wrapper that exports in easy-to-parse format
    "$JOBCTL" pop --format=shell
}

# Main scheduler loop
main() {
    init_queue
    
    while true; do
        local job_info
        job_info=$(get_next_job)
        
        if [[ -n "$job_info" ]]; then
            eval "$job_info"  # Sets $JOB_ID, $JOB_CMD, etc.
            
            log_info "Starting job #$JOB_ID: $JOB_CMD"
            
            # Run in background with resource limits
            (
                ulimit -t "$JOB_MAX_TIME" 2>/dev/null
                ulimit -v "$((JOB_MAX_MEM * 1024))" 2>/dev/null
                
                eval "$JOB_CMD"
                exit_code=$?
                
                "$JOBCTL" complete "$JOB_ID" "$exit_code"
            ) &
        fi
        
        sleep 1
    done
}
```

---

## Debugging Tips

### Verifying Shared Memory

```bash
# List shared memory segments
ls -la /dev/shm/

# Inspect with hexdump
hexdump -C /dev/shm/jobscheduler_queue | head

# Check semaphore
ls -la /dev/shm/sem.jobscheduler_sem
```

### Debugging with GDB

```bash
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
