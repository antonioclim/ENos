#!/usr/bin/env python3
"""
S04_04_personalized_data_generator.py — Deterministic Teaching Data Generator

Generates ID-seeded synthetic practice data. The 32-bit seed can collide;
personalisation is not proof of authorship or prevention of solution sharing.
The legacy 12-character MD5 value is a dataset identifier, not authentication.
--verify compares that identifier only; --verify-files compares all five files
byte-for-byte with regenerated content and still makes no authorship claim.

Usage:
    python3 S04_04_personalized_data_generator.py <MATRICOL>
    python3 S04_04_personalized_data_generator.py --verify <MATRICOL> <CHECKSUM>

Author: ing. dr. Antonio Clim, ASE Bucharest — CSIE
Version: 1.0

Retained author account (anecdotal, not a measured detection guarantee):
    Last semester I caught 3 students with identical outputs on 'random' data.
    Turns out they shared solutions. Now each student gets unique data,
    so even if they share code, the outputs will not match. Checkmate.
"""

import argparse
import hashlib
import re
import random
import sys
import json
from pathlib import Path
from datetime import datetime, timedelta
from typing import Dict, Any, List, Tuple

# ═══════════════════════════════════════════════════════════════════════════════
# CONFIGURATION
# ═══════════════════════════════════════════════════════════════════════════════

# Romanian first and last names for realistic data
FIRST_NAMES = [
    "Andrei", "Maria", "Ion", "Elena", "Alexandru", "Ana", "Mihai", "Ioana",
    "George", "Cristina", "Adrian", "Gabriela", "Florin", "Daniela", "Bogdan",
    "Alina", "Vlad", "Roxana", "Radu", "Simona", "Dan", "Andreea", "Cosmin"
]

LAST_NAMES = [
    "Popescu", "Ionescu", "Popa", "Dumitrescu", "Stan", "Stoica", "Gheorghe",
    "Rusu", "Munteanu", "Matei", "Constantin", "Serban", "Moldovan", "Nistor",
    "Tudor", "Dragomir", "Badea", "Neagu", "Ciobanu", "Dinu", "Preda", "Luca"
]

DEPARTMENTS = ["IT", "HR", "Sales", "Marketing", "Finance", "Operations", "R&D"]
PRODUCTS = ["Laptop", "Monitor", "Keyboard", "Mouse", "Headphones", "Webcam", "SSD", "RAM"]
REGIONS = ["North", "South", "East", "West", "Central"]
LOG_LEVELS = ["INFO", "DEBUG", "WARNING", "ERROR"]
HTTP_METHODS = ["GET", "POST", "PUT", "DELETE"]
HTTP_CODES = [200, 200, 200, 200, 200, 201, 301, 400, 401, 403, 404, 500]
PATHS = ["/index.html", "/api/users", "/api/login", "/dashboard", "/admin", "/products", "/cart"]


# ═══════════════════════════════════════════════════════════════════════════════
# CORE FUNCTIONS
# ═══════════════════════════════════════════════════════════════════════════════

def generate_seed(student_id: str) -> int:
    """
    Transform student ID into a reproducible random seed.
    Same ID always generates the same data.
    """
    hash_bytes = hashlib.sha256(student_id.encode()).digest()
    return int.from_bytes(hash_bytes[:4], byteorder='big')


def generate_access_log(rng: random.Random, num_lines: int) -> Tuple[List[str], Dict]:
    """Generate access.log with tracking of correct answers."""
    lines = []
    stats = {
        'ip_counts': {},
        'method_counts': {},
        'code_counts': {},
        'total_lines': num_lines
    }
    
    # Generate a pool of IPs for this student
    ip_pool = [f"192.168.{rng.randint(1, 10)}.{rng.randint(1, 254)}" 
               for _ in range(rng.randint(8, 15))]
    
    base_date = datetime(2025, 1, 15, 8, 0, 0)
    
    for i in range(num_lines):
        ip = rng.choice(ip_pool)
        method = rng.choice(HTTP_METHODS)
        code = rng.choice(HTTP_CODES)
        path = rng.choice(PATHS)
        size = rng.randint(100, 15000)
        
        timestamp = base_date + timedelta(seconds=i * rng.randint(1, 30))
        month = ("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec")[timestamp.month - 1]
        ts_str = timestamp.strftime(f"%d/{month}/%Y:%H:%M:%S +0200")
        
        line = f'{ip} - - [{ts_str}] "{method} {path} HTTP/1.1" {code} {size}'
        lines.append(line)
        
        # Track stats
        stats['ip_counts'][ip] = stats['ip_counts'].get(ip, 0) + 1
        stats['method_counts'][method] = stats['method_counts'].get(method, 0) + 1
        stats['code_counts'][code] = stats['code_counts'].get(code, 0) + 1
    
    # Calculate derived stats
    stats['unique_ips'] = len(stats['ip_counts'])
    stats['top_ip'] = max(stats['ip_counts'], key=stats['ip_counts'].get)
    stats['top_ip_count'] = stats['ip_counts'][stats['top_ip']]
    stats['error_count'] = sum(v for k, v in stats['code_counts'].items() if k >= 400)
    stats['error_rate'] = round(stats['error_count'] / num_lines * 100, 2)
    
    return lines, stats


