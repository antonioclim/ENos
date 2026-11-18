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
