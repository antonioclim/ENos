"""
ENos Educational Kit — Shared Library

Common utilities for all seminar scripts.

Modules:
    logging_utils: Standardised logging with coloured output
    randomisation_utils: Student-specific test parameter generation (FAZA 5)
"""

from .logging_utils import setup_logging, get_logger, ColouredFormatter
from .randomisation_utils import (
    generate_student_seed,
    randomise_test_parameters,
    get_student_test_data,
    extract_student_id,
    TestParameters
)

__all__ = [
    # Logging
    'setup_logging',
    'get_logger', 
    'ColouredFormatter',
    # Randomisation (FAZA 5)
    'generate_student_seed',
    'randomise_test_parameters',
    'get_student_test_data',
    'extract_student_id',
    'TestParameters',
]
