#!/usr/bin/env python3
"""Build the Lab 0C PDF from its adjacent Markdown source.

Author of teaching material: Antonio Clim, PhD. Dependencies: reportlab,
markdown-it-py and pypdf. Uses embedded DejaVu fonts (supply --font-dir).
Adds marked content, a structure tree, heading bookmarks and figure alternatives.
This is not a PDF/UA conformance assertion or a screen-reader acceptance test.
"""
from __future__ import annotations
import argparse
from contextlib import contextmanager
from html import escape
from pathlib import Path
import re
import tempfile
from markdown_it import MarkdownIt
from reportlab.lib import colors
from reportlab.lib.enums import TA_LEFT
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import ParagraphStyle
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.pdfgen.canvas import Canvas
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, Flowable, KeepTogether
from pypdf import PdfReader, PdfWriter
from pypdf.generic import (DictionaryObject, NameObject, ArrayObject, NumberObject,
                           TextStringObject, BooleanObject)

W = A4[0] - 88
N = NameObject
D = DictionaryObject
A = ArrayObject
I = NumberObject
T = TextStringObject
registry=[]
stack=[]
page_mcids={}

@contextmanager
def structure(role, canvas, alt=None, marked=False):
    page=canvas.getPageNumber()-1
    node={'role':role,'page':page,'children':[],'alt':alt}
    if stack:stack[-1]['children'].append(node)
    else:registry.append(node)
    if marked:
        mcid=page_mcids.get(page,0);page_mcids[page]=mcid+1;node['mcid']=mcid
        canvas._code.append(f'/{role} <</MCID {mcid}>> BDC')
    stack.append(node)
    try:yield node
    finally:
        stack.pop()
        if marked:canvas._code.append('EMC')

class TaggedParagraph(Paragraph):
    def __init__(self,*args,role='P',bookmark=None,**kw):
        super().__init__(*args,**kw);self.role=role;self.bookmark=bookmark
    def draw(self):
        if self.bookmark:
            level,key,title=self.bookmark
            self.canv.bookmarkHorizontalAbsolute(key,self.canv.absolutePosition(0,self.height)[1])
            self.canv.addOutlineEntry(title,key,level=level,closed=False)
        with structure(self.role,self.canv,marked=True):super().draw()

class TaggedCode(Flowable):
    def __init__(self,text):
        super().__init__();self.lines=text.rstrip('\n').split('\n');self.width=W;self.height=20+11.3*len(self.lines)
    def draw(self):
        c=self.canv
        with structure('Code',c,marked=True):
            c.setFillColor(colors.HexColor('#f1f5f9'));c.roundRect(0,0,W,self.height,4,fill=1,stroke=0)
            c.setFillColor(colors.HexColor('#102c44'));c.setFont('DVMono',8)
            for i,line in enumerate(self.lines):
                if pdfmetrics.stringWidth(line,'DVMono',8)>W-18:raise ValueError('Code line too wide: '+line)
                c.drawString(9,self.height-14-11.3*i,line)

class TaggedTable(Flowable):
    def __init__(self,rows,style):
        super().__init__();self.width=W;self.cols=[W*.19,W*.405,W*.405];self.rows=[];self.heights=[]
        for row in rows:
            paras=[TaggedParagraph(cell,style) for cell in row];hs=[p.wrap(w-14,1000)[1] for p,w in zip(paras,self.cols)]
            self.rows.append(paras);self.heights.append(max(hs)+14)
        self.height=sum(self.heights)+6
    def draw(self):
        c=self.canv;y=self.height
        with structure('Table',c):
            for ri,(row,h) in enumerate(zip(self.rows,self.heights)):
                y-=h;x=0
                with structure('TR',c):
                    for p,w in zip(row,self.cols):
                        c.setFillColor(colors.HexColor('#dce8f0' if ri==0 else ('#f4f7fa' if ri%2 else '#ffffff')))
                        c.setStrokeColor(colors.HexColor('#b5c6d3'));c.rect(x,y,w,h,fill=1,stroke=1)
                        with structure('TH' if ri==0 else 'TD',c):
                            p.drawOn(c,x+7,y+h-7-p.height)
                        x+=w

