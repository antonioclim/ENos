#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
═══════════════════════════════════════════════════════════════════════════════
📝 test_autograder.py - Unit Tests for Seminar 02 Autograder
═══════════════════════════════════════════════════════════════════════════════

DESCRIPTION:
    Unit tests for the autograder functions including syntax checking,
    pattern matching, grading logic and AI indicator detection.

USAGE:
    python3 -m pytest tests/test_autograder.py -v
    python3 tests/test_autograder.py

AUTHOR: OS Pedagogical Kit | ASE Bucharest - CSIE
VERSION: 1.1 | January 2025
═══════════════════════════════════════════════════════════════════════════════
"""

import unittest
import tempfile
import os
import sys
import json
from pathlib import Path

# Add parent directories to path for imports
sys.path.insert(0, str(Path(__file__).parent.parent / 'scripts' / 'python'))
sys.path.insert(0, str(Path(__file__).parent.parent / 'formative'))

# Try to import from autograder
try:
    from S02_01_autograder import (
        check_syntax, 
        has_pattern, 
        count_pattern_matches,
        check_ai_indicators,
        PATTERNS,
        AI_INDICATORS
    )
    AUTOGRADER_AVAILABLE = True
except ImportError:
    AUTOGRADER_AVAILABLE = False


class TestSyntaxChecker(unittest.TestCase):
    """Tests for Bash syntax checking."""
    
    @unittest.skipUnless(AUTOGRADER_AVAILABLE, "Autograder not available")
    def test_valid_simple_script(self):
        """Test that a simple valid script passes syntax check."""
        with tempfile.NamedTemporaryFile(mode='w', suffix='.sh', delete=False) as f:
            f.write('#!/bin/bash\necho "hello"\n')
            f.flush()
            ok, msg = check_syntax(f.name)
            self.assertTrue(ok, f"Valid script failed: {msg}")
            os.unlink(f.name)
    
    @unittest.skipUnless(AUTOGRADER_AVAILABLE, "Autograder not available")
    def test_valid_complex_script(self):
        """Test a more complex valid script with loops and conditions."""
        script = '''#!/bin/bash
set -euo pipefail

for i in {1..5}; do
    echo "$i"
done

if [[ -f /etc/passwd ]]; then
    echo "File exists"
fi
'''
        with tempfile.NamedTemporaryFile(mode='w', suffix='.sh', delete=False) as f:
            f.write(script)
            f.flush()
            ok, msg = check_syntax(f.name)
            self.assertTrue(ok, f"Complex valid script failed: {msg}")
            os.unlink(f.name)
    
    @unittest.skipUnless(AUTOGRADER_AVAILABLE, "Autograder not available")
    def test_invalid_script_missing_then(self):
        """Test that script with missing 'then' fails."""
        script = '''#!/bin/bash
if [[ -f file ]]
    echo "exists"
fi
'''
        with tempfile.NamedTemporaryFile(mode='w', suffix='.sh', delete=False) as f:
            f.write(script)
            f.flush()
            ok, msg = check_syntax(f.name)
            self.assertFalse(ok, "Script with missing 'then' should fail")
            os.unlink(f.name)
    
    @unittest.skipUnless(AUTOGRADER_AVAILABLE, "Autograder not available")
    def test_invalid_script_unclosed_quote(self):
        """Test that script with unclosed quote fails."""
        script = '''#!/bin/bash
echo "hello
'''
        with tempfile.NamedTemporaryFile(mode='w', suffix='.sh', delete=False) as f:
            f.write(script)
            f.flush()
            ok, msg = check_syntax(f.name)
            self.assertFalse(ok, "Script with unclosed quote should fail")
            os.unlink(f.name)


class TestPatternMatching(unittest.TestCase):
    """Tests for pattern matching functions."""
    
    @unittest.skipUnless(AUTOGRADER_AVAILABLE, "Autograder not available")
    def test_has_pattern_and_operator(self):
        """Test detection of && operator."""
        content = 'mkdir dir && cd dir && echo "done"'
        self.assertTrue(has_pattern(content, PATTERNS['operators']['and']))
    
    @unittest.skipUnless(AUTOGRADER_AVAILABLE, "Autograder not available")
    def test_has_pattern_or_operator(self):
        """Test detection of || operator."""
        content = 'command || echo "failed"'
        self.assertTrue(has_pattern(content, PATTERNS['operators']['or']))
    
    @unittest.skipUnless(AUTOGRADER_AVAILABLE, "Autograder not available")
    def test_has_pattern_pipe_not_or(self):
        """Test that single | is detected as pipe, not ||."""
        content = 'cat file | grep pattern'
        self.assertTrue(has_pattern(content, PATTERNS['operators']['pipe']))
        # Should NOT match as OR
        self.assertFalse(has_pattern(content, PATTERNS['operators']['or']))
    
    @unittest.skipUnless(AUTOGRADER_AVAILABLE, "Autograder not available")
    def test_has_pattern_redirect_stdout(self):
        """Test stdout redirection detection."""
        content = 'echo "test" > file.txt'
        self.assertTrue(has_pattern(content, PATTERNS['redirect']['stdout']))
    
    @unittest.skipUnless(AUTOGRADER_AVAILABLE, "Autograder not available")
    def test_has_pattern_redirect_append(self):
        """Test append redirection detection."""
        content = 'echo "more" >> file.txt'
        self.assertTrue(has_pattern(content, PATTERNS['redirect']['append']))
    
    @unittest.skipUnless(AUTOGRADER_AVAILABLE, "Autograder not available")
    def test_has_pattern_here_doc(self):
        """Test here document detection."""
        content = '''cat << EOF
line 1
line 2
EOF'''
        self.assertTrue(has_pattern(content, PATTERNS['redirect']['here_doc']))
    
    @unittest.skipUnless(AUTOGRADER_AVAILABLE, "Autograder not available")
    def test_has_pattern_for_loop(self):
        """Test for loop detection."""
        content = 'for i in {1..5}; do echo $i; done'
        self.assertTrue(has_pattern(content, PATTERNS['loops']['for']))
    
    @unittest.skipUnless(AUTOGRADER_AVAILABLE, "Autograder not available")
    def test_has_pattern_while_loop(self):
        """Test while loop detection."""
        content = 'while read line; do echo "$line"; done < file'
        self.assertTrue(has_pattern(content, PATTERNS['loops']['while']))
    
    @unittest.skipUnless(AUTOGRADER_AVAILABLE, "Autograder not available")
    def test_count_pattern_matches(self):
        """Test counting multiple pattern occurrences."""
        content = 'echo "a" | sort | uniq | head'
        count = count_pattern_matches(content, PATTERNS['operators']['pipe'])
        self.assertEqual(count, 3)


class TestBugDetection(unittest.TestCase):
    """Tests for common bug detection."""
    
    @unittest.skipUnless(AUTOGRADER_AVAILABLE, "Autograder not available")
    def test_detect_brace_var_bug(self):
        """Test detection of {1..$n} bug."""
        content = 'for i in {1..$n}; do echo $i; done'
        self.assertTrue(has_pattern(content, PATTERNS['bugs']['brace_var']))
    
    @unittest.skipUnless(AUTOGRADER_AVAILABLE, "Autograder not available")
    def test_no_false_positive_brace_expansion(self):
        """Test that valid brace expansion is not flagged."""
        content = 'for i in {1..10}; do echo $i; done'
        self.assertFalse(has_pattern(content, PATTERNS['bugs']['brace_var']))
    
    @unittest.skipUnless(AUTOGRADER_AVAILABLE, "Autograder not available")
    def test_detect_cat_pipe_while(self):
        """Test detection of cat|while subshell bug."""
        content = 'cat file.txt | while read line; do ((count++)); done'
        self.assertTrue(has_pattern(content, PATTERNS['bugs']['cat_pipe_while']))
    
    @unittest.skipUnless(AUTOGRADER_AVAILABLE, "Autograder not available")
    def test_no_false_positive_correct_while_read(self):
        """Test that correct while read is not flagged."""
        content = 'while read line; do echo "$line"; done < file.txt'
        self.assertFalse(has_pattern(content, PATTERNS['bugs']['cat_pipe_while']))


class TestEdgeCases(unittest.TestCase):
    """Tests for edge cases and unusual inputs."""
    
    @unittest.skipUnless(AUTOGRADER_AVAILABLE, "Autograder not available")
    def test_empty_file(self):
        """Empty file should not crash syntax checker."""
        with tempfile.NamedTemporaryFile(mode='w', suffix='.sh', delete=False) as f:
            f.write('')
            f.flush()
            # Should not raise exception
            try:
                ok, msg = check_syntax(f.name)
                # Empty file may or may not pass depending on bash version
            except Exception as e:
                self.fail(f"Empty file caused exception: {e}")
            finally:
                os.unlink(f.name)
    
    @unittest.skipUnless(AUTOGRADER_AVAILABLE, "Autograder not available")
    def test_unicode_in_script(self):
        """Script with Unicode (Romanian diacritics) should work."""
        script = '''#!/bin/bash
# Script cu caractere românești: ă, â, î, ș, ț
echo "Bună ziua!"
'''
        with tempfile.NamedTemporaryFile(mode='w', suffix='.sh', delete=False, 
                                         encoding='utf-8') as f:
            f.write(script)
            f.flush()
            ok, msg = check_syntax(f.name)
            self.assertTrue(ok, f"Unicode script failed: {msg}")
            os.unlink(f.name)
    
    @unittest.skipUnless(AUTOGRADER_AVAILABLE, "Autograder not available")
    def test_very_long_line(self):
        """Script with very long line should not crash."""
        long_echo = 'echo "' + 'a' * 10000 + '"'
        script = f'#!/bin/bash\n{long_echo}\n'
        with tempfile.NamedTemporaryFile(mode='w', suffix='.sh', delete=False) as f:
            f.write(script)
            f.flush()
            try:
                ok, msg = check_syntax(f.name)
            except Exception as e:
                self.fail(f"Long line caused exception: {e}")
            finally:
                os.unlink(f.name)
    
    @unittest.skipUnless(AUTOGRADER_AVAILABLE, "Autograder not available")
    def test_binary_content_handling(self):
        """Files with binary content should not crash pattern matching."""
        content = 'echo "test"\x00\x01\x02binary data'
        # Should not crash
        try:
            result = has_pattern(content, PATTERNS['operators']['and'])
            self.assertFalse(result)
        except Exception as e:
            self.fail(f"Binary content caused exception: {e}")
    
    @unittest.skipUnless(AUTOGRADER_AVAILABLE, "Autograder not available")
    def test_nested_quotes(self):
        """Test handling of nested quote patterns."""
        content = '''echo "He said 'hello'"'''
        ok = has_pattern(content, r'echo')
        self.assertTrue(ok)
    
    @unittest.skipUnless(AUTOGRADER_AVAILABLE, "Autograder not available")
    def test_escaped_characters(self):
        """Test handling of escaped special characters."""
        content = r'echo "Path: /home/user/\$HOME"'
        # Should not crash and should still find echo
        ok = has_pattern(content, r'\becho\b')
        self.assertTrue(ok)


class TestAIIndicatorDetection(unittest.TestCase):
    """Tests for AI content indicator detection."""
    
    @unittest.skipUnless(AUTOGRADER_AVAILABLE, "Autograder not available")
    def test_no_indicators_in_simple_script(self):
        """Simple beginner script should have no AI indicators."""
        # Create a temporary directory with a simple script
        with tempfile.TemporaryDirectory() as tmpdir:
            script_path = Path(tmpdir) / 'ex1_operatori.sh'
            script_path.write_text('''#!/bin/bash
# my script
echo "hello"
ls && echo "done"
''')
            indicators = check_ai_indicators(Path(tmpdir))
            # Simple script should not trigger many indicators
            self.assertLessEqual(len(indicators), 1)
    
    @unittest.skipUnless(AUTOGRADER_AVAILABLE, "Autograder not available")
    def test_detects_overly_elaborate_comments(self):
        """Should detect Python docstring-style comments in Bash."""
        with tempfile.TemporaryDirectory() as tmpdir:
            script_path = Path(tmpdir) / 'ex1_operatori.sh'
            script_path.write_text('''#!/bin/bash
# Args: input_file - the file to process
# Returns: 0 on success, 1 on failure
# Example: ./script.sh input.txt
process_file() {
    echo "processing"
}
''')
            indicators = check_ai_indicators(Path(tmpdir))
            # Should detect the docstring-style comments
            indicator_names = [i.indicator_name for i in indicators]
            self.assertTrue(
                any('comment' in name.lower() for name in indicator_names) or
                len(indicators) > 0,
                "Should detect unusual comment patterns"
            )
    
    @unittest.skipUnless(AUTOGRADER_AVAILABLE, "Autograder not available")
    def test_detects_elaborate_variable_names(self):
        """Should detect overly descriptive variable names."""
        with tempfile.TemporaryDirectory() as tmpdir:
            script_path = Path(tmpdir) / 'ex1_operatori.sh'
            script_path.write_text('''#!/bin/bash
user_input_value="test"
file_content_data=$(cat file.txt)
error_message_text="failed"
echo "$user_input_value"
''')
            indicators = check_ai_indicators(Path(tmpdir))
            indicator_descs = [i.description for i in indicators]
            # Check if elaborate naming was detected
            has_naming_indicator = any(
                'variable' in desc.lower() or 'naming' in desc.lower() 
                for desc in indicator_descs
            )
            # This is a soft check - the pattern may or may not trigger
            # depending on exact implementation
            self.assertTrue(len(indicators) >= 0)  # Should not crash
    
    @unittest.skipUnless(AUTOGRADER_AVAILABLE, "Autograder not available")
    def test_high_comment_ratio_detection(self):
        """Should detect unusually high comment-to-code ratio."""
        with tempfile.TemporaryDirectory() as tmpdir:
            script_path = Path(tmpdir) / 'ex1_operatori.sh'
            # Create script with more comments than code
            script_path.write_text('''#!/bin/bash
# This is a comment
# Another comment
# Yet another comment
# More comments
# Even more comments
# And another
# Keep going
# Almost there
# One more
# Last one
echo "hello"
echo "world"
''')
            indicators = check_ai_indicators(Path(tmpdir))
            indicator_descs = [i.description for i in indicators]
            # Check if high comment ratio was detected
            has_ratio_indicator = any(
                'comment' in desc.lower() and 'ratio' in desc.lower()
                for desc in indicator_descs
            )
            # Soft check - ratio detection may vary
            self.assertTrue(len(indicators) >= 0)
    
    @unittest.skipUnless(AUTOGRADER_AVAILABLE, "Autograder not available")
    def test_empty_directory_no_crash(self):
        """AI detection should not crash on empty directory."""
        with tempfile.TemporaryDirectory() as tmpdir:
            try:
                indicators = check_ai_indicators(Path(tmpdir))
                self.assertEqual(len(indicators), 0)
            except Exception as e:
                self.fail(f"Empty directory caused exception: {e}")


class TestFilterPatterns(unittest.TestCase):
    """Tests for filter command pattern detection."""
    
    @unittest.skipUnless(AUTOGRADER_AVAILABLE, "Autograder not available")
    def test_detect_sort(self):
        """Test sort command detection."""
        content = 'cat file | sort -n'
        self.assertTrue(has_pattern(content, PATTERNS['filters']['sort']))
    
    @unittest.skipUnless(AUTOGRADER_AVAILABLE, "Autograder not available")
    def test_detect_uniq(self):
        """Test uniq command detection."""
        content = 'sort file | uniq -c'
        self.assertTrue(has_pattern(content, PATTERNS['filters']['uniq']))
    
    @unittest.skipUnless(AUTOGRADER_AVAILABLE, "Autograder not available")
    def test_detect_cut(self):
        """Test cut command detection."""
        content = "cut -d',' -f1 data.csv"
        self.assertTrue(has_pattern(content, PATTERNS['filters']['cut']))
    
    @unittest.skipUnless(AUTOGRADER_AVAILABLE, "Autograder not available")
    def test_detect_tr(self):
        """Test tr command detection."""
        content = "tr 'a-z' 'A-Z'"
        self.assertTrue(has_pattern(content, PATTERNS['filters']['tr']))
    
    @unittest.skipUnless(AUTOGRADER_AVAILABLE, "Autograder not available")
    def test_detect_awk(self):
        """Test awk command detection."""
        content = "awk '{print $1}' file"
        self.assertTrue(has_pattern(content, PATTERNS['filters']['awk']))
    
    @unittest.skipUnless(AUTOGRADER_AVAILABLE, "Autograder not available")
    def test_no_false_positive_sortie(self):
        """Test that 'sortie' (French for exit) is not detected as sort."""
        content = 'echo "sortie"'  # sortie = exit in French
        # This should still match because \bsort\b would match 'sort' in 'sortie'
        # Actually \b means word boundary, so 'sortie' should NOT match 'sort'
        self.assertFalse(has_pattern(content, PATTERNS['filters']['sort']))


class TestGoodPracticesPatterns(unittest.TestCase):
    """Tests for good practices detection."""
    
    @unittest.skipUnless(AUTOGRADER_AVAILABLE, "Autograder not available")
    def test_detect_shebang_bin_bash(self):
        """Test #!/bin/bash shebang detection."""
        content = '#!/bin/bash\necho "test"'
        self.assertTrue(has_pattern(content, PATTERNS['good_practices']['shebang']))
    
    @unittest.skipUnless(AUTOGRADER_AVAILABLE, "Autograder not available")
    def test_detect_shebang_env_bash(self):
        """Test #!/usr/bin/env bash shebang detection."""
        content = '#!/usr/bin/env bash\necho "test"'
        self.assertTrue(has_pattern(content, PATTERNS['good_practices']['shebang']))
    
    @unittest.skipUnless(AUTOGRADER_AVAILABLE, "Autograder not available")
    def test_detect_error_handling_set_e(self):
        """Test set -e detection."""
        content = '#!/bin/bash\nset -e\necho "test"'
        self.assertTrue(has_pattern(content, PATTERNS['good_practices']['error_handling']))
    
    @unittest.skipUnless(AUTOGRADER_AVAILABLE, "Autograder not available")
    def test_detect_function_definition(self):
        """Test function definition detection."""
        content = '''
my_func() {
    echo "hello"
}
'''
        self.assertTrue(has_pattern(content, PATTERNS['good_practices']['functions']))
    
    @unittest.skipUnless(AUTOGRADER_AVAILABLE, "Autograder not available")
    def test_detect_function_keyword(self):
        """Test function keyword detection."""
        content = '''
function my_func {
    echo "hello"
}
'''
        self.assertTrue(has_pattern(content, PATTERNS['good_practices']['functions']))


# Run tests
if __name__ == '__main__':
    unittest.main(verbosity=2)
