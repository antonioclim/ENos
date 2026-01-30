#!/usr/bin/env python3
"""
test_randomisation_utils.py — Comprehensive Tests for Student Randomisation

Operating Systems | ASE Bucharest — CSIE
Author: ing. dr. Antonio Clim
Version: 1.0 | January 2025

Tests the deterministic randomisation system used for anti-plagiarism measures.

Run with: pytest -v test_randomisation_utils.py
"""

import random
from dataclasses import fields

import pytest

# Import the module under test
from randomisation_utils import (
    generate_student_seed,
    randomise_test_parameters,
    get_student_test_data,
    TestParameters
)


# =============================================================================
# TestGenerateStudentSeed
# =============================================================================

class TestGenerateStudentSeed:
    """Test suite for deterministic seed generation."""
    
    def test_same_student_same_assignment_produces_same_seed(self):
        """Same student + same assignment should always produce identical seeds."""
        seed1 = generate_student_seed("student123", "SEM03_HW", include_week=False)
        seed2 = generate_student_seed("student123", "SEM03_HW", include_week=False)
        assert seed1 == seed2
    
    def test_different_students_produce_different_seeds(self):
        """Different students should get different seeds."""
        seed1 = generate_student_seed("student123", "SEM03_HW", include_week=False)
        seed2 = generate_student_seed("student456", "SEM03_HW", include_week=False)
        assert seed1 != seed2
    
    def test_different_assignments_produce_different_seeds(self):
        """Same student, different assignments should get different seeds."""
        seed1 = generate_student_seed("student123", "SEM03_HW", include_week=False)
        seed2 = generate_student_seed("student123", "SEM04_HW", include_week=False)
        assert seed1 != seed2
    
    def test_case_insensitivity_for_student_id(self):
        """Student IDs should be normalised to lowercase."""
        seed1 = generate_student_seed("Student123", "SEM03_HW", include_week=False)
        seed2 = generate_student_seed("student123", "SEM03_HW", include_week=False)
        seed3 = generate_student_seed("STUDENT123", "SEM03_HW", include_week=False)
        
        assert seed1 == seed2 == seed3
    
    def test_whitespace_is_stripped_from_student_id(self):
        """Whitespace in student ID should be stripped."""
        seed1 = generate_student_seed("  student123  ", "SEM03_HW", include_week=False)
        seed2 = generate_student_seed("student123", "SEM03_HW", include_week=False)
        seed3 = generate_student_seed("\tstudent123\n", "SEM03_HW", include_week=False)
        
        assert seed1 == seed2 == seed3
    
    def test_returns_positive_integer(self):
        """Seed should be a positive integer."""
        seed = generate_student_seed("test@example.com", "PROJECT_1", include_week=False)
        
        assert isinstance(seed, int)
        assert seed >= 0
    
    def test_seed_is_within_reasonable_range(self):
        """Seed should be within 32-bit integer range (8 hex digits)."""
        seed = generate_student_seed("any_student", "any_assignment", include_week=False)
        
        # 8 hex digits = max 0xFFFFFFFF = 4294967295
        assert seed <= 0xFFFFFFFF
    
    def test_email_format_student_id_works(self):
        """Email-format student IDs should work correctly."""
        seed1 = generate_student_seed("ion.popescu@stud.ase.ro", "SEM01_HW", include_week=False)
        seed2 = generate_student_seed("ion.popescu@stud.ase.ro", "SEM01_HW", include_week=False)
        
        assert seed1 == seed2
        assert isinstance(seed1, int)
    
    def test_matriculation_number_student_id_works(self):
        """Numeric matriculation numbers should work correctly."""
        seed1 = generate_student_seed("12345678", "SEM02_HW", include_week=False)
        seed2 = generate_student_seed("12345678", "SEM02_HW", include_week=False)
        
        assert seed1 == seed2
    
    def test_include_week_true_varies_by_week(self):
        """When include_week=True, seeds may vary by calendar week."""
        # Note: This test is somewhat fragile as it depends on current date
        # We mainly verify that the parameter is accepted
        seed = generate_student_seed("student", "SEM01", include_week=True)
        assert isinstance(seed, int)
    
    def test_empty_student_id_still_produces_seed(self):
        """Empty student ID should still produce a valid (though inadvisable) seed."""
        seed = generate_student_seed("", "SEM01_HW", include_week=False)
        assert isinstance(seed, int)
    
    def test_special_characters_in_assignment_name(self):
        """Special characters in assignment name should be handled."""
        seed = generate_student_seed("student", "PROJECT_ÄÖÜ/v2", include_week=False)
        assert isinstance(seed, int)


# =============================================================================
# TestRandomiseTestParameters
# =============================================================================

