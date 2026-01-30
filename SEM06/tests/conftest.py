"""Pytest configuration for SEM06 tests."""

import pytest
from pathlib import Path


@pytest.fixture(scope="session")
def sem06_root() -> Path:
    """Return SEM06 root directory."""
    return Path(__file__).parent.parent


@pytest.fixture(scope="session")
def projects_path(sem06_root: Path) -> Path:
    """Return projects directory."""
    return sem06_root / "scripts" / "projects"


@pytest.fixture(scope="session")
def deployer_path(projects_path: Path) -> Path:
    """Return deployer project directory."""
    return projects_path / "deployer"


@pytest.fixture(scope="session")
def monitor_path(projects_path: Path) -> Path:
    """Return monitor project directory."""
    return projects_path / "monitor"


@pytest.fixture(scope="session")
def backup_path(projects_path: Path) -> Path:
    """Return backup project directory."""
    return projects_path / "backup"


@pytest.fixture(scope="session")
def formative_path(sem06_root: Path) -> Path:
    """Return formative assessment directory."""
    return sem06_root / "formative"
