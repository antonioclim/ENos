#!/usr/bin/env python3
"""Explicit, isolated test fixture. Not an HTTP client or complete curl emulator."""
import json
import os
import sys

expected = json.loads(os.environ['MOCK_CURL_EXPECTED_ARGV_JSON'])
if sys.argv[1:] != expected:
    print(f'Unexpected curl argv: {sys.argv[1:]!r}', file=sys.stderr)
    raise SystemExit(2)
status = int(os.environ.get('MOCK_CURL_HTTP_STATUS', '200'))
transport = int(os.environ.get('MOCK_CURL_EXIT', '0'))
if not 100 <= status <= 599 or not 0 <= transport <= 255:
    raise SystemExit(2)
if transport:
    raise SystemExit(transport)
if '--fail' in expected and status >= 400:
    raise SystemExit(22)
sys.stdout.write(os.environ.get('MOCK_CURL_BODY', ''))
