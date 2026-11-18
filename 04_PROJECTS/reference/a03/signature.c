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
