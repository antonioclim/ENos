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