class Architecture(Flowable):
    captions={'type1':'Figure 1. Type 1 hypervisor (bare-metal)', 'type2':'Figure 2. Type 2 hypervisor (hosted)', 'container':'Figure 3. Linux container architecture (Docker example)'}
    alternatives={
        'type1':'Four virtual machines each contain applications, a guest OS and virtual hardware. They share a Type 1 hypervisor above the physical hardware.',
        'type2':'Three virtual machines each contain applications, a guest OS and virtual hardware. A hosted hypervisor sits above a host operating system and physical hardware.',
        'container':'Five containers each contain an application and libraries/dependencies. A container engine/runtime manages processes using one shared Linux host kernel above the hardware.'}
    def __init__(self,kind):super().__init__();self.kind=kind;self.width=W;self.height=208 if kind=='type2' else 188
    def draw(self):
        c=self.canv
        with structure('Figure',c,alt=self.alternatives[self.kind],marked=True):
            c.setFillColor(colors.HexColor('#183c55'));c.setFont('DV-Bold',9);c.drawString(0,self.height-12,self.captions[self.kind])
            def box(x,y,w,h,label,fill='#e7f0f6'):
                c.setFillColor(colors.HexColor(fill));c.setStrokeColor(colors.HexColor('#738fa5'));c.roundRect(x,y,w,h,3,fill=1,stroke=1)
                c.setFillColor(colors.HexColor('#183c55'));c.setFont('DV',8.1)
                for j,line in enumerate(label.split('\n')):c.drawCentredString(x+w/2,y+h/2+3*(len(label.split('\n'))-1)-10*j,line)
            box(0,8,W,23,'Physical hardware','#d5e3ed')
            if self.kind=='container':
                box(0,36,W,23,'Host OS (Linux kernel)');box(0,64,W,23,'Container engine / runtime (Docker example)')
                n=5;bw=(W-8*(n-1))/n
                for k in range(n):box(k*(bw+8),96,bw,58,f'App {k+1}\nLibraries / deps', '#edf4e9')
            else:
                top=36
                if self.kind=='type2':box(0,top,W,23,'Host OS (e.g. Windows or Linux)');top+=28
                box(0,top,W,23,'Type 1 hypervisor' if self.kind=='type1' else 'Type 2 hypervisor (hosted)')
                n=4 if self.kind=='type1' else 3;bw=(W-10*(n-1))/n
                for k in range(n):box(k*(bw+10),top+32,bw,72,f'VM {k+1}\nApplications\nGuest OS\nVirtual hardware','#edf4e9')

def inline(token):
    result=[]
    for t in token.children or []:
        if t.type=='text':
            text=escape(t.content)
            text=re.sub(r'https?://[^\s<>]+',lambda m:'<link href="'+m.group(0)+'" color="#145782">'+m.group(0)+'</link>',text)
            result.append(text)
        elif t.type=='code_inline':result.append('<font name="DVMono" size="8.5">'+escape(t.content)+'</font>')
        elif t.type=='strong_open':result.append('<b>')
        elif t.type=='strong_close':result.append('</b>')
        elif t.type=='em_open':result.append('<i>')
        elif t.type=='em_close':result.append('</i>')
        elif t.type in ('softbreak','hardbreak'):result.append(' ' if t.type=='softbreak' else '<br/>')
        elif t.type=='link_open':result.append('<link href="'+escape(t.attrGet('href'),quote=True)+'" color="#145782">')
        elif t.type=='link_close':result.append('</link>')
        else:raise ValueError('Unsupported inline token '+t.type)
    return ''.join(result)

