"""Static dependency graph fixtures: no HTTP request or browser execution."""
import importlib.util
from pathlib import Path

spec=importlib.util.spec_from_file_location('enos_resources',Path(__file__).with_name('check_html_resources.py'))
mod=importlib.util.module_from_spec(spec);spec.loader.exec_module(mod)


def test_recursive_local_css_and_encoded_font_path(tmp_path):
    (tmp_path/'lesson.html').write_text('<head><link rel="stylesheet" href="main.css"></head><body><a href="https://example.test/reference">Reference</a></body>')
    (tmp_path/'main.css').write_text('@import "font.css"; /* url(https://not-a-load.test) */')
    (tmp_path/'font.css').write_text('@font-face{src:url("font%20%23.woff2")} .icon{background:url(data:image/png;base64,YQ==)}')
    (tmp_path/'font #.woff2').write_bytes(b'derived font-byte fixture')
    report=mod.check(tmp_path)
    assert report['success'] and report['counts']['local']==3 and report['counts']['embedded']==1


def test_remote_or_missing_resource_fails_but_outbound_link_does_not(tmp_path):
    (tmp_path/'lesson.html').write_text('<head><script src="https://example.test/runtime.js"></script><link rel="stylesheet" href="missing.css"></head>')
    report=mod.check(tmp_path)
    assert not report['success'] and report['counts']['remote']==1 and report['counts']['missing']==1


def test_unused_vendor_html_and_css_are_not_runtime_requests(tmp_path):
    vendor=tmp_path/'assets/vendor/upstream';vendor.mkdir(parents=True)
    (vendor/'original.css').write_text('@import url(https://fonts.example.test);')
    (vendor/'support.html').write_text('<script src="https://not-loaded.example.test"></script>')
    (tmp_path/'lesson.html').write_text('<html><head></head><body>Offline content</body></html>')
    report=mod.check(tmp_path)
    assert report['success'] and report['html_documents']==1 and report['counts']['remote']==0
