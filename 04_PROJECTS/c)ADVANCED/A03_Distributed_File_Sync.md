# A03: Distributed File Sync

> **Level:** ADVANCED | **Estimated time:** 40-50 hours | **Components:** Bash + C

---

## Description

File synchronisation system between multiple machines (similar to rsync/Dropbox): real-time change detection, efficient transfer (delta sync), conflict resolution and a C component for fast hashing and binary diff.

---

## Why C?

The C component provides:
- **Fast hashing** (SHA-256 for large files)
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
│       ├── signature.c          # Block signatures
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

The corrected local components are also supplied in [reference/a03](../reference/a03/).
They implement hashing, an Adler-32-style rolling checksum, block signatures and
in-memory delta generation/application. They do not provide the omitted CLI,
network serialisers, watcher or conflict policy. The checksum uses Adler's initial
sum of one and modulo 65521; it is not a claim of binary compatibility with rsync's
rolling checksum. The in-memory delta representation can grow with input size;
allocation failures are reported and streaming bounded storage is further work.

**Adopted D6 digest contract:** file and block digests use SHA-256 with an
exact 32-byte C representation. A student-supplied `synctool hash PATH` command
must emit exactly 64 lower-case hexadecimal characters followed by one newline
on success, use standard error for diagnostics and return a non-zero status
without a success digest on failure. Serialised digest records must identify
`version: 2` and `algorithm: sha256` explicitly, reject duplicate fields and
malformed values and carry a digest of exactly 64 lower-case hexadecimal
characters. Records using a legacy version or the historical MD5 algorithm are
rejected; migration recomputes SHA-256 from the original bytes rather than
reinterpreting a 16-byte digest.

The local reference and its known-answer tests implement the digest change.
The CLI, digest-record parser, network serialisers, watcher and conflict policy
remain student implementation tasks. Their assessment adapters remain
`PENDING_CLI_ADAPTER` or `PENDING_TRANSPORT_ADAPTER` until supplied and validated.
This algorithm decision does not adopt examination points or an institutional
grading policy. A checksum does not authenticate a peer or establish authorship.

Delta application rejects source/destination identity and validates all
instructions before creating a same-directory owned stage. It publishes with a
rename only after successful reads, writes, flush and file fsync. Use a trusted,
quiescent parent directory: this example does not implement hostile path-race
isolation or directory-fsync crash durability. Source stat comparisons detect
ordinary concurrent changes but are not a filesystem snapshot. The network layer
must verify the expected result digest and base version before accepting a patch.

### Main Header (syncutil.h)