def add_structure(raw,output):
    writer=PdfWriter(clone_from=raw)
    root=D({N('/Type'):N('/StructTreeRoot')});rootref=writer._add_object(root)
    document=D({N('/Type'):N('/StructElem'),N('/S'):N('/Document'),N('/P'):rootref,N('/K'):A()});docref=writer._add_object(document)
    root[N('/K')]=A([docref]);parents={p:[None]*n for p,n in page_mcids.items()}
    def node_pdf(node,parent):
        pg=writer.pages[node['page']].indirect_reference
        d=D({N('/Type'):N('/StructElem'),N('/S'):N('/'+node['role']),N('/P'):parent,N('/Pg'):pg});ref=writer._add_object(d)
        if node.get('alt'):d[N('/Alt')]=T(node['alt'])
        if node['role']=='TH':d[N('/A')]=D({N('/O'):N('/Table'),N('/Scope'):N('/Column')})
        children=[]
        if 'mcid' in node:
            children.append(I(node['mcid']));parents[node['page']][node['mcid']]=ref
        children.extend(node_pdf(child,ref) for child in node['children'])
        d[N('/K')]=A(children)
        return ref
    document[N('/K')]=A([node_pdf(node,docref) for node in registry])
    nums=[]
    for page,items in sorted(parents.items()):
        if any(x is None for x in items):raise ValueError('Unassigned marked content')
        nums.extend([I(page),A(items)]);writer.pages[page][N('/StructParents')]=I(page);writer.pages[page][N('/Tabs')]=N('/S')
    root[N('/ParentTree')]=writer._add_object(D({N('/Nums'):A(nums)}));root[N('/ParentTreeNextKey')]=I(len(writer.pages))
    writer._root_object[N('/StructTreeRoot')]=rootref
    writer._root_object[N('/MarkInfo')]=D({N('/Marked'):BooleanObject(True)})
    writer._root_object[N('/Lang')]=T('en-GB')
    writer._root_object[N('/ViewerPreferences')]=D({N('/DisplayDocTitle'):BooleanObject(True)})
    writer.add_metadata({'/Title':'Chapter 0: Prerequisites — Virtualisation','/Author':'Antonio Clim, PhD','/Subject':'Operating Systems — Lab 0C; Ubuntu Server 24.04 LTS; v2.1 ENos v6 candidate','/Keywords':'virtualisation, Ubuntu, ENos, Lab 0C','/Creator':'ENos build_lab0c_pdf.py (ReportLab + pypdf)'})
    # Reproducible bytes, with no fabricated creation/modification timestamp.
    for key in ['/CreationDate','/ModDate']:
        writer._info.get_object().pop(N(key),None)
    with output.open('wb') as f:writer.write(f)

