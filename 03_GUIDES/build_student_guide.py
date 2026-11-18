#!/usr/bin/env python3
"""Rebuild the static student guide from Markdown with Pandoc GFM semantics.

The separate 02_INIT_HOMEWORKS interactive edition is not overwritten.
Author attribution in the Markdown is retained verbatim. Requires pandoc.
"""
from pathlib import Path
import hashlib
import html
import subprocess


def main():
    root=Path(__file__).resolve().parent
    source=root/'STUDENT_GUIDE_EN.md'
    run=subprocess.run(['pandoc','--from=gfm','--to=html5',str(source)],capture_output=True,text=True,check=True)
    css=(root/'student_guide_style.css').read_text()
    print_css=(root.parent/'assets/css/print.css').read_text().rstrip()
    digest=hashlib.sha256(source.read_bytes()).hexdigest()
    version=subprocess.run(['pandoc','--version'],capture_output=True,text=True,check=True).stdout.splitlines()[0]
    output='<!DOCTYPE html>\n<html lang="en-GB">\n<head>\n<meta charset="UTF-8">\n<meta name="viewport" content="width=device-width, initial-scale=1.0">\n'
    output+='<title>ENos — Homework Recording: Student Guide</title>\n'
    output+=f'<meta name="generator" content="{html.escape(version,quote=True)}">\n<meta name="source-sha256" content="{digest}">\n'
    output+='<style>\n'+css+'\n</style>\n<style id="enos-print-styles">\n'+print_css+'\n</style>\n</head>\n<body>\n<main>\n'+run.stdout+'\n</main>\n</body>\n</html>\n'
    (root/'STUDENT_GUIDE_EN.html').write_text(output)
    print(f'Rebuilt STUDENT_GUIDE_EN.html; Markdown SHA256 {digest}; {version}')

if __name__=='__main__':main()
