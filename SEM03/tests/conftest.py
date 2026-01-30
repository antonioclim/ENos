"""Pytest configuration for SEM03 tests."""

import pytest
from pathlib import Path


@pytest.fixture(scope="session")
def sem03_root() -> Path:
    """Return SEM03 root directory."""
    return Path(__file__).parent.parent


@pytest.fixture(scope="session")
def scripts_path(sem03_root: Path) -> Path:
    """Return scripts directory."""
    return sem03_root / "scripts"


@pytest.fixture(scope="session")
def python_scripts_path(scripts_path: Path) -> Path:
    """Return Python scripts directory."""
    return scripts_path / "python"


@pytest.fixture(scope="session")
def bash_scripts_path(scripts_path: Path) -> Path:
    """Return Bash scripts directory."""
    return scripts_path / "bash"


@pytest.fixture(scope="session")
def formative_path(sem03_root: Path) -> Path:
    """Return formative assessment directory."""
    return sem03_root / "formative"
