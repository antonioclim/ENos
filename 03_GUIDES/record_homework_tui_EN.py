#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
╔═══════════════════════════════════════════════════════════════════════════════╗
║                                                                               ║
║          📹 HOMEWORK RECORDING SYSTEM - MATRIX EDITION                        ║
║                    Operating Systems 2023-2027                                ║
║                       Revolvix/github.com                                     ║
║                                                                               ║
║                         Version 1.1.0                                         ║
║                                                                               ║
╚═══════════════════════════════════════════════════════════════════════════════╝

An elegant Matrix-style TUI for recording homework with asciinema.
Features: RSA cryptographic signatures, automatic upload, beautiful animations.

Requirements: Python 3.8+, asciinema, openssl, sshpass
Auto-install: rich, questionary (Python packages)

Changelog:
    1.1.0 (2025-01): Type hints, improved docstrings, robust error handling
    1.0.0 (2025-01): Initial version with Matrix theme
"""

from __future__ import annotations

import os
import sys
import subprocess
import tempfile
import base64
import re
import time
import random
import shutil
import json
from datetime import datetime
from pathlib import Path
from typing import Dict, Any, Optional, Callable, TypeVar, List, Tuple

# 
# CONFIGURATION
# 

CONFIG_FILE: str = os.path.expanduser("~/.homework_recorder_config.json")

PUBLIC_KEY: str = """-----BEGIN PUBLIC KEY-----
MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCieNySGxV0PZUBbAjbwksHyUUB
soa9fbLVI9uK7viOAVi0c5ZHjfnwU/LhRxLT4qbBNSlUBoXqiiVAg+Z+NWY2B/eY
POoTxuSLgkS0NfJjd55t2N4gzJHydma6gfwLg3kpDEJoSIlTfI83aFHuyzPxgzbj
HAsViFvWuv8rlbxvHwIDAQAB
-----END PUBLIC KEY-----"""

SCP_SERVER: str = "sop.ase.ro"
SCP_PORT: str = "1001"
SCP_PASSWORD: str = "stud"
SCP_BASE_PATH: str = "/home/HOMEWORKS"
MAX_RETRIES: int = 3

SPECIALIZATIONS: Dict[str, Tuple[str, str]] = {
    "1": ("eninfo", "Economic Informatics (English)"),
    "2": ("grupeid", "ID Group"),
    "3": ("roinfo", "Economic Informatics (Romanian)")
}

# Type variable for generic functions
T = TypeVar('T')

# 
# CONFIGURATION FUNCTIONS (SAVE/LOAD PREVIOUS DATA)
# 

def load_config() -> Dict[str, Any]:
    """
    Load previously saved configuration (if it exists).
    
    Returns:
        Dict with keys: surname, firstname, group, specialization_key
        or empty dict if it does not exist/cannot be read.
    
    Note:
        Configuration is saved in ~/.homework_recorder_config.json
    """
    config_path = Path(CONFIG_FILE)
    if not config_path.exists():
        return {}
    
    try:
        with config_path.open('r', encoding='utf-8') as f:
            return json.load(f)
    except (json.JSONDecodeError, IOError, PermissionError):
        return {}


def save_config(data: Dict[str, str]) -> bool:
    """
    Save configuration for later use.
    
    Args:
        data: Dict with student data (surname, firstname, group, etc.)
    
    Returns:
        True if save succeeded, False otherwise.
    """
    config: Dict[str, str] = {
        'surname': data.get('surname', ''),
        'firstname': data.get('firstname', ''),
        'group': data.get('group', ''),
        'specialization_key': data.get('specialization_key', '1')
    }
    try:
        with open(CONFIG_FILE, 'w', encoding='utf-8') as f:
            json.dump(config, f, ensure_ascii=False, indent=2)
        return True
    except IOError:
        return False


# 
# AUTO-INSTALL DEPENDENCIES
# 

def install_python_packages() -> None:
    """
    Install required Python packages if missing.
    
    Raises:
        SystemExit: If installation fails critically.
    """
    # Check if pip is installed, if not - install it
    try:
        subprocess.run(
            [sys.executable, '-m', 'pip', '--version'],
            capture_output=True,
            check=True
        )
    except (subprocess.CalledProcessError, FileNotFoundError):
        print("\n\033[33m⚡ Installing pip...\033[0m\n")
        subprocess.run(['sudo', 'apt', 'update', '-qq'], check=True)
        subprocess.run(['sudo', 'apt', 'install', '-y', 'python3-pip'], check=True)
        print("\033[32m✓ pip has been installed!\033[0m\n")
    
    required: List[str] = ['rich', 'questionary']
    missing: List[str] = []
    
    for pkg in required:
        try:
            __import__(pkg)
        except ImportError:
            missing.append(pkg)
    
    if missing:
        print(f"\n\033[33m⚡ Installing Python packages: {', '.join(missing)}...\033[0m\n")
        
        # Detect pip version to decide whether to use --break-system-packages
        pip_version_result = subprocess.run(
            [sys.executable, '-m', 'pip', '--version'],
            capture_output=True,
            text=True
        )
        pip_version_str = pip_version_result.stdout.split()[1] if pip_version_result.returncode == 0 else "0"
        
        # Extract major version
        try:
            pip_major_version = int(pip_version_str.split('.')[0])
        except (ValueError, IndexError):
            pip_major_version = 0
        
        # --break-system-packages is only needed for pip >= 23 on externally-managed systems
        pip_cmd: List[str] = [sys.executable, '-m', 'pip', 'install', '--quiet', '--user']
        
        # Try first with --user (works on all versions)
        try:
            subprocess.run(pip_cmd + missing, check=True)
        except subprocess.CalledProcessError:
            # If --user fails, try without (may require sudo)
            try:
                subprocess.run([sys.executable, '-m', 'pip', 'install', '--quiet'] + missing, check=True)
            except subprocess.CalledProcessError:
                # Last attempt: with --break-system-packages (pip 23+)
                if pip_major_version >= 23:
                    subprocess.run(
                        [sys.executable, '-m', 'pip', 'install', '--quiet', '--break-system-packages'] + missing,
                        check=True
                    )
                else:
                    # Install through apt as fallback
                    print("\033[33m⚡ Installing through apt...\033[0m\n")
                    apt_packages: List[str] = ['python3-rich']
                    subprocess.run(['sudo', 'apt', 'install', '-y'] + apt_packages, check=False)
                    subprocess.run([sys.executable, '-m', 'pip', 'install', '--quiet', 'questionary'], check=True)
        
        print("\033[32m✓ Python packages have been installed!\033[0m\n")
        
        # Re-import after installation - add user path to sys.path if needed
        import site
        user_site = site.getusersitepackages()
        if user_site not in sys.path:
            sys.path.insert(0, user_site)
        
        # Re-import modules
        for pkg in missing:
            globals()[pkg] = __import__(pkg)


def check_system_packages() -> None:
    """
    Check and install system packages if missing.
    
    Packages checked: asciinema, openssl, sshpass
    """
    packages: Dict[str, str] = {
        'asciinema': 'asciinema',
        'openssl': 'openssl',
        'sshpass': 'sshpass'
    }
    
    missing: List[str] = []
    for cmd, pkg in packages.items():
        if shutil.which(cmd) is None:
            missing.append(pkg)
    
    if missing:
        print(f"\n\033[33m⚡ Installing system packages: {', '.join(missing)}...\033[0m\n")
        subprocess.run(['sudo', 'apt', 'update', '-qq'], check=True)
        subprocess.run(['sudo', 'apt', 'install', '-y'] + missing, check=True)
        print("\033[32m✓ System packages have been installed!\033[0m\n")


# Run installation checks before importing rich/questionary
try:
    install_python_packages()
    check_system_packages()
except Exception as e:
    print(f"\033[31m✗ Installation error: {e}\033[0m")
    sys.exit(1)

# Now import the packages
from rich.console import Console
from rich.panel import Panel
from rich.text import Text
from rich.progress import Progress, SpinnerColumn, TextColumn, BarColumn, TaskProgressColumn
from rich.table import Table
from rich.layout import Layout
from rich.live import Live
from rich.align import Align
from rich.style import Style
from rich.box import DOUBLE, ROUNDED, HEAVY
from rich import box
import questionary
from questionary import Style as QStyle

# 
# MATRIX THEME
# 

console: Console = Console()

# Matrix colour palette
MATRIX_GREEN: str = "#00ff41"
MATRIX_DARK_GREEN: str = "#00cc44"
MATRIX_BRIGHT: str = "#00ff00"
MATRIX_DIM: str = "#00aa33"
MATRIX_CYAN: str = "#00ffff"
MATRIX_YELLOW: str = "#ffff00"
MATRIX_RED: str = "#ff0040"

# Questionary style (Matrix theme)
matrix_style: QStyle = QStyle([
    ('qmark', f'fg:{MATRIX_BRIGHT} bold'),
    ('question', f'fg:{MATRIX_GREEN} bold'),
    ('answer', f'fg:{MATRIX_CYAN} bold'),
    ('pointer', f'fg:{MATRIX_BRIGHT} bold'),
    ('highlighted', f'fg:{MATRIX_BRIGHT} bold'),
    ('selected', f'fg:{MATRIX_CYAN}'),
    ('separator', f'fg:{MATRIX_DIM}'),
    ('instruction', f'fg:{MATRIX_DIM}'),
    ('text', f'fg:{MATRIX_GREEN}'),
    ('disabled', f'fg:{MATRIX_DIM} italic'),
])

# 
# MATRIX EFFECTS
# 

def matrix_rain(duration: float = 1.5, width: Optional[int] = None) -> None:
    """
    Display the Matrix digital rain effect.
    
    Args:
        duration: Duration of the effect in seconds
        width: Screen width (None for auto-detect)
    """
    if width is None:
        width = console.width
    
    chars: str = "ｱｲｳｴｵｶｷｸｹｺｻｼｽｾｿﾀﾁﾂﾃﾄﾅﾆﾇﾈﾉﾊﾋﾌﾍﾎﾏﾐﾑﾒﾓﾔﾕﾖﾗﾘﾙﾚﾛﾜﾝ0123456789ABCDEF"
    columns: List[int] = [0] * width
    
    start_time: float = time.time()
    
    with Live(console=console, refresh_per_second=20, transient=True) as live:
        while time.time() - start_time < duration:
            lines: List[str] = []
            for y in range(min(20, console.height - 5)):
                line: str = ""
                for x in range(width):
                    if random.random() < 0.1:
                        columns[x] = random.randint(0, 20)
                    
                    if columns[x] > 0:
                        if columns[x] > 15:
                            line += f"[bold {MATRIX_BRIGHT}]{random.choice(chars)}[/]"
                        elif columns[x] > 10:
                            line += f"[{MATRIX_GREEN}]{random.choice(chars)}[/]"
                        else:
                            line += f"[{MATRIX_DARK_GREEN}]{random.choice(chars)}[/]"
                        columns[x] -= 1
                    else:
                        line += " "
                lines.append(line)
            
            text = Text.from_markup("\n".join(lines))
            live.update(text)
            time.sleep(0.05)


def typing_effect(text: str, style: str = MATRIX_GREEN, delay: float = 0.02) -> None:
    """
    Display text with typing effect.
    
    Args:
        text: Text to display
        style: Colour style
        delay: Delay between characters in seconds
    """
    for char in text:
        console.print(char, style=style, end="")
        time.sleep(delay)
    console.print()


def glitch_text(text: str, iterations: int = 5) -> None:
    """
    Display text with glitch effect.
    
    Args:
        text: Text to display
        iterations: Number of glitch iterations
    """
    glitch_chars: str = "!@#$%^&*()_+-=[]{}|;':\",./<>?"
    
    with Live(console=console, refresh_per_second=20, transient=True) as live:
        for i in range(iterations):
            glitched: str = ""
            for char in text:
                if random.random() < 0.3 - (i * 0.05):
                    glitched += random.choice(glitch_chars)
                else:
                    glitched += char
            live.update(Text(glitched, style=f"bold {MATRIX_GREEN}"))
            time.sleep(0.1)
        
        live.update(Text(text, style=f"bold {MATRIX_BRIGHT}"))
        time.sleep(0.3)


def spinner_task(description: str, task_func: Callable[..., T], *args: Any, **kwargs: Any) -> T:
    """
    Execute a task with a Matrix-style spinner.
    
    Args:
        description: Task description displayed next to spinner
        task_func: Function to execute
        *args: Positional arguments for function
        **kwargs: Keyword arguments for function
    
    Returns:
        Result of the executed function
    """
    with Progress(
        SpinnerColumn(spinner_name="dots", style=f"bold {MATRIX_GREEN}"),
        TextColumn(f"[{MATRIX_GREEN}]{{task.description}}"),
        console=console,
        transient=True
    ) as progress:
        task = progress.add_task(description, total=None)
        result: T = task_func(*args, **kwargs)
        progress.update(task, completed=True)
    return result


def progress_bar(description: str, total: int, update_func: Callable[[int], None]) -> None:
    """
    Display a Matrix-style progress bar.
    
    Args:
        description: Task description
        total: Total number of steps
        update_func: Function called at each step with current index
    """
    with Progress(
        TextColumn(f"[{MATRIX_GREEN}]{{task.description}}"),
        BarColumn(bar_width=40, style=MATRIX_DARK_GREEN, complete_style=MATRIX_BRIGHT),
        TaskProgressColumn(),
        console=console
    ) as progress:
        task = progress.add_task(description, total=total)
        for i in range(total):
            update_func(i)
            progress.update(task, advance=1)
            time.sleep(0.05)


# 
# UI COMPONENTS
# 

def clear_screen() -> None:
    """Clear the terminal screen."""
    console.clear()


def show_banner() -> None:
    """Display the Matrix-style banner."""
    banner: str = """
    ╔══════════════════════════════════════════════════════════════════════════╗
    ║                                                                          ║
    ║   ██╗  ██╗ ██████╗ ███╗   ███╗███████╗██╗    ██╗ ██████╗ ██████╗ ██╗  ██╗║
    ║   ██║  ██║██╔═══██╗████╗ ████║██╔════╝██║    ██║██╔═══██╗██╔══██╗██║ ██╔╝║
    ║   ███████║██║   ██║██╔████╔██║█████╗  ██║ █╗ ██║██║   ██║██████╔╝█████╔╝ ║
    ║   ██╔══██║██║   ██║██║╚██╔╝██║██╔══╝  ██║███╗██║██║   ██║██╔══██╗██╔═██╗ ║
    ║   ██║  ██║╚██████╔╝██║ ╚═╝ ██║███████╗╚███╔███╔╝╚██████╔╝██║  ██║██║  ██╗║
    ║   ╚═╝  ╚═╝ ╚═════╝ ╚═╝     ╚═╝╚══════╝ ╚══╝╚══╝  ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝║
    ║                                                                          ║
    ║         ██████╗ ███████╗ ██████╗ ██████╗ ██████╗ ██████╗ ███████╗██████╗ ║
    ║         ██╔══██╗██╔════╝██╔════╝██╔═══██╗██╔══██╗██╔══██╗██╔════╝██╔══██╗║
    ║         ██████╔╝█████╗  ██║     ██║   ██║██████╔╝██║  ██║█████╗  ██████╔╝║
    ║         ██╔══██╗██╔══╝  ██║     ██║   ██║██╔══██╗██║  ██║██╔══╝  ██╔══██╗║
    ║         ██║  ██║███████╗╚██████╗╚██████╔╝██║  ██║██████╔╝███████╗██║  ██║║
    ║         ╚═╝  ╚═╝╚══════╝ ╚═════╝ ╚═════╝ ╚═╝  ╚═╝╚═════╝ ╚══════╝╚═╝  ╚═╝║
    ║                                                                          ║
    ║                   [ OPERATING SYSTEMS 2023-2027 ]                        ║
    ║                        [ MATRIX EDITION v1.1 ]                           ║
    ║                                                                          ║
    ╚══════════════════════════════════════════════════════════════════════════╝
    """
    console.print(banner, style=f"bold {MATRIX_GREEN}")


def show_section(title: str, subtitle: Optional[str] = None) -> None:
    """
    Display a section header.
    
    Args:
        title: Section title
        subtitle: Optional subtitle
    """
    console.print()
    panel_content = Text(title, style=f"bold {MATRIX_BRIGHT}")
    if subtitle:
        panel_content.append(f"\n{subtitle}", style=f"{MATRIX_DARK_GREEN}")
    
    console.print(Panel(
        Align.center(panel_content),
        border_style=MATRIX_GREEN,
        box=DOUBLE,
        padding=(0, 2)
    ))
    console.print()


def show_success(message: str) -> None:
    """Display success message."""
    console.print(f"  [{MATRIX_BRIGHT}]✓[/] [{MATRIX_GREEN}]{message}[/]")


def show_error(message: str) -> None:
    """Display error message."""
    console.print(f"  [{MATRIX_RED}]✗ {message}[/]")


def show_warning(message: str) -> None:
    """Display warning message."""
    console.print(f"  [{MATRIX_YELLOW}]⚠ {message}[/]")


def show_info(message: str) -> None:
    """Display info message."""
    console.print(f"  [{MATRIX_CYAN}]ℹ {message}[/]")


# 
# VALIDATION FUNCTIONS
# 

def validate_surname(text: str) -> bool:
    """
    Validate surname.
    
    Args:
        text: String to validate
        
    Returns:
        True if it contains only letters and hyphen, 
        does not start/end with hyphen.
    
    Examples:
        >>> validate_surname("Smith")
        True
        >>> validate_surname("Jones-Williams")
        True
        >>> validate_surname("-Invalid")
        False
        >>> validate_surname("")
        False
    """
    if not text:
        return False
    if not re.match(r'^[a-zA-Z-]+$', text):
        return False
    if text.startswith('-') or text.endswith('-'):
        return False
    return True


def validate_firstname(text: str) -> bool:
    """
    Validate first name.
    
    Args:
        text: String to validate
        
    Returns:
        True if valid (same rules as validate_surname)
    """
    return validate_surname(text)


def validate_group(text: str) -> bool:
    """
    Validate group (exactly 4 digits).
    
    Args:
        text: String to validate
        
    Returns:
        True if it contains exactly 4 digits
        
    Examples:
        >>> validate_group("1029")
        True
        >>> validate_group("123")
        False
    """
    return bool(re.match(r'^\d{4}$', text))


def validate_homework(text: str) -> bool:
    """
    Validate homework number (01-07 followed by a letter).
    
    Args:
        text: String to validate
        
    Returns:
        True if it has the correct format
        
    Examples:
        >>> validate_homework("01a")
        True
        >>> validate_homework("03b")
        True
        >>> validate_homework("08a")
        False
    """
    return bool(re.match(r'^0[1-7][a-zA-Z]$', text))


# 
# DATA COLLECTION
# 

def collect_student_data() -> Dict[str, str]:
    """
    Collect and validate student data with Matrix-style prompts.
    
    Returns:
        Dict with keys: surname, firstname, group, specialization,
        specialization_name, specialization_key, homework
        
    Raises:
        KeyboardInterrupt: If user presses Ctrl+C
    """
    data: Dict[str, str] = {}
    
    # Load previous configuration (if it exists)
    config: Dict[str, Any] = load_config()
    prev_surname: str = config.get('surname', '')
    prev_firstname: str = config.get('firstname', '')
    prev_group: str = config.get('group', '')
    
    show_section("📝 STUDENT IDENTIFICATION", "Enter your details below")
    
    # Info about pre-filled values
    if prev_surname or prev_firstname or prev_group:
        show_info("Previous values are pre-filled. Press ENTER to keep them or type something else.")
        console.print()
    
    # Surname
    while True:
        default_hint: str = f" [{prev_surname}]" if prev_surname else ""
        surname: Optional[str] = questionary.text(
            f"Surname{default_hint}:",
            default=prev_surname,
            style=matrix_style,
            instruction="(letters and hyphen only, e.g.: Jones-Williams)"
        ).ask()
        
        if surname is None:  # User pressed Ctrl+C
            raise KeyboardInterrupt
        
        # If they just pressed ENTER and we have a default value
        if surname == '' and prev_surname:
            surname = prev_surname
        
        if validate_surname(surname):
            data['surname'] = surname.upper()
            show_success(f"Surname: {data['surname']}")
            break
        else:
            show_error("Invalid! Use only letters and hyphen (no spaces).")
    
    console.print()
    
    # First name
    while True:
        default_hint = f" [{prev_firstname}]" if prev_firstname else ""
        firstname: Optional[str] = questionary.text(
            f"First name{default_hint}:",
            default=prev_firstname,
            style=matrix_style,
            instruction="(letters and hyphen only, e.g.: Mary-Anne)"
        ).ask()
        
        if firstname is None:
            raise KeyboardInterrupt
        
        if firstname == '' and prev_firstname:
            firstname = prev_firstname
        
        if validate_firstname(firstname):
            data['firstname'] = firstname.title()
            show_success(f"First name: {data['firstname']}")
            break
        else:
            show_error("Invalid! Use only letters and hyphen (no spaces).")
    
    console.print()
    
    # Group
    while True:
        default_hint = f" [{prev_group}]" if prev_group else ""
        group: Optional[str] = questionary.text(
            f"Group number{default_hint}:",
            default=prev_group,
            style=matrix_style,
            instruction="(exactly 4 digits, e.g.: 1029)"
        ).ask()
        
        if group is None:
            raise KeyboardInterrupt
        
        if group == '' and prev_group:
            group = prev_group
        
        if validate_group(group):
            data['group'] = group
            show_success(f"Group: {data['group']}")
            break
        else:
            show_error("Invalid! Group must have exactly 4 digits.")
    
    console.print()
    
    # Specialisation
    spec_choices = [
        questionary.Choice(title=v[1], value=k) 
        for k, v in SPECIALIZATIONS.items()
    ]
    
    spec_choice: Optional[str] = questionary.select(
        "Select specialisation:",
        choices=spec_choices,
        style=matrix_style,
        instruction="(use arrow keys)"
    ).ask()
    
    if spec_choice is None:
        raise KeyboardInterrupt
    
    data['specialization'] = SPECIALIZATIONS[spec_choice][0]
    data['specialization_name'] = SPECIALIZATIONS[spec_choice][1]
    data['specialization_key'] = spec_choice  # Save key for config
    show_success(f"Specialisation: {data['specialization_name']}")
    
    console.print()
    
    # Homework number (NOT pre-filled - always different)
    while True:
        homework: Optional[str] = questionary.text(
            "Homework number:",
            style=matrix_style,
            instruction="(01-07 + letter, e.g.: 03b)"
        ).ask()
        
        if homework is None:
            raise KeyboardInterrupt
        
        if validate_homework(homework):
            data['homework'] = homework[:2] + homework[2].lower()
            show_success(f"Homework: HW{data['homework']}")
            break
        else:
            show_error("Invalid! Format: 01-07 followed by a letter (e.g.: 01a, 03b, 07c)")
    
    # Save configuration for next time
    save_config(data)
    
    return data


# 
# FILE OPERATIONS
# 

def generate_filename(data: Dict[str, str]) -> str:
    """
    Generate filename for homework.
    
    Args:
        data: Dict with student data
        
    Returns:
        Filename in format: GROUP_SURNAME_FirstName_HWxx.cast
    """
    return f"{data['group']}_{data['surname']}_{data['firstname']}_HW{data['homework']}.cast"


def start_recording(filepath: str, data: Dict[str, str]) -> None:
    """
    Start asciinema recording with custom stop command.
    
    Args:
        filepath: Full path to the .cast file
        data: Dict with student data
    """
    show_section("🎬 RECORDING SESSION", "Type 'STOP_homework' to stop")
    
    # Create temporary bashrc with alias
    temp_rc = tempfile.NamedTemporaryFile(mode='w', suffix='.bashrc', delete=False)
    temp_rc.write('''
# Load default configuration
if [ -f ~/.bashrc ]; then
    source ~/.bashrc
fi

# Matrix alias for stopping
alias STOP_homework='echo ""; echo -e "\\033[32m🛑 Recording stopped. Saving...\\033[0m"; exit'

# Recording start message
echo ""
echo -e "\\033[32m╔═══════════════════════════════════════════════════════════════════════╗\\033[0m"
echo -e "\\033[32m║                     🔴 RECORDING IN PROGRESS                          ║\\033[0m"
echo -e "\\033[32m╠═══════════════════════════════════════════════════════════════════════╣\\033[0m"
echo -e "\\033[32m║                                                                       ║\\033[0m"
echo -e "\\033[32m║   To STOP and SAVE the recording, type: \\033[1;33mSTOP_homework\\033[32m             ║\\033[0m"
echo -e "\\033[32m║                                                                       ║\\033[0m"
echo -e "\\033[32m║   or press Ctrl+D                                                     ║\\033[0m"
echo -e "\\033[32m║                                                                       ║\\033[0m"
echo -e "\\033[32m╚═══════════════════════════════════════════════════════════════════════╝\\033[0m"
echo ""
''')
    temp_rc.close()
    
    # Display recording information
    table = Table(box=box.ROUNDED, border_style=MATRIX_GREEN, show_header=False)
    table.add_column("Field", style=MATRIX_DARK_GREEN)
    table.add_column("Value", style=f"bold {MATRIX_BRIGHT}")
    table.add_row("Student", f"{data['surname']} {data['firstname']}")
    table.add_row("Group", data['group'])
    table.add_row("Specialisation", data['specialization'])
    table.add_row("Homework", f"HW{data['homework']}")
    table.add_row("File", os.path.basename(filepath))
    
    console.print(table)
    console.print()
    
    # Countdown
    for i in range(3, 0, -1):
        console.print(f"  [{MATRIX_YELLOW}]Starting in {i}...[/]", end="\r")
        time.sleep(1)
    console.print(f"  [{MATRIX_BRIGHT}]🎬 RECORDING![/]          ")
    console.print()
    
    # Run asciinema
    try:
        subprocess.run(
            ['asciinema', 'rec', '--overwrite', filepath, '-c', f'bash --rcfile {temp_rc.name}'],
            check=True
        )
    finally:
        # Cleanup
        os.unlink(temp_rc.name)
    
    console.print()
    show_success("Recording completed!")


def generate_signature(filepath: str, data: Dict[str, str]) -> str:
    """
    Generate cryptographic signature for the recording.
    
    Args:
        filepath: Path to the .cast file
        data: Dict with student data
        
    Returns:
        Data string that was signed
    """
    show_section("🔐 CRYPTOGRAPHIC SIGNATURE", "Securing the homework...")
    
    def do_sign() -> str:
        # Get file information
        file_size: int = os.path.getsize(filepath)
        current_date: str = datetime.now().strftime("%d-%m-%Y")
        current_time: str = datetime.now().strftime("%H:%M:%S")
        system_user: str = os.getenv('USER', 'unknown')
        absolute_path: str = os.path.abspath(filepath)
        
        # Build data for signature
        data_to_sign: str = f"{data['surname']}+{data['firstname']} {data['group']} {file_size} {current_date} {current_time} {system_user} {absolute_path}"
        
        # Save public key temporarily
        temp_key = tempfile.NamedTemporaryFile(mode='w', suffix='.pem', delete=False)
        temp_key.write(PUBLIC_KEY)
        temp_key.close()
        
        try:
            # Encrypt with RSA
            process = subprocess.run(
                ['openssl', 'pkeyutl', '-encrypt', '-pubin', '-inkey', temp_key.name, '-pkeyopt', 'rsa_padding_mode:pkcs1'],
                input=data_to_sign.encode(),
                capture_output=True,
                check=True
            )
            
            # Convert to base64
            encrypted_b64: str = base64.b64encode(process.stdout).decode()
            
            # Append to file
            with open(filepath, 'a') as f:
                f.write(f"\n## {encrypted_b64}\n")
            
            return data_to_sign
        finally:
            os.unlink(temp_key.name)
    
    # Execute with spinner
    signed_data: str = spinner_task("Generating RSA signature...", do_sign)
    
    show_success("Cryptographic signature added!")
    show_info(f"Signed data: {signed_data[:50]}...")
    
    return signed_data


def upload_homework(filepath: str, data: Dict[str, str]) -> bool:
    """
    Upload homework to server with retry logic.
    
    Args:
        filepath: Path to the .cast file
        data: Dict with student data
        
    Returns:
        True if upload succeeded, False otherwise
    """
    show_section("📤 UPLOADING TO SERVER", f"Destination: {SCP_SERVER}:{SCP_PORT}")
    
    filename: str = os.path.basename(filepath)
    scp_user: str = "stud-id"
    scp_dest: str = f"{SCP_BASE_PATH}/{data['specialization']}"
    
    # Display connection information
    table = Table(box=box.ROUNDED, border_style=MATRIX_GREEN, show_header=False)
    table.add_column("", style=MATRIX_DARK_GREEN)
    table.add_column("", style=f"bold {MATRIX_CYAN}")
    table.add_row("Server", f"{SCP_SERVER}:{SCP_PORT}")
    table.add_row("User", scp_user)
    table.add_row("Destination", scp_dest)
    table.add_row("File", filename)
    console.print(table)
    console.print()
    
    for attempt in range(1, MAX_RETRIES + 1):
        show_info(f"Attempt {attempt} of {MAX_RETRIES}...")
        
        try:
            # Simulate progress
            with Progress(
                SpinnerColumn(spinner_name="dots12", style=f"bold {MATRIX_GREEN}"),
                TextColumn(f"[{MATRIX_GREEN}]Uploading..."),
                BarColumn(bar_width=30, style=MATRIX_DARK_GREEN, complete_style=MATRIX_BRIGHT),
                TaskProgressColumn(),
                console=console,
                transient=True
            ) as progress:
                task = progress.add_task("upload", total=100)
                
                # Start SCP in background
                process = subprocess.Popen(
                    [
                        'sshpass', '-p', SCP_PASSWORD,
                        'scp', '-P', SCP_PORT,
                        '-o', 'StrictHostKeyChecking=no',
                        '-o', 'UserKnownHostsFile=/dev/null',
                        '-o', 'LogLevel=ERROR',
                        filepath,
                        f"{scp_user}@{SCP_SERVER}:{scp_dest}/"
                    ],
                    stdout=subprocess.DEVNULL,
                    stderr=subprocess.DEVNULL
                )
                
                # Simulate progress while waiting
                while process.poll() is None:
                    current: float = progress.tasks[0].completed
                    if current < 90:
                        progress.update(task, advance=random.randint(5, 15))
                    time.sleep(0.3)
                
                progress.update(task, completed=100)
            
            if process.returncode == 0:
                console.print()
                console.print(Panel(
                    Align.center(Text("✅ UPLOAD SUCCESSFUL!", style=f"bold {MATRIX_BRIGHT}")),
                    border_style=MATRIX_GREEN,
                    box=DOUBLE
                ))
                return True
            else:
                raise subprocess.CalledProcessError(process.returncode, 'scp')
                
        except Exception:
            show_warning(f"Attempt {attempt} failed.")
            if attempt < MAX_RETRIES:
                show_info("Retrying in 3 seconds...")
                time.sleep(3)
    
    # All attempts failed
    console.print()
    console.print(Panel(
        Align.center(Text.from_markup(f"""[bold {MATRIX_RED}]❌ COULD NOT SEND HOMEWORK![/]

