#!/usr/bin/env python3
"""
AI Fingerprint Scanner - Detects typical LLM-generated patterns
Operating Systems | ASE Bucharest - CSIE

Purpose: Scan documentation for obvious AI generation traces
Usage: python3 S01_06_ai_fingerprint_scanner.py [directory_path]
"""

import re
import sys
from pathlib import Path
from typing import List, Tuple, Dict
from dataclasses import dataclass


@dataclass
class Finding:
    """Represents a detected AI pattern."""
    file: Path
    line_num: int
    pattern: str
    context: str
    suggestion: str


# AI patterns with replacement suggestions
AI_PATTERNS: List[Tuple[str, str, str]] = [
    (r'\bcomprehensive\b', 'comprehensive', 'complete, thorough, detailed'),
    (r'\brobust\b', 'robust', 'solid, resilient, reliable'),
    (r'\bleverage\b', 'leverage', 'use, take advantage of, exploit'),
    (r'\bseamless\b', 'seamless', 'smooth, fluid, uninterrupted'),
    (r'\bdelve\b', 'delve', 'explore, examine, look into'),
    (r'\bfacilitate\b', 'facilitate', 'enable, allow, make possible'),
    (r'\butilize\b', 'utilize', 'use'),
    (r'\benhance\b', 'enhance', 'improve, increase, strengthen'),
    (r'\boptimize\b', 'optimize', 'improve, make more efficient'),
    (r'\bstreamline\b', 'streamline', 'simplify, make more efficient'),
    (r'\bpivotal\b', 'pivotal', 'essential, crucial, key'),
    (r'\bparadigm\b', 'paradigm', 'model, approach, framework'),
    (r'\bholistic\b', 'holistic', 'complete, overall, integrated'),
    (r'\bsynergy\b', 'synergy', 'collaboration, combined effect'),
    (r'\bproactive\b', 'proactive', 'preventive, anticipatory'),
    (r"\bit'?s important to note\b", "it's important to note", 'DELETE entirely'),
    (r'\bin order to\b', 'in order to', 'to'),
    (r'\bplethora\b', 'plethora', 'many, numerous, a lot of'),
    (r'\bmyriad\b', 'myriad', 'many, diverse, various'),
    (r'\bculminates?\b', 'culminate', 'ends with, leads to, results in'),
    (r'\bfostering?\b', 'foster', 'encourage, promote, develop'),
    (r'\bempowering?\b', 'empower', 'enable, allow, give the ability'),
    (r'\bunderpinning?\b', 'underpin', 'support, form the basis of'),
    (r'\boverarchings?\b', 'overarching', 'general, overall, main'),
    (r'\bensure\b', 'ensure (if overused)', 'verify, check, guarantee'),
]


class Colours:
    """ANSI colour codes for terminal output."""
    RED = '\033[0;31m'
    GREEN = '\033[0;32m'
    YELLOW = '\033[1;33m'
    BLUE = '\033[0;34m'
    CYAN = '\033[0;36m'
    NC = '\033[0m'
    BOLD = '\033[1m'


def scan_file(filepath: Path) -> List[Finding]:
    """
    Scan a file for AI patterns.
    
    Args:
        filepath: Path to the file to scan
        
    Returns:
        List of Finding objects with all detections
    """
    findings = []
    
    try:
        content = filepath.read_text(encoding='utf-8')
        lines = content.split('\n')
    except Exception as e:
        print(f"{Colours.RED}Error reading {filepath}: {e}{Colours.NC}")
        return findings
    
    for line_num, line in enumerate(lines, 1):
        for pattern, name, suggestion in AI_PATTERNS:
            matches = re.finditer(pattern, line, re.IGNORECASE)
            for match in matches:
                start = max(0, match.start() - 30)
                end = min(len(line), match.end() + 30)
                context = line[start:end]
                if start > 0:
                    context = '...' + context
                if end < len(line):
                    context = context + '...'
                
                findings.append(Finding(
                    file=filepath,
                    line_num=line_num,
                    pattern=name,
                    context=context,
                    suggestion=suggestion
                ))
    
    return findings


def scan_directory(directory: Path, extensions: List[str] = None) -> Dict[Path, List[Finding]]:
    """
    Recursively scan a directory for AI patterns.
    
    Args:
        directory: Directory to scan
        extensions: List of file extensions (default: .md, .txt)
        
    Returns:
        Dict mapping files to their findings
    """
    if extensions is None:
        extensions = ['.md', '.txt', '.rst']
    
    results = {}
    
    for ext in extensions:
        for filepath in directory.rglob(f'*{ext}'):
            findings = scan_file(filepath)
            if findings:
                results[filepath] = findings
    
    return results


def generate_report(results: Dict[Path, List[Finding]], verbose: bool = True) -> str:
    """
    Generate a text report with all findings.
    
    Args:
        results: Dict with scan results
        verbose: Whether to include full details
        
    Returns:
        Formatted report as string
    """
    lines = []
    lines.append("=" * 70)
    lines.append("  AI FINGERPRINT SCAN REPORT")
    lines.append("=" * 70)
    lines.append("")
    
    total_findings = sum(len(f) for f in results.values())
    lines.append(f"Files scanned with issues: {len(results)}")
    lines.append(f"Total patterns detected: {total_findings}")
    lines.append("")
    
    if total_findings == 0:
        lines.append(f"{Colours.GREEN}[OK] No AI patterns detected!{Colours.NC}")
        return '\n'.join(lines)
    
    # Group by pattern for statistics
    pattern_counts: Dict[str, int] = {}
    for findings in results.values():
        for f in findings:
            pattern_counts[f.pattern] = pattern_counts.get(f.pattern, 0) + 1
    
    lines.append("-" * 70)
    lines.append("SUMMARY BY PATTERN:")
    lines.append("-" * 70)
    for pattern, count in sorted(pattern_counts.items(), key=lambda x: -x[1]):
        lines.append(f"  [{count:3d}x] {pattern}")
    lines.append("")
    
    if verbose:
        lines.append("-" * 70)
        lines.append("DETAILS BY FILE:")
        lines.append("-" * 70)
        
        for filepath, findings in sorted(results.items()):
            lines.append(f"\n{Colours.CYAN}{filepath.name}{Colours.NC}")
            for f in findings:
                lines.append(f"  L{f.line_num:4d}: {Colours.YELLOW}{f.pattern}{Colours.NC}")
                lines.append(f"         Context: \"{f.context}\"")
                lines.append(f"         -> Replace with: {Colours.GREEN}{f.suggestion}{Colours.NC}")
    
    lines.append("")
    lines.append("=" * 70)
    
    return '\n'.join(lines)


def main():
    """Main entry point."""
    if len(sys.argv) < 2:
        target_dir = Path('docs')
    else:
        target_dir = Path(sys.argv[1])
    
    if not target_dir.exists():
        print(f"{Colours.RED}Error: Directory '{target_dir}' does not exist!{Colours.NC}")
        sys.exit(1)
    
    print(f"{Colours.BLUE}Scanning {target_dir} for AI patterns...{Colours.NC}\n")
    
    results = scan_directory(target_dir)
    report = generate_report(results)
    print(report)
    
    # Exit code for CI/CD integration
    total_findings = sum(len(f) for f in results.values())
    sys.exit(0 if total_findings == 0 else 1)


if __name__ == '__main__':
    main()
