#!/usr/bin/env python3
"""
randomisation_utils.py - Student-specific test parameter randomisation
Operating Systems | ASE Bucharest - CSIE

Purpose: Generate deterministic, personalised test parameters for each student
         to prevent copying and ensure authentic submissions.

FAZA 5: AI Risk — Student Protection

Usage:
    from randomisation_utils import generate_student_seed, randomise_test_parameters
    
    seed = generate_student_seed(student_id, "SEM03_HW")
    params = randomise_test_parameters(seed)
"""

import hashlib
import random
from datetime import datetime
from typing import Dict, Any, List, Optional
from dataclasses import dataclass, field


@dataclass
class TestParameters:
    """Container for randomised test parameters."""
    
    # Network exercises
    ip_addresses: List[str] = field(default_factory=list)
    ports: List[int] = field(default_factory=list)
    
    # File system exercises
    file_sizes: List[int] = field(default_factory=list)
    file_names: List[str] = field(default_factory=list)
    directory_names: List[str] = field(default_factory=list)
    
    # Time-based exercises
    timestamps: List[int] = field(default_factory=list)
    cron_hours: List[int] = field(default_factory=list)
    cron_days: List[int] = field(default_factory=list)
    
    # Process exercises
    pids: List[int] = field(default_factory=list)
    signals: List[int] = field(default_factory=list)
    
    # Permission exercises
    usernames: List[str] = field(default_factory=list)
    permissions_octal: List[str] = field(default_factory=list)
    
    # Text processing exercises
    search_patterns: List[str] = field(default_factory=list)
    line_numbers: List[int] = field(default_factory=list)
    
    # General
    random_strings: List[str] = field(default_factory=list)
    random_numbers: List[int] = field(default_factory=list)
    
    # Seed for reproducibility
    seed: int = 0
    student_id: str = ""
    assignment: str = ""


def generate_student_seed(student_id: str, assignment: str, include_week: bool = True) -> int:
    """
    Generate deterministic seed for reproducible randomisation.
    
    Same student + same assignment = same seed = same test parameters.
    Different students get different parameters.
    
    Args:
        student_id: Student identifier (e.g., matriculation number, email)
        assignment: Assignment identifier (e.g., "SEM03_HW", "PROJECT_1")
        include_week: Whether to include current week for weekly variation
    
    Returns:
        Integer seed for random number generator
    
    Examples:
        >>> seed1 = generate_student_seed("student123", "SEM03_HW")
        >>> seed2 = generate_student_seed("student123", "SEM03_HW")
        >>> seed1 == seed2  # Same student, same assignment
        True
        >>> seed3 = generate_student_seed("student456", "SEM03_HW")
        >>> seed1 != seed3  # Different students
        True
    """
    # Normalise student ID (lowercase, strip whitespace)
    normalised_id = student_id.lower().strip()
    
    # Build the combined string
    if include_week:
        week = datetime.now().strftime('%Y-%W')
        combined = f"{normalised_id}:{assignment}:{week}"
    else:
        combined = f"{normalised_id}:{assignment}"
    
    # Generate SHA-256 hash and extract first 8 hex characters
    hash_bytes = hashlib.sha256(combined.encode('utf-8')).hexdigest()[:8]
    
    return int(hash_bytes, 16)


def randomise_test_parameters(seed: int, student_id: str = "", assignment: str = "") -> TestParameters:
    """
    Generate randomised test parameters for a student.
    
    All parameters are generated deterministically from the seed,
    so the same seed always produces the same parameters.
    
    Args:
        seed: Random seed (from generate_student_seed)
        student_id: Optional student ID for metadata
        assignment: Optional assignment name for metadata
    
    Returns:
        TestParameters object with all randomised values
    
    Example:
        >>> seed = generate_student_seed("student123", "SEM03_HW")
        >>> params = randomise_test_parameters(seed)
        >>> params.ip_addresses  # Same every time for this student
        ['10.0.47.123', '10.0.215.89', ...]
    """
    random.seed(seed)
    
    params = TestParameters(seed=seed, student_id=student_id, assignment=assignment)
    
    # IP addresses for network exercises (private ranges)
    params.ip_addresses = [
        f"10.0.{random.randint(1, 254)}.{random.randint(1, 254)}"
        for _ in range(10)
    ]
    
    # Port numbers (non-privileged range)
    params.ports = [
        random.randint(1024, 65535)
        for _ in range(10)
    ]
    
    # File sizes (1KB to 10MB)
    params.file_sizes = [
        random.randint(1024, 10485760)
        for _ in range(15)
    ]
    
    # File names
    file_prefixes = ['data', 'log', 'config', 'backup', 'output', 'input', 'temp', 'cache']
    file_extensions = ['.txt', '.log', '.cfg', '.dat', '.csv', '.json', '.xml', '.sh']
    params.file_names = [
        f"{random.choice(file_prefixes)}_{random.randint(100, 999)}{random.choice(file_extensions)}"
        for _ in range(10)
    ]
    
    # Directory names
    dir_prefixes = ['project', 'module', 'lib', 'src', 'test', 'doc', 'bin', 'etc']
    params.directory_names = [
        f"{random.choice(dir_prefixes)}_{random.randint(10, 99)}"
        for _ in range(10)
    ]
    
    # Timestamps (2021-01-01 to 2025-12-31)
    params.timestamps = [
        random.randint(1609459200, 1767225600)
        for _ in range(10)
    ]
    
    # Cron hours (0-23)
    params.cron_hours = [
        random.randint(0, 23)
        for _ in range(5)
    ]
    
    # Cron days (1-28 to be safe)
    params.cron_days = [
        random.randint(1, 28)
        for _ in range(5)
    ]
    
    # Process IDs
    params.pids = [
        random.randint(1000, 65535)
        for _ in range(10)
    ]
    
    # Signals (common ones)
    common_signals = [1, 2, 3, 9, 15, 18, 19, 20]  # HUP, INT, QUIT, KILL, TERM, CONT, STOP, TSTP
    params.signals = [
        random.choice(common_signals)
        for _ in range(5)
    ]
    
    # Usernames
    params.usernames = [
        f"user{random.randint(100, 999)}"
        for _ in range(5)
    ]
    
    # Permissions (octal)
    common_perms = ['644', '755', '700', '750', '640', '600', '664', '775']
    params.permissions_octal = [
        random.choice(common_perms)
        for _ in range(5)
    ]
    
    # Search patterns for grep/sed/awk
    pattern_bases = ['error', 'warning', 'info', 'debug', 'failed', 'success', 'start', 'end']
    params.search_patterns = [
        f"{random.choice(pattern_bases)}[{random.randint(0, 9)}]"
        for _ in range(5)
    ]
    
    # Line numbers
    params.line_numbers = [
        random.randint(1, 1000)
        for _ in range(10)
    ]
    
    # Random strings (for various purposes)
    chars = 'abcdefghijklmnopqrstuvwxyz0123456789'
    params.random_strings = [
        ''.join(random.choices(chars, k=random.randint(6, 12)))
        for _ in range(10)
    ]
    
    # Random numbers
    params.random_numbers = [
        random.randint(1, 10000)
        for _ in range(20)
    ]
    
    return params


