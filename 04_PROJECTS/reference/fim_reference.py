#!/usr/bin/env python3
"""M12 local reference: staged SQLite baselines and JSON change records.

Exit codes: 0 unchanged/saved, 1 changes, 2 unavailable/invalid/incomplete.
Config JSON: roots (absolute directory paths), exclude (absolute glob patterns),
algorithm (md5, sha1, sha256 or sha512). Regular files only, no symlink traversal.
update replaces only the selected configured roots; other roots are retained.
No notification, restoration or real service operation is performed.
"""
from __future__ import annotations
import contextlib
import fcntl
import fnmatch
import hashlib
import json
import os
import sqlite3
import stat
import sys
import tempfile
from pathlib import Path
ALGORITHMS={'md5','sha1','sha256','sha512'}
SCHEMA='''CREATE TABLE metadata(key TEXT PRIMARY KEY,value TEXT NOT NULL);
CREATE TABLE files(path TEXT PRIMARY KEY,hash TEXT NOT NULL,size INTEGER NOT NULL,
mtime_ns INTEGER NOT NULL,permissions INTEGER NOT NULL,uid INTEGER NOT NULL,gid INTEGER NOT NULL);
PRAGMA user_version=1;'''


def stream_digest(stream, algorithm):
    digest = hashlib.new(algorithm)
    for chunk in iter(lambda: stream.read(1024 * 1024), b''):
        digest.update(chunk)
    return digest.hexdigest()


def configuration(path: str) -> dict:
    value=json.loads(Path(path).read_text())
    if not isinstance(value,dict) or set(value)-{'roots','exclude','algorithm'}:
        raise ValueError('invalid configuration keys')
    roots=value.get('roots'); excludes=value.get('exclude',[]); algorithm=value.get('algorithm','sha256')
    if not isinstance(roots,list) or not roots or not all(isinstance(p,str) and p.startswith('/') for p in roots):
        raise ValueError('roots must be a nonempty list of absolute directory paths')
    if not isinstance(excludes,list) or not all(isinstance(p,str) for p in excludes) or algorithm not in ALGORITHMS:
        raise ValueError('invalid exclusions or algorithm')
    return {'roots':sorted(set(roots)),'exclude':excludes,'algorithm':algorithm}


def read_baseline(db_path: Path) -> tuple[dict,dict]:
    if not db_path.is_file() or db_path.is_symlink(): raise ValueError('baseline missing or symlinked')
    with sqlite3.connect(db_path.as_uri()+'?mode=ro',uri=True) as db:
        if db.execute('PRAGMA user_version').fetchone()[0]!=1: raise ValueError('unsupported schema; migrate explicitly')
        config=json.loads(db.execute("SELECT value FROM metadata WHERE key='config'").fetchone()[0])
        rows={row[0]:tuple(row[1:]) for row in db.execute('SELECT path,hash,size,mtime_ns,permissions,uid,gid FROM files')}
    return config,rows


def collect(config: dict, db_path: Path) -> dict:
    rows={}
    def onerror(error): raise error
    ignored={str(db_path),str(db_path)+'.lock',str(db_path)+'-journal',str(db_path)+'-wal',str(db_path)+'-shm'}
    for root_name in config['roots']:
        root=Path(root_name)
        if not root.is_dir() or root.is_symlink(): raise ValueError(f'root unavailable: {root}')
        for directory,dirs,names in os.walk(root,followlinks=False,onerror=onerror):
            dirs[:]=[name for name in dirs if not (Path(directory)/name).is_symlink()]
            for name in names:
                path=Path(directory)/name; path_text=str(path)
                if path_text in ignored or any(fnmatch.fnmatchcase(path_text,p) for p in config['exclude']): continue
                before=path.lstat()
                if not stat.S_ISREG(before.st_mode): continue
                with path.open('rb') as stream:
                    opened=os.fstat(stream.fileno())
                    if (opened.st_dev,opened.st_ino)!=(before.st_dev,before.st_ino): raise ValueError('file changed during open')
                    digest=stream_digest(stream,config['algorithm'])
                    after=os.fstat(stream.fileno())
                if (before.st_size,before.st_mtime_ns,before.st_ctime_ns)!=(after.st_size,after.st_mtime_ns,after.st_ctime_ns):
                    raise ValueError(f'file changed during hash: {path}')
                rows[path_text]=(digest,before.st_size,before.st_mtime_ns,stat.S_IMODE(before.st_mode),before.st_uid,before.st_gid)
    return rows


def save(db_path: Path, config: dict, rows: dict) -> None:
    fd,stage_name=tempfile.mkstemp(prefix=db_path.name+'.partial.',dir=db_path.parent)
    os.close(fd); stage=Path(stage_name)
    try:
        with sqlite3.connect(stage) as db:
            db.executescript(SCHEMA)
            with db:
                db.execute('INSERT INTO metadata VALUES(?,?)',('config',json.dumps(config)))
                db.executemany('INSERT INTO files VALUES(?,?,?,?,?,?,?)',[(path,*row) for path,row in sorted(rows.items())])
        with stage.open('rb') as stream: os.fsync(stream.fileno())
        os.replace(stage,db_path)
    finally:
        with contextlib.suppress(FileNotFoundError): stage.unlink()


def run(mode: str, db_path: Path, config_path: str|None=None) -> int:
    db_path=db_path.absolute()
    if db_path.is_symlink(): raise ValueError('baseline may not be a symlink')
    with open(str(db_path)+'.lock','a') as lock:
        fcntl.flock(lock,fcntl.LOCK_SH if mode=='check' else fcntl.LOCK_EX)
        if mode=='check':
            config,old=read_baseline(db_path); current=collect(config,db_path); changes=[]
            fields=('hash','size','mtime_ns','permissions','uid','gid')
            for path in sorted(set(old)|set(current)):
                if path not in old: kinds=['added']
                elif path not in current: kinds=['deleted']
                else: kinds=[field for field,a,b in zip(fields,old[path],current[path]) if a!=b]
                if kinds: changes.append({'path':path,'changes':kinds})
            print(json.dumps({'schema_version':1,'files_changed':len(changes),'changes':changes},indent=2))
            return int(bool(changes))
        if mode not in {'create','update'} or config_path is None: raise ValueError('invalid operation')
        config=configuration(config_path)
        if mode=='create' and db_path.exists(): raise ValueError('baseline exists; use explicit update')
        new=collect(config,db_path)
        if mode=='update':
            old_config,old=read_baseline(db_path)
            if config['algorithm']!=old_config['algorithm'] or config['exclude']!=old_config['exclude']:
                raise ValueError('algorithm/exclusion change requires a new complete baseline')
            retained={path:row for path,row in old.items() if not any(Path(path).is_relative_to(root) for root in config['roots'])}
            retained.update(new); new=retained
            config['roots']=sorted(set(old_config['roots'])|set(config['roots']))
        save(db_path,config,new)
        print(json.dumps({'status':'saved','files':len(new),'algorithm':config['algorithm']}))
        return 0


def main(argv: list[str]) -> int:
    try:
        if not ((len(argv) == 2 and argv[0] == 'check') or
                (len(argv) == 3 and argv[0] in {'create', 'update'})):
            raise ValueError('usage: fim_reference.py create|update DB CONFIG | check DB')
        return run(argv[0],Path(argv[1]),argv[2] if len(argv)==3 else None)
    except (ValueError,KeyError,OSError,sqlite3.Error,TypeError) as error:
        print(f'Integrity operation unavailable: {error}',file=sys.stderr);return 2
if __name__=='__main__': raise SystemExit(main(sys.argv[1:]))
