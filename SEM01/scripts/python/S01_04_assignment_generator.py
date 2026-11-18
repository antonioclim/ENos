#!/usr/bin/env python3
"""
Assignment Generator - Generates deterministic assignment variants per identifier
Operating Systems | ASE Bucharest - CSIE

Purpose: Vary requirements; personalisation alone does not prevent copying or prove authorship.
Usage: python3 S01_04_assignment_generator.py <student_id> [--output dir]

Each student receives:
- Different directory names
- Different variable names
- Different aliases to implement
- Different glob patterns to demonstrate
"""

import argparse
import re
import hashlib
import random
import sys
import json
from pathlib import Path
from datetime import datetime
from typing import Dict, List, Optional
from dataclasses import dataclass, asdict


@dataclass
class AssignmentVariant:
    """Represents a deterministic assignment variant; different identifiers can collide."""
    student_id: str
    generated_at: str
    seed: int
    
    # Directory structure
    root_dir: str
    sub_dirs: List[str]
    
    # Main files
    main_script: str
    vars_script: str
    info_script: str
    glob_script: str
    
    # Variables to demonstrate
    custom_vars: List[str]
    env_vars_to_display: List[str]
    
    # Required aliases
    required_aliases: List[str]
    optional_alias_name: str
    
    # Glob patterns
    glob_patterns: List[str]
    file_extensions: List[str]
    
    # Required function
    function_name: str
    function_description: str


# Variant pools
DIRECTORY_POOLS = {
    'root': ['project', 'assignment', 'workspace', 'lab01', 'shell_project', 'submission'],
    'sub1': ['src', 'code', 'scripts', 'bin', 'main'],
    'sub2': ['docs', 'documentation', 'readme', 'info'],
    'sub3': ['tests', 'testing', 'verification', 'check'],
}

SCRIPT_NAMES = {
    'main': ['main.sh', 'start.sh', 'run.sh', 'app.sh', 'init.sh'],
    'vars': ['variables.sh', 'vars.sh', 'env_demo.sh', 'config.sh', 'settings.sh'],
    'info': ['system_info.sh', 'sysinfo.sh', 'about.sh', 'status.sh', 'info.sh'],
    'glob': ['glob_demo.sh', 'patterns.sh', 'wildcards.sh', 'files.sh', 'test_glob.sh'],
}

VARIABLE_POOLS = {
    'custom': [
        ['PROJECT_NAME', 'AUTHOR', 'VERSION'],
        ['APP_NAME', 'CREATOR', 'RELEASE'],
        ['PROGRAM_NAME', 'DEVELOPER', 'BUILD'],
        ['SCRIPT_NAME', 'OWNER', 'REVISION'],
        ['MODULE_NAME', 'MAINTAINER', 'EDITION'],
    ],
    'env': [
        ['USER', 'HOME', 'SHELL', 'PATH'],
        ['USER', 'HOME', 'PWD', 'LANG'],
        ['LOGNAME', 'HOME', 'SHELL', 'TERM'],
        ['USER', 'HOSTNAME', 'SHELL', 'PATH'],
    ],
}

ALIAS_POOLS = {
    'required': [
        ['ll', 'la', 'cls'],
        ['ll', 'lt', 'cls'],
        ['la', 'lh', 'c'],
        ['ll', 'lrt', 'clear'],
        ['la', 'll', 'cls'],
    ],
    'optional': ['mycd', 'mkcd', 'cdup', 'back', 'proj', 'quick', 'go'],
}

GLOB_POOLS = {
    'patterns': [
        ['*.txt', 'file?.sh', '[abc]*'],
        ['*.sh', 'test?.txt', '[0-9]*'],
        ['*.md', 'doc?.*', '[a-z]*'],
        ['*.log', 'app?.sh', '[A-Z]*'],
    ],
    'extensions': [
        ['.txt', '.sh', '.md'],
        ['.log', '.sh', '.txt'],
        ['.md', '.py', '.sh'],
        ['.txt', '.log', '.csv'],
    ],
}

FUNCTION_POOLS = [
    ('mkcd', 'Create a directory and change into it'),
    ('mkproj', 'Create a project structure with subdirectories'),
    ('backup', 'Create a backup copy with timestamp'),
    ('extract', 'Extract archives based on extension'),
    ('goto', 'Navigate to frequently used directories'),
]


