# A03: Distributed File Sync

> **Level:** ADVANCED | **Estimated time:** 40-50 hours | **Components:** Bash + C

---

## Description

File synchronisation system between multiple machines (similar to rsync/Dropbox): real-time change detection, efficient transfer (delta sync), conflict resolution and a C component for fast hashing and binary diff.

---

## Why C?

The C component provides:
- **Fast hashing** (MD5/SHA for large files)
- **Rolling hash** for rsync-style delta sync
- **Binary diff** for efficient transfer
- **inotify wrapper** for change detection

---

## Learning Objectives

- rsync algorithm (rolling checksum)
- inotify for filesystem monitoring
- Network programming basics (sockets)
- Conflict detection and resolution
- Delta encoding and efficient transfer

---

## Functional Requirements

### Mandatory (Bash)
1. **File monitoring** - detect modifications, additions, deletions
2. **Sync protocol** - communication between nodes
3. **Conflict handling** - detection and resolution
4. **Configuration** - dirs to sync, excludes
5. **Logging** - complete audit trail
6. **Recovery** - resume interrupted sync

### C Component (Mandatory for ADVANCED)
7. **Fast hashing** - efficient file checksums
8. **Rolling hash** - for delta detection
9. **Binary diff** - generate and apply patches

### Optional
10. **Compression** - compressed transfer
11. **Encryption** - secure transfer
12. **Multi-node** - sync between >2 machines

---

## Architecture

```
        Machine A                           Machine B
┌─────────────────────┐             ┌─────────────────────┐
│   sync_daemon.sh    │◄───────────►│   sync_daemon.sh    │
│                     │   Network   │                     │
├─────────────────────┤             ├─────────────────────┤
│  ┌───────────────┐  │             │  ┌───────────────┐  │
│  │ File Watcher  │  │             │  │ File Watcher  │  │
│  │ (inotify)     │  │             │  │ (inotify)     │  │
│  └───────────────┘  │             │  └───────────────┘  │
│  ┌───────────────┐  │             │  ┌───────────────┐  │
│  │ libsyncutil.so│  │             │  │ libsyncutil.so│  │
│  │ Hash + Diff   │  │             │  │ Hash + Diff   │  │
│  └───────────────┘  │             │  └───────────────┘  │
└─────────────────────┘             └─────────────────────┘
          │                                   │
          ▼                                   ▼
    ┌───────────┐                       ┌───────────┐
    │ /sync/dir │                       │ /sync/dir │
    └───────────┘                       └───────────┘
```

---

## Project Structure

```
A03_Distributed_File_Sync/
├── README.md
├── Makefile
├── src/
│   ├── bash/
│   │   ├── sync_daemon.sh       # Main daemon
│   │   ├── sync_client.sh       # CLI interface
│   │   ├── lib/
│   │   │   ├── watcher.sh       # inotify wrapper
│   │   │   ├── protocol.sh      # Sync protocol
│   │   │   ├── conflict.sh      # Conflict resolution
│   │   │   └── transfer.sh      # File transfer
│   │   └── hooks/
│   │       ├── pre_sync.sh
│   │       └── post_sync.sh
│   └── c/
│       ├── syncutil.h           # Public header
│       ├── hash.c               # Fast hashing
│       ├── rolling_hash.c       # Rolling checksum
│       ├── diff.c               # Binary diff
│       ├── inotify_helper.c     # inotify wrapper
│       └── synctool.c           # CLI utility
├── etc/
│   ├── sync.conf
│   └── excludes
├── tests/
│   ├── test_hash.c
│   ├── test_diff.c
│   └── test_sync.sh
└── docs/
    ├── PROTOCOL.md
    └── ALGORITHM.md
```

---

## C Component - Implementation

### Main Header (syncutil.h)