class TestRandomiseTestParameters:
    """Test suite for parameter randomisation."""
    
    def test_returns_test_parameters_instance(self):
        """Should return a TestParameters dataclass instance."""
        params = randomise_test_parameters(12345)
        assert isinstance(params, TestParameters)
    
    def test_same_seed_produces_identical_parameters(self):
        """Same seed should always produce identical parameter sets."""
        params1 = randomise_test_parameters(12345)
        params2 = randomise_test_parameters(12345)
        
        assert params1.ip_addresses == params2.ip_addresses
        assert params1.ports == params2.ports
        assert params1.file_names == params2.file_names
        assert params1.file_sizes == params2.file_sizes
        assert params1.permissions_octal == params2.permissions_octal
        assert params1.usernames == params2.usernames
        assert params1.random_strings == params2.random_strings
    
    def test_different_seeds_produce_different_parameters(self):
        """Different seeds should produce different parameter sets."""
        params1 = randomise_test_parameters(12345)
        params2 = randomise_test_parameters(54321)
        
        # At least some fields should differ
        differences = 0
        if params1.ip_addresses != params2.ip_addresses:
            differences += 1
        if params1.ports != params2.ports:
            differences += 1
        if params1.file_names != params2.file_names:
            differences += 1
        if params1.random_numbers != params2.random_numbers:
            differences += 1
        
        assert differences >= 2, "At least 2 fields should differ between different seeds"
    
    def test_seed_stored_in_parameters(self):
        """The seed should be stored in the returned parameters."""
        params = randomise_test_parameters(99999)
        assert params.seed == 99999
    
    def test_student_id_stored_in_parameters(self):
        """Student ID should be stored when provided."""
        params = randomise_test_parameters(12345, student_id="test_student")
        assert params.student_id == "test_student"
    
    def test_assignment_stored_in_parameters(self):
        """Assignment name should be stored when provided."""
        params = randomise_test_parameters(12345, assignment="SEM03_HW")
        assert params.assignment == "SEM03_HW"


# =============================================================================
# TestParameterRanges
# =============================================================================

class TestParameterRanges:
    """Test that generated parameters are within valid ranges."""
    
    @pytest.fixture
    def params(self):
        """Provide a standard set of parameters for range testing."""
        return randomise_test_parameters(42424242)
    
    def test_ip_addresses_are_valid_private_range(self, params):
        """IP addresses should be in 10.x.x.x private range."""
        for ip in params.ip_addresses:
            parts = ip.split('.')
            assert len(parts) == 4, f"IP should have 4 octets: {ip}"
            assert parts[0] == '10', f"IP should start with 10: {ip}"
            
            for part in parts:
                val = int(part)
                assert 0 <= val <= 255, f"Octet out of range: {part} in {ip}"
    
    def test_ports_are_in_non_privileged_range(self, params):
        """Ports should be in non-privileged range (1024-65535)."""
        for port in params.ports:
            assert 1024 <= port <= 65535, f"Port out of range: {port}"
    
    def test_file_sizes_are_positive(self, params):
        """File sizes should be positive integers."""
        for size in params.file_sizes:
            assert size > 0, f"File size should be positive: {size}"
            assert size <= 10485760, f"File size exceeds 10MB: {size}"
    
    def test_file_names_have_valid_format(self, params):
        """File names should have prefix_number.extension format."""
        for name in params.file_names:
            assert '_' in name, f"File name should contain underscore: {name}"
            assert '.' in name, f"File name should have extension: {name}"
    
    def test_permissions_are_valid_octal(self, params):
        """Permissions should be valid octal strings."""
        valid_digits = set('01234567')
        
        for perm in params.permissions_octal:
            assert len(perm) == 3 or len(perm) == 4, f"Permission should be 3-4 digits: {perm}"
            assert all(c in valid_digits for c in perm), f"Invalid octal digit in: {perm}"
    
    def test_cron_hours_are_valid(self, params):
        """Cron hours should be 0-23."""
        for hour in params.cron_hours:
            assert 0 <= hour <= 23, f"Hour out of range: {hour}"
    
    def test_cron_days_are_valid(self, params):
        """Cron days should be 1-28 (safe range)."""
        for day in params.cron_days:
            assert 1 <= day <= 28, f"Day out of range: {day}"
    
    def test_pids_are_valid(self, params):
        """PIDs should be in reasonable range."""
        for pid in params.pids:
            assert 1000 <= pid <= 65535, f"PID out of range: {pid}"
    
    def test_signals_are_common_unix_signals(self, params):
        """Signals should be common Unix signal numbers."""
        valid_signals = {1, 2, 3, 9, 15, 18, 19, 20}  # HUP, INT, QUIT, KILL, TERM, CONT, STOP, TSTP
        
        for sig in params.signals:
            assert sig in valid_signals, f"Uncommon signal: {sig}"
    
    def test_usernames_have_valid_format(self, params):
        """Usernames should follow user### pattern."""
        for username in params.usernames:
            assert username.startswith('user'), f"Username should start with 'user': {username}"
            number_part = username[4:]
            assert number_part.isdigit(), f"Username should end with digits: {username}"
    
    def test_line_numbers_are_positive(self, params):
        """Line numbers should be positive."""
        for line in params.line_numbers:
            assert line >= 1, f"Line number should be >= 1: {line}"
    
    def test_random_strings_are_alphanumeric(self, params):
        """Random strings should be lowercase alphanumeric."""
        valid_chars = set('abcdefghijklmnopqrstuvwxyz0123456789')
        
        for s in params.random_strings:
            assert len(s) >= 6, f"String too short: {s}"
            assert len(s) <= 12, f"String too long: {s}"
            assert all(c in valid_chars for c in s), f"Invalid characters in: {s}"


