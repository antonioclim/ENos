"""Owned local M14 fixtures; no real credentials, receiver or Windows acceptance."""
import importlib.util
import json
import os
import re
import stat
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path
from unittest import mock

ROOT = Path(__file__).resolve().parents[1]
RENDERER = ROOT / "reference/m14/render_local.py"
SPEC = importlib.util.spec_from_file_location("m14_local_renderer", RENDERER)
M14 = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(M14)
CANARY = "DEMO_ONLY_M14_CANARY_62fda4"


def transport(values=None):
    values = values if values is not None else [("APP", "demo", "0"), ("TOKEN", CANARY, "1")]
    return b"".join(part.encode("utf-8") + b"\0" for triple in values for part in triple)


class M14Fixture(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="enos-m14-preview-")
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.template = self.root / "app.tmpl"
        self.template.write_text("app=${APP}\nsecret=${TOKEN}\n")

    def cli(self, *args, raw=None, env=None):
        command = [sys.executable, "-B", str(RENDERER), str(self.template), *map(str, args)]
        self.assertNotIn(CANARY, " ".join(command))
        return subprocess.run(command, input=transport() if raw is None else raw,
                              capture_output=True, env={**os.environ, **(env or {})}, timeout=10)


class M14PreviewTests(M14Fixture):
    def test_default_and_stale_global_previews_are_redacted(self):
        for inherited in ("false", "true"):
            with self.subTest(inherited=inherited):
                result = self.cli(env={"ALLOW_SECRET_OUTPUT": inherited})
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertEqual(result.stdout, b"app=demo\nsecret=<redacted>\n")
                self.assertNotIn(CANARY.encode(), result.stdout + result.stderr)

    def test_documented_bash_wrapper_passes_values_via_stdin(self):
        if not __import__("shutil").which("bash"):
            self.skipTest("Bash unavailable")
        document = (ROOT / "a)MEDIUM/M14_Environment_Config_Manager.md").read_text()
        wrapper = next(block for block in re.findall(r"```bash\n(.*?)\n```", document, re.S)
                       if block.startswith("render_template()"))
        code = "declare -A ENV_VARS SECRET_KEYS\nENV_VARS[APP]=demo\n" + \
               "ENV_VARS[TOKEN]=" + CANARY + "\nSECRET_KEYS[TOKEN]=1\n" + wrapper + \
               '\nrender_template "$M14_TEMPLATE"\n'
        result = subprocess.run(["bash"], input=code.encode(), capture_output=True,
                                env={**os.environ, "M14_RENDERER": str(RENDERER),
                                     "M14_TEMPLATE": str(self.template), "ALLOW_SECRET_OUTPUT": "true"}, timeout=10)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertNotIn(CANARY.encode(), result.stdout + result.stderr)
        self.assertIn(b"<redacted>", result.stdout)

    def test_CBC_fragment_is_an_explicit_synthetic_round_trip(self):
        if not all(__import__("shutil").which(x) for x in ("bash", "openssl")):
            self.skipTest("Native Bash/OpenSSL fragment NOT_RUN")
        document = (ROOT / "a)MEDIUM/M14_Environment_Config_Manager.md").read_text()
        fragment = next(block for block in re.findall(r"```bash\n(.*?)\n```", document, re.S)
                        if block.startswith("encrypt_value()"))
        code = fragment + "\nENVMAN_PASSWORD=DEMO_ONLY_password\nENVMAN_SYNTHETIC_DEMO=false\n" + \
               "if encrypt_value " + CANARY + "; then exit 5; fi\n" + \
               "ENVMAN_SYNTHETIC_DEMO=true\n" + \
               "if encrypt_value not_a_demo; then exit 6; fi\n" + \
               "encrypted=$(encrypt_value " + CANARY + ") || exit 7\n" + \
               "decrypted=$(decrypt_value \"$encrypted\") || exit 8\n" + \
               "[[ $decrypted == " + CANARY + " ]] || exit 9\nprintf 'CBC_DEMO_ROUNDTRIP_PASS\\n'\n"
        result = subprocess.run(["bash"], input=code.encode(), capture_output=True, timeout=15)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout, b"CBC_DEMO_ROUNDTRIP_PASS\n")
        self.assertNotIn(CANARY.encode(), result.stdout + result.stderr)

    def test_substitution_is_single_pass_and_dollar_escape_is_literal(self):
        values = {"APP": "${TOKEN}", "TOKEN": CANARY}
        self.assertEqual(M14.render("$APP/$$/${TOKEN}", values, {"TOKEN"}, preview=True),
                         "${TOKEN}/$/<redacted>")

    def test_invalid_transport_missing_variables_and_values_publish_nothing(self):
        invalid = [b"broken", transport([("TOKEN", CANARY, "1"), ("TOKEN", "other", "1")]),
                   transport([("BAD-KEY", "value", "0")]), transport([("APP", "demo\nvalue", "0")]),
                   transport([("APP", "demo", "2")]), b"APP\0\xff\x00" + b"0\0"]
        for raw in invalid:
            with self.subTest(raw_length=len(raw)):
                result = self.cli(raw=raw)
                self.assertNotEqual(result.returncode, 0)
                self.assertEqual(result.stdout, b"")
                self.assertNotIn(CANARY.encode(), result.stderr)
        result = self.cli(raw=transport([("APP", "demo", "0")]))
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(result.stdout, b"")