```c
#ifndef SYNCUTIL_H
#define SYNCUTIL_H

#include <stdint.h>
#include <stddef.h>
#include <stdbool.h>
#include <sys/types.h>
#include <time.h>

/* Block size for rolling hash */
#define BLOCK_SIZE 4096
#define HASH_SIZE 32  /* SHA-256 */
#define DIGEST_RECORD_VERSION 2
#define DIGEST_ALGORITHM "sha256"

/* File hash structure */
typedef struct {
    unsigned char hash[HASH_SIZE];
    size_t file_size;
    time_t mtime;
} FileChecksum;

/* Block signature for delta sync */
typedef struct {
    uint32_t weak_hash;           /* Rolling (Adler-32 style) */
    unsigned char strong_hash[HASH_SIZE]; /* SHA-256 */
    off_t offset;
    size_t length;               /* Short final block length is explicit. */
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

/* Compute SHA-256 hash of file */
int hash_file(const char *path, FileChecksum *checksum);

/* Compute SHA-256 of data block */
int hash_block(const unsigned char *data, size_t len, 
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

int rolling_hash_init(RollingHash *rh, size_t window_size);
int rolling_hash_update(RollingHash *rh, unsigned char old_byte, 
                         unsigned char new_byte);
uint32_t rolling_hash_digest(const RollingHash *rh);
void rolling_hash_free(RollingHash *rh);
void rolling_hash_reset(RollingHash *rh);

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
#include <openssl/evp.h>
#include <sys/stat.h>
#include <unistd.h>
#include <errno.h>

/* Version 2 uses SHA-256 for file and block digests. A digest does not
 * authenticate a peer or establish authorship. */
int hash_block(const unsigned char *data, size_t len, unsigned char *hash) {
    unsigned int written = 0;
    unsigned char result[HASH_SIZE];
    if ((!data && len) || !hash) { errno = EINVAL; return -1; }
    if (EVP_Digest(data, len, result, &written, EVP_sha256(), NULL) != 1 || written != HASH_SIZE) return -1;
    memcpy(hash, result, HASH_SIZE); /* Publish only a complete digest. */
    return 0;
}

int hash_file(const char *path, FileChecksum *checksum) {
    if (!path || !checksum) { errno = EINVAL; return -1; }
    FILE *f = fopen(path, "rb");
    if (!f) return -1;
    EVP_MD_CTX *ctx = EVP_MD_CTX_new();
    struct stat before, after;
    FileChecksum result = {0};
    int rc = -1;
    if (!ctx || fstat(fileno(f), &before) < 0 || !S_ISREG(before.st_mode) || EVP_DigestInit_ex(ctx, EVP_sha256(), NULL) != 1) goto done;
    unsigned char buffer[BLOCK_SIZE];
    size_t count;
    while ((count = fread(buffer, 1, sizeof buffer, f)) > 0) {
        if (count > SIZE_MAX-result.file_size || EVP_DigestUpdate(ctx, buffer, count) != 1) goto done;
        result.file_size += count;
    }
    if (ferror(f) || fstat(fileno(f), &after) < 0 || before.st_size != after.st_size ||
        before.st_mtim.tv_sec != after.st_mtim.tv_sec || before.st_mtim.tv_nsec != after.st_mtim.tv_nsec ||
        before.st_ctim.tv_sec != after.st_ctim.tv_sec || before.st_ctim.tv_nsec != after.st_ctim.tv_nsec) goto done;
    unsigned int written = 0;
    if (EVP_DigestFinal_ex(ctx, result.hash, &written) != 1 || written != HASH_SIZE) goto done;
    result.mtime = after.st_mtime;
    rc = 0;
done:
    EVP_MD_CTX_free(ctx);
    if (fclose(f) != 0) rc = -1;
    if (rc == 0) *checksum = result; /* No partial result is published on error. */
    return rc;
}

bool checksums_equal(const FileChecksum *a, const FileChecksum *b) {
    return a && b && a->file_size == b->file_size && memcmp(a->hash, b->hash, HASH_SIZE) == 0;
}
```

### Rolling Hash (rolling_hash.c)

```c
#include "syncutil.h"
#include <stdlib.h>
#include <string.h>
#include <errno.h>

#define MOD_ADLER UINT32_C(65521)

/* Initialise a zeroed/freed object; reset an existing object to reuse its window. */
int rolling_hash_init(RollingHash *rh, size_t window_size) {
    if (!rh || !window_size) { errno = EINVAL; return -1; }
    unsigned char *window = calloc(window_size, 1);
    if (!window) return -1;
    *rh = (RollingHash){.a=1, .window_size=window_size, .window=window};
    return 0;
}

void rolling_hash_reset(RollingHash *rh) {
    if (!rh) return;
    rh->a=1; rh->b=0; rh->count=0; rh->window_pos=0;
}

int rolling_hash_update(RollingHash *rh, unsigned char old_byte, unsigned char new_byte) {
    if (!rh || !rh->window || !rh->window_size) { errno=EINVAL; return -1; }
    if (rh->count < rh->window_size) {
        if (old_byte != 0) { errno=EINVAL; return -1; }
        rh->a = (rh->a + new_byte) % MOD_ADLER;
        rh->b = (rh->b + rh->a) % MOD_ADLER;
        rh->count++;
    } else {
        if (old_byte != rh->window[rh->window_pos]) { errno=EINVAL; return -1; }
        rh->a = (rh->a + MOD_ADLER - old_byte + new_byte) % MOD_ADLER;
        uint32_t weight = (uint32_t)(((uint64_t)(rh->window_size % MOD_ADLER) * old_byte) % MOD_ADLER);
        rh->b = (rh->b + MOD_ADLER - weight + rh->a + MOD_ADLER - 1) % MOD_ADLER;
    }
    rh->window[rh->window_pos] = new_byte;
    rh->window_pos = (rh->window_pos + 1) % rh->window_size;
    return 0;
}

uint32_t rolling_hash_digest(const RollingHash *rh) { return rh ? (rh->b << 16) | rh->a : 0; }
void rolling_hash_free(RollingHash *rh) {
    if (rh) { free(rh->window); *rh=(RollingHash){0}; }
}
```

### Signature Generation (signature.c)