# =============================================================================
# TestParameterCounts
# =============================================================================

class TestParameterCounts:
    """Test that parameter lists have expected lengths."""
    
    @pytest.fixture
    def params(self):
        return randomise_test_parameters(11111)
    
    def test_ip_addresses_count(self, params):
        assert len(params.ip_addresses) == 10
    
    def test_ports_count(self, params):
        assert len(params.ports) == 10
    
    def test_file_sizes_count(self, params):
        assert len(params.file_sizes) == 15
    
    def test_file_names_count(self, params):
        assert len(params.file_names) == 10
    
    def test_directory_names_count(self, params):
        assert len(params.directory_names) == 10
    
    def test_timestamps_count(self, params):
        assert len(params.timestamps) == 10
    
    def test_cron_hours_count(self, params):
        assert len(params.cron_hours) == 5
    
    def test_cron_days_count(self, params):
        assert len(params.cron_days) == 5
    
    def test_pids_count(self, params):
        assert len(params.pids) == 10
    
    def test_signals_count(self, params):
        assert len(params.signals) == 5
    
    def test_usernames_count(self, params):
        assert len(params.usernames) == 5
    
    def test_permissions_count(self, params):
        assert len(params.permissions_octal) == 5
    
    def test_search_patterns_count(self, params):
        assert len(params.search_patterns) == 5
    
    def test_line_numbers_count(self, params):
        assert len(params.line_numbers) == 10
    
    def test_random_strings_count(self, params):
        assert len(params.random_strings) == 10
    
    def test_random_numbers_count(self, params):
        assert len(params.random_numbers) == 20


# =============================================================================
# TestGetStudentTestData
# =============================================================================

class TestGetStudentTestData:
    """Test the convenience function for seminar-specific data."""
    
    def test_returns_dictionary(self):
        """Should return a dictionary."""
        data = get_student_test_data("test_student", 1)
        assert isinstance(data, dict)
    
    def test_contains_required_keys(self):
        """Dictionary should contain all required keys."""
        data = get_student_test_data("test_student", 3)
        
        required_keys = [
            'seed', 'student_id', 'ip_addresses', 'ports',
            'file_sizes', 'file_names', 'directory_names',
            'timestamps', 'pids'
        ]
        
        for key in required_keys:
            assert key in data, f"Missing key: {key}"
    
    def test_same_student_same_seminar_produces_same_data(self):
        """Same student + seminar should produce identical data."""
        data1 = get_student_test_data("consistent_student", 4)
        data2 = get_student_test_data("consistent_student", 4)
        
        assert data1['seed'] == data2['seed']
        assert data1['ip_addresses'] == data2['ip_addresses']
    
    def test_different_seminars_produce_different_data(self):
        """Different seminars should produce different data."""
        data1 = get_student_test_data("student", 1)
        data2 = get_student_test_data("student", 2)
        
        assert data1['seed'] != data2['seed']
    
    def test_seminar_numbers_1_through_7(self):
        """All seminar numbers 1-7 should work."""
        for sem in range(1, 8):
            data = get_student_test_data("test", sem)
            assert isinstance(data, dict)
            assert 'seed' in data


# =============================================================================
# Integration Tests
# =============================================================================

class TestIntegration:
    """Integration tests for complete randomisation workflow."""
    
    def test_complete_anti_plagiarism_workflow(self):
        """Test full workflow: student ID → seed → parameters."""
        # Simulate two students
        student_a = "maria.ionescu@stud.ase.ro"
        student_b = "andrei.popescu@stud.ase.ro"
        assignment = "SEM04_HW"
        
        # Generate seeds
        seed_a = generate_student_seed(student_a, assignment, include_week=False)
        seed_b = generate_student_seed(student_b, assignment, include_week=False)
        
        # Seeds should differ
        assert seed_a != seed_b
        
        # Generate parameters
        params_a = randomise_test_parameters(seed_a, student_a, assignment)
        params_b = randomise_test_parameters(seed_b, student_b, assignment)
        
        # Parameters should differ
        assert params_a.ip_addresses != params_b.ip_addresses
        assert params_a.file_names != params_b.file_names
        
        # But same student should get same parameters
        seed_a2 = generate_student_seed(student_a, assignment, include_week=False)
        params_a2 = randomise_test_parameters(seed_a2, student_a, assignment)
        
        assert params_a.ip_addresses == params_a2.ip_addresses
        assert params_a.file_names == params_a2.file_names
    
    def test_determinism_across_runs(self):
        """Verify determinism is maintained across multiple runs."""
        # Run the same generation 100 times
        expected_params = randomise_test_parameters(9999)
        
        for _ in range(100):
            params = randomise_test_parameters(9999)
            assert params.ip_addresses == expected_params.ip_addresses
            assert params.ports == expected_params.ports
            assert params.random_numbers == expected_params.random_numbers


# =============================================================================
# Entry Point
# =============================================================================

if __name__ == '__main__':
    pytest.main([__file__, '-v', '--tb=short'])
