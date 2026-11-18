#!/usr/bin/env python3
"""Merge owned tail children into JSONL; no header inference or implicit backlog.

Each physical line is one record. Bytes which are not UTF-8 use base64. Initial
backlog is zero; tail -F rotation/truncation does not provide exactly-once delivery.
"""
import base64
import datetime as dt
import json
import os
import selectors
import signal
import subprocess
import sys


def main(paths):
    if not paths: raise ValueError('at least one source is required')
    children=[]; selection=selectors.DefaultSelector(); buffers={}
    signal.signal(signal.SIGTERM,lambda *_: (_ for _ in ()).throw(SystemExit(143)))
    try:
        for source in paths:
            child=subprocess.Popen(['tail','-n','0','-F','--',source],stdout=subprocess.PIPE)
            children.append(child); selection.register(child.stdout,selectors.EVENT_READ,(source,child)); buffers[child]=b''
        while selection.get_map():
            for key,_ in selection.select():
                source,child=key.data; data=os.read(key.fd,65536)
                if not data: raise RuntimeError(f'tail exited for {source!r}: status {child.poll()}')
                buffers[child]+=data
                while b'\n' in buffers[child]:
                    line,buffers[child]=buffers[child].split(b'\n',1)
                    record={'source':source,'observed_at':dt.datetime.now(dt.timezone.utc).isoformat()}
                    try: record.update(message=line.decode('utf-8'),encoding='utf-8')
                    except UnicodeDecodeError: record.update(message=base64.b64encode(line).decode(),encoding='base64')
                    print(json.dumps(record),flush=True)
                if len(buffers[child])>1024*1024: raise ValueError('unterminated log line exceeds 1 MiB limit')
    finally:
        selection.close()
        for child in children:
            if child.poll() is None: child.terminate()
        for child in children:
            try: child.wait(timeout=2)
            except subprocess.TimeoutExpired: child.kill(); child.wait()
            if child.stdout: child.stdout.close()
    return 0
if __name__=='__main__':
    try: raise SystemExit(main(sys.argv[1:]))
    except (ValueError,OSError,RuntimeError) as error:
        print(f'Collection failed: {error}',file=sys.stderr);raise SystemExit(2)
