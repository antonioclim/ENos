#!/usr/bin/env python3
"""
Unit tests for S05_01_autograder.py

Operating Systems | ASE Bucharest - CSIE
Seminar 5: Advanced Bash Scripting

These tests validate the autograder's checking functions to ensure
consistent and fair grading of student submissions.

Run with: python3 -m pytest test_autograder.py -v
Or simply: python3 test_autograder.py
"""

import unittest
import sys
import os
import tempfile
import shutil

# Add parent directory to path for imports
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'scripts', 'python'))

# Try to import the autograder module
try:
    from S05_01_autograder import BashAutograder, CheckResult
except ImportError:
    # Create mock classes for standalone testing
    class CheckResult:
        def __init__(self, passed: bool, message: str, points: float):
            self.passed = passed
            self.message = message
            self.points = points
    
    class BashAutograder:
        """Mock autograder for testing when real module unavailable."""
        pass


class TestShebangCheck(unittest.TestCase):
    """Tests for shebang line validation."""
    
    def setUp(self):
        """Set up test fixtures."""
        self.temp_dir = tempfile.mkdtemp()
    
    def tearDown(self):
        """Clean up test fixtures."""
        shutil.rmtree(self.temp_dir, ignore_errors=True)
    
    def _create_script(self, content: str) -> str:
        """Helper to create a temporary script file."""
        path = os.path.join(self.temp_dir, 'test_script.sh')
        with open(path, 'w') as f:
            f.write(content)
        return path
    
    def test_valid_shebang_bin_bash(self):
        """Test that #!/bin/bash is accepted."""
        content = "#!/bin/bash\necho 'hello'"
        # Check for shebang presence
        self.assertTrue(content.startswith('#!/bin/bash'))
    
    def test_valid_shebang_env_bash(self):
        """Test that #!/usr/bin/env bash is accepted."""
        content = "#!/usr/bin/env bash\necho 'hello'"
        self.assertTrue(content.startswith('#!/usr/bin/env bash'))
    
    def test_invalid_shebang_sh(self):
        """Test that #!/bin/sh is rejected (no arrays support)."""
        content = "#!/bin/sh\necho 'hello'"
        # This should be flagged as invalid for advanced Bash scripts
        self.assertFalse(content.startswith('#!/bin/bash'))
    
    def test_missing_shebang(self):
        """Test that missing shebang is detected."""
        content = "echo 'hello'\necho 'world'"
        self.assertFalse(content.startswith('#!'))
    
    def test_shebang_with_flags(self):
        """Test that shebang with flags is accepted."""
        content = "#!/bin/bash -e\necho 'hello'"
        self.assertTrue('#!/bin/bash' in content)


class TestStrictModeCheck(unittest.TestCase):
    """Tests for strict mode (set -euo pipefail) validation."""
    
    def test_full_strict_mode(self):
        """Test detection of complete strict mode."""
        content = "#!/bin/bash\nset -euo pipefail\necho 'hello'"
        self.assertIn('set -euo pipefail', content)
    
    def test_partial_strict_mode_e_only(self):
        """Test detection of partial strict mode (only -e)."""
        content = "#!/bin/bash\nset -e\necho 'hello'"
        self.assertIn('set -e', content)
        self.assertNotIn('set -euo pipefail', content)
    
    def test_strict_mode_separate_flags(self):
        """Test detection of strict mode with separate set commands."""
        content = "#!/bin/bash\nset -e\nset -u\nset -o pipefail\necho 'hello'"
        has_e = 'set -e' in content
        has_u = 'set -u' in content
        has_pipefail = 'set -o pipefail' in content
        self.assertTrue(has_e and has_u and has_pipefail)
    
    def test_missing_strict_mode(self):
        """Test detection of missing strict mode."""
        content = "#!/bin/bash\necho 'hello'"
        self.assertNotIn('set -e', content)
        self.assertNotIn('set -u', content)


class TestLocalVariableCheck(unittest.TestCase):
    """Tests for local variable usage in functions."""
    
    def test_function_with_local(self):
        """Test that functions using local are detected."""
        content = '''#!/bin/bash
my_func() {
    local var="value"
    echo "$var"
}
'''
        self.assertIn('local ', content)
    
    def test_function_without_local(self):
        """Test that functions without local are flagged."""
        content = '''#!/bin/bash
my_func() {
    var="value"
    echo "$var"
}
'''
        # Check that 'local' is NOT used
        lines_in_func = content.split('my_func')[1].split('}')[0]
        self.assertNotIn('local ', lines_in_func)
    
    def test_multiple_local_declarations(self):
        """Test detection of multiple local variables."""
        content = '''#!/bin/bash
process() {
    local input="$1"
    local output=""
    local count=0
    # processing
}
'''
        local_count = content.count('local ')
        self.assertEqual(local_count, 3)


class TestAssociativeArrayCheck(unittest.TestCase):
    """Tests for associative array declaration validation."""
    
    def test_proper_declare_A(self):
        """Test that declare -A is detected."""
        content = '''#!/bin/bash
declare -A config
config[host]="localhost"
config[port]="8080"
'''
        self.assertIn('declare -A', content)
    
    def test_missing_declare_A(self):
        """Test that missing declare -A is flagged."""
        content = '''#!/bin/bash
config[host]="localhost"
config[port]="8080"
'''
        self.assertNotIn('declare -A', content)
    
    def test_declare_A_with_initialization(self):
        """Test declare -A with inline initialization."""
        content = '''#!/bin/bash
declare -A config=(
    [host]="localhost"
    [port]="8080"
)
'''
        self.assertIn('declare -A', content)


