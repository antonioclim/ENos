#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
═══════════════════════════════════════════════════════════════════════════════
S03_01_autograder.py - Automated Grading System for Seminar 3
═══════════════════════════════════════════════════════════════════════════════
Operating Systems | Bucharest UES - CSIE

DESCRIPTION:
    Automated grader for Seminar 03 assignments that verifies:
    - find and xargs commands
    - Scripts with parameters and getopts
    - Permission settings (chmod, chown, umask)
    - Cron configurations
    
FEATURES:
    - Automated bash script evaluation
    - Syntax and functionality verification
    - Parameter and option testing
    - Permission and security validation
    - Cron expression verification
    - Detailed report generation
    - Formative feedback for students
    
USAGE:
    python3 S03_01_autograder.py --submission <directory>
    python3 S03_01_autograder.py --submission <directory> --verbose
    python3 S03_01_autograder.py --batch <class_directory>
    python3 S03_01_autograder.py --test-find <commands_file>
    python3 S03_01_autograder.py --test-cron <crontab_file>

AUTHOR: OS Team | VERSION: 1.0 | DATE: 2025
═══════════════════════════════════════════════════════════════════════════════
"""

import logging
import os
import sys
import re
import json
import subprocess
import tempfile
import shutil
import argparse
from datetime import datetime
from pathlib import Path
from dataclasses import dataclass, field, asdict
from typing import List, Dict, Optional, Tuple, Any
from enum import Enum
import traceback

# Logging setup — import shared utilities from kit lib
sys.path.insert(0, str(Path(__file__).parent.parent.parent.parent / 'lib'))
from logging_utils import setup_logging

logger = setup_logging(__name__)

# 
# TERMINAL COLOUR CONFIGURATION
# 

class Colours:
    """ANSI codes for terminal colours"""
    RED = '\033[0;31m'
    GREEN = '\033[0;32m'
    YELLOW = '\033[1;33m'
    BLUE = '\033[0;34m'
    MAGENTA = '\033[0;35m'
    CYAN = '\033[0;36m'
    WHITE = '\033[1;37m'
    GRAY = '\033[0;90m'
    BOLD = '\033[1m'
    DIM = '\033[2m'
    RESET = '\033[0m'
    
    @classmethod
    def disable(cls):
        """Disable colours (for non-terminal output)"""
        for attr in dir(cls):
            if not attr.startswith('_') and attr.isupper():
                setattr(cls, attr, '')

# Automatic detection if terminal supports colours
if not sys.stdout.isatty():
    Colours.disable()

# 
# DATA MODELS
# 

class TestStatus(Enum):
    """Possible statuses for a test"""
    PASSED = "passed"
    FAILED = "failed"
    PARTIAL = "partial"
    ERROR = "error"
    SKIPPED = "skipped"

@dataclass
class TestResult:
    """Result of an individual test"""
    name: str
    status: TestStatus
    points_earned: float
    points_max: float
    message: str
    details: List[str] = field(default_factory=list)
    suggestions: List[str] = field(default_factory=list)
    
    @property
    def percentage(self) -> float:
        if self.points_max == 0:
            return 100.0
        return (self.points_earned / self.points_max) * 100

@dataclass
class CategoryResult:
    """Result of a test category"""
    name: str
    tests: List[TestResult] = field(default_factory=list)
    
    @property
    def total_earned(self) -> float:
        return sum(t.points_earned for t in self.tests)
    
    @property
    def total_max(self) -> float:
        return sum(t.points_max for t in self.tests)
    
    @property
    def percentage(self) -> float:
        if self.total_max == 0:
            return 100.0
        return (self.total_earned / self.total_max) * 100
    
    @property
    def passed_count(self) -> int:
        return sum(1 for t in self.tests if t.status == TestStatus.PASSED)

@dataclass
class GradingResult:
    """Complete grading result"""
    student_id: str
    submission_path: str
    timestamp: str
    categories: List[CategoryResult] = field(default_factory=list)
    warnings: List[str] = field(default_factory=list)
    security_issues: List[str] = field(default_factory=list)
    
    @property
    def total_earned(self) -> float:
        return sum(c.total_earned for c in self.categories)
    
    @property
    def total_max(self) -> float:
        return sum(c.total_max for c in self.categories)
    
    @property
    def percentage(self) -> float:
        if self.total_max == 0:
            return 100.0
        return (self.total_earned / self.total_max) * 100
    
    @property
    def grade(self) -> str:
        """Calculate final grade"""
        p = self.percentage
        if p >= 90:
            return "10"
        elif p >= 80:
            return "9"
        elif p >= 70:
            return "8"
        elif p >= 60:
            return "7"
        elif p >= 50:
            return "6"
        elif p >= 40:
            return "5"
        else:
            return "4"

# 
# SPECIFIC VALIDATORS
# 

class BashValidator:
    """Bash script validation"""
    
    @staticmethod
    def check_syntax(script_path: str) -> Tuple[bool, str]:
        """Check the syntax of a bash script"""
        try:
            result = subprocess.run(
                ['bash', '-n', script_path],
                capture_output=True,
                text=True,
                timeout=10
            )
            if result.returncode == 0:
                return True, "Correct syntax"
            else:
                return False, result.stderr.strip()
        except subprocess.TimeoutExpired:
            return False, "Timeout during syntax check"
        except Exception as e:
            return False, f"Error: {str(e)}"
    
    @staticmethod
    def check_shebang(script_path: str) -> Tuple[bool, str]:
        """Check for shebang presence"""
        try:
            with open(script_path, 'r') as f:
                first_line = f.readline().strip()
            
            if first_line.startswith('#!'):
                if 'bash' in first_line:
                    return True, f"Correct shebang: {first_line}"
                elif 'sh' in first_line:
                    return True, f"POSIX shebang: {first_line} (consider #!/bin/bash)"
                else:
                    return False, f"Unusual shebang: {first_line}"
            else:
                return False, "Missing shebang (#!/bin/bash)"
        except Exception as e:
            return False, f"Read error: {str(e)}"
    
    @staticmethod
    def check_executable(script_path: str) -> Tuple[bool, str]:
        """Check if the script is executable"""
        if os.access(script_path, os.X_OK):
            return True, "Script is executable"
        else:
            mode = oct(os.stat(script_path).st_mode)[-3:]
            return False, f"Script is not executable (permissions: {mode})"
    
    @staticmethod
    def has_usage_function(script_content: str) -> bool:
        """Check if the script has a usage/help function"""
        patterns = [
            r'usage\s*\(\s*\)',
            r'show_help\s*\(\s*\)',
            r'print_usage\s*\(\s*\)',
            r'help\s*\(\s*\)',
            r'-h\s*\|.*--help',
            r'--help\s*\)',
        ]
        for pattern in patterns:
            if re.search(pattern, script_content, re.IGNORECASE):
                return True
        return False
    
    @staticmethod
    def uses_getopts(script_content: str) -> bool:
        """Check for getopts usage"""
        return bool(re.search(r'while\s+getopts\s+', script_content))
    
    @staticmethod
    def uses_shift_after_getopts(script_content: str) -> bool:
        """Check if shift is used after getopts"""
        # Look for pattern shift $((OPTIND - 1)) after getopts
        getopts_match = re.search(r'while\s+getopts\s+', script_content)
        if getopts_match:
            after_getopts = script_content[getopts_match.end():]
            # Look for shift OPTIND in the following lines
            if re.search(r'shift\s+\$\(\(OPTIND', after_getopts[:500]):
                return True
            if re.search(r'shift\s+`expr\s+\$OPTIND', after_getopts[:500]):
                return True
        return False
    
    @staticmethod
    def check_error_handling(script_content: str) -> Dict[str, bool]:
        """Check error handling techniques"""
        checks = {
            'set_e': bool(re.search(r'set\s+-e', script_content)),
            'set_u': bool(re.search(r'set\s+-u', script_content)),
            'set_pipefail': bool(re.search(r'set\s+-o\s+pipefail', script_content)),
            'exit_codes': bool(re.search(r'exit\s+[1-9]', script_content)),
            'error_function': bool(re.search(r'(error|die|fail)\s*\(\s*\)', script_content)),
            'trap': bool(re.search(r'trap\s+', script_content)),
        }
        return checks

class FindValidator:
    """Find command validation"""
    
    @staticmethod
    def parse_find_command(command: str) -> Dict[str, Any]:
        """Parse a find command and extract components"""
        result = {
            'valid': True,
            'path': None,
            'tests': [],
            'actions': [],
            'operators': [],
            'errors': []
        }
        
        # Check if it starts with find
        if not command.strip().startswith('find'):
            result['valid'] = False
            result['errors'].append("Command does not start with 'find'")
            return result
        
        # Extract command parts
        parts = command.split()
        if len(parts) < 2:
            result['valid'] = False
            result['errors'].append("Find command is incomplete")
            return result
        
        # Detect path
        if len(parts) > 1 and not parts[1].startswith('-'):
            result['path'] = parts[1]
        
        # Detect common tests
        tests_patterns = {
            '-name': 'search by name',
            '-iname': 'search by name (case insensitive)',
            '-type': 'search by type',
            '-size': 'search by size',
            '-mtime': 'search by modification time (days)',
            '-mmin': 'search by modification time (minutes)',
            '-atime': 'search by access time',
            '-ctime': 'search by creation time',
            '-perm': 'search by permissions',
            '-user': 'search by owner',
            '-group': 'search by group',
            '-newer': 'search for files newer than',
            '-maxdepth': 'depth limit',
            '-mindepth': 'minimum depth',
        }
        
        for test, desc in tests_patterns.items():
            if test in command:
                result['tests'].append((test, desc))
        
        # Detect actions
        actions_patterns = {
            '-print': 'display (implicit)',
            '-print0': 'display with null delimiter',
            '-printf': 'formatted display',
            '-exec': 'command execution',
            '-ok': 'execution with confirmation',
            '-delete': 'deletion',
            '-ls': 'detailed display',
        }
        
        for action, desc in actions_patterns.items():
            if action in command:
                result['actions'].append((action, desc))
        
        # Detect operators
        if ' -o ' in command or ' -or ' in command:
            result['operators'].append('OR')
        if ' -a ' in command or ' -and ' in command:
            result['operators'].append('explicit AND')
        if ' ! ' in command or ' -not ' in command:
            result['operators'].append('NOT')
        if '\\(' in command or '( ' in command:
            result['operators'].append('grouping')
        
        return result
    
    @staticmethod
    def test_find_command(command: str, test_dir: str) -> Tuple[bool, str, str]:
        """Test a find command in a test directory"""
        try:
            # Replace path with test directory
            # Detect and replace first argument that isn't an option
            parts = command.split()
            if len(parts) > 1:
                if not parts[1].startswith('-'):
                    parts[1] = test_dir
                else:
                    parts.insert(1, test_dir)
                command = ' '.join(parts)
            
            result = subprocess.run(
                command,
                shell=True,
                capture_output=True,
                text=True,
                timeout=30,
                cwd=test_dir
            )
            
            stdout = result.stdout.strip()
            stderr = result.stderr.strip()
            
            if result.returncode == 0:
                return True, stdout, stderr
            else:
                return False, stdout, stderr
                
        except subprocess.TimeoutExpired:
            return False, "", "Execution timeout"
        except Exception as e:
            return False, "", f"Error: {str(e)}"
    
    @staticmethod
    def check_dangerous_patterns(command: str) -> List[str]:
        """Check for dangerous patterns in find commands"""
        warnings = []
        
        # -delete without confirmation
        if '-delete' in command and '-print' not in command:
            warnings.append("⚠️ -delete without -print for prior verification")
        
        # -exec rm without -i
        if '-exec' in command and 'rm' in command and '-i' not in command:
            warnings.append("⚠️ -exec rm without -i (interactive)")
        
        # Dangerous paths
        dangerous_paths = ['/', '/etc', '/usr', '/var', '/home']
        for path in dangerous_paths:
            if f'find {path} ' in command or f'find {path}/' in command:
                if '-delete' in command or 'rm' in command:
                    warnings.append(f"☠️ Dangerous command on {path}!")
        
        return warnings

class PermissionsValidator:
    """Permission and chmod command validation"""
    
    OCTAL_PATTERN = re.compile(r'^[0-7]{3,4}$')
    SYMBOLIC_PATTERN = re.compile(r'^[ugoa]*[+\-=][rwxXst]+$')
    
    @staticmethod
    def parse_octal(octal: str) -> Dict[str, Any]:
        """Parse octal permissions"""
        result = {
            'valid': True,
            'special': None,
            'owner': None,
            'group': None,
            'others': None,
            'symbolic': '',
            'description': ''
        }
        
        if not PermissionsValidator.OCTAL_PATTERN.match(octal):
            result['valid'] = False
            return result
        
        # Normalise to 4 digits
        if len(octal) == 3:
            octal = '0' + octal
        
        special = int(octal[0])
        owner = int(octal[1])
        group = int(octal[2])
        others = int(octal[3])
        
        result['special'] = special
        result['owner'] = owner
        result['group'] = group
        result['others'] = others
        
        # Convert to symbolic
        def digit_to_rwx(d: int) -> str:
            r = 'r' if d & 4 else '-'
            w = 'w' if d & 2 else '-'
            x = 'x' if d & 1 else '-'
            return r + w + x
        
        symbolic = digit_to_rwx(owner) + digit_to_rwx(group) + digit_to_rwx(others)
        
        # Adjust for special bits
        if special & 4:  # SUID
            symbolic = symbolic[:2] + ('s' if owner & 1 else 'S') + symbolic[3:]
        if special & 2:  # SGID
            symbolic = symbolic[:5] + ('s' if group & 1 else 'S') + symbolic[6:]
        if special & 1:  # Sticky
            symbolic = symbolic[:8] + ('t' if others & 1 else 'T')
        
        result['symbolic'] = symbolic
        
        # Generate description
        descriptions = []
        perm_names = {
            '755': 'Standard for directories and executable scripts',
            '644': 'Standard for regular files',
            '600': 'Private files (owner only)',
            '700': 'Private directories',
            '777': '⚠️ DANGEROUS - anyone can do anything',
            '666': '⚠️ DANGEROUS - anyone can read/write',
            '750': 'Shared directory with group',
            '640': 'File shared with group (read-only)',
            '400': 'Read-only for owner',
            '444': 'Read-only for everyone',
        }
        
        short_octal = octal[-3:]
        if short_octal in perm_names:
            result['description'] = perm_names[short_octal]
        
        return result
    
    @staticmethod
    def check_dangerous_permissions(octal: str) -> List[str]:
        """Check for dangerous permissions"""
        warnings = []
        
        if octal in ['777', '0777']:
            warnings.append("☠️ 777 - Fully open permissions! Major security risk.")
        elif octal in ['666', '0666']:
            warnings.append("⚠️ 666 - Anyone can read/write. Unsafe for most cases.")
        elif octal.endswith('7'):
            warnings.append("⚠️ World-writable - anyone can modify.")
        elif octal.endswith('6'):
            warnings.append("⚠️ World-readable and writable.")
        
        # SUID on non-standard files
        if octal.startswith('4') and len(octal) == 4:
            warnings.append("ℹ️ SUID set - verify if necessary.")
        
        return warnings
    
    @staticmethod
    def validate_chmod_command(command: str) -> Tuple[bool, List[str]]:
        """Validate a chmod command"""
        issues = []
        
        if not command.strip().startswith('chmod'):
            return False, ["Command does not start with 'chmod'"]
        
        # Check for dangerous patterns
        if '777' in command:
            issues.append("☠️ Uses 777 - avoid this!")
        if '666' in command:
            issues.append("⚠️ Uses 666 - unsafe for most files")
        
        # Check recursion without X
        if '-R' in command and 'X' not in command:
            if re.search(r'-R.*[0-7]{3}', command):
                issues.append("💡 chmod -R with octal - consider using 'X' instead of 'x' for directories")
        
        # Check if on root
        if '/' in command and not re.search(r'/[a-zA-Z]', command):
            issues.append("☠️ Possible chmod on / - DANGEROUS!")
        
        return len(issues) == 0, issues

class CronValidator:
    """Cron expression and configuration validation"""
    
    FIELD_RANGES = {
        'minute': (0, 59),
        'hour': (0, 23),
        'dom': (1, 31),
        'month': (1, 12),
        'dow': (0, 7)
    }
    
    SPECIAL_STRINGS = {
        '@reboot': 'At system startup',
        '@yearly': 'Yearly (0 0 1 1 *)',
        '@annually': 'Yearly (0 0 1 1 *)',
        '@monthly': 'Monthly (0 0 1 * *)',
        '@weekly': 'Weekly (0 0 * * 0)',
        '@daily': 'Daily (0 0 * * *)',
        '@midnight': 'Daily (0 0 * * *)',
        '@hourly': 'Every hour (0 * * * *)',
    }
    
    @staticmethod
    def parse_cron_expression(expression: str) -> Dict[str, Any]:
        """Parse a cron expression"""
        result = {
            'valid': True,
            'fields': {},
            'description': '',
            'errors': [],
            'warnings': []
        }
        
        expression = expression.strip()
        
        # Check for special strings
        if expression.startswith('@'):
            first_word = expression.split()[0]
            if first_word in CronValidator.SPECIAL_STRINGS:
                result['description'] = CronValidator.SPECIAL_STRINGS[first_word]
                result['fields'] = {'special': first_word}
                return result
            else:
                result['valid'] = False
                result['errors'].append(f"Unknown special string: {first_word}")
                return result
        
        # Parse the 5 fields
        parts = expression.split()
        if len(parts) < 5:
            result['valid'] = False
            result['errors'].append(f"Incomplete expression - requires 5 fields, found {len(parts)}")
            return result
        
        fields = ['minute', 'hour', 'dom', 'month', 'dow']
        for i, (field_name, field_value) in enumerate(zip(fields, parts[:5])):
            validation = CronValidator.validate_field(field_value, field_name)
            result['fields'][field_name] = {
                'value': field_value,
                'valid': validation['valid'],
                'meaning': validation['meaning']
            }
            if not validation['valid']:
                result['valid'] = False
                result['errors'].extend(validation['errors'])
        
        # Generate description
        if result['valid']:
            result['description'] = CronValidator.generate_description(result['fields'])
        
        # Check for problematic patterns
        result['warnings'] = CronValidator.check_problematic_patterns(result['fields'])
        
        return result
    
    @staticmethod
    def validate_field(value: str, field_name: str) -> Dict[str, Any]:
        """Validate an individual field"""
        result = {
            'valid': True,
            'meaning': '',
            'errors': []
        }
        
        min_val, max_val = CronValidator.FIELD_RANGES[field_name]
        
        # Wildcard
        if value == '*':
            result['meaning'] = 'any value'
            return result
        
        # Step (*/n or range/n)
        if '/' in value:
            base, step = value.split('/', 1)
            if not step.isdigit():
                result['valid'] = False
                result['errors'].append(f"Invalid step in {field_name}: {step}")
                return result
            step_val = int(step)
            if base == '*':
                result['meaning'] = f'every {step_val}'
            else:
                result['meaning'] = f'every {step_val} in {base}'
            return result
        
        # Range (n-m)
        if '-' in value and not value.startswith('-'):
            parts = value.split('-')
            if len(parts) == 2:
                try:
                    start = int(parts[0])
                    end = int(parts[1])
                    if start < min_val or end > max_val:
                        result['valid'] = False
                        result['errors'].append(f"Range out of bounds for {field_name}")
                    else:
                        result['meaning'] = f'from {start} to {end}'
                    return result
                except ValueError:
                    pass
        
        # List (n,m,o)
        if ',' in value:
            values = value.split(',')
            try:
                nums = [int(v) for v in values]
                for n in nums:
                    if n < min_val or n > max_val:
                        result['valid'] = False
                        result['errors'].append(f"Value {n} out of bounds for {field_name}")
                result['meaning'] = f'values {", ".join(values)}'
                return result
            except ValueError:
                result['valid'] = False
                result['errors'].append(f"Invalid values in {field_name}: {value}")
                return result
        
        # Simple value
        try:
            num = int(value)
            if num < min_val or num > max_val:
                result['valid'] = False
                result['errors'].append(f"Value {num} out of bounds for {field_name} ({min_val}-{max_val})")
            else:
                result['meaning'] = str(num)
            return result
        except ValueError:
            # May be a day or month name
            day_names = {'sun': 0, 'mon': 1, 'tue': 2, 'wed': 3, 'thu': 4, 'fri': 5, 'sat': 6}
            month_names = {'jan': 1, 'feb': 2, 'mar': 3, 'apr': 4, 'may': 5, 'jun': 6,
                          'jul': 7, 'aug': 8, 'sep': 9, 'oct': 10, 'nov': 11, 'dec': 12}
            
            if field_name == 'dow' and value.lower() in day_names:
                result['meaning'] = value.capitalize()
                return result
            if field_name == 'month' and value.lower() in month_names:
                result['meaning'] = value.capitalize()
                return result
            
            result['valid'] = False
            result['errors'].append(f"Invalid value for {field_name}: {value}")
            return result
    
    @staticmethod
    def generate_description(fields: Dict) -> str:
        """Generate a natural language description"""
        minute = fields.get('minute', {}).get('value', '*')
        hour = fields.get('hour', {}).get('value', '*')
        dom = fields.get('dom', {}).get('value', '*')
        month = fields.get('month', {}).get('value', '*')
        dow = fields.get('dow', {}).get('value', '*')
        
        # Common patterns
        if minute == '*' and hour == '*' and dom == '*' and month == '*' and dow == '*':
            return "Every minute"
        if minute == '0' and hour == '*' and dom == '*' and month == '*' and dow == '*':
            return "Every hour (minute 0)"
        if minute == '0' and hour == '0' and dom == '*' and month == '*' and dow == '*':
            return "Daily at midnight"
        
        parts = []
        
        # Time
        if minute != '*' or hour != '*':
            if minute.isdigit() and hour.isdigit():
                parts.append(f"at {hour}:{minute.zfill(2)}")
            elif minute.startswith('*/'):
                parts.append(f"every {minute[2:]} minutes")
            elif hour.startswith('*/'):
                parts.append(f"every {hour[2:]} hours")
        
        # Day
        if dow != '*' and dow != '0-7':
            if dow == '1-5':
                parts.append("Monday-Friday")
            elif dow in ['0', '7']:
                parts.append("Sunday")
            elif dow == '6':
                parts.append("Saturday")
            else:
                parts.append(f"days {dow}")
        
        if dom != '*':
            parts.append(f"on days {dom} of the month")
        
        if month != '*':
            parts.append(f"in month {month}")
        
        return ', '.join(parts) if parts else "Custom schedule"
    
    @staticmethod
    def check_problematic_patterns(fields: Dict) -> List[str]:
        """Check for problematic patterns"""
        warnings = []
        
        minute = fields.get('minute', {}).get('value', '')
        
        # Job running too frequently
        if minute == '*':
            warnings.append("⚠️ Runs every minute - ensure this is necessary")
        
        # dom and dow both specified
        dom = fields.get('dom', {}).get('value', '')
        dow = fields.get('dow', {}).get('value', '')
        if dom != '*' and dow != '*':
            warnings.append("ℹ️ Both dom and dow are specified - it's an OR relationship, not AND!")
        
        return warnings
    
    @staticmethod
    def check_cron_best_practices(cron_line: str) -> List[str]:
        """Check best practices for a crontab line"""
        issues = []
        
        # Check for absolute paths
        if not re.search(r'(^|\s)/\S+\.(sh|py|pl)', cron_line):
            if re.search(r'\.(sh|py|pl)(\s|$)', cron_line):
                issues.append("💡 Use absolute paths for scripts")
        
        # Check for logging
        if '>>' not in cron_line and '>/dev/null' not in cron_line:
            if not cron_line.strip().startswith('#'):
                issues.append("💡 Consider adding logging (>> /path/to/log 2>&1)")
        
        # Check for unescaped %
        if '%' in cron_line and '\\%' not in cron_line:
            if not cron_line.strip().startswith('#'):
                issues.append("⚠️ The % character must be escaped (\\%) in crontab")
        
        return issues

# 
# MAIN GRADING CLASS
# 

class Autograder:
    """Automated grader for Seminar 3 assignments"""
    
    def __init__(self, submission_path: str, verbose: bool = False):
        self.submission_path = Path(submission_path)
        self.verbose = verbose
        self.result = GradingResult(
            student_id=self._extract_student_id(),
            submission_path=str(self.submission_path),
            timestamp=datetime.now().isoformat()
        )
        self.temp_dir = None
    
    def _extract_student_id(self) -> str:
        """Extract student ID from submission path"""
        # Try to find a student ID pattern
        path_str = str(self.submission_path)
        
        # Pattern: surname_firstname or similar
        match = re.search(r'([a-zA-Z]+_[a-zA-Z]+)', path_str)
        if match:
            return match.group(1)
        
        # Use directory name
        return self.submission_path.name
    
    def _log(self, message: str, level: str = "info"):
        """Logging with levels"""
        if not self.verbose and level == "debug":
            return
        
        prefix = {
            "info": f"{Colours.CYAN}ℹ️ {Colours.RESET}",
            "success": f"{Colours.GREEN}✅{Colours.RESET}",
            "warning": f"{Colours.YELLOW}⚠️ {Colours.RESET}",
            "error": f"{Colours.RED}❌{Colours.RESET}",
            "debug": f"{Colours.GRAY}🔍{Colours.RESET}",
        }.get(level, "")
        
        print(f"{prefix} {message}")
    
    def setup_test_environment(self):
        """Create temporary test environment"""
        self.temp_dir = tempfile.mkdtemp(prefix="autograder_")
        
        # Create directory structure for tests
        test_dirs = ['src', 'docs', 'tests', 'build', 'logs']
        for d in test_dirs:
            os.makedirs(os.path.join(self.temp_dir, d), exist_ok=True)
        
        # Create test files
        test_files = [
            ('src/main.c', '// Main source file\nint main() { return 0; }'),
            ('src/utils.c', '// Utilities'),
            ('src/config.h', '// Config header'),
            ('docs/README.md', '# Documentation'),
            ('docs/manual.txt', 'User manual'),
            ('tests/test_main.py', '# Test file'),
            ('tests/test_utils.py', '# Test utilities'),
            ('logs/app.log', 'Log entries here'),
            ('build/output.o', 'Binary content'),
        ]
        
        for path, content in test_files:
            full_path = os.path.join(self.temp_dir, path)
            os.makedirs(os.path.dirname(full_path), exist_ok=True)
            with open(full_path, 'w') as f:
                f.write(content)
        
        # Create files with different sizes
        with open(os.path.join(self.temp_dir, 'large_file.bin'), 'wb') as f:
            f.write(b'\0' * (2 * 1024 * 1024))  # 2MB
        
        # Create files with different timestamps
        old_file = os.path.join(self.temp_dir, 'old_file.txt')
        with open(old_file, 'w') as f:
            f.write('Old content')
        os.utime(old_file, (0, 0))  # Very old timestamp
        
        self._log(f"Test environment created in {self.temp_dir}", "debug")
    
    def cleanup_test_environment(self):
        """Clean up test environment"""
        if self.temp_dir and os.path.exists(self.temp_dir):
            shutil.rmtree(self.temp_dir)
            self._log("Test environment cleaned up", "debug")
    
    def grade(self) -> GradingResult:
        """Execute complete grading"""
        self._log(f"Starting grading for: {self.submission_path}")
        
        try:
            self.setup_test_environment()
            
            # Check that directory exists
            if not self.submission_path.exists():
                self.result.warnings.append(f"Submission directory does not exist: {self.submission_path}")
                return self.result
            
            # Grade by category
            self._grade_find_commands()
            self._grade_scripts()
            self._grade_permissions()
            self._grade_cron()
            
            # Final security checks
            self._security_check()
            
        finally:
            self.cleanup_test_environment()
        
        return self.result
    
    def _grade_find_commands(self):
        """Grade find commands"""
        category = CategoryResult(name="Find and Xargs Commands")
        
        # Search for find commands file
        find_files = list(self.submission_path.glob('**/find*.txt')) + \
                    list(self.submission_path.glob('**/commands*.txt'))
        
        if not find_files:
            category.tests.append(TestResult(
                name="Find commands file",
                status=TestStatus.SKIPPED,
                points_earned=0,
                points_max=20,
                message="Find commands file not found"
            ))
        else:
            find_file = find_files[0]
            self._log(f"Analysing find commands from: {find_file}")
            
            with open(find_file, 'r') as f:
                content = f.read()
            
            # Extract find commands
            commands = [line.strip() for line in content.split('\n') 
                       if line.strip().startswith('find')]
            
            if commands:
                # Test 1: Number of commands
                category.tests.append(TestResult(
                    name="Number of find commands",
                    status=TestStatus.PASSED if len(commands) >= 5 else TestStatus.PARTIAL,
                    points_earned=min(len(commands), 5) * 2,
                    points_max=10,
                    message=f"{len(commands)} find commands found",
                    suggestions=["Requirement: minimum 5 diverse find commands"] if len(commands) < 5 else []
                ))
                
                # Test 2: Test diversity
                all_tests = set()
                for cmd in commands:
                    parsed = FindValidator.parse_find_command(cmd)
                    for test, _ in parsed.get('tests', []):
                        all_tests.add(test)
                
                diversity_score = min(len(all_tests) / 5, 1.0) * 10
                category.tests.append(TestResult(
                    name="Find test diversity",
                    status=TestStatus.PASSED if len(all_tests) >= 5 else TestStatus.PARTIAL,
                    points_earned=diversity_score,
                    points_max=10,
                    message=f"Tests used: {', '.join(all_tests)}",
                    details=[f"Total test types: {len(all_tests)}"]
                ))
                
                # Test 3: xargs usage
                xargs_commands = [c for c in content.split('\n') if 'xargs' in c]
                category.tests.append(TestResult(
                    name="xargs usage",
                    status=TestStatus.PASSED if xargs_commands else TestStatus.FAILED,
                    points_earned=10 if xargs_commands else 0,
                    points_max=10,
                    message=f"{len(xargs_commands)} commands with xargs" if xargs_commands else "Missing xargs usage",
                    suggestions=[] if xargs_commands else ["Add examples with find | xargs"]
                ))
                
                # Test 4: Security checks
                all_warnings = []
                for cmd in commands:
                    warnings = FindValidator.check_dangerous_patterns(cmd)
                    all_warnings.extend(warnings)
                
                if all_warnings:
                    self.result.security_issues.extend(all_warnings)
                    category.tests.append(TestResult(
                        name="Find commands security",
                        status=TestStatus.PARTIAL,
                        points_earned=5,
                        points_max=10,
                        message="Security issues detected",
                        details=all_warnings
                    ))
                else:
                    category.tests.append(TestResult(
                        name="Find commands security",
                        status=TestStatus.PASSED,
                        points_earned=10,
                        points_max=10,
                        message="No security issues detected"
                    ))
        
        self.result.categories.append(category)
    
    def _grade_scripts(self):
        """Grade bash scripts"""
        category = CategoryResult(name="Bash Scripts with Parameters")
        
        # Search for .sh scripts
        scripts = list(self.submission_path.glob('**/*.sh'))
        
        if not scripts:
            category.tests.append(TestResult(
                name="Bash scripts",
                status=TestStatus.SKIPPED,
                points_earned=0,
                points_max=30,
                message="No .sh scripts found"
            ))
        else:
            self._log(f"Analysing {len(scripts)} bash scripts")
            
            for script in scripts[:3]:  # Limit to first 3
                script_name = script.name
                
                # Syntax check
                syntax_ok, syntax_msg = BashValidator.check_syntax(str(script))
                category.tests.append(TestResult(
                    name=f"Syntax: {script_name}",
                    status=TestStatus.PASSED if syntax_ok else TestStatus.FAILED,
                    points_earned=5 if syntax_ok else 0,
                    points_max=5,
                    message=syntax_msg
                ))
                
                if not syntax_ok:
                    continue
                
                # Read content
                with open(script, 'r') as f:
                    content = f.read()
                
                # Shebang check
                shebang_ok, shebang_msg = BashValidator.check_shebang(str(script))
                category.tests.append(TestResult(
                    name=f"Shebang: {script_name}",
                    status=TestStatus.PASSED if shebang_ok else TestStatus.FAILED,
                    points_earned=2 if shebang_ok else 0,
                    points_max=2,
                    message=shebang_msg
                ))
                
                # Usage/help check
                has_usage = BashValidator.has_usage_function(content)
                category.tests.append(TestResult(
                    name=f"Help function: {script_name}",
                    status=TestStatus.PASSED if has_usage else TestStatus.FAILED,
                    points_earned=3 if has_usage else 0,
                    points_max=3,
                    message="Has usage/help function" if has_usage else "Missing help function",
                    suggestions=[] if has_usage else ["Add a usage() function for -h/--help"]
                ))
                
                # getopts check
                uses_getopts = BashValidator.uses_getopts(content)
                if uses_getopts:
                    uses_shift = BashValidator.uses_shift_after_getopts(content)
                    category.tests.append(TestResult(
                        name=f"getopts: {script_name}",
                        status=TestStatus.PASSED if uses_shift else TestStatus.PARTIAL,
                        points_earned=5 if uses_shift else 3,
                        points_max=5,
                        message="Uses getopts correctly with shift" if uses_shift else "Uses getopts but without shift OPTIND",
                        suggestions=[] if uses_shift else ["Add: shift $((OPTIND - 1)) after the getopts loop"]
                    ))
                
                # Error handling check
                error_checks = BashValidator.check_error_handling(content)
                error_score = sum(error_checks.values()) * 1.5
                error_details = [f"{'✓' if v else '✗'} {k}" for k, v in error_checks.items()]
                category.tests.append(TestResult(
                    name=f"Error handling: {script_name}",
                    status=TestStatus.PASSED if error_score >= 6 else TestStatus.PARTIAL,
                    points_earned=min(error_score, 9),
                    points_max=9,
                    message=f"{sum(error_checks.values())}/6 error handling techniques",
                    details=error_details
                ))
        
        self.result.categories.append(category)
    
    def _grade_permissions(self):
        """Grade permission configurations"""
        category = CategoryResult(name="Permissions and chmod")
        
        # Search for relevant files
        perm_files = list(self.submission_path.glob('**/perm*.txt')) + \
                    list(self.submission_path.glob('**/chmod*.txt')) + \
                    list(self.submission_path.glob('**/permis*.sh'))
        
        if not perm_files:
            # Check in scripts
            scripts = list(self.submission_path.glob('**/*.sh'))
            chmod_usage = False
            for script in scripts:
                with open(script, 'r') as f:
                    if 'chmod' in f.read():
                        chmod_usage = True
                        perm_files.append(script)
            
        if not perm_files:
            category.tests.append(TestResult(
                name="Permission configurations",
                status=TestStatus.SKIPPED,
                points_earned=0,
                points_max=25,
                message="No permission configurations found"
            ))
        else:
            # Analyse chmod commands found
            all_chmod_commands = []
            for pf in perm_files:
                with open(pf, 'r') as f:
                    content = f.read()
                    # Extract chmod commands
                    chmod_matches = re.findall(r'chmod\s+[^\n]+', content)
                    all_chmod_commands.extend(chmod_matches)
            
            if all_chmod_commands:
                # Test: Number of chmod commands
                category.tests.append(TestResult(
                    name="chmod commands",
                    status=TestStatus.PASSED if len(all_chmod_commands) >= 3 else TestStatus.PARTIAL,
                    points_earned=min(len(all_chmod_commands) * 2, 10),
                    points_max=10,
                    message=f"{len(all_chmod_commands)} chmod commands found"
                ))
                
                # Test: Octal and symbolic usage
                octal_used = any(re.search(r'chmod\s+[0-7]{3,4}', cmd) for cmd in all_chmod_commands)
                symbolic_used = any(re.search(r'chmod\s+[ugoa]+[+\-=]', cmd) for cmd in all_chmod_commands)
                
                category.tests.append(TestResult(
                    name="Octal mode",
                    status=TestStatus.PASSED if octal_used else TestStatus.FAILED,
                    points_earned=5 if octal_used else 0,
                    points_max=5,
                    message="Uses chmod with octal values" if octal_used else "Does not use octal chmod"
                ))
                
                category.tests.append(TestResult(
                    name="Symbolic mode",
                    status=TestStatus.PASSED if symbolic_used else TestStatus.FAILED,
                    points_earned=5 if symbolic_used else 0,
                    points_max=5,
                    message="Uses symbolic chmod" if symbolic_used else "Does not use symbolic chmod"
                ))
                
                # Permission security check
                all_issues = []
                for cmd in all_chmod_commands:
                    valid, issues = PermissionsValidator.validate_chmod_command(cmd)
                    all_issues.extend(issues)
                
                if all_issues:
                    self.result.security_issues.extend(all_issues)
                
                category.tests.append(TestResult(
                    name="Permission security",
                    status=TestStatus.PASSED if not all_issues else TestStatus.PARTIAL,
                    points_earned=5 if not all_issues else 2,
                    points_max=5,
                    message="No security issues" if not all_issues else f"{len(all_issues)} issues found",
                    details=all_issues
                ))
        
        self.result.categories.append(category)
    
    def _grade_cron(self):
        """Grade cron configurations"""
        category = CategoryResult(name="Cron Configuration")
        
        # Search for crontab files
        cron_files = list(self.submission_path.glob('**/cron*.txt')) + \
                    list(self.submission_path.glob('**/crontab*')) + \
                    list(self.submission_path.glob('**/*.cron'))
        
        if not cron_files:
            category.tests.append(TestResult(
                name="Cron configurations",
                status=TestStatus.SKIPPED,
                points_earned=0,
                points_max=15,
                message="No cron configurations found"
            ))
        else:
            self._log(f"Analysing {len(cron_files)} cron files")
            
            all_cron_lines = []
            for cf in cron_files:
                with open(cf, 'r') as f:
                    lines = [l.strip() for l in f.readlines() 
                            if l.strip() and not l.strip().startswith('#')]
                    all_cron_lines.extend(lines)
            
            valid_expressions = 0
            cron_warnings = []
            
            for line in all_cron_lines:
                # Extract expression (first 5 fields or special string)
                if line.startswith('@'):
                    expr = line.split()[0]
                else:
                    parts = line.split()
                    if len(parts) >= 5:
                        expr = ' '.join(parts[:5])
                    else:
                        continue
                
                parsed = CronValidator.parse_cron_expression(expr)
                if parsed['valid']:
                    valid_expressions += 1
                
                # Best practices
                bp_issues = CronValidator.check_cron_best_practices(line)
                cron_warnings.extend(bp_issues)
            
            # Test: Valid cron expressions
            category.tests.append(TestResult(
                name="Valid cron expressions",
                status=TestStatus.PASSED if valid_expressions >= 3 else TestStatus.PARTIAL,
                points_earned=min(valid_expressions * 3, 9),
                points_max=9,
                message=f"{valid_expressions} valid cron expressions",
                suggestions=["Requirement: minimum 3 cron expressions"] if valid_expressions < 3 else []
            ))
            
            # Test: Best practices
            category.tests.append(TestResult(
                name="Cron best practices",
                status=TestStatus.PASSED if not cron_warnings else TestStatus.PARTIAL,
                points_earned=6 if not cron_warnings else 3,
                points_max=6,
                message="Follows best practices" if not cron_warnings else f"{len(cron_warnings)} suggestions",
                details=cron_warnings
            ))
        
        self.result.categories.append(category)
    
    def _security_check(self):
        """Final security checks"""
        # Search for dangerous patterns in all files
        dangerous_patterns = [
            (r'rm\s+-rf\s+/', "rm -rf / detected!"),
            (r'chmod\s+777\s+/', "chmod 777 on root!"),
            (r'eval\s+\$', "eval with variable - injection risk"),
            (r'\|\s*bash', "Pipe directly into bash - injection risk"),
            (r'curl.*\|\s*sh', "curl | sh - unsafe remote code execution"),
        ]
        
        for file_path in self.submission_path.glob('**/*'):
            if file_path.is_file() and file_path.suffix in ['.sh', '.txt', '.cron', '']:
                try:
                    with open(file_path, 'r', errors='ignore') as f:
                        content = f.read()
                    
                    for pattern, message in dangerous_patterns:
                        if re.search(pattern, content):
                            self.result.security_issues.append(
                                f"☠️ {message} in {file_path.name}"
                            )
                except Exception:
                    pass

# 
# REPORTING
# 

class ReportGenerator:
    """Report generator"""
    
    @staticmethod
    def print_console_report(result: GradingResult):
        """Display report in console"""
        c = Colors
        
        print()
        print(f"{c.CYAN}{'═' * 80}{c.RESET}")
        print(f"{c.CYAN}║{c.RESET} {c.BOLD}GRADING REPORT - Seminar 3 OS{c.RESET}")
        print(f"{c.CYAN}{'═' * 80}{c.RESET}")
        print()
        
        print(f"  {c.WHITE}Student:{c.RESET} {result.student_id}")
        print(f"  {c.WHITE}Date:{c.RESET} {result.timestamp}")
        print(f"  {c.WHITE}Submission:{c.RESET} {result.submission_path}")
        print()
        
        # Results by category
        for category in result.categories:
            status_icon = "✅" if category.percentage >= 80 else "⚠️" if category.percentage >= 50 else "❌"
            print(f"{c.YELLOW}┌{'─' * 78}┐{c.RESET}")
            print(f"{c.YELLOW}│{c.RESET} {status_icon} {c.BOLD}{category.name}{c.RESET}")
            print(f"{c.YELLOW}│{c.RESET}   Score: {category.total_earned:.1f}/{category.total_max:.1f} ({category.percentage:.1f}%)")
            print(f"{c.YELLOW}└{'─' * 78}┘{c.RESET}")
            
            for test in category.tests:
                if test.status == TestStatus.PASSED:
                    icon = f"{c.GREEN}✓{c.RESET}"
                elif test.status == TestStatus.PARTIAL:
                    icon = f"{c.YELLOW}◐{c.RESET}"
                elif test.status == TestStatus.SKIPPED:
                    icon = f"{c.GRAY}○{c.RESET}"
                else:
                    icon = f"{c.RED}✗{c.RESET}"
                
                print(f"  {icon} {test.name}: {test.points_earned:.1f}/{test.points_max:.1f}")
                print(f"    {c.DIM}{test.message}{c.RESET}")
                
                for detail in test.details[:3]:
                    print(f"    {c.GRAY}  • {detail}{c.RESET}")
                
                for suggestion in test.suggestions:
                    print(f"    {c.CYAN}  💡 {suggestion}{c.RESET}")
            
            print()
        
        # Security issues
        if result.security_issues:
            print(f"{c.RED}{'─' * 80}{c.RESET}")
            print(f"{c.RED}⚠️  SECURITY ISSUES DETECTED:{c.RESET}")
            for issue in result.security_issues:
                print(f"  {c.RED}• {issue}{c.RESET}")
            print()
        
        # Warnings
        if result.warnings:
            print(f"{c.YELLOW}{'─' * 80}{c.RESET}")
            print(f"{c.YELLOW}ℹ️  WARNINGS:{c.RESET}")
            for warning in result.warnings:
                print(f"  {c.YELLOW}• {warning}{c.RESET}")
            print()
        
        # Final summary
        print(f"{c.CYAN}{'═' * 80}{c.RESET}")
        grade_color = c.GREEN if result.percentage >= 50 else c.RED
        print(f"{c.CYAN}║{c.RESET} {c.BOLD}FINAL RESULT:{c.RESET}")
        print(f"{c.CYAN}║{c.RESET}   Total score: {result.total_earned:.1f}/{result.total_max:.1f} ({result.percentage:.1f}%)")
        print(f"{c.CYAN}║{c.RESET}   Estimated grade: {grade_color}{result.grade}{c.RESET}")
        print(f"{c.CYAN}{'═' * 80}{c.RESET}")
        print()
    
    @staticmethod
    def generate_json_report(result: GradingResult) -> str:
        """Generate JSON report"""
        data = {
            'student_id': result.student_id,
            'submission_path': result.submission_path,
            'timestamp': result.timestamp,
            'total_earned': result.total_earned,
            'total_max': result.total_max,
            'percentage': result.percentage,
            'grade': result.grade,
            'categories': [],
            'security_issues': result.security_issues,
            'warnings': result.warnings
        }
        
        for cat in result.categories:
            cat_data = {
                'name': cat.name,
                'total_earned': cat.total_earned,
                'total_max': cat.total_max,
                'percentage': cat.percentage,
                'tests': []
            }
            for test in cat.tests:
                cat_data['tests'].append({
                    'name': test.name,
                    'status': test.status.value,
                    'points_earned': test.points_earned,
                    'points_max': test.points_max,
                    'message': test.message,
                    'details': test.details,
                    'suggestions': test.suggestions
                })
            data['categories'].append(cat_data)
        
        return json.dumps(data, indent=2, ensure_ascii=False)
    
    @staticmethod
    def generate_markdown_report(result: GradingResult) -> str:
        """Generate Markdown report"""
        lines = [
            f"# Grading Report - Seminar 3 OS",
            "",
            f"**Student:** {result.student_id}",
            f"**Date:** {result.timestamp}",
            f"**Estimated grade:** {result.grade}",
            "",
            "## Results",
            "",
            f"| Total | {result.total_earned:.1f} / {result.total_max:.1f} | {result.percentage:.1f}% |",
            "|-------|---------|------|",
            ""
        ]
        
        for cat in result.categories:
            lines.append(f"### {cat.name}")
            lines.append("")
            lines.append(f"Score: **{cat.total_earned:.1f} / {cat.total_max:.1f}** ({cat.percentage:.1f}%)")
            lines.append("")
            lines.append("| Test | Score | Status |")
            lines.append("|------|---------|--------|")
            
            for test in cat.tests:
                status_emoji = "✅" if test.status == TestStatus.PASSED else "⚠️" if test.status == TestStatus.PARTIAL else "❌"
                lines.append(f"| {test.name} | {test.points_earned:.1f}/{test.points_max:.1f} | {status_emoji} |")
            
            lines.append("")
        
        if result.security_issues:
            lines.append("## ⚠️ Security Issues")
            lines.append("")
            for issue in result.security_issues:
                lines.append(f"- {issue}")
            lines.append("")
        
        return '\n'.join(lines)

# 
# CLI INTERFACE
# 

def create_sample_submission():
    """Create a sample submission for testing"""
    sample_dir = Path('./sample_submission')
    sample_dir.mkdir(exist_ok=True)
    
    # Find commands file
    (sample_dir / 'find_commands.txt').write_text("""# Find commands for assignment S5-6