def generate_server_log(rng: random.Random, num_lines: int) -> Tuple[List[str], Dict]:
    """Generate server.log with various log levels."""
    lines = []
    stats = {
        'level_counts': {level: 0 for level in LOG_LEVELS},
        'total_lines': num_lines,
        'failed_auth': []
    }
    
    ip_pool = [f"192.168.{rng.randint(1, 10)}.{rng.randint(1, 254)}" 
               for _ in range(6)]
    
    email_pool = [f"{rng.choice(FIRST_NAMES).lower()}.{rng.choice(LAST_NAMES).lower()}@test.com"
                  for _ in range(5)]
    
    messages = {
        'INFO': [
            "Application started successfully",
            "User {} logged in from {}",
            "Request processed in {}ms",
            "Cache refreshed",
            "Configuration reloaded"
        ],
        'DEBUG': [
            "Processing request for endpoint {}",
            "Database query executed: {} rows",
            "Memory usage: {}MB"
        ],
        'WARNING': [
            "High memory usage detected: {}%",
            "Slow query detected: {}ms",
            "Rate limit approaching for IP {}"
        ],
        'ERROR': [
            "Database connection failed",
            "Authentication failed for {} from {}",
            "Internal server error in module {}"
        ]
    }
    
    base_date = datetime(2025, 1, 15, 8, 23, 45)
    
    for i in range(num_lines):
        # Weight towards INFO
        weights = [50, 20, 15, 15]  # INFO, DEBUG, WARNING, ERROR
        level = rng.choices(LOG_LEVELS, weights=weights)[0]
        
        timestamp = base_date + timedelta(seconds=i * rng.randint(5, 60))
        ts_str = timestamp.strftime("%Y-%m-%d %H:%M:%S")
        
        msg_template = rng.choice(messages[level])
        
        # Fill in placeholders
        if '{}' in msg_template:
            if 'logged in' in msg_template:
                email = rng.choice(email_pool)
                ip = rng.choice(ip_pool)
                msg = msg_template.format(email, ip)
            elif 'Authentication failed' in msg_template:
                email = rng.choice(email_pool)
                ip = rng.choice(ip_pool)
                msg = msg_template.format(email, ip)
                stats['failed_auth'].append({
                    'time': timestamp.strftime("%H:%M:%S"),
                    'email': email,
                    'ip': ip
                })
            elif 'memory' in msg_template.lower() or 'Memory' in msg_template:
                msg = msg_template.format(rng.randint(60, 95))
            elif 'ms' in msg_template:
                msg = msg_template.format(rng.randint(100, 5000))
            elif 'rows' in msg_template:
                msg = msg_template.format(rng.randint(10, 1000))
            elif 'endpoint' in msg_template:
                msg = msg_template.format(rng.choice(PATHS))
            elif 'module' in msg_template:
                msg = msg_template.format(rng.choice(['auth', 'api', 'db', 'cache']))
            elif 'IP' in msg_template:
                msg = msg_template.format(rng.choice(ip_pool))
            else:
                msg = msg_template.format(rng.randint(1, 100))
        else:
            msg = msg_template
        
        line = f"[{ts_str}] [{level}] {msg}"
        lines.append(line)
        stats['level_counts'][level] += 1
    
    return lines, stats