```c
#include "syncutil.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <unistd.h>
#include <errno.h>

SignatureTable *signature_generate(const char *path, size_t block_size) {
    if (!path || !block_size) { errno=EINVAL; return NULL; }
    FILE *f=fopen(path,"rb");
    if (!f) return NULL;
    struct stat before,after;
    SignatureTable *sig=NULL;
    unsigned char *buffer=NULL;
    RollingHash rh={0};
    if (fstat(fileno(f),&before)<0 || !S_ISREG(before.st_mode) || before.st_size<0 || (uintmax_t)before.st_size>SIZE_MAX) goto fail;
    size_t length=(size_t)before.st_size, count=length/block_size+(length%block_size!=0);
    if (count>SIZE_MAX/sizeof(BlockSignature)) goto fail;
    sig=calloc(1,sizeof *sig);
    if (!sig) goto fail;
    sig->block_count=count; sig->block_size=block_size;
    if (count) {
        sig->blocks=calloc(count,sizeof *sig->blocks); buffer=malloc(block_size);
        if (!sig->blocks || !buffer || rolling_hash_init(&rh,block_size)<0) goto fail;
    }
    for (size_t i=0;i<count;++i) {
        size_t need=length-i*block_size;
        if (need>block_size) need=block_size;
        if (fread(buffer,1,need,f)!=need) goto fail;
        rolling_hash_reset(&rh);
        for (size_t j=0;j<need;++j) if (rolling_hash_update(&rh,0,buffer[j])<0) goto fail;
        sig->blocks[i].weak_hash=rolling_hash_digest(&rh);
        if (hash_block(buffer,need,sig->blocks[i].strong_hash)<0) goto fail;
        sig->blocks[i].offset=(off_t)(i*block_size); sig->blocks[i].length=need;
    }
    if (fgetc(f)!=EOF || ferror(f) || fstat(fileno(f),&after)<0 || before.st_size!=after.st_size ||
        before.st_mtim.tv_sec!=after.st_mtim.tv_sec || before.st_mtim.tv_nsec!=after.st_mtim.tv_nsec ||
        before.st_ctim.tv_sec!=after.st_ctim.tv_sec || before.st_ctim.tv_nsec!=after.st_ctim.tv_nsec) goto fail;
    rolling_hash_free(&rh); free(buffer);
    if (fclose(f)!=0) { signature_free(sig); return NULL; }
    return sig;
fail:
    rolling_hash_free(&rh); free(buffer); signature_free(sig); fclose(f); return NULL;
}

void signature_free(SignatureTable *sig) { if (sig) { free(sig->blocks); free(sig); } }
```

### Delta Generation (diff.c)