def generate_seed(student_id: str) -> int:
    """
    Generate a deterministic seed from the student ID.
    The same ID always produces the same variant.
    """
    hash_bytes = hashlib.sha256(student_id.lower().encode()).digest()
    return int.from_bytes(hash_bytes[:4], 'big')


def generate_variant(student_id: str) -> AssignmentVariant:
    """
    Generate a complete assignment variant for a student.
    
    Args:
        student_id: Unique student identifier (name, email or matriculation number)
        
    Returns:
        AssignmentVariant with all personalised requirements
    """
    seed = generate_seed(student_id)
    random.seed(seed)
    
    root_dir = random.choice(DIRECTORY_POOLS['root'])
    sub_dirs = [
        random.choice(DIRECTORY_POOLS['sub1']),
        random.choice(DIRECTORY_POOLS['sub2']),
        random.choice(DIRECTORY_POOLS['sub3']),
    ]
    
    main_script = random.choice(SCRIPT_NAMES['main'])
    vars_script = random.choice(SCRIPT_NAMES['vars'])
    info_script = random.choice(SCRIPT_NAMES['info'])
    glob_script = random.choice(SCRIPT_NAMES['glob'])
    
    custom_vars = random.choice(VARIABLE_POOLS['custom'])
    env_vars = random.choice(VARIABLE_POOLS['env'])
    
    required_aliases = random.choice(ALIAS_POOLS['required'])
    optional_alias = random.choice(ALIAS_POOLS['optional'])
    
    glob_patterns = random.choice(GLOB_POOLS['patterns'])
    file_extensions = random.choice(GLOB_POOLS['extensions'])
    
    func_name, func_desc = random.choice(FUNCTION_POOLS)
    
    return AssignmentVariant(
        student_id=student_id,
        generated_at=datetime.now().isoformat(),
        seed=seed,
        root_dir=root_dir,
        sub_dirs=sub_dirs,
        main_script=main_script,
        vars_script=vars_script,
        info_script=info_script,
        glob_script=glob_script,
        custom_vars=custom_vars,
        env_vars_to_display=env_vars,
        required_aliases=required_aliases,
        optional_alias_name=optional_alias,
        glob_patterns=glob_patterns,
        file_extensions=file_extensions,
        function_name=func_name,
        function_description=func_desc,
    )


def render_assignment_md(variant: AssignmentVariant) -> str:
    """Generate the assignment document in Markdown format."""
    return f'''# Assignment Seminar 1: Shell Basics
## Personalised Variant for: {variant.student_id}

> **Variant ID:** {variant.seed}  
> **Generated:** {variant.generated_at}
> **Assessment:** PENDING_POLICY. The historical weights below are preserved for
> author review, not an adopted marking rule. The 32-bit seed is a variant
> identifier, not evidence of identity, authenticity or unique assignment content.

---

## Requirements

### 1. Directory Structure (20%)

Create the following structure:

```
{variant.root_dir}/
├── {variant.sub_dirs[0]}/
│   ├── {variant.main_script}
│   ├── {variant.vars_script}
│   └── {variant.info_script}
├── {variant.sub_dirs[1]}/
│   └── README.md
└── {variant.sub_dirs[2]}/
    └── {variant.glob_script}
```

**Recommended command:** Use `mkdir -p` with brace expansion.

---

### 2. Variables Script: `{variant.vars_script}` (25%)

The script must:

1. Define at least 3 local variables:
   - `{variant.custom_vars[0]}` - the project name
   - `{variant.custom_vars[1]}` - your name
   - `{variant.custom_vars[2]}` - version (e.g. "1.0")

2. Display the following environment variables:
   - `${variant.env_vars_to_display[0]}`
   - `${variant.env_vars_to_display[1]}`
   - `${variant.env_vars_to_display[2]}`
   - `${variant.env_vars_to_display[3]}`

3. Demonstrate the difference between local and exported variables.

---

### 3. Configure .bashrc (25%)

Write an exercise-owned `bashrc_snippet.sh`; inspect and test it in a disposable Bash session before any deliberate personal-shell installation:

**Required aliases:**
- `{variant.required_aliases[0]}` - for detailed listing
- `{variant.required_aliases[1]}` - for alternative listing  
- `{variant.required_aliases[2]}` - for clearing the screen

**Personal alias:**
- `{variant.optional_alias_name}` - define a useful alias for yourself

**Required function:**
- `{variant.function_name}()` - {variant.function_description}

---

### 4. Globbing Test: `{variant.glob_script}` (20%)

Demonstrate understanding of patterns:

1. Create test files with extensions: `{', '.join(variant.file_extensions)}`
2. Demonstrate the patterns:
   - `{variant.glob_patterns[0]}`
   - `{variant.glob_patterns[1]}`
   - `{variant.glob_patterns[2]}`
3. Explain the difference between `ls *` and `ls .*`

---

### 5. System Info Script: `{variant.info_script}` (10%)

Display system information in a pleasant format.

---

## Oral Verification — policy pending

Historical proposal: two questions about the submitted code:
- Explain what a specific line does
- Modify something live at the instructor's request

**PENDING_POLICY:** the historical maximum-grade-5 rule is not applied automatically. The author must settle oral-assessment weight, eligibility and equivalent accommodations; explanation alone is not proof of authorship.

---

## Submission

Archive: `SurnameName_Seminar1.zip`  
Deadline: See platform  
Structure format: exactly as above

---

*Automatically generated variant - do not modify the ID*
'''