def generate_employees_csv(rng: random.Random, num_employees: int) -> Tuple[List[str], Dict]:
    """Generate employees.csv with department statistics."""
    lines = ["ID,Name,Department,Salary,Email,HireDate,Status"]
    stats = {
        'total_employees': num_employees,
        'dept_stats': {},
        'salary_total': 0
    }
    
    used_names = set()
    statuses = ['active', 'active', 'active', 'active', 'inactive', 'on_leave']
    
    for i in range(num_employees):
        # Generate unique name
        attempts = 0
        while attempts < 100:
            first = rng.choice(FIRST_NAMES)
            last = rng.choice(LAST_NAMES)
            name = f"{first} {last}"
            if name not in used_names:
                used_names.add(name)
                break
            attempts += 1
        
        emp_id = 1001 + i
        dept = rng.choice(DEPARTMENTS)
        salary = rng.randint(45, 95) * 1000
        email = f"{first.lower()}.{last.lower()}@techcorp.ro"
        hire_year = rng.randint(2018, 2024)
        hire_date = f"{hire_year}-{rng.randint(1,12):02d}-{rng.randint(1,28):02d}"
        status = rng.choice(statuses)
        
        line = f"{emp_id},{name},{dept},{salary},{email},{hire_date},{status}"
        lines.append(line)
        
        # Track stats
        if dept not in stats['dept_stats']:
            stats['dept_stats'][dept] = {'count': 0, 'salaries': [], 'total': 0}
        stats['dept_stats'][dept]['count'] += 1
        stats['dept_stats'][dept]['salaries'].append(salary)
        stats['dept_stats'][dept]['total'] += salary
        stats['salary_total'] += salary
    
    # Calculate aggregates
    for dept, data in stats['dept_stats'].items():
        data['avg'] = round(data['total'] / data['count'], 2)
        data['min'] = min(data['salaries'])
        data['max'] = max(data['salaries'])
        del data['salaries']  # Do not need the full list
    
    stats['salary_avg'] = round(stats['salary_total'] / num_employees, 2)
    
    return lines, stats


def generate_sales_csv(rng: random.Random, num_sales: int) -> Tuple[List[str], Dict]:
    """Generate sales.csv with product and region statistics."""
    lines = ["Date,Product,Quantity,UnitPrice,Region,Salesperson"]
    stats = {
        'total_sales': num_sales,
        'product_stats': {},
        'region_stats': {},
        'salesperson_stats': {},
        'total_revenue': 0
    }
    
    # Generate salesperson pool
    salespeople = [f"{rng.choice(FIRST_NAMES)}" for _ in range(6)]
    
    # Price ranges per product
    price_ranges = {
        "Laptop": (800, 1500),
        "Monitor": (200, 500),
        "Keyboard": (50, 150),
        "Mouse": (20, 80),
        "Headphones": (50, 200),
        "Webcam": (80, 200),
        "SSD": (100, 300),
        "RAM": (50, 200)
    }
    
    base_date = datetime(2025, 1, 1)
    
    for i in range(num_sales):
        date = base_date + timedelta(days=rng.randint(0, 30))
        date_str = date.strftime("%Y-%m-%d")
        
        product = rng.choice(PRODUCTS)
        quantity = rng.randint(1, 10)
        price_range = price_ranges[product]
        unit_price = round(rng.uniform(*price_range), 2)
        region = rng.choice(REGIONS)
        salesperson = rng.choice(salespeople)
        
        revenue = round(quantity * unit_price, 2)
        
        line = f"{date_str},{product},{quantity},{unit_price},{region},{salesperson}"
        lines.append(line)
        
        # Track stats
        if product not in stats['product_stats']:
            stats['product_stats'][product] = {'units': 0, 'revenue': 0}
        stats['product_stats'][product]['units'] += quantity
        stats['product_stats'][product]['revenue'] += revenue
        
        if region not in stats['region_stats']:
            stats['region_stats'][region] = {'revenue': 0}
        stats['region_stats'][region]['revenue'] += revenue
        
        key = f"{region}:{salesperson}"
        if key not in stats['salesperson_stats']:
            stats['salesperson_stats'][key] = 0
        stats['salesperson_stats'][key] += revenue
        
        stats['total_revenue'] += revenue
    
    # Round all revenues
    stats['total_revenue'] = round(stats['total_revenue'], 2)
    for p in stats['product_stats'].values():
        p['revenue'] = round(p['revenue'], 2)
    for r in stats['region_stats'].values():
        r['revenue'] = round(r['revenue'], 2)
    
    # Find top performers
    stats['top_products'] = sorted(
        stats['product_stats'].items(),
        key=lambda x: x[1]['revenue'],
        reverse=True
    )[:3]
    
    stats['top_regions'] = sorted(
        stats['region_stats'].items(),
        key=lambda x: x[1]['revenue'],
        reverse=True
    )[:3]
    
    return lines, stats