# Find all .c files
find . -type f -name "*.c"

# Find files larger than 1MB
find . -type f -size +1M

# Find files modified in the last hour
find . -type f -mmin -60

# Find and display with ls -l
find . -type f -name "*.txt" -exec ls -l {} \\;

# Combination with xargs
find . -type f -name "*.log" -print0 | xargs -0 wc -l

# Delete old files (with verification)
find /tmp -type f -mtime +30 -print -delete
""")
    
    # Script with getopts
    (sample_dir / 'fileinfo.sh').write_text("""#!/bin/bash
# Script for displaying file information

set -e

usage() {
    echo "Usage: $0 [-h] [-v] [-s] file..."
    echo "  -h  Display this help"
    echo "  -v  Verbose mode"
    echo "  -s  Display size"
    exit 0
}

VERBOSE=false
SHOW_SIZE=false

while getopts "hvs" opt; do
    case $opt in
        h) usage ;;
        v) VERBOSE=true ;;
        s) SHOW_SIZE=true ;;
        ?) echo "Invalid option"; exit 1 ;;
    esac
done

shift $((OPTIND - 1))

if [ $# -eq 0 ]; then
    echo "Error: specify at least one file"
    exit 1
fi

for file in "$@"; do
    if [ ! -e "$file" ]; then
        echo "File does not exist: $file"
        continue
    fi
    
    echo "File: $file"
    if $SHOW_SIZE; then
        ls -lh "$file" | awk '{print "  Size: " $5}'
    fi
    if $VERBOSE; then
        file "$file" | sed 's/^/  Type: /'
    fi
done
""")
    
    # Permissions file
    (sample_dir / 'permissions.txt').write_text("""# Permission configurations

# Set standard permissions for scripts
chmod 755 script.sh

# Private file
chmod 600 config.txt

# Shared directory with group
chmod 750 shared_dir

# Symbolic mode
chmod u+x,g+r,o-rwx important.sh

# WRONG: Don't do this!
# chmod 777 everything.sh
""")
    
    # Crontab file
    (sample_dir / 'crontab.txt').write_text("""# Crontab for assignment S5-6

# Daily backup at 3 AM
0 3 * * * /home/user/backup.sh >> /var/log/backup.log 2>&1

# Weekly cleanup (Sunday)
0 0 * * 0 /home/user/cleanup.sh

# Health check every hour during the day
0 9-18 * * 1-5 /home/user/health_check.sh >> /var/log/health.log 2>&1

# At system startup
@reboot /home/user/start_services.sh
""")
    
    print(f"Sample submission created in: {sample_dir}")
    return sample_dir

def main():
    parser = argparse.ArgumentParser(
        description='Automated grader for Seminar 3 OS assignments',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Usage examples:
  %(prog)s --submission ./student_assignment/
  %(prog)s --submission ./student_assignment/ --verbose
  %(prog)s --submission ./student_assignment/ --output report.json
  %(prog)s --create-sample
  %(prog)s --test-cron "0 3 * * *"
  %(prog)s --test-find "find . -type f -name '*.txt'"
        """
    )
    
    parser.add_argument('--submission', '-s', type=str,
                       help='Directory with submission to grade')
    parser.add_argument('--verbose', '-v', action='store_true',
                       help='Verbose mode')
    parser.add_argument('--output', '-o', type=str,
                       help='Output file for report (JSON or MD)')
    parser.add_argument('--batch', '-b', type=str,
                       help='Batch grading - directory with multiple submissions')
    parser.add_argument('--create-sample', action='store_true',
                       help='Create a sample submission for testing')
    parser.add_argument('--test-cron', type=str,
                       help='Test a cron expression')
    parser.add_argument('--test-find', type=str,
                       help='Test a find command')
    parser.add_argument('--test-permissions', type=str,
                       help='Test octal permissions (e.g.: 755)')
    parser.add_argument('--no-color', action='store_true',
                       help='Disable colours')
    
    args = parser.parse_args()
    
    if args.no_color:
        Colours.disable()
    
    # Create sample submission
    if args.create_sample:
        logger.info("Creating sample submission...")
        create_sample_submission()
        return 0
    
    # Test cron expression
    if args.test_cron:
        result = CronValidator.parse_cron_expression(args.test_cron)
        print(f"Expression: {args.test_cron}")
        print(f"Valid: {result['valid']}")
        print(f"Description: {result['description']}")
        if result['errors']:
            print(f"Errors: {', '.join(result['errors'])}")
        if result['warnings']:
            print(f"Warnings: {', '.join(result['warnings'])}")
        return 0
    
    # Test find command
    if args.test_find:
        result = FindValidator.parse_find_command(args.test_find)
        print(f"Command: {args.test_find}")
        print(f"Valid: {result['valid']}")
        print(f"Path: {result['path']}")
        print(f"Tests: {[t[0] for t in result['tests']]}")
        print(f"Actions: {[a[0] for a in result['actions']]}")
        warnings = FindValidator.check_dangerous_patterns(args.test_find)
        if warnings:
            print(f"Warnings: {warnings}")
        return 0
    
    # Test permissions
    if args.test_permissions:
        result = PermissionsValidator.parse_octal(args.test_permissions)
        print(f"Octal: {args.test_permissions}")
        print(f"Valid: {result['valid']}")
        print(f"Symbolic: {result['symbolic']}")
        print(f"Description: {result['description']}")
        warnings = PermissionsValidator.check_dangerous_permissions(args.test_permissions)
        if warnings:
            print(f"Warnings: {warnings}")
        return 0
    
    # Grade submission
    if args.submission:
        logger.info(f"Starting grading for: {args.submission}")
        grader = Autograder(args.submission, verbose=args.verbose)
        result = grader.grade()
        
        # Display report in console
        ReportGenerator.print_console_report(result)
        
        # Save report if specified
        if args.output:
            if args.output.endswith('.json'):
                with open(args.output, 'w') as f:
                    f.write(ReportGenerator.generate_json_report(result))
            elif args.output.endswith('.md'):
                with open(args.output, 'w') as f:
                    f.write(ReportGenerator.generate_markdown_report(result))
            logger.info(f"Report saved to: {args.output}")
            print(f"Report saved to: {args.output}")
        
        logger.info(f"Final result: {result.percentage:.1f}% (Grade: {result.grade})")
        return 0 if result.percentage >= 50 else 1
    
    # Batch grading
    if args.batch:
        batch_dir = Path(args.batch)
        if not batch_dir.exists():
            print(f"Directory does not exist: {batch_dir}")
            return 1
        
        results = []
        for sub_dir in sorted(batch_dir.iterdir()):
            if sub_dir.is_dir():
                print(f"\n{'='*60}")
                print(f"Grading: {sub_dir.name}")
                print(f"{'='*60}")
                
                grader = Autograder(str(sub_dir), verbose=args.verbose)
                result = grader.grade()
                results.append(result)
                
                print(f"  → {result.student_id}: {result.percentage:.1f}% (Grade: {result.grade})")
        
        # Summary statistics
        print(f"\n{'='*60}")
        print("OVERALL STATISTICS")
        print(f"{'='*60}")
        print(f"Total graded: {len(results)}")
        avg = sum(r.percentage for r in results) / len(results) if results else 0
        print(f"Average: {avg:.1f}%")
        passed = sum(1 for r in results if float(r.grade) >= 5)
        print(f"Passed: {passed}/{len(results)}")
        
        return 0
    
    # No arguments - display help
    parser.print_help()
    return 0

if __name__ == '__main__':
    sys.exit(main())
