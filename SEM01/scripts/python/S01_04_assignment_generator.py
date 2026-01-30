#!/usr/bin/env python3
"""
Assignment Generator - Generates unique assignment variants per student
Operating Systems | ASE Bucharest - CSIE

Purpose: Prevent copying through randomised requirements per student
Usage: python3 S01_04_assignment_generator.py <student_id> [--output dir]

Each student receives:
- Different directory names
- Different variable names
- Different aliases to implement
- Different glob patterns to demonstrate
"""

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
    """Represents a unique assignment variant."""
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

Add to `.bashrc`:

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

## Oral Verification (MANDATORY)

At submission you will answer 2 questions about your code:
- Explain what a specific line does
- Modify something live at the instructor's request

**Without oral verification = maximum grade 5.**

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
    """Entry point."""
    if len(sys.argv) < 2:
        print("Usage: python3 S01_04_assignment_generator.py <student_id> [--output dir]")
        print("\nExample:")
        print("  python3 S01_04_assignment_generator.py PopescuIon")
        print("  python3 S01_04_assignment_generator.py maria.ionescu@stud.ase.ro --output ./homework/")
        sys.exit(1)
    
    student_id = sys.argv[1]
    
    # Parse output directory
    output_dir = Path('.')
    if '--output' in sys.argv:
        idx = sys.argv.index('--output')
        if idx + 1 < len(sys.argv):
            output_dir = Path(sys.argv[idx + 1])
            output_dir.mkdir(parents=True, exist_ok=True)
    
    # Generate variant
    variant = generate_variant(student_id)
    
    # Save assignment in Markdown
    md_path = output_dir / f"HOMEWORK_{student_id.replace('@', '_').replace('.', '_')}.md"
    md_path.write_text(render_assignment_md(variant), encoding='utf-8')
    print(f"[OK] Assignment generated: {md_path}")
    
    # Save config for validator
    config_path = output_dir / f"config_{variant.seed}.json"
    config_path.write_text(json.dumps(render_validator_config(variant), indent=2), encoding='utf-8')
    print(f"[OK] Validator config: {config_path}")
    
    # Display summary
    print(f"\n{'='*50}")
    print(f"Student: {student_id}")
    print(f"Seed: {variant.seed}")
    print(f"Root directory: {variant.root_dir}/")
    print(f"Function: {variant.function_name}()")
    print(f"Aliases: {', '.join(variant.required_aliases)}")
    print(f"{'='*50}")


if __name__ == '__main__':
    main()
