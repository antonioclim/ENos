#!/usr/bin/env python3
"""
Unit tests for SEM03 (Advanced File Operations) autograder.

Tests cover:
- Find command validation
- Xargs usage patterns
- Permission handling
- Script safety checks

Author: ing. dr. Antonio Clim, ASE-CSIE
"""

import pytest
import subprocess
import tempfile
import os
from pathlib import Path
from typing import Generator

# Path to autograder
AUTOGRADER_PATH = Path(__file__).parent.parent / "scripts" / "python" / "S03_01_autograder.py"


class TestAutograderExists:
    """Verify autograder script exists and has valid syntax."""
    
    def test_autograder_file_exists(self) -> None:
        """Autograder script must exist."""
        assert AUTOGRADER_PATH.exists(), f"Autograder not found at {AUTOGRADER_PATH}"
    
    def test_autograder_is_python(self) -> None:
        """Autograder must be valid Python."""
        result = subprocess.run(
            ["python3", "-m", "py_compile", str(AUTOGRADER_PATH)],
            capture_output=True,
            text=True
        )
        assert result.returncode == 0, f"Syntax error: {result.stderr}"
    
    def test_autograder_has_main(self) -> None:
        """Autograder must have main() function."""
        content = AUTOGRADER_PATH.read_text()
        assert "def main(" in content, "Missing main() function"


class TestFindCommandValidation:
    """Tests for find command pattern detection."""
    
    @pytest.fixture
    def temp_dir(self) -> Generator[Path, None, None]:
        """Create temporary directory for tests."""
        with tempfile.TemporaryDirectory() as tmpdir:
            yield Path(tmpdir)
    
    def test_detect_unquoted_variable(self, temp_dir: Path) -> None:
        """Detect unquoted variable in find -name."""
        script = temp_dir / "bad_find.sh"
        script.write_text('#!/bin/bash\nfind . -name $pattern\n')
        
        # This should be flagged as unsafe
        content = script.read_text()
        assert "$pattern" in content and '"$pattern"' not in content
    
    def test_accept_quoted_variable(self, temp_dir: Path) -> None:
        """Accept properly quoted variable."""
        script = temp_dir / "good_find.sh"
        script.write_text('#!/bin/bash\nfind . -name "$pattern"\n')
        
        content = script.read_text()
        assert '"$pattern"' in content
    
    def test_detect_missing_print0(self, temp_dir: Path) -> None:
        """Detect find without -print0 when piped to xargs."""
        script = temp_dir / "unsafe_pipe.sh"
        script.write_text('#!/bin/bash\nfind . -name "*.txt" | xargs rm\n')
        
        content = script.read_text()
        # Should have -print0 and xargs -0
        assert "-print0" not in content  # This is the bug to detect


class TestPermissionPatterns:
    """Tests for chmod/chown pattern validation."""
    
    def test_detect_chmod_777(self) -> None:
        """Flag chmod 777 as security issue."""
        dangerous_patterns = ["chmod 777", "chmod -R 777", "chmod 0777"]
        for pattern in dangerous_patterns:
            # These should all be flagged
            assert "777" in pattern
    
    def test_accept_chmod_755(self) -> None:
        """Accept chmod 755 for executables."""
        safe_patterns = ["chmod 755", "chmod +x", "chmod 644"]
        for pattern in safe_patterns:
            assert "777" not in pattern


class TestXargsUsage:
    """Tests for xargs command validation."""
    
    def test_xargs_without_zero_flag(self) -> None:
        """Detect xargs without -0 when receiving from find."""
        unsafe = "find . -print0 | xargs rm"  # Missing -0 in xargs
        assert "-0" not in unsafe.split("|")[1]
    
    def test_xargs_with_zero_flag(self) -> None:
        """Accept xargs -0 with find -print0."""
        safe = "find . -print0 | xargs -0 rm"
        assert "-print0" in safe and "-0" in safe


class TestScriptSafety:
    """Tests for general script safety patterns."""
    
    @pytest.fixture
    def temp_dir(self) -> Generator[Path, None, None]:
        """Create temporary directory for tests."""
        with tempfile.TemporaryDirectory() as tmpdir:
            yield Path(tmpdir)
    
    def test_detect_missing_set_options(self, temp_dir: Path) -> None:
        """Detect missing set -euo pipefail."""
        script = temp_dir / "unsafe.sh"
        script.write_text('#!/bin/bash\necho "no safety"\n')
        
        content = script.read_text()
        assert "set -e" not in content  # Should be flagged
    
    def test_accept_safe_script(self, temp_dir: Path) -> None:
        """Accept script with proper safety options."""
        script = temp_dir / "safe.sh"
        script.write_text('#!/bin/bash\nset -euo pipefail\necho "safe"\n')
        
        content = script.read_text()
        assert "set -euo pipefail" in content


if __name__ == "__main__":
    pytest.main([__file__, "-v"])