@unittest.skipUnless(os.name == "posix" and hasattr(os, "O_NOFOLLOW"), "POSIX lifecycle NOT_RUN")
class M14LifecycleTests(M14Fixture):
    def setUp(self):
        super().setUp()
        os.chmod(self.root, 0o700)
        self.payload = ("app=demo\nsecret=" + CANARY + "\n").encode()

    def test_private_modes_exact_dummy_bytes_and_cleanup(self):
        observed = []

        def receiver(fd, expected):
            directory = self.root / "owned"
            file = directory / "service.conf"
            self.assertEqual(stat.S_IMODE(directory.stat().st_mode), 0o700)
            self.assertEqual(stat.S_IMODE(file.stat().st_mode), 0o600)
            self.assertEqual(file.stat().st_uid, os.getuid())
            observed.append(os.read(fd, len(expected) + 1))
            self.assertEqual(observed[-1], self.payload)
            return len(expected)

        result = M14.run_local_demo(self.root, "owned", self.payload, receiver)
        self.assertEqual(result, {"status": "VERIFIED_LOCAL_SYNTHETIC", "bytes": len(self.payload), "output_removed": True})
        self.assertEqual(observed, [self.payload])
        self.assertFalse((self.root / "owned").exists())
        self.assertTrue(self.template.exists())

    def test_cli_requires_explicit_output_action_and_synthetic_values(self):
        flags = ("--workspace", self.root, "--output-dir", "owned")
        refused = self.cli(*flags, env={"ALLOW_SECRET_OUTPUT": "true"})
        self.assertNotEqual(refused.returncode, 0)
        self.assertFalse((self.root / "owned").exists())
        refused = self.cli(*flags, "--synthetic-demo", raw=transport([("APP", "demo", "0"), ("TOKEN", "not-a-demo-value", "1")]))
        self.assertNotEqual(refused.returncode, 0)
        self.assertFalse((self.root / "owned").exists())
        result = self.cli(*flags, "--synthetic-demo")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertTrue(json.loads(result.stdout)["output_removed"])
        self.assertNotIn(CANARY.encode(), result.stdout + result.stderr)
        self.assertFalse((self.root / "owned").exists())
        preview = self.cli(env={"ALLOW_SECRET_OUTPUT": "true"})
        self.assertNotIn(CANARY.encode(), preview.stdout + preview.stderr)

    def test_existing_targets_symlinks_and_traversal_are_preserved(self):
        existing = self.root / "existing"
        existing.mkdir(mode=0o700)
        marker = existing / "service.conf"
        marker.write_text("preserve")
        link = self.root / "linked"
        link.symlink_to(existing, target_is_directory=True)
        for name in ("existing", "linked", "../escape", ".", ".."):
            with self.subTest(name=name), self.assertRaises((M14.LifecycleError, OSError)):
                M14.run_local_demo(self.root, name, self.payload)
            self.assertEqual(marker.read_text(), "preserve")
        self.assertTrue(link.is_symlink())
        workspace_link = self.root / "workspace-link"
        workspace_link.symlink_to(existing, target_is_directory=True)
        with self.assertRaises(M14.LifecycleError):
            M14.run_local_demo(workspace_link, "new", self.payload)

    def test_wrong_modes_owner_version_control_and_sync_workspace_are_refused(self):
        os.chmod(self.root, 0o755)
        with self.assertRaises(M14.LifecycleError):
            M14.run_local_demo(self.root, "new", self.payload)
        os.chmod(self.root, 0o700)
        with mock.patch.object(M14.os, "getuid", return_value=os.getuid() + 1), self.assertRaises(M14.LifecycleError):
            M14.run_local_demo(self.root, "new", self.payload)
        (self.root / ".git").write_text("fixture marker")
        with self.assertRaises(M14.LifecycleError):
            M14.run_local_demo(self.root, "new", self.payload)
        (self.root / ".git").unlink()
        synced = self.root / "OneDrive"
        synced.mkdir(mode=0o700)
        with self.assertRaises(M14.LifecycleError):
            M14.run_local_demo(synced, "new", self.payload)
        self.assertFalse((self.root / "new").exists())

    def test_write_fsync_and_receiver_failures_clean_created_output(self):
        for method in ("write", "fsync"):
            with self.subTest(method=method), mock.patch.object(M14.os, method, side_effect=OSError("fixture error")), self.assertRaises(OSError):
                M14.run_local_demo(self.root, "failed", self.payload)
            self.assertFalse((self.root / "failed").exists())
        with mock.patch.object(M14.os, "write", return_value=0), self.assertRaises(M14.LifecycleError):
            M14.run_local_demo(self.root, "short", self.payload)
        self.assertFalse((self.root / "short").exists())

        def failing_receiver(fd, expected):
            raise M14.LifecycleError("Dummy fixture failed")

        with self.assertRaises(M14.LifecycleError):
            M14.run_local_demo(self.root, "receiver", self.payload, failing_receiver)
        self.assertFalse((self.root / "receiver").exists())

    def test_cleanup_failure_is_reported_as_residual_not_success(self):
        with mock.patch.object(M14.os, "unlink", side_effect=PermissionError("fixture permission error")):
            with self.assertRaisesRegex(M14.LifecycleError, "Residual"):
                M14.run_local_demo(self.root, "residual", self.payload)
        file = self.root / "residual/service.conf"
        self.assertTrue(file.exists())
        self.assertEqual(stat.S_IMODE(file.stat().st_mode), 0o600)

    def test_output_refuses_unverified_platform_semantics(self):
        with mock.patch.object(M14.os, "name", "nt"), self.assertRaises(M14.LifecycleError):
            M14.run_local_demo(self.root, "new", self.payload)
        self.assertFalse((self.root / "new").exists())


if __name__ == "__main__":
    unittest.main()
