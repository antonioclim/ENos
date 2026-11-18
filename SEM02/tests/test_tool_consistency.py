#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
test_tool_consistency.py - Verify autograder and validator expect same files

This test exists because we once had a nasty bug where the Python autograder
expected Romanian filenames and the Bash validator expected English ones.
Students were confused and frustrated. Never again.

Run with: python3 -m pytest tests/test_tool_consistency.py -v
"""

import unittest
import re
from pathlib import Path


class TestToolConsistency(unittest.TestCase):
    """Ensure autograder and validator are in sync."""
    
    def setUp(self):
        """Find the tool files."""
        self.base_dir = Path(__file__).parent.parent
        self.autograder = self.base_dir / 'scripts' / 'python' / 'S02_01_autograder.py'
        self.validator = self.base_dir / 'scripts' / 'bash' / 'S02_03_validator.sh'
    
    def test_both_tools_exist(self):
        """Both autograder and validator must exist."""
        self.assertTrue(self.autograder.exists(), 
                       f"Autograder not found: {self.autograder}")
        self.assertTrue(self.validator.exists(), 
                       f"Validator not found: {self.validator}")
    
    def test_expected_files_match(self):
        """CRITICAL: Both tools must expect the same filenames."""
        # Extract from autograder (Python dict)
        autograder_content = self.autograder.read_text()
        autograder_match = re.search(
            r'EXPECTED_FILES\s*=\s*\{([^}]+)\}', 
            autograder_content, 
            re.DOTALL
        )
        self.assertIsNotNone(autograder_match, "Could not find EXPECTED_FILES in autograder")
        
        # Parse filenames from the dict
        autograder_files = set(re.findall(r"'(ex\d+_\w+\.sh)'", autograder_match.group(1)))
        
        # Extract from validator (Bash array)
        validator_content = self.validator.read_text()
        validator_match = re.search(
            r'REQUIRED_FILES=\(\s*([^)]+)\)', 
            validator_content, 
            re.DOTALL
        )
        self.assertIsNotNone(validator_match, "Could not find REQUIRED_FILES in validator")
        
        # Parse filenames from the array
        validator_files = set(re.findall(r'"(ex\d+_\w+\.sh)"', validator_match.group(1)))
        
        # The critical check
        self.assertEqual(
            autograder_files, 
            validator_files,
            f"MISMATCH DETECTED!\n"
            f"Autograder expects: {sorted(autograder_files)}\n"
            f"Validator expects:  {sorted(validator_files)}\n"
            f"Only in autograder: {autograder_files - validator_files}\n"
            f"Only in validator:  {validator_files - autograder_files}"
        )
    
    def test_filenames_are_english(self):
        """All expected filenames should be in English."""
        autograder_content = self.autograder.read_text()
        
        # Romanian words that should NOT appear in filenames
        romanian_patterns = [
            r'operatori', r'redirectare', r'filtre', r'bucle', r'integrat',
            r'tema', r'creeaza', r'verificare'
        ]
        
        for pattern in romanian_patterns:
            matches = re.findall(f"'{pattern}", autograder_content, re.IGNORECASE)
            self.assertEqual(
                len(matches), 0,
                f"Found Romanian word '{pattern}' in autograder filenames"
            )
    
    def test_autograder_version_is_current(self):
        """Autograder should be v2.0 or later (when AI penalties were added)."""
        content = self.autograder.read_text()
        
        # Check for version indicator
        has_ai_penalty = 'ai_penalty' in content.lower() or 'apply_ai_penalty' in content
        self.assertTrue(
            has_ai_penalty,
            "Autograder should have AI penalty system (v2.0+)"
        )
    
    def test_five_exercises_expected(self):
        """Both tools should expect exactly 5 exercise files."""
        autograder_content = self.autograder.read_text()
        validator_content = self.validator.read_text()
        
        # Extract just the EXPECTED_FILES section for autograder
        autograder_match = re.search(
            r'EXPECTED_FILES\s*=\s*\{([^}]+)\}', 
            autograder_content, 
            re.DOTALL
        )
        autograder_section = autograder_match.group(1) if autograder_match else ""
        autograder_count = len(re.findall(r"'ex\d+_\w+\.sh'", autograder_section))
        
        # Extract just the REQUIRED_FILES section for validator
        validator_match = re.search(
            r'REQUIRED_FILES=\(\s*([^)]+)\)', 
            validator_content, 
            re.DOTALL
        )
        validator_section = validator_match.group(1) if validator_match else ""
        validator_count = len(re.findall(r'"ex\d+_\w+\.sh"', validator_section))
        
        self.assertEqual(autograder_count, 5, "Autograder should expect 5 exercises")
        self.assertEqual(validator_count, 5, "Validator should expect 5 exercises")


class TestHomeworkNaming(unittest.TestCase):
    """Check homework file naming conventions."""
    
    def setUp(self):
        self.homework_dir = Path(__file__).parent.parent / 'homework'
    
    def test_homework_file_exists(self):
        """S02_01_HOMEWORK.md should exist (not ASSIGNMENT.md)."""
        homework_file = self.homework_dir / 'S02_01_HOMEWORK.md'
        assignment_file = self.homework_dir / 'S02_01_ASSIGNMENT.md'
        
        self.assertTrue(
            homework_file.exists(),
            f"Missing {homework_file} - should be renamed from ASSIGNMENT.md"
        )
        self.assertFalse(
            assignment_file.exists(),
            f"Old file {assignment_file} still exists - should be renamed to HOMEWORK.md"
        )
    
    def test_create_homework_script_header(self):
        """create_homework.sh should not reference old Romanian filename."""
        script = self.homework_dir / 'S02_02_create_homework.sh'
        if script.exists():
            content = script.read_text()
            self.assertNotIn(
                'creeaza_tema',
                content,
                "Script header still references old Romanian filename"
            )


if __name__ == '__main__':
    unittest.main(verbosity=2)