def get_student_test_data(student_id: str, seminar: int) -> Dict[str, Any]:
    """
    Convenience function to get test data for a specific seminar.
    
    Args:
        student_id: Student identifier
        seminar: Seminar number (1-7)
    
    Returns:
        Dictionary with seminar-specific test parameters
    """
    seed = generate_student_seed(student_id, f"SEM{seminar:02d}_HW")
    params = randomise_test_parameters(seed, student_id, f"SEM{seminar:02d}")
    
    # Return as dict for easier access
    return {
        'seed': params.seed,
        'student_id': params.student_id,
        'ip_addresses': params.ip_addresses,
        'ports': params.ports,
        'file_sizes': params.file_sizes,
        'file_names': params.file_names,
        'directory_names': params.directory_names,
        'timestamps': params.timestamps,
        'pids': params.pids,
        'usernames': params.usernames,
        'permissions': params.permissions_octal,
        'search_patterns': params.search_patterns,
        'line_numbers': params.line_numbers,
        'random_strings': params.random_strings,
        'random_numbers': params.random_numbers,
    }


def extract_student_id(submission_path: str) -> Optional[str]:
    """
    Attempt to extract student ID from submission path or metadata.
    
    Common patterns:
    - /submissions/student123/
    - /student123_assignment.zip
    - metadata.json with student_id field
    
    Args:
        submission_path: Path to the submission
    
    Returns:
        Extracted student ID or None
    """
    import os
    import json
    from pathlib import Path
    
    path = Path(submission_path)
    
    # Check for metadata.json
    metadata_file = path / 'metadata.json'
    if metadata_file.exists():
        try:
            with open(metadata_file) as f:
                data = json.load(f)
                if 'student_id' in data:
                    return str(data['student_id'])
        except (json.JSONDecodeError, KeyError):
            pass
    
    # Try to extract from directory name
    dir_name = path.name if path.is_dir() else path.parent.name
    
    # Common patterns: student_123, 123456, ABC123
    import re
    patterns = [
        r'student[_-]?(\d+)',
        r'^(\d{6,})$',
        r'^([A-Z]{2,3}\d{3,})$',
    ]
    
    for pattern in patterns:
        match = re.search(pattern, dir_name, re.IGNORECASE)
        if match:
            return match.group(1) if match.groups() else match.group(0)
    
    # Fallback: use directory name itself
    return dir_name if dir_name else None


# Self-test when run directly
if __name__ == '__main__':
    print("=== Randomisation Utilities Test ===\n")
    
    # Test seed generation
    test_id = "student123"
    test_assignment = "SEM03_HW"
    
    seed = generate_student_seed(test_id, test_assignment, include_week=False)
    print(f"Student: {test_id}")
    print(f"Assignment: {test_assignment}")
    print(f"Generated seed: {seed}")
    
    # Test parameter generation
    params = randomise_test_parameters(seed, test_id, test_assignment)
    
    print(f"\nGenerated parameters:")
    print(f"  IP addresses: {params.ip_addresses[:3]}...")
    print(f"  Ports: {params.ports[:3]}...")
    print(f"  File names: {params.file_names[:3]}...")
    print(f"  Usernames: {params.usernames}")
    print(f"  Permissions: {params.permissions_octal}")
    
    # Verify reproducibility
    params2 = randomise_test_parameters(seed)
    assert params.ip_addresses == params2.ip_addresses, "Reproducibility failed!"
    print("\n✅ Reproducibility verified: same seed produces same parameters")
    
    # Test different students
    seed2 = generate_student_seed("student456", test_assignment, include_week=False)
    params3 = randomise_test_parameters(seed2)
    assert params.ip_addresses != params3.ip_addresses, "Different students should have different params!"
    print("✅ Uniqueness verified: different students get different parameters")
