#!/usr/bin/env python3
"""
Unit tests for SEM06 (Capstone Project) components.

Tests cover:
- Deployer core functionality
- Monitor core functionality
- Backup system components
- Integration patterns

Author: ing. dr. Antonio Clim, ASE-CSIE
"""

import pytest
import subprocess
from pathlib import Path
from typing import Generator
import tempfile
import os


# Paths to project components
PROJECTS_PATH = Path(__file__).parent.parent / "scripts" / "projects"


class TestDeployerCore:
    """Tests for deployer project core functionality."""
    
    @pytest.fixture
    def deployer_path(self) -> Path:
        """Path to deployer project."""
        return PROJECTS_PATH / "deployer"
    
    def test_deployer_exists(self, deployer_path: Path) -> None:
        """Deployer project directory must exist."""
        assert deployer_path.exists(), f"Deployer not found at {deployer_path}"
    
    def test_core_lib_exists(self, deployer_path: Path) -> None:
        """Core library must exist."""
        core = deployer_path / "lib" / "core.sh"
        assert core.exists(), "lib/core.sh not found"
    
    def test_core_lib_syntax(self, deployer_path: Path) -> None:
        """Core library must have valid Bash syntax."""
        core = deployer_path / "lib" / "core.sh"
        result = subprocess.run(
            ["bash", "-n", str(core)],
            capture_output=True,
            text=True
        )
        assert result.returncode == 0, f"Syntax error: {result.stderr}"
    
    def test_has_health_check_function(self, deployer_path: Path) -> None:
        """Deployer must have health check function."""
        core = deployer_path / "lib" / "core.sh"
        content = core.read_text()
        assert "health_check" in content or "check_health" in content or \
               "verify" in content.lower(), "Missing health check functionality"


class TestMonitorCore:
    """Tests for monitor project core functionality."""
    
    @pytest.fixture
    def monitor_path(self) -> Path:
        """Path to monitor project."""
        return PROJECTS_PATH / "monitor"
    
    def test_monitor_exists(self, monitor_path: Path) -> None:
        """Monitor project directory must exist."""
        assert monitor_path.exists(), f"Monitor not found at {monitor_path}"
    
    def test_core_lib_exists(self, monitor_path: Path) -> None:
        """Core library must exist."""
        core = monitor_path / "lib" / "core.sh"
        assert core.exists(), "lib/core.sh not found"
    
    def test_core_lib_syntax(self, monitor_path: Path) -> None:
        """Core library must have valid Bash syntax."""
        core = monitor_path / "lib" / "core.sh"
        result = subprocess.run(
            ["bash", "-n", str(core)],
            capture_output=True,
            text=True
        )
        assert result.returncode == 0, f"Syntax error: {result.stderr}"
    
    def test_has_metric_collection(self, monitor_path: Path) -> None:
        """Monitor must have metric collection functions."""
        core_files = list((monitor_path / "lib").glob("*.sh"))
        all_content = "".join(f.read_text() for f in core_files)
        
        # Should have CPU, memory, disk metrics
        assert "cpu" in all_content.lower(), "Missing CPU monitoring"
        assert "memory" in all_content.lower() or "mem" in all_content.lower(), \
            "Missing memory monitoring"


class TestBackupCore:
    """Tests for backup project core functionality."""
    
    @pytest.fixture
    def backup_path(self) -> Path:
        """Path to backup project."""
        return PROJECTS_PATH / "backup"
    
    def test_backup_exists(self, backup_path: Path) -> None:
        """Backup project directory must exist."""
        assert backup_path.exists(), f"Backup not found at {backup_path}"
    
    def test_core_lib_exists(self, backup_path: Path) -> None:
        """Core library must exist."""
        core = backup_path / "lib" / "core.sh"
        assert core.exists(), "lib/core.sh not found"
    
    def test_core_lib_syntax(self, backup_path: Path) -> None:
        """Core library must have valid Bash syntax."""
        core = backup_path / "lib" / "core.sh"
        result = subprocess.run(
            ["bash", "-n", str(core)],
            capture_output=True,
            text=True
        )
        assert result.returncode == 0, f"Syntax error: {result.stderr}"
    
    def test_has_rotation_logic(self, backup_path: Path) -> None:
        """Backup must have rotation/retention logic."""
        lib_path = backup_path / "lib"
        if lib_path.exists():
            all_content = "".join(f.read_text() for f in lib_path.glob("*.sh"))
            # Should have retention or rotation
            assert "retain" in all_content.lower() or "rotat" in all_content.lower(), \
                "Missing backup rotation/retention logic"


class TestProjectStructure:
    """Tests for consistent project structure."""
    
    @pytest.mark.parametrize("project", ["deployer", "monitor", "backup"])
    def test_has_readme(self, project: str) -> None:
        """Each project must have README."""
        readme = PROJECTS_PATH / project / "README.md"
        assert readme.exists(), f"{project} missing README.md"
    
    @pytest.mark.parametrize("project", ["deployer", "monitor", "backup"])
    def test_has_lib_directory(self, project: str) -> None:
        """Each project must have lib/ directory."""
        lib_dir = PROJECTS_PATH / project / "lib"
        assert lib_dir.exists(), f"{project} missing lib/ directory"
    
    @pytest.mark.parametrize("project", ["deployer", "monitor", "backup"])
    def test_has_main_script(self, project: str) -> None:
        """Each project must have a main script."""
        project_path = PROJECTS_PATH / project
        main_script = project_path / f"{project}.sh"
        assert main_script.exists(), f"{project} missing main script {project}.sh"


class TestBashSyntaxAll:
    """Verify all Bash scripts have valid syntax."""
    
    def test_all_bash_scripts_valid(self) -> None:
        """All .sh files must have valid Bash syntax."""
        errors = []
        for project in ["deployer", "monitor", "backup"]:
            project_path = PROJECTS_PATH / project
            for sh_file in project_path.rglob("*.sh"):
                result = subprocess.run(
                    ["bash", "-n", str(sh_file)],
                    capture_output=True,
                    text=True
                )
                if result.returncode != 0:
                    errors.append(f"{sh_file}: {result.stderr}")
        
        assert not errors, f"Bash syntax errors found:\n" + "\n".join(errors)


if __name__ == "__main__":
    pytest.main([__file__, "-v"])
