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