```c
#include "syncutil.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <unistd.h>
#include <errno.h>

#define HASH_TABLE_SIZE 65536

typedef struct HashEntry {
    uint32_t weak_hash;
    size_t block_index;
    struct HashEntry *next;
} HashEntry;

static int append_instruction(Delta *delta, size_t *capacity, DeltaInstruction value) {
    if (delta->instruction_count==*capacity) {
        size_t next=*capacity ? *capacity*2 : 128;
        if (next<*capacity || next>SIZE_MAX/sizeof *delta->instructions) return -1;
        DeltaInstruction *grown=realloc(delta->instructions,next*sizeof *grown);
        if (!grown) return -1;
        delta->instructions=grown; *capacity=next;
    }
    delta->instructions[delta->instruction_count++]=value;
    return 0;
}

static int append_literal(Delta *delta,size_t *capacity,const unsigned char *data,size_t length) {
    if (!length) return 0;
    unsigned char *copy=malloc(length);
    if (!copy) return -1;
    memcpy(copy,data,length);
    DeltaInstruction value={.type=DELTA_DATA,.u.data={copy,length}};
    if (append_instruction(delta,capacity,value)<0) { free(copy); return -1; }
    return 0;
}

Delta *delta_generate(const SignatureTable *old_sig,const char *new_path) {
    if (!old_sig || !new_path || !old_sig->block_size || (old_sig->block_count && !old_sig->blocks)) { errno=EINVAL; return NULL; }
    FILE *f=fopen(new_path,"rb");
    if (!f) return NULL;
    struct stat before,after;
    HashEntry **table=NULL;
    Delta *delta=NULL;
    RollingHash rh={0};
    unsigned char *pending=NULL;
    size_t pending_len=0,pending_capacity=0,instruction_capacity=0;
    int ok=0;
    if (fstat(fileno(f),&before)<0 || !S_ISREG(before.st_mode)) goto done;
    table=calloc(HASH_TABLE_SIZE,sizeof *table); delta=calloc(1,sizeof *delta);
    if (!table || !delta || rolling_hash_init(&rh,old_sig->block_size)<0) goto done;
    for (size_t i=0;i<old_sig->block_count;++i) {
        const BlockSignature *block=&old_sig->blocks[i];
        if (block->offset<0 || !block->length || block->length>old_sig->block_size) goto done;
        if (block->length!=old_sig->block_size) continue; /* Short final blocks become literals. */
        size_t idx=block->weak_hash%HASH_TABLE_SIZE;
        HashEntry *entry=malloc(sizeof *entry);
        if (!entry) goto done;
        *entry=(HashEntry){block->weak_hash,i,table[idx]}; table[idx]=entry;
    }
    int c;
    while ((c=fgetc(f))!=EOF) {
        if (pending_len==pending_capacity) {
            size_t next=pending_capacity ? pending_capacity*2 : 4096;
            if (next<=pending_capacity) goto done;
            unsigned char *grown=realloc(pending,next);
            if (!grown) goto done;
            pending=grown; pending_capacity=next;
        }
        unsigned char old=rh.count<rh.window_size ? 0 : rh.window[rh.window_pos];
        if (rolling_hash_update(&rh,old,(unsigned char)c)<0) goto done;
        pending[pending_len++]=(unsigned char)c;
        if (rh.count<rh.window_size) continue;
        uint32_t weak=rolling_hash_digest(&rh);
        for (HashEntry *entry=table[weak%HASH_TABLE_SIZE];entry;entry=entry->next) {
            if (entry->weak_hash!=weak) continue;
            unsigned char strong[HASH_SIZE];
            if (hash_block(pending+pending_len-old_sig->block_size,old_sig->block_size,strong)<0) goto done;
            const BlockSignature *block=&old_sig->blocks[entry->block_index];
            if (memcmp(strong,block->strong_hash,HASH_SIZE)!=0) continue;
            if (append_literal(delta,&instruction_capacity,pending,pending_len-old_sig->block_size)<0) goto done;
            DeltaInstruction copy={.type=DELTA_COPY,.u.copy={block->offset,old_sig->block_size}};
            if (append_instruction(delta,&instruction_capacity,copy)<0) goto done;
            pending_len=0;
            rolling_hash_reset(&rh); /* Retain ownership; no repeated allocation/leak. */
            break;
        }
    }
    if (ferror(f) || fstat(fileno(f),&after)<0 || before.st_size!=after.st_size ||
        before.st_mtim.tv_sec!=after.st_mtim.tv_sec || before.st_mtim.tv_nsec!=after.st_mtim.tv_nsec ||
        before.st_ctim.tv_sec!=after.st_ctim.tv_sec || before.st_ctim.tv_nsec!=after.st_ctim.tv_nsec ||
        append_literal(delta,&instruction_capacity,pending,pending_len)<0) goto done;
    ok=1;
done:
    free(pending); rolling_hash_free(&rh);
    if (table) {
        for (size_t i=0;i<HASH_TABLE_SIZE;++i) {
            HashEntry *entry=table[i];
            while (entry) { HashEntry *next=entry->next; free(entry); entry=next; }
        }
        free(table);
    }
    if (fclose(f)!=0) ok=0;
    if (!ok) { delta_free(delta); return NULL; }
    return delta;
}

int delta_apply(const char *old_path,const Delta *delta,const char *new_path) {
    if (!old_path || !new_path || !delta || (delta->instruction_count && !delta->instructions)) { errno=EINVAL; return -1; }
    FILE *old_f=fopen(old_path,"rb"),*out=NULL;
    if (!old_f) return -1;
    struct stat old_st,target_st,after;
    char *stage=NULL;
    int fd=-1,rc=-1;
    if (fstat(fileno(old_f),&old_st)<0 || !S_ISREG(old_st.st_mode)) goto done;
    if (lstat(new_path,&target_st)==0) {
        if (!S_ISREG(target_st.st_mode) || (old_st.st_dev==target_st.st_dev && old_st.st_ino==target_st.st_ino)) { errno=EINVAL; goto done; }
    } else if (errno!=ENOENT) goto done;
    size_t total=0;
    /* Validate every instruction before creating an output candidate. */
    for (size_t i=0;i<delta->instruction_count;++i) {
        const DeltaInstruction *v=&delta->instructions[i];
        size_t length;
        if (v->type==DELTA_COPY) {
            if (v->u.copy.offset<0 || v->u.copy.offset>old_st.st_size || (uintmax_t)v->u.copy.length>(uintmax_t)(old_st.st_size-v->u.copy.offset)) { errno=EINVAL; goto done; }
            length=v->u.copy.length;
        } else if (v->type==DELTA_DATA) {
            if (v->u.data.length && !v->u.data.data) { errno=EINVAL; goto done; }
            length=v->u.data.length;
        } else { errno=EINVAL; goto done; }
        if (length>SIZE_MAX-total) { errno=EOVERFLOW; goto done; }
        total+=length;
    }
    size_t path_len=strlen(new_path);
    if (path_len>SIZE_MAX-32) goto done;
    stage=malloc(path_len+32);
    if (!stage) goto done;
    snprintf(stage,path_len+32,"%s.partial.XXXXXX",new_path);
    fd=mkstemp(stage);
    if (fd<0) goto done;
    out=fdopen(fd,"wb");
    if (!out) goto done;
    fd=-1;
    unsigned char buffer[8192];
    for (size_t i=0;i<delta->instruction_count;++i) {
        const DeltaInstruction *v=&delta->instructions[i];
        if (v->type==DELTA_DATA) {
            if (v->u.data.length && fwrite(v->u.data.data,1,v->u.data.length,out)!=v->u.data.length) goto done;
        } else {
            if (fseeko(old_f,v->u.copy.offset,SEEK_SET)<0) goto done;
            size_t remaining=v->u.copy.length;
            while (remaining) {
                size_t part=remaining<sizeof buffer ? remaining : sizeof buffer;
                if (fread(buffer,1,part,old_f)!=part || fwrite(buffer,1,part,out)!=part) goto done;
                remaining-=part;
            }
        }
    }
    if (ferror(old_f) || ferror(out) || fflush(out)!=0 || fsync(fileno(out))<0 ||
        fstat(fileno(old_f),&after)<0 || old_st.st_size!=after.st_size ||
        old_st.st_mtim.tv_sec!=after.st_mtim.tv_sec || old_st.st_mtim.tv_nsec!=after.st_mtim.tv_nsec ||
        old_st.st_ctim.tv_sec!=after.st_ctim.tv_sec || old_st.st_ctim.tv_nsec!=after.st_ctim.tv_nsec) goto done;
    if (fclose(out)!=0) { out=NULL; goto done; }
    out=NULL;
    if (fclose(old_f)!=0) { old_f=NULL; goto done; }
    old_f=NULL;
    if (rename(stage,new_path)<0) goto done;
    rc=0;
done:
    if (old_f && fclose(old_f)!=0) rc=-1;
    if (out && fclose(out)!=0) rc=-1;
    if (fd>=0) close(fd);
    if (stage) { if (rc!=0) unlink(stage); free(stage); }
    return rc;
}

void delta_free(Delta *delta) {
    if (!delta) return;
    for (size_t i=0;i<delta->instruction_count;++i)
        if (delta->instructions[i].type==DELTA_DATA) free(delta->instructions[i].u.data.data);
    free(delta->instructions); free(delta);
}
```