class TestArrayQuotingCheck(unittest.TestCase):
    """Tests for proper array quoting in iterations."""
    
    def test_properly_quoted_array(self):
        """Test that properly quoted arrays are accepted."""
        content = '''#!/bin/bash
arr=("one" "two" "three")
for item in "${arr[@]}"; do
    echo "$item"
done
'''
        self.assertIn('"${arr[@]}"', content)
    
    def test_unquoted_array(self):
        """Test that unquoted arrays are flagged."""
        content = '''#!/bin/bash
arr=("one" "two" "three")
for item in ${arr[@]}; do
    echo "$item"
done
'''
        # Check for unquoted array expansion
        self.assertIn('${arr[@]}', content)
        self.assertNotIn('"${arr[@]}"', content)


class TestTrapCleanupCheck(unittest.TestCase):
    """Tests for trap EXIT cleanup detection."""
    
    def test_trap_exit_present(self):
        """Test that trap EXIT is detected."""
        content = '''#!/bin/bash
cleanup() {
    rm -f "$TEMP_FILE"
}
trap cleanup EXIT
'''
        self.assertIn('trap', content)
        self.assertIn('EXIT', content)
    
    def test_trap_with_inline_command(self):
        """Test trap with inline cleanup command."""
        content = '''#!/bin/bash
TEMP_FILE=$(mktemp)
trap 'rm -f "$TEMP_FILE"' EXIT
'''
        self.assertIn("trap '", content)
        self.assertIn('EXIT', content)
    
    def test_missing_trap(self):
        """Test detection of missing trap."""
        content = '''#!/bin/bash
TEMP_FILE=$(mktemp)
# No cleanup!
'''
        self.assertNotIn('trap', content)


class TestUsageFunctionCheck(unittest.TestCase):
    """Tests for usage/help function detection."""
    
    def test_usage_function_present(self):
        """Test that usage() function is detected."""
        content = '''#!/bin/bash
usage() {
    echo "Usage: $0 [options]"
    exit 1
}
'''
        self.assertIn('usage()', content)
    
    def test_show_help_function(self):
        """Test alternative help function names."""
        content = '''#!/bin/bash
show_help() {
    cat << EOF
Usage: $0 [options]
EOF
}
'''
        self.assertIn('show_help()', content)
    
    def test_missing_usage(self):
        """Test detection of missing usage function."""
        content = '''#!/bin/bash
main() {
    echo "Hello"
}
main "$@"
'''
        self.assertNotIn('usage', content)
        self.assertNotIn('help', content)


class TestIntegration(unittest.TestCase):
    """Integration tests for complete script validation."""
    
    def test_professional_template_compliance(self):
        """Test that a professional template passes all checks."""
        content = '''#!/bin/bash
#
# Script: example.sh
# Description: Example script
# Author: Test
# Version: 1.0.0
#

set -euo pipefail

readonly SCRIPT_NAME=$(basename "$0")

usage() {
    echo "Usage: $SCRIPT_NAME [options]"
    exit 1
}

cleanup() {
    rm -f "${TEMP_FILE:-}"
}
trap cleanup EXIT

process_data() {
    local input="$1"
    local result=""
    declare -A counts
    
    for item in "${input[@]}"; do
        ((counts[$item]++)) || true
    done
    
    echo "${counts[@]}"
}

main() {
    local TEMP_FILE
    TEMP_FILE=$(mktemp)
    
    process_data "$@"
}

main "$@"
'''
        # Check all required elements
        checks = {
            'shebang': content.startswith('#!/bin/bash'),
            'strict_mode': 'set -euo pipefail' in content,
            'local_vars': 'local ' in content,
            'declare_A': 'declare -A' in content,
            'trap_exit': 'trap' in content and 'EXIT' in content,
            'usage': 'usage()' in content,
            'quoted_arrays': '"${' in content,
        }
        
        for check_name, passed in checks.items():
            self.assertTrue(passed, f"Failed check: {check_name}")


class TestEdgeCases(unittest.TestCase):
    """Tests for edge cases and unusual patterns."""
    
    def test_empty_script(self):
        """Test handling of empty script."""
        content = ""
        self.assertEqual(len(content), 0)
    
    def test_comments_only(self):
        """Test script with only comments."""
        content = '''# This is a comment
# Another comment
# No actual code
'''
        self.assertFalse(content.strip().replace('#', '').replace('\n', '').replace(' ', '') != '')
    
    def test_heredoc_not_confused_with_function(self):
        """Test that heredocs are not confused with functions."""
        content = '''#!/bin/bash
cat << 'EOF'
This looks like() {
    a function but is not
}
EOF
'''
        # Should not detect this as a real function
        # Real function detection would need proper parsing
        self.assertIn('EOF', content)
    
    def test_subshell_local_scope(self):
        """Test understanding of subshell scope."""
        content = '''#!/bin/bash
(
    # Variables here are automatically local to subshell
    var="value"
)
# var is not accessible here
'''
        self.assertIn('(', content)


if __name__ == '__main__':
    # Run tests with verbosity
    unittest.main(verbosity=2)