```c
#ifndef SYNCUTIL_H
#define SYNCUTIL_H

#include <stdint.h>
#include <stddef.h>
#include <stdbool.h>
#include <sys/types.h>

/* Block size for rolling hash */
#define BLOCK_SIZE 4096
#define HASH_SIZE 16  /* MD5 */

/* File hash structure */
typedef struct {
    unsigned char hash[HASH_SIZE];
    size_t file_size;
    time_t mtime;
} FileChecksum;

/* Block signature for delta sync */
typedef struct {
    uint32_t weak_hash;           /* Rolling (Adler-32 style) */
    unsigned char strong_hash[HASH_SIZE]; /* MD5 */
    off_t offset;
} BlockSignature;

/* Signature table for a file */
typedef struct {
    size_t block_count;
    size_t block_size;
    BlockSignature *blocks;
} SignatureTable;

/* Delta instruction */
typedef enum {
    DELTA_COPY,      /* Copy block from old file */
    DELTA_DATA       /* New data */
} DeltaType;

typedef struct {
    DeltaType type;
    union {
        struct {
            off_t offset;
            size_t length;
        } copy;
        struct {
            unsigned char *data;
            size_t length;
        } data;
    } u;
} DeltaInstruction;

/* Delta (patch) */
typedef struct {
    size_t instruction_count;
    DeltaInstruction *instructions;
} Delta;

/* ===== Hashing Functions ===== */

/* Compute MD5 hash of file */
int hash_file(const char *path, FileChecksum *checksum);

/* Compute MD5 of data block */
void hash_block(const unsigned char *data, size_t len, 
                unsigned char *hash);

/* Compare two checksums */
bool checksums_equal(const FileChecksum *a, const FileChecksum *b);

/* ===== Rolling Hash (Adler-32 style) ===== */

typedef struct {
    uint32_t a;
    uint32_t b;
    size_t count;
    size_t window_size;
    unsigned char *window;
    size_t window_pos;
} RollingHash;

void rolling_hash_init(RollingHash *rh, size_t window_size);
void rolling_hash_update(RollingHash *rh, unsigned char old_byte, 
                         unsigned char new_byte);
uint32_t rolling_hash_digest(const RollingHash *rh);
void rolling_hash_free(RollingHash *rh);

/* ===== Signature Generation ===== */

/* Generate signature table for a file */
SignatureTable *signature_generate(const char *path, size_t block_size);
void signature_free(SignatureTable *sig);

/* Serialise/deserialise signatures for network transfer */
unsigned char *signature_serialise(const SignatureTable *sig, size_t *len);
SignatureTable *signature_deserialise(const unsigned char *data, size_t len);

/* ===== Delta Generation & Application ===== */

/* Generate delta between old signatures and new file */
Delta *delta_generate(const SignatureTable *old_sig, const char *new_path);

/* Apply delta to old file, creating new file */
int delta_apply(const char *old_path, const Delta *delta, 
                const char *new_path);

void delta_free(Delta *delta);

/* Serialise/deserialise delta for network transfer */
unsigned char *delta_serialise(const Delta *delta, size_t *len);
Delta *delta_deserialise(const unsigned char *data, size_t len);

/* ===== inotify Helpers ===== */

typedef void (*FileChangeCallback)(const char *path, uint32_t mask, 
                                    void *user_data);

typedef struct InotifyWatcher InotifyWatcher;

InotifyWatcher *watcher_create(void);
int watcher_add_recursive(InotifyWatcher *w, const char *path);
int watcher_remove(InotifyWatcher *w, const char *path);
void watcher_set_callback(InotifyWatcher *w, FileChangeCallback cb, 
                          void *user_data);
int watcher_poll(InotifyWatcher *w, int timeout_ms);
void watcher_destroy(InotifyWatcher *w);

#endif /* SYNCUTIL_H */
```

### Fast Hashing (hash.c)

```c
#include "syncutil.h"
#include <stdio.h>
#include <string.h>
#include <openssl/md5.h>
#include <sys/stat.h>

int hash_file(const char *path, FileChecksum *checksum) {
    FILE *f = fopen(path, "rb");
    if (!f) return -1;
    
    MD5_CTX ctx;
    MD5_Init(&ctx);
    
    unsigned char buffer[BLOCK_SIZE];
    size_t bytes_read;
    size_t total_size = 0;
    
    while ((bytes_read = fread(buffer, 1, BLOCK_SIZE, f)) > 0) {
        MD5_Update(&ctx, buffer, bytes_read);
        total_size += bytes_read;
    }
    
    MD5_Final(checksum->hash, &ctx);
    checksum->file_size = total_size;
    
    /* Get mtime */
    struct stat st;
    if (fstat(fileno(f), &st) == 0) {
        checksum->mtime = st.st_mtime;
    }
    
    fclose(f);
    return 0;
}

void hash_block(const unsigned char *data, size_t len, 
                unsigned char *hash) {
    MD5_CTX ctx;
    MD5_Init(&ctx);
    MD5_Update(&ctx, data, len);
    MD5_Final(hash, &ctx);
}

bool checksums_equal(const FileChecksum *a, const FileChecksum *b) {
    return memcmp(a->hash, b->hash, HASH_SIZE) == 0;
}
```

