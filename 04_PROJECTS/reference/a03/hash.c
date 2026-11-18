#include "syncutil.h"
#include <stdio.h>
#include <string.h>
#include <openssl/evp.h>
#include <sys/stat.h>
#include <unistd.h>
#include <errno.h>

/* MD5 is retained solely as the existing teaching-format digest. It is not
 * authentication. The SHA-256 assessment mismatch awaits an author decision. */
int hash_block(const unsigned char *data, size_t len, unsigned char *hash) {
    unsigned int written = 0;
    if ((!data && len) || !hash) { errno = EINVAL; return -1; }
    if (EVP_Digest(data, len, hash, &written, EVP_md5(), NULL) != 1 || written != HASH_SIZE) return -1;
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
    if (!ctx || fstat(fileno(f), &before) < 0 || !S_ISREG(before.st_mode) || EVP_DigestInit_ex(ctx, EVP_md5(), NULL) != 1) goto done;
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
