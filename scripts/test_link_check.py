"""Regression fixtures for real parser inputs and unambiguous exit status."""
from scripts.link_check import check, main


def test_internal_links_parse_balanced_paths_references_and_duplicate_headings(tmp_path):
    page = tmp_path / 'lesson (one).md'
    page.write_text('# Same heading\n\n# Same heading\n\n<a id="stable"></a>\n')
    source = tmp_path / 'README.md'
    source.write_text('[first](lesson%20%28one%29.md#same-heading)\n'
                      '[duplicate](<lesson (one).md#same-heading-1>)\n'
                      '[reference][lesson]\n\n'
                      '[lesson]: <lesson (one).md#stable>\n\n'
                      '`[not a link](absent.md)`\n\n'
                      '```sh\n[also not a link](absent.md)\n```\n')
    result = check(source, tmp_path)
    assert result['success'] and result['counts']['valid'] == 3


def test_missing_fragment_is_not_a_valid_existing_file(tmp_path):
    source = tmp_path / 'README.md'
    source.write_text('# Present\n\n[missing](#absent)\n')
    result = check(source, tmp_path)
    assert not result['success'] and result['counts']['broken'] == 1


def test_256_failures_cannot_wrap_to_shell_success(tmp_path, capsys):
    source = tmp_path / 'README.md'
    source.write_text('\n'.join(f'[link {n}](missing{n}.md)' for n in range(256)))
    assert main([str(source), '--json']) == 1
    import json
    result = json.loads(capsys.readouterr().out)
    assert result['counts']['broken'] == 256


def test_html_targets_and_offline_external_scope(tmp_path):
    source = tmp_path / 'page.html'
    source.write_text('<h1 id="start">Title</h1><a href="#start">Go</a>'
                      '<a href="https://example.org/">External</a>')
    result = check(source, tmp_path)
    assert result['success']
    assert result['counts']['valid'] == 1
    assert result['counts']['not_checked'] == 1


def test_declared_template_slots_are_not_accepted_as_real_links(tmp_path):
    template=tmp_path/'04_PROJECTS/templates/README_template.md';template.parent.mkdir(parents=True)
    template.write_text('[Source A](url)\n[Source B](url)\n[Source C](url)\n')
    result=check(template,tmp_path)
    assert result['success'] and result['counts']['valid']==0 and result['counts']['not_checked']==3
    assert all('placeholder' in row['detail'] for row in result['results'])
    ordinary=tmp_path/'README.md';ordinary.write_text('[An actual citation](url)\n')
    result=check(ordinary,tmp_path)
    assert not result['success'] and result['counts']['broken']==1