### Rolling Hash (rolling_hash.c)

```c
#include "syncutil.h"
#include <stdlib.h>
#include <string.h>

#define MOD_ADLER 65521

void rolling_hash_init(RollingHash *rh, size_t window_size) {
    rh->a = 1;
    rh->b = 0;
    rh->count = 0;
    rh->window_size = window_size;
    rh->window = calloc(window_size, 1);
    rh->window_pos = 0;
}

void rolling_hash_update(RollingHash *rh, unsigned char old_byte, 
                         unsigned char new_byte) {
    /* Remove old byte contribution, add new byte */
    rh->a = (rh->a - old_byte + new_byte) % MOD_ADLER;
    rh->b = (rh->b - (rh->window_size * old_byte) + rh->a - 1) % MOD_ADLER;
    
    /* Handle negative modulo */
    if ((int32_t)rh->a < 0) rh->a += MOD_ADLER;
    if ((int32_t)rh->b < 0) rh->b += MOD_ADLER;
    
    /* Update window */
    rh->window[rh->window_pos] = new_byte;
    rh->window_pos = (rh->window_pos + 1) % rh->window_size;
    
    if (rh->count < rh->window_size) rh->count++;
}

uint32_t rolling_hash_digest(const RollingHash *rh) {
    return (rh->b << 16) | rh->a;
}

void rolling_hash_free(RollingHash *rh) {
    free(rh->window);
    rh->window = NULL;
}
```

### Signature Generation (signature.c)

```c
#include "syncutil.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

SignatureTable *signature_generate(const char *path, size_t block_size) {
    FILE *f = fopen(path, "rb");
    if (!f) return NULL;
    
    /* Get file size */
    fseek(f, 0, SEEK_END);
    size_t file_size = ftell(f);
    fseek(f, 0, SEEK_SET);
    
    size_t block_count = (file_size + block_size - 1) / block_size;
    
    SignatureTable *sig = malloc(sizeof(SignatureTable));
    sig->block_count = block_count;
    sig->block_size = block_size;
    sig->blocks = malloc(block_count * sizeof(BlockSignature));
    
    unsigned char *buffer = malloc(block_size);
    RollingHash rh;
    
    for (size_t i = 0; i < block_count; i++) {
        size_t bytes_read = fread(buffer, 1, block_size, f);
        
        /* Calculate weak hash (rolling) */
        rolling_hash_init(&rh, bytes_read);
        for (size_t j = 0; j < bytes_read; j++) {
            rolling_hash_update(&rh, 0, buffer[j]);
        }
        sig->blocks[i].weak_hash = rolling_hash_digest(&rh);
        rolling_hash_free(&rh);
        
        /* Calculate strong hash (MD5) */
        hash_block(buffer, bytes_read, sig->blocks[i].strong_hash);
        
        sig->blocks[i].offset = i * block_size;
    }
    
    free(buffer);
    fclose(f);
    return sig;
}

void signature_free(SignatureTable *sig) {
    if (sig) {
        free(sig->blocks);
        free(sig);
    }
}
```

### Delta Generation (diff.c)

