"""Regressions: scope, permissions, failure reporting and no partial validation writes."""
from pathlib import Path
import importlib.util
import stat
import subprocess
import sys

SCRIPT=Path(__file__).with_name('add_print_styles.py')
spec=importlib.util.spec_from_file_location('enos_print_styles',SCRIPT)
mod=importlib.util.module_from_spec(spec);spec.loader.exec_module(mod)

def test_selected_directory_does_not_change_sibling_and_preserves_mode(tmp_path):
    a=tmp_path/'selected';b=tmp_path/'other';a.mkdir();b.mkdir()
    x=a/'one.html';y=b/'two.html'
    for p in (x,y):p.write_text('<html><head></head><body>Teaching material</body></html>')
    x.chmod(0o644);before=y.read_bytes()
    assert mod.main([str(a)])==0
    assert 'enos-print-styles' in x.read_text() and y.read_bytes()==before
    assert stat.S_IMODE(x.stat().st_mode)==0o644
    once=x.read_bytes();assert mod.main([str(a)])==0;assert x.read_bytes()==once

def test_existing_unrelated_print_rule_does_not_suppress_common_rules(tmp_path):
    p=tmp_path/'x.html';p.write_text('<head><style>@media print {h1 {color: black;}}</style></head>')
    assert mod.main([str(p)])==0
    assert p.read_text().count('id="enos-print-styles"')==1
    assert 'h1 {color: black;}' in p.read_text()

def test_invalid_document_reports_failure_before_any_write(tmp_path):
    a=tmp_path/'a.html';z=tmp_path/'z.html';a.write_text('<head></head>');z.write_text('<body>missing head</body>')
    before=a.read_bytes()
    p=subprocess.run([sys.executable,str(SCRIPT),str(tmp_path)],capture_output=True,text=True)
    assert p.returncode==1 and 'missing closing' in p.stderr
    assert a.read_bytes()==before

def test_dry_run_does_not_write_and_missing_path_fails(tmp_path):
    p=tmp_path/'x.html';p.write_text('<head></head>');before=p.read_bytes()
    assert mod.main(['--dry-run',str(p)])==0 and p.read_bytes()==before
    assert mod.main([str(tmp_path/'missing')])==1

def test_replace_failure_leaves_original_and_cleans_temporary(tmp_path,monkeypatch):
    p=tmp_path/'x.html';p.write_text('original')
    def fail(*args):raise PermissionError('fixture denied replacement')
    monkeypatch.setattr(mod.os,'replace',fail)
    import pytest
    with pytest.raises(PermissionError):mod.replace(p,'changed')
    assert p.read_text()=='original' and list(tmp_path.iterdir())==[p]

def test_root_selection_preserves_pinned_vendor_html(tmp_path, monkeypatch):
    monkeypatch.setattr(mod, 'ROOT', tmp_path)
    css=tmp_path/'assets/css/print.css';css.parent.mkdir(parents=True);css.write_text('@media print {body {color: black;}}\n')
    vendor=tmp_path/'assets/vendor/package/view.html';vendor.parent.mkdir(parents=True);vendor.write_text('<head></head><body>upstream</body>')
    own=tmp_path/'lesson.html';own.write_text('<head></head><body>lesson</body>')
    before=vendor.read_bytes()
    assert mod.main([])==0
    assert 'enos-print-styles' in own.read_text() and vendor.read_bytes()==before
    assert mod.main([str(vendor)])==1 and vendor.read_bytes()==before