[{MATRIX_YELLOW}]The file has been saved locally.[/]

[bold {MATRIX_BRIGHT}]
╔════════════════════════════════════════════════════════════════════════════╗
║                                                                            ║
║   📁  {filename:<68} ║
║                                                                            ║
╚════════════════════════════════════════════════════════════════════════════╝
[/]

[{MATRIX_CYAN}]Try later (when you restore internet connection) using:[/]

[bold {MATRIX_GREEN}]scp -P {SCP_PORT} {filename} {scp_user}@{SCP_SERVER}:{scp_dest}/[/]

[{MATRIX_YELLOW}]⚠️  DO NOT modify the .cast file before sending![/]""")),
        border_style=MATRIX_RED,
        box=DOUBLE,
        title="[bold] Submission Failed [/]",
        title_align="center"
    ))
    
    return False


# 
# MAIN FLOW
# 

def show_summary(data: Dict[str, str], filepath: str, upload_success: bool) -> None:
    """
    Display final summary.
    
    Args:
        data: Dict with student data
        filepath: Path to the .cast file
        upload_success: True if upload succeeded
    """
    show_section("📋 FINAL SUMMARY", "Session complete")
    
    table = Table(box=box.DOUBLE, border_style=MATRIX_GREEN)
    table.add_column("Field", style=MATRIX_DARK_GREEN)
    table.add_column("Value", style=f"bold {MATRIX_BRIGHT}")
    
    table.add_row("Student", f"{data['surname']} {data['firstname']}")
    table.add_row("Group", data['group'])
    table.add_row("Specialisation", data['specialization_name'])
    table.add_row("Homework", f"HW{data['homework']}")
    table.add_row("File", os.path.basename(filepath))
    table.add_row("Local path", filepath)
    
    status: str = f"[{MATRIX_BRIGHT}]✓ Uploaded[/]" if upload_success else f"[{MATRIX_YELLOW}]⚠ Local only[/]"
    table.add_row("Status", status)
    
    console.print(table)


def main() -> None:
    """Main entry point."""
    try:
        clear_screen()
        
        # Intro with Matrix rain
        matrix_rain(duration=1.0)
        
        clear_screen()
        show_banner()
        
        time.sleep(0.5)
        
        # Collect data
        data: Dict[str, str] = collect_student_data()
        
        # Generate filename
        filename: str = generate_filename(data)
        filepath: str = os.path.join(os.getcwd(), filename)
        
        console.print()
        show_section("📄 FILE INFORMATION")
        show_success(f"Filename: {filename}")
        show_info(f"Path: {filepath}")
        
        # Confirm before recording
        console.print()
        confirm_result: Optional[bool] = questionary.confirm(
            "Are you ready to start recording?",
            style=matrix_style,
            default=True
        ).ask()
        
        if not confirm_result:
            show_warning("Recording cancelled.")
            return
        
        # Start recording
        start_recording(filepath, data)
        
        # Generate signature
        console.print()
        generate_signature(filepath, data)
        
        # Upload
        console.print()
        upload_success: bool = upload_homework(filepath, data)
        
        # Summary
        console.print()
        show_summary(data, filepath, upload_success)
        
        # Final message
        console.print()
        console.print(Panel(
            Align.center(Text("🎉 PROCESS COMPLETED!", style=f"bold {MATRIX_BRIGHT}")),
            border_style=MATRIX_GREEN,
            box=DOUBLE
        ))
        
        # Exit with Matrix effect
        console.print()
        typing_effect("Thank you for using Homework Recorder. Good luck!", style=MATRIX_GREEN, delay=0.03)
        console.print()
        
    except KeyboardInterrupt:
        console.print()
        show_warning("Operation cancelled by user.")
        sys.exit(1)
    except Exception as e:
        console.print()
        show_error(f"An error occurred: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()