---

## Makefile

```makefile
CC = gcc
CFLAGS = -std=c11 -D_POSIX_C_SOURCE=200809L -Wall -Wextra -O2 -fPIC
LDFLAGS = -lcrypto -lpthread

SRC_DIR = src/c
BUILD_DIR = build
BIN_DIR = bin

LIB_SOURCES = $(SRC_DIR)/hash.c $(SRC_DIR)/rolling_hash.c \
              $(SRC_DIR)/signature.c $(SRC_DIR)/diff.c $(SRC_DIR)/inotify_helper.c
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

The messages below describe operations, not a parseable wire format. A completed
student protocol must define a versioned length-delimited frame (bounded length,
message type, request ID and payload) and reject truncated/unknown frames. Encode
paths as relative components beneath an agreed sync root; reject absolute paths,
`..`, NUL and symlink escapes. Binary signatures/deltas need a specified byte
order, widths, algorithm ID, block length and length checks; never transmit raw C
structs or split binary payloads on spaces/newlines. Include the base file version
and expected result digest, and acknowledge only a validated committed result.

Recovery must associate a transfer ID with an owned partial file and publish once;
repeated messages must not repeat destructive actions. A changed base is a conflict,
not permission to overwrite. The three listed conflict strategies remain choices
to specify and test explicitly; “newest” requires a declared clock/version model.
Serialisation, transport, authentication and recovery state are student work; this
schematic does not claim interoperable or secure network execution.

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
- National Institute of Standards and Technology. (2015). *Secure Hash Standard (SHS)* (FIPS PUB 180-4). https://doi.org/10.6028/NIST.FIPS.180-4
- [OpenSSL digest documentation](https://docs.openssl.org/master/man3/EVP_DigestInit/)
- Seminar 2-3 - IPC, network basics

---

*ADVANCED Project | Operating Systems | ASE-CSIE*
