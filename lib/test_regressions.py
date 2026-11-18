"""Regression checks for logging reconfiguration and reassessment identity."""

import logging
import random
from pathlib import Path

from lib.logging_utils import get_logger, setup_logging
from lib.randomisation_utils import (
    extract_student_id, generate_student_seed, get_student_test_data,
    randomise_test_parameters,
)


def test_logging_reconfiguration_retains_debug_and_selects_new_file(tmp_path):
    name = 'enos.regression.reconfigure'
    setup_logging(name, logging.INFO, use_colours=False)
    destination = tmp_path / 'debug.log'
    logger = setup_logging(name, logging.DEBUG, destination, use_colours=False)
    assert get_logger(name) is logger
    logger.debug('reassessment diagnostic')
    for handler in logger.handlers:
        handler.flush()
    assert 'reassessment diagnostic' in destination.read_text()
    assert logger.level == logging.DEBUG
    assert len(logger.handlers) == 2
    replacement = tmp_path / 'replacement.log'
    setup_logging(name, logging.DEBUG, replacement, use_colours=False).debug('new destination')
    assert 'new destination' in replacement.read_text()
    assert 'new destination' not in destination.read_text()


def test_randomisation_does_not_change_global_random_state():
    before = random.getstate()
    first = randomise_test_parameters(123456)
    assert random.getstate() == before
    assert first == randomise_test_parameters(123456)


def test_reassessment_uses_original_seed_even_with_a_different_week():
    original = get_student_test_data('student123', 3, week='2026-03')
    later = get_student_test_data('student123', 3, seed=original['seed'], week='2026-47')
    assert original == later
    assert generate_student_seed('student123', 'SEM03_HW', week='2026-03') != \
        generate_student_seed('student123', 'SEM03_HW', week='2026-47')


def test_archive_identity_uses_each_filename_and_not_shared_parent(tmp_path):
    for student in ('123', '456'):
        candidate = tmp_path / f'student{student}_assignment.zip'
        assert extract_student_id(str(candidate)) == student
        candidate.write_bytes(b'fixture: identity extraction does not unpack archives')
        assert extract_student_id(str(candidate)) == student
    assert extract_student_id(str(tmp_path / 'unidentified.zip')) is None


def test_invalid_metadata_does_not_crash_identity_extraction(tmp_path):
    submission = tmp_path / 'student123'
    submission.mkdir()
    (submission / 'metadata.json').write_text('[]')
    assert extract_student_id(str(submission)) == '123'