```c
#include "syncutil.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define HASH_TABLE_SIZE 65536

/* Hash table for quick weak hash lookup */
typedef struct {
    uint32_t weak_hash;
    size_t block_index;
    struct HashEntry *next;
} HashEntry;

static size_t hash_index(uint32_t weak_hash) {
    return weak_hash % HASH_TABLE_SIZE;
}

Delta *delta_generate(const SignatureTable *old_sig, const char *new_path) {
    if (!old_sig || !new_path) return NULL;
    
    FILE *f = fopen(new_path, "rb");
    if (!f) return NULL;
    
    /* Build hash table from old signatures */
    HashEntry **hash_table = calloc(HASH_TABLE_SIZE, sizeof(HashEntry *));
    
    for (size_t i = 0; i < old_sig->block_count; i++) {
        size_t idx = hash_index(old_sig->blocks[i].weak_hash);
        HashEntry *entry = malloc(sizeof(HashEntry));
        entry->weak_hash = old_sig->blocks[i].weak_hash;
        entry->block_index = i;
        entry->next = hash_table[idx];
        hash_table[idx] = entry;
    }
    
    /* Initialize delta */
    Delta *delta = malloc(sizeof(Delta));
    delta->instruction_count = 0;
    size_t capacity = 128;
    delta->instructions = malloc(capacity * sizeof(DeltaInstruction));
    
    /* Scan new file */
    size_t block_size = old_sig->block_size;
    unsigned char *buffer = malloc(block_size);
    unsigned char *pending_data = malloc(1024 * 1024); /* 1MB buffer */
    size_t pending_len = 0;
    
    RollingHash rh;
    rolling_hash_init(&rh, block_size);
    
    int c;
    size_t pos = 0;
    size_t window_filled = 0;
    
    while ((c = fgetc(f)) != EOF) {
        unsigned char byte = (unsigned char)c;
        
        unsigned char old_byte = 0;
        if (window_filled >= block_size) {
            old_byte = pending_data[pending_len - block_size];
        }
        
        rolling_hash_update(&rh, old_byte, byte);
        pending_data[pending_len++] = byte;
        window_filled++;
        
        if (window_filled >= block_size) {
            uint32_t weak = rolling_hash_digest(&rh);
            size_t idx = hash_index(weak);
            
            /* Check hash table */
            HashEntry *entry = hash_table[idx];
            while (entry) {
                if (entry->weak_hash == weak) {
                    /* Verify with strong hash */
                    unsigned char strong[HASH_SIZE];
                    hash_block(pending_data + pending_len - block_size, 
                              block_size, strong);
                    
                    if (memcmp(strong, 
                              old_sig->blocks[entry->block_index].strong_hash,
                              HASH_SIZE) == 0) {
                        /* Match found! */
                        
                        /* Emit pending data (minus the matched block) */
                        size_t data_len = pending_len - block_size;
                        if (data_len > 0) {
                            if (delta->instruction_count >= capacity) {
                                capacity *= 2;
                                delta->instructions = realloc(
                                    delta->instructions,
                                    capacity * sizeof(DeltaInstruction));
                            }
                            
                            DeltaInstruction *inst = 
                                &delta->instructions[delta->instruction_count++];
                            inst->type = DELTA_DATA;
                            inst->u.data.data = malloc(data_len);
                            memcpy(inst->u.data.data, pending_data, data_len);
                            inst->u.data.length = data_len;
                        }
                        
                        /* Emit copy instruction */
                        if (delta->instruction_count >= capacity) {
                            capacity *= 2;
                            delta->instructions = realloc(
                                delta->instructions,
                                capacity * sizeof(DeltaInstruction));
                        }
                        
                        DeltaInstruction *inst = 
                            &delta->instructions[delta->instruction_count++];
                        inst->type = DELTA_COPY;
                        inst->u.copy.offset = 
                            old_sig->blocks[entry->block_index].offset;
                        inst->u.copy.length = block_size;
                        
                        /* Reset */
                        pending_len = 0;
                        window_filled = 0;
                        rolling_hash_init(&rh, block_size);
                        
                        break;
                    }
                }
                entry = entry->next;
            }
        }
        
        pos++;
    }
    
    /* Emit remaining pending data */
    if (pending_len > 0) {
        if (delta->instruction_count >= capacity) {
            capacity *= 2;
            delta->instructions = realloc(
                delta->instructions,
                capacity * sizeof(DeltaInstruction));
        }
        
        DeltaInstruction *inst = 
            &delta->instructions[delta->instruction_count++];
        inst->type = DELTA_DATA;
        inst->u.data.data = malloc(pending_len);
        memcpy(inst->u.data.data, pending_data, pending_len);
        inst->u.data.length = pending_len;
    }
    
    /* Cleanup */
    free(buffer);
    free(pending_data);
    rolling_hash_free(&rh);
    
    for (size_t i = 0; i < HASH_TABLE_SIZE; i++) {
        HashEntry *entry = hash_table[i];
        while (entry) {
            HashEntry *next = entry->next;
            free(entry);
            entry = next;
        }
    }
    free(hash_table);
    
    fclose(f);
    return delta;
}

int delta_apply(const char *old_path, const Delta *delta, 
                const char *new_path) {
    FILE *old_f = fopen(old_path, "rb");
    FILE *new_f = fopen(new_path, "wb");
    
    if (!old_f || !new_f) {
        if (old_f) fclose(old_f);
        if (new_f) fclose(new_f);
        return -1;
    }
    
    for (size_t i = 0; i < delta->instruction_count; i++) {
        const DeltaInstruction *inst = &delta->instructions[i];
        
        if (inst->type == DELTA_COPY) {
            /* Copy block from old file */
            unsigned char *buffer = malloc(inst->u.copy.length);
            fseek(old_f, inst->u.copy.offset, SEEK_SET);
            fread(buffer, 1, inst->u.copy.length, old_f);
            fwrite(buffer, 1, inst->u.copy.length, new_f);
            free(buffer);
        } else {
            /* Write new data */
            fwrite(inst->u.data.data, 1, inst->u.data.length, new_f);
        }
    }
    
    fclose(old_f);
    fclose(new_f);
    return 0;
}

void delta_free(Delta *delta) {
    if (!delta) return;
    
    for (size_t i = 0; i < delta->instruction_count; i++) {
        if (delta->instructions[i].type == DELTA_DATA) {
            free(delta->instructions[i].u.data.data);
        }
    }
    free(delta->instructions);
    free(delta);
}
```