def generate_contacts_txt(rng: random.Random) -> Tuple[List[str], Dict]:
    """Generate contacts.txt with emails, IPs and phone numbers."""
    lines = []
    stats = {
        'valid_emails': [],
        'invalid_emails': [],
        'ips': [],
        'phones': []
    }
    
    # Valid emails
    for _ in range(rng.randint(6, 10)):
        first = rng.choice(FIRST_NAMES).lower()
        last = rng.choice(LAST_NAMES).lower()
        domain = rng.choice(['gmail.com', 'yahoo.ro', 'outlook.com', 'company.ro'])
        
        formats = [
            f"{first}.{last}@{domain}",
            f"{first}_{last}@{domain}",
            f"{first}{rng.randint(1,99)}@{domain}",
            f"{first}.{last}+work@{domain}"
        ]
        email = rng.choice(formats)
        lines.append(f"Contact: {email}")
        stats['valid_emails'].append(email)
    
    # Invalid emails
    invalid = [
        "invalid@",
        "@nodomain.com",
        "spaces in@email.com",
        "missing.domain@",
        "double@@at.com"
    ]
    for inv in rng.sample(invalid, 3):
        lines.append(f"Contact: {inv}")
        stats['invalid_emails'].append(inv)
    
    # IPs
    for _ in range(rng.randint(5, 8)):
        ip = f"{rng.randint(1,255)}.{rng.randint(0,255)}.{rng.randint(0,255)}.{rng.randint(1,254)}"
        lines.append(f"Server IP: {ip}")
        stats['ips'].append(ip)
    
    # Romanian phone numbers
    phone_formats = [
        lambda: f"07{rng.randint(20,89)}-{rng.randint(100,999)}-{rng.randint(100,999)}",
        lambda: f"07{rng.randint(20,89)}.{rng.randint(100,999)}.{rng.randint(100,999)}",
        lambda: f"07{rng.randint(20,89)} {rng.randint(100,999)} {rng.randint(100,999)}",
        lambda: f"07{rng.randint(20,89)}{rng.randint(100,999)}{rng.randint(100,999)}"
    ]
    for fmt in phone_formats:
        phone = fmt()
        lines.append(f"Phone: {phone}")
        stats['phones'].append(phone)
    
    rng.shuffle(lines)
    
    stats['total_valid_emails'] = len(stats['valid_emails'])
    stats['total_invalid_emails'] = len(stats['invalid_emails'])
    stats['unique_ips'] = len(set(stats['ips']))
    stats['total_phones'] = len(stats['phones'])
    
    return lines, stats


def compute_checksum(files_content: Dict[str, str]) -> str:
    """Retain the historical MD5 dataset identifier; not a content authentication protocol."""
    combined = ''.join(sorted(files_content.values()))
    return hashlib.md5(combined.encode()).hexdigest()[:12]


# ═══════════════════════════════════════════════════════════════════════════════
# MAIN FUNCTIONS
# ═══════════════════════════════════════════════════════════════════════════════