def render_validator_config(variant: AssignmentVariant) -> dict:
    """Generate configuration for validator/autograder."""
    return {
        'student_id': variant.student_id,
        'seed': variant.seed,
        'structure': {
            'root': variant.root_dir,
            'required_dirs': [
                f"{variant.root_dir}/{variant.sub_dirs[0]}",
                f"{variant.root_dir}/{variant.sub_dirs[1]}",
                f"{variant.root_dir}/{variant.sub_dirs[2]}",
            ],
            'required_files': [
                f"{variant.root_dir}/{variant.sub_dirs[0]}/{variant.main_script}",
                f"{variant.root_dir}/{variant.sub_dirs[0]}/{variant.vars_script}",
                f"{variant.root_dir}/{variant.sub_dirs[0]}/{variant.info_script}",
                f"{variant.root_dir}/{variant.sub_dirs[1]}/README.md",
                f"{variant.root_dir}/{variant.sub_dirs[2]}/{variant.glob_script}",
            ],
        },
        'variables': {
            'custom_required': variant.custom_vars,
            'env_required': variant.env_vars_to_display,
        },
        'bashrc': {
            'aliases': variant.required_aliases,
            'function': variant.function_name,
        },
        'globbing': {
            'patterns': variant.glob_patterns,
            'extensions': variant.file_extensions,
        },
    }


def main():
    """Generate files without overwriting an existing variant."""
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('student_id', help='Identifier, name or email; no path separators/control characters')
    parser.add_argument('--output', type=Path, default=Path('.'))
    args = parser.parse_args()
    student_id = args.student_id
    if not 1 <= len(student_id) <= 128 or any(ord(c) < 32 for c in student_id) or any(c in student_id for c in '/\\'):
        parser.error('student_id must be 1–128 characters without path separators or control characters')
    variant = generate_variant(student_id)
    slug = re.sub(r'[^A-Za-z0-9_-]', '_', student_id)
    md_path = args.output / f'HOMEWORK_{slug}.md'
    config_path = args.output / f'config_{variant.seed}.json'
    if any(p.exists() or p.is_symlink() for p in (md_path, config_path)):
        parser.error('Refusing to overwrite an existing assignment/configuration; use a fresh output directory')
    args.output.mkdir(parents=True, exist_ok=True)
    try:
        with md_path.open('x', encoding='utf-8') as handle:
            handle.write(render_assignment_md(variant))
        with config_path.open('x', encoding='utf-8') as handle:
            json.dump(render_validator_config(variant), handle, indent=2)
            handle.write('\n')
    except OSError as exc:
        print(f'Generation incomplete; inspect the owned output directory: {exc}', file=sys.stderr)
        return 1
    print(f'[OK] Assignment generated: {md_path}')
    print(f'[OK] Validator config: {config_path}')
    print(f'Student identifier: {student_id}; seed: {variant.seed}; assessment: PENDING_POLICY')
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