---

## Makefile

```makefile
CC = gcc
CFLAGS = -Wall -Wextra -O2 -fPIC
LDFLAGS = -lcrypto -lpthread

SRC_DIR = src/c
BUILD_DIR = build
BIN_DIR = bin

LIB_SOURCES = $(SRC_DIR)/hash.c $(SRC_DIR)/rolling_hash.c \
              $(SRC_DIR)/diff.c $(SRC_DIR)/inotify_helper.c
LIB_TARGET = $(BUILD_DIR)/libsyncutil.so
CLI_TARGET = $(BIN_DIR)/synctool

.PHONY: all clean test

all: $(LIB_TARGET) $(CLI_TARGET)

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

$(BIN_DIR):
	mkdir -p $(BIN_DIR)

$(LIB_TARGET): $(LIB_SOURCES) | $(BUILD_DIR)
	$(CC) $(CFLAGS) -shared -o $@ $^ $(LDFLAGS)

$(CLI_TARGET): $(SRC_DIR)/synctool.c $(LIB_TARGET) | $(BIN_DIR)
	$(CC) $(CFLAGS) -o $@ $< -L$(BUILD_DIR) -lsyncutil \
		-Wl,-rpath,'$$ORIGIN/../build' $(LDFLAGS)

test: $(LIB_TARGET)
	$(CC) $(CFLAGS) -o $(BUILD_DIR)/test_hash tests/test_hash.c \
		-L$(BUILD_DIR) -lsyncutil -Wl,-rpath,$(BUILD_DIR) $(LDFLAGS)
	$(CC) $(CFLAGS) -o $(BUILD_DIR)/test_diff tests/test_diff.c \
		-L$(BUILD_DIR) -lsyncutil -Wl,-rpath,$(BUILD_DIR) $(LDFLAGS)
	./$(BUILD_DIR)/test_hash
	./$(BUILD_DIR)/test_diff

clean:
	rm -rf $(BUILD_DIR) $(BIN_DIR)
```

---

## Sync Protocol (Simplified Protocol)

```
1. HELLO - Handshake between nodes
   A -> B: HELLO <node_id> <protocol_version>
   B -> A: HELLO <node_id> <protocol_version>

2. SCAN - List files
   A -> B: SCAN <path>
   B -> A: FILE <path> <checksum> <mtime> <size>
   B -> A: FILE ...
   B -> A: END_SCAN

3. SYNC_REQUEST - Request sync for file
   A -> B: SYNC_REQUEST <path>
   B -> A: SIGNATURE <serialised_signature_table>

4. DELTA - Transfer delta
   A -> B: DELTA <path> <serialised_delta>
   B -> A: OK | ERROR <message>

5. CONFLICT - Conflict notification
   A -> B: CONFLICT <path> <local_checksum> <remote_checksum>
   Resolution strategies:
   - newest wins
   - manual (keep both)
   - prompt user
```

---

## Specific Evaluation Criteria

| Criterion | Weight | Description |
|-----------|--------|-------------|
| File monitoring | 15% | inotify, correct |
| Hashing & signatures | 20% | Fast, accurate |
| Delta sync | 25% | Rolling hash, efficient |
| Protocol | 15% | Correct communication |
| Conflict handling | 10% | Detection, resolution |
| Code quality | 10% | Clean, no memory leaks |
| Documentation | 5% | Protocol, algorithm |

---

## Resources

- rsync algorithm paper (Andrew Tridgell)
- `man inotify` - Linux file monitoring
- OpenSSL documentation (hashing)
- Seminar 2-3 - IPC, network basics

---

*ADVANCED Project | Operating Systems | ASE-CSIE*