def generate_student_data(student_id: str) -> Dict[str, Any]:
    """Generate all data files for a student."""
    seed = generate_seed(student_id)
    rng = random.Random(seed)
    
    # Randomise sizes slightly per student
    num_access = rng.randint(60, 100)
    num_server = rng.randint(25, 40)
    num_employees = rng.randint(12, 20)
    num_sales = rng.randint(40, 60)
    
    # Generate all files
    access_lines, access_stats = generate_access_log(rng, num_access)
    server_lines, server_stats = generate_server_log(rng, num_server)
    employees_lines, employees_stats = generate_employees_csv(rng, num_employees)
    sales_lines, sales_stats = generate_sales_csv(rng, num_sales)
    contacts_lines, contacts_stats = generate_contacts_txt(rng)
    
    files = {
        'access.log': '\n'.join(access_lines),
        'server.log': '\n'.join(server_lines),
        'employees.csv': '\n'.join(employees_lines),
        'sales.csv': '\n'.join(sales_lines),
        'contacts.txt': '\n'.join(contacts_lines)
    }
    
    checksum = compute_checksum(files)
    
    answers = {
        'student_id': student_id,
        'checksum': checksum,
        'generated_at': datetime.now().isoformat(),
        'access_log': access_stats,
        'server_log': server_stats,
        'employees_csv': employees_stats,
        'sales_csv': sales_stats,
        'contacts_txt': contacts_stats
    }
    
    return {
        'files': files,
        'answers': answers,
        'checksum': checksum
    }


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    mode = parser.add_mutually_exclusive_group()
    mode.add_argument('--verify', nargs=2, metavar=('ID', 'CHECKSUM'), help='Compare the legacy identifier only; no submitted files are read')
    mode.add_argument('--verify-files', nargs=2, metavar=('ID', 'DIRECTORY'), help='Compare all five named files against regenerated bytes, read-only')
    parser.add_argument('--output-dir', type=Path, default=Path('.'), help='Existing parent directory for new generated folders')
    parser.add_argument('student_id', nargs='?')
    args = parser.parse_args(argv)
    if (args.verify or args.verify_files) and args.student_id is not None:
        parser.error('do not combine a verification mode with a positional ID')
    student_id = (args.verify or args.verify_files or [args.student_id])[0]
    if student_id is None or not re.fullmatch(r'[A-Za-z0-9][A-Za-z0-9_-]{0,63}', student_id):
        parser.error('ID must contain 1-64 ASCII letters/digits, underscore or hyphen, starting with a letter/digit')
    data = generate_student_data(student_id)
    if args.verify:
        matches = args.verify[1] == data['checksum']
        print(('MATCH' if matches else 'MISMATCH') + ': legacy dataset identifier; submitted files and authorship were not verified')
        return 0 if matches else 1
    if args.verify_files:
        folder = Path(args.verify_files[1])
        failures = []
        for name, content in data['files'].items():
            try:
                if (folder / name).read_bytes() != content.encode('utf-8'):
                    failures.append(name + ': content differs')
            except OSError as exc:
                failures.append(name + ': ' + str(exc))
        if failures:
            print('File comparison failed:\n' + '\n'.join(failures), file=sys.stderr)
            return 1
        print('All five generated data files match byte-for-byte; authorship and institutional acceptance are unverified')
        return 0
    parent = args.output_dir
    if not parent.is_dir() or parent.is_symlink():
        parser.error('--output-dir must name an existing real directory')
    output_dir = parent / f'student_{student_id}'
    instructor_dir = parent / 'instructor_answers'
    answer_file = instructor_dir / f'{student_id}_answers.json'
    if output_dir.exists() or output_dir.is_symlink() or answer_file.exists() or answer_file.is_symlink():
        parser.error('generated destination already exists; choose a fresh parent directory to regenerate without overwriting')
    if instructor_dir.is_symlink() or (instructor_dir.exists() and not instructor_dir.is_dir()):
        parser.error('instructor_answers must be a real directory, not a symlink/file')
    try:
        output_dir.mkdir()
        instructor_dir.mkdir(exist_ok=True)
        for name, content in data['files'].items():
            with (output_dir / name).open('x', encoding='utf-8', newline='') as stream:
                stream.write(content)
        manifest = {
            'provenance': 'DERIVED synthetic ID-seeded teaching data',
            'student_id': student_id,
            'legacy_dataset_identifier': data['checksum'],
            'files_sha256': {name: hashlib.sha256(content.encode('utf-8')).hexdigest() for name, content in data['files'].items()},
            'authentication': 'UNVERIFIED',
        }
        with (output_dir / 'data_manifest.json').open('x', encoding='utf-8') as stream:
            json.dump(manifest, stream, indent=2)
        with answer_file.open('x', encoding='utf-8') as stream:
            json.dump(data['answers'], stream, indent=2, default=str)
    except OSError as exc:
        print(f'Generation incomplete: {exc}. Retain/inspect any partial owned outputs.', file=sys.stderr)
        return 1
    print(f'Data generated: {output_dir}')
    print(f'Checksum: {data["checksum"]} (legacy identifier)')
    print(f'Answer file: {answer_file} (separate location does not provide confidentiality)')
    print('Per-file SHA-256 values are in data_manifest.json; none authenticates the student.')
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
