"""Compile exact documented C modules and run bounded owned-file regressions.
These tests do not run the missing schedulers, network protocols or live readline bridge.
"""
import os
import re
import shutil
import subprocess
import tempfile
import unittest
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]

@unittest.skipUnless(shutil.which('gcc'),'GCC unavailable: exact C regressions NOT_RUN')
class AdvancedSemantics(unittest.TestCase):
    def setUp(self):
        self.temp=tempfile.TemporaryDirectory(prefix='enos-advanced-');self.addCleanup(self.temp.cleanup);self.path=Path(self.temp.name)
    def extract(self,project,names):
        source=next((ROOT/'c)ADVANCED').glob(project+'*.md')).read_text()
        blocks=re.findall(r'```c\n(.*?)\n```',source,re.S)
        self.assertEqual(len(blocks),len(names))
        for name,block in zip(names,blocks):(self.path/name).write_text(block+'\n')
    def compile_run(self,source,modules,libs=(),args=(),asan=False):
        (self.path/'probe.c').write_text(source)
        flags=['-std=c11','-D_POSIX_C_SOURCE=200809L','-Wall','-Wextra','-Werror','-O1','-g']
        if asan:flags+=['-fsanitize=address,undefined','-fno-omit-frame-pointer']
        compile=subprocess.run(['gcc',*flags,'probe.c',*modules,*libs,'-o','probe'],cwd=self.path,text=True,capture_output=True)
        self.assertEqual(compile.returncode,0,compile.stderr)
        env={**os.environ,'ASAN_OPTIONS':os.environ.get('ASAN_OPTIONS','detect_leaks=1:halt_on_error=1')}
        result=subprocess.run([str(self.path/'probe'),*map(str,args)],cwd=self.path,env=env,text=True,capture_output=True,timeout=30)
        self.assertEqual(result.returncode,0,result.stdout+'\n'+result.stderr)
    def test_a01_create_attach_preserves_pending_jobs(self):
        self.extract('A01',['jobqueue.h','jobqueue.c','jobctl.c'])
        self.compile_run(r'''
#include "jobqueue.h"
#include <assert.h>
#include <stdlib.h>
#include <unistd.h>
#include <stdio.h>
#include <errno.h>
int main(void) {
 char name[64]; snprintf(name,sizeof name,"test_%ld",(long)getpid()); assert(setenv("JOBQUEUE_INSTANCE",name,1)==0);
 if (queue_init()<0) { perror("owned shm fixture unavailable"); return 77; }
 Job a={.priority=2}; snprintf(a.command,sizeof a.command,"printf fixture");
 int id=queue_push(&a); assert(id>0); queue_detach();
 assert(queue_init()<0 && errno==EEXIST); assert(queue_attach()==0); assert(queue_size()==1);
 Job b={0}; assert(queue_pop(&b)==0 && b.job_id==id); assert(queue_size()==0);
 queue_detach(); assert(queue_destroy()==0); return 0;
}''',['jobqueue.c'],['-pthread','-lrt'])
    def test_a01_missing_or_invalid_options_stop_before_queue_api(self):
        self.extract('A01',['jobqueue.h','jobqueue.c','jobctl.c'])
        adapter=r'''
#include "jobqueue.h"
#include <stdlib.h>
int queue_init(void){abort();} int queue_attach(void){abort();} void queue_detach(void){}
int queue_destroy(void){abort();} int queue_push(const Job*x){(void)x;abort();} int queue_pop(Job*x){(void)x;abort();}
int queue_size(void){abort();} int queue_list(Job*a,int b,JobState c){(void)a;(void)b;(void)c;abort();}
int queue_get_by_id(int a,Job*b){(void)a;(void)b;abort();} int queue_cancel(int a){(void)a;abort();}
int queue_update_state(int a,JobState b,int c){(void)a;(void)b;(void)c;abort();}
void queue_stats(int*a,int*b,int*c,int*d){(void)a;(void)b;(void)c;(void)d;abort();}
'''
        (self.path/'adapter.c').write_text(adapter)
        cp=subprocess.run(['gcc','-std=c11','-D_POSIX_C_SOURCE=200809L','-Wall','-Wextra','-Werror','jobctl.c','adapter.c','-o','cli'],cwd=self.path,capture_output=True,text=True);self.assertEqual(cp.returncode,0,cp.stderr)
        for argv in [['-p','2'],['--memory','abc'],['--time','-1'],['--priority','999999999999999999999999']]:
            p=subprocess.run([str(self.path/'cli'),*argv],capture_output=True,text=True);self.assertEqual(p.returncode,2,(argv,p.stderr))
    def test_a02_long_colours_command_context_and_utf8_trie(self):
        self.extract('A02',['shellext.h','lexer.c','highlighter.c','trie.c'])
        self.compile_run(r'''
#include "shellext.h"
#include <assert.h>
#include <string.h>
#include <stdlib.h>
#include <errno.h>
int main(void) {
 char colour[5001]; memset(colour,'c',5000); colour[5000]=0;
 ColourScheme cs={.command=colour,.reset=colour}; highlighter_init(&cs);
 char *x=highlight_line("x"); assert(x && strlen(x)==10001); highlighter_free(x);
 cs=(ColourScheme){.command="<C>",.builtin="<B>",.reset="!"}; highlighter_init(&cs);
 x=highlight_line("echo hello && printf yes\nfoo arg"); assert(x && strstr(x,"<B>echo! hello") && strstr(x,"<B>printf! yes") && strstr(x,"<C>foo! arg") && !strstr(x,"<C>hello")); highlighter_free(x);
 lexer_init("\"unterminated"); assert(lexer_next_token().type==TOKEN_ERROR);
 lexer_init("\xff"); assert(lexer_next_token().length==1);
 TrieNode *root=trie_create(); assert(root); assert(trie_insert(root,"café")==0); assert(trie_insert(root,"café")==0); assert(trie_insert(root,"cat")==0);
 int count=-1; char **values=trie_complete(root,"café",&count); assert(values && count==1 && strcmp(values[0],"café")==0); trie_free_results(values,count);
 values=trie_complete(root,"missing",&count); assert(!values && count==0 && errno==0);
 trie_destroy(root); return 0;
}''',['lexer.c','highlighter.c','trie.c'],asan=True)
    def test_a03_rolling_large_delta_and_failure_preserves_targets(self):
        self.extract('A03',['syncutil.h','hash.c','rolling_hash.c','signature.c','diff.c'])
        (self.path/'old').write_bytes(bytes(range(256))*32+b'tail')
        (self.path/'new').write_bytes(b'prefix'+bytes(range(256))*32+b'\x07'*1_200_000+b'changed tail')
        (self.path/'abc').write_bytes(b'abc');(self.path/'target').write_bytes(b'preserve');(self.path/'empty').write_bytes(b'')
        self.compile_run(r'''
#include "syncutil.h"
#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
static int same(const char*a,const char*b) { FILE*x=fopen(a,"rb"),*y=fopen(b,"rb"); assert(x&&y);int p,q;do {p=fgetc(x);q=fgetc(y);if(p!=q){fclose(x);fclose(y);return 0;}}while(p!=EOF);assert(!ferror(x)&&!ferror(y));fclose(x);fclose(y);return 1; }
int main(void) {
 RollingHash r={0}; assert(rolling_hash_init(&r,0)<0); assert(rolling_hash_init(&r,300)==0);
 unsigned char bytes[2000];for(size_t i=0;i<sizeof bytes;++i)bytes[i]=(unsigned char)(i*37+11);
 for(size_t i=0;i<sizeof bytes;++i){assert(rolling_hash_update(&r,i>=300?bytes[i-300]:0,bytes[i])==0);if(i>=299){RollingHash fresh={0};assert(rolling_hash_init(&fresh,300)==0);for(size_t j=i-299;j<=i;++j)assert(rolling_hash_update(&fresh,0,bytes[j])==0);assert(rolling_hash_digest(&r)==rolling_hash_digest(&fresh));rolling_hash_free(&fresh);}}
 rolling_hash_free(&r);
 FileChecksum abc={0};assert(hash_file("abc",&abc)==0 && abc.file_size==3); const unsigned char expected[16]={0x90,0x01,0x50,0x98,0x3c,0xd2,0x4f,0xb0,0xd6,0x96,0x3f,0x7d,0x28,0xe1,0x7f,0x72};assert(memcmp(abc.hash,expected,16)==0);
 assert(hash_file(".",&abc)<0); assert(!signature_generate("old",0));
 SignatureTable *sig=signature_generate("old",4096);assert(sig && sig->block_count==3);
 Delta*d=delta_generate(sig,"new");assert(d);assert(delta_apply("old",d,"result")==0);assert(same("new","result"));
 assert(delta_apply("old",d,"old")<0);assert(link("old","alias")==0);assert(delta_apply("old",d,"alias")<0);
 DeltaInstruction bad={.type=(DeltaType)99}; Delta invalid={1,&bad};assert(delta_apply("old",&invalid,"target")<0);
 bad=(DeltaInstruction){.type=DELTA_COPY,.u.copy={9000000,1}};assert(delta_apply("old",&invalid,"target")<0);
 FILE*t=fopen("target","rb");char check[9]={0};assert(fread(check,1,8,t)==8 && strcmp(check,"preserve")==0);fclose(t);
 delta_free(d);signature_free(sig);
 sig=signature_generate("empty",4096);assert(sig && sig->block_count==0);d=delta_generate(sig,"empty");assert(d && d->instruction_count==0);assert(delta_apply("old",d,"empty-result")==0);assert(same("empty","empty-result"));delta_free(d);signature_free(sig);
 return 0;
}''',['hash.c','rolling_hash.c','signature.c','diff.c'],['-lcrypto'],asan=True)
if __name__=='__main__':unittest.main()