def main():
    ap=argparse.ArgumentParser(description=__doc__);base=Path(__file__).parent
    ap.add_argument('--source',type=Path,default=base/'TC0_Lab0C_Virtualisation_ENv2.md')
    ap.add_argument('--output',type=Path,default=base/'TC0_Lab0C_Virtualisation_ENv2.pdf')
    ap.add_argument('--font-dir',type=Path,default=Path('/usr/share/fonts/truetype/dejavu'))
    args=ap.parse_args()
    for name,file in [('DV','DejaVuSans.ttf'),('DV-Bold','DejaVuSans-Bold.ttf'),('DV-Italic','DejaVuSans-Oblique.ttf'),('DV-BoldItalic','DejaVuSans-BoldOblique.ttf'),('DVMono','DejaVuSansMono.ttf')]:pdfmetrics.registerFont(TTFont(name,str(args.font_dir/file)))
    pdfmetrics.registerFontFamily('DV',normal='DV',bold='DV-Bold',italic='DV-Italic',boldItalic='DV-BoldItalic')
    body=ParagraphStyle('Body',fontName='DV',fontSize=9.25,leading=13.2,spaceAfter=7,textColor=colors.HexColor('#172c3d'),allowWidows=0,allowOrphans=0)
    cell=ParagraphStyle('Cell',parent=body,fontSize=8,leading=11,spaceAfter=0)
    heads={i:ParagraphStyle('H'+str(i),parent=body,fontName='DV-Bold',fontSize={1:20,2:13,3:10.5}[i],leading={1:25,2:17,3:15}[i],spaceBefore=12 if i>1 else 0,spaceAfter=8,keepWithNext=True,textColor=colors.HexColor('#123f5a')) for i in (1,2,3)}
    md=MarkdownIt('commonmark').enable('table');tokens=md.parse(args.source.read_text());story=[];i=0;list_stack=[];list_prefix=None;outline=0
    while i<len(tokens):
        t=tokens[i]
        if t.type=='heading_open':
            level=int(t.tag[1]);n=tokens[i+1];key=f'heading-{outline}';outline+=1
            story.append(TaggedParagraph(inline(n),heads[level],role='H'+str(level),bookmark=(level-1,key,n.content)));i+=3;continue
        if t.type in ('bullet_list_open','ordered_list_open'):
            list_stack.append(None if t.type=='bullet_list_open' else int(t.attrGet('start') or 1));i+=1;continue
        if t.type in ('bullet_list_close','ordered_list_close'):list_stack.pop();i+=1;continue
        if t.type=='list_item_open':
            n=list_stack[-1];list_prefix='• ' if n is None else str(n)+'. '
            if n is not None:list_stack[-1]+=1
            i+=1;continue
        if t.type=='list_item_close':list_prefix=None;i+=1;continue
        if t.type=='paragraph_open':
            n=tokens[i+1];style=body
            if list_stack:style=ParagraphStyle('List',parent=body,leftIndent=12,firstLineIndent=-10)
            story.append(TaggedParagraph(escape(list_prefix or '')+inline(n),style,role='P'))
            list_prefix=None;i+=3;continue
        if t.type=='fence':story.extend([TaggedCode(t.content),Spacer(1,8)]);i+=1;continue
        if t.type=='html_block':
            m=re.fullmatch(r'<!-- FIGURE:(\w+) -->\s*',t.content)
            if not m:raise ValueError('Unsupported HTML block '+t.content)
            story.extend([Architecture(m.group(1)),Spacer(1,8)]);i+=1;continue
        if t.type=='table_open':
            rows=[];row=None;i+=1
            while tokens[i].type!='table_close':
                tt=tokens[i]
                if tt.type=='tr_open':row=[]
                elif tt.type=='inline':row.append(inline(tt))
                elif tt.type=='tr_close':rows.append(row)
                i+=1
            story.extend([TaggedTable(rows,cell),Spacer(1,7)]);i+=1;continue
        raise ValueError('Unsupported block token '+t.type)
    def chrome(c,doc):
        c.saveState();c._code.append('/Artifact BMC');c.setFont('DV',8);c.setFillColor(colors.HexColor('#456479'))
        c.drawString(44,A4[1]-27,'OS Lab 0C — Virtualisation');c.drawRightString(A4[0]-44,A4[1]-27,'v2.1 · Ubuntu Server 24.04 LTS')
        c.setStrokeColor(colors.HexColor('#c3d3de'));c.line(44,A4[1]-33,A4[0]-44,A4[1]-33)
        c.drawString(44,24,'Adapted by Antonio Clim, PhD');c.drawRightString(A4[0]-44,24,str(doc.page));c._code.append('EMC');c.restoreState()
    args.output.parent.mkdir(parents=True,exist_ok=True)
    with tempfile.TemporaryDirectory(prefix='enos-lab0c-') as tmp:
        raw=Path(tmp)/'raw.pdf';doc=SimpleDocTemplate(str(raw),pagesize=A4,leftMargin=44,rightMargin=44,topMargin=48,bottomMargin=43,title='Chapter 0: Prerequisites — Virtualisation',author='Antonio Clim, PhD',pageCompression=1)
        doc.build(story,onFirstPage=chrome,onLaterPages=chrome,
                  canvasmaker=lambda *a,**kw:Canvas(*a,**dict(kw,invariant=1)))
        add_structure(raw,args.output)
    print(f'Built {args.output}: {len(PdfReader(args.output).pages)} pages, {sum(page_mcids.values())} marked content groups')

if __name__=='__main__':main()
