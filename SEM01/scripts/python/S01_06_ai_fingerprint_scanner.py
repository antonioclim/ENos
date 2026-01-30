#!/usr/bin/env python3
"""
AI Fingerprint Scanner - Detects typical LLM-generated patterns
Operating Systems | ASE Bucharest - CSIE

Purpose: Scan documentation for obvious AI generation traces
Usage: python3 S01_06_ai_fingerprint_scanner.py [directory_path]

FAZA 5 UPDATE: Extended with HIGH_RISK, MEDIUM_RISK, and STRUCTURAL patterns
"""

import argparse
import json
import logging
import re
import sys
from pathlib import Path
from typing import List, Tuple, Dict, Any
from dataclasses import dataclass, field, asdict
from enum import Enum

# Logging setup — import shared utilities from kit lib
sys.path.insert(0, str(Path(__file__).parent.parent.parent.parent / 'lib'))
from logging_utils import setup_logging

logger = setup_logging(__name__)


class RiskLevel(Enum):
    """Risk level categories for AI patterns."""
    HIGH = "high"
    MEDIUM = "medium"
    STRUCTURAL = "structural"
    LOW = "low"


@dataclass
class Finding:
    """Represents a detected AI pattern."""
    file: Path
    line_num: int
    pattern: str
    context: str
    suggestion: str
    risk_level: RiskLevel = RiskLevel.LOW


@dataclass
class ScanResults:
    """Aggregated scan results with categorisation."""
    high_risk: List[Finding] = field(default_factory=list)
    medium_risk: List[Finding] = field(default_factory=list)
    structural: List[Finding] = field(default_factory=list)
    low_risk: List[Finding] = field(default_factory=list)
    
    @property
    def total_count(self) -> int:
        return len(self.high_risk) + len(self.medium_risk) + len(self.structural) + len(self.low_risk)


# ═══════════════════════════════════════════════════════════════════════════════
# PATTERN DEFINITIONS — EXTENDED FOR FAZA 5
# ═══════════════════════════════════════════════════════════════════════════════

# HIGH-RISK PATTERNS: Strong indicators of AI-generated content
HIGH_RISK_PATTERNS: List[Tuple[str, str, str]] = [
    # Classic AI markers
    (r'\bdelve\b', 'delve', 'explore, examine, look into'),
    (r'\bplethora\b', 'plethora', 'many, numerous, a lot of'),
    (r'\bmyriad\b', 'myriad', 'many, diverse, various'),
    (r'\bculminates?\b', 'culminate', 'ends with, leads to, results in'),
    (r'\bfostering?\b', 'foster', 'encourage, promote, develop'),
    (r'\bempowering?\b', 'empower', 'enable, allow, give the ability'),
    (r'\bunderpinning?\b', 'underpin', 'support, form the basis of'),
    (r'\boverarchings?\b', 'overarching', 'general, overall, main'),
    
    # Preamble patterns (FAZA 5 additions)
    (r"it'?s important to note", "it's important to note", 'DELETE entirely'),
    (r"it'?s worth noting", "it's worth noting", 'DELETE entirely'),
    (r"it bears mentioning", "it bears mentioning", 'DELETE entirely'),
    
    # AI-typical transitions (FAZA 5 additions)
    (r"at its core", "at its core", 'fundamentally, essentially'),
    (r"stands as a testament", "stands as a testament", 'demonstrates, shows, proves'),
    (r"pave the way", "pave the way", 'enable, prepare, lead to'),
    (r"shed light on", "shed light on", 'clarify, explain, illuminate'),
    (r"serves as a reminder", "serves as a reminder", 'reminds us, shows'),
    
    # Buzzwords (FAZA 5 additions)
    (r'\bgame-?changer\b', 'game-changer', 'significant change, major improvement'),
    (r'\bcutting-?edge\b', 'cutting-edge', 'advanced, modern, latest'),
    (r'\bstate-?of-?the-?art\b', 'state-of-the-art', 'advanced, modern, best available'),
    (r'\bgroundbreaking\b', 'groundbreaking', 'innovative, novel, pioneering'),
    
    # Verbose constructions (FAZA 5 additions)
    (r"first and foremost", "first and foremost", 'first, primarily, mainly'),
    (r"last but not least", "last but not least", 'finally, also'),
    (r"in today'?s world", "in today's world", 'today, currently, now'),
    (r"in this day and age", "in this day and age", 'today, currently, nowadays'),
]

# MEDIUM-RISK PATTERNS: Common but not definitive indicators
MEDIUM_RISK_PATTERNS: List[Tuple[str, str, str]] = [
    # Original patterns
    (r'\bcomprehensive\b', 'comprehensive', 'complete, thorough, detailed'),
    (r'\brobust\b', 'robust', 'solid, resilient, reliable'),
    (r'\bleverage\b', 'leverage', 'use, take advantage of, exploit'),
    (r'\bseamless\b', 'seamless', 'smooth, fluid, uninterrupted'),
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
    (r'\bin order to\b', 'in order to', 'to'),
    (r'\bensure\b', 'ensure (if overused)', 'verify, check, guarantee'),
    
    # FAZA 5 additions
    (r'\barguably\b', 'arguably', 'perhaps, possibly, some say'),
    (r'\bundoubtedly\b', 'undoubtedly', 'certainly, clearly'),
    (r'\bunquestionably\b', 'unquestionably', 'clearly, certainly, definitely'),
    (r"it goes without saying", "it goes without saying", 'DELETE entirely'),
    (r"needless to say", "needless to say", 'DELETE entirely'),
    (r"as we all know", "as we all know", 'DELETE or rephrase'),
    
    # Conclusion patterns (FAZA 5 additions)
    (r"^in conclusion,", "In conclusion,", 'To summarise: / In summary:'),
    (r"^to summarize,", "To summarize,", 'In summary:'),
    (r"^to sum up,", "To sum up,", 'In summary:'),
    (r"^in summary,", "In summary,", 'To conclude:'),
]

# STRUCTURAL PATTERNS: Document structure indicators (new in FAZA 5)
STRUCTURAL_PATTERNS: List[Tuple[str, str, str]] = [
    (r"^In (this|the following) (section|article|document|guide)",
     "In this section/article", 'Rephrase or remove meta-reference'),
    (r"^Let'?s (explore|examine|look at|dive into|delve into)",
     "Let's explore/examine", 'Start directly with the topic'),
    (r"^(First|Second|Third|Finally|Lastly),",
     "First/Second/Third", 'Use numbered lists or remove ordinals'),
    (r"^Here'?s (what|how|why)",
     "Here's what/how/why", 'Rephrase more directly'),
    (r"^(Now|Next), let'?s",
     "Now/Next, let's", 'Start with the action directly'),
]

# LOW-RISK PATTERNS: May indicate AI but common in human writing too
LOW_RISK_PATTERNS: List[Tuple[str, str, str]] = [
    (r'\bmoreover\b', 'moreover', 'also, additionally, further'),
    (r'\bfurthermore\b', 'furthermore', 'also, additionally, in addition'),
    (r'\bnevertheless\b', 'nevertheless', 'however, still, yet'),
    (r'\bnonetheless\b', 'nonetheless', 'however, still, even so'),
    (r'\bhence\b', 'hence', 'so, therefore, thus'),
    (r'\bthereby\b', 'thereby', 'by this, in this way'),
]


class Colours:
    """ANSI colour codes for terminal output."""
    RED = '\033[0;31m'
    GREEN = '\033[0;32m'
    YELLOW = '\033[1;33m'
    BLUE = '\033[0;34m'
    CYAN = '\033[0;36m'
    MAGENTA = '\033[0;35m'
    NC = '\033[0m'
    BOLD = '\033[1m'
    DIM = '\033[2m'
    
    @classmethod
    def disable(cls):
        """Disable colours for non-terminal output."""
        for attr in dir(cls):
            if not attr.startswith('_') and attr.isupper():
                setattr(cls, attr, '')


# Automatic detection if terminal supports colours
if not sys.stdout.isatty():
    Colours.disable()


def scan_line_for_patterns(
    line: str,
    line_num: int,
    filepath: Path,
    patterns: List[Tuple[str, str, str]],
    risk_level: RiskLevel
) -> List[Finding]:
    """
    Scan a single line for patterns at a specific risk level.
    
    Args:
        line: The line content to scan
        line_num: Line number in the file
        filepath: Path to the file
        patterns: List of (regex, name, suggestion) tuples
        risk_level: The risk level for these patterns
        
    Returns:
        List of Finding objects
    """
    findings = []
    
    for pattern, name, suggestion in patterns:
        flags = re.IGNORECASE if not pattern.startswith('^') else re.IGNORECASE | re.MULTILINE
        matches = list(re.finditer(pattern, line, flags))
        
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
                context=context.strip(),
                suggestion=suggestion,
                risk_level=risk_level
            ))
    
    return findings


def scan_file(filepath: Path) -> ScanResults:
    """
    Scan a file for AI patterns at all risk levels.
    
    Args:
        filepath: Path to the file to scan
        
    Returns:
        ScanResults object with categorised findings
    """
    results = ScanResults()
    
    try:
        content = filepath.read_text(encoding='utf-8')
        lines = content.split('\n')
    except Exception as e:
        logger.error(f"Error reading {filepath}: {e}")
        print(f"{Colours.RED}Error reading {filepath}: {e}{Colours.NC}")
        return results
    
    for line_num, line in enumerate(lines, 1):
        # Skip code blocks and inline code
        if line.strip().startswith('```') or '`' in line:
            continue
        # Skip URLs
        if 'http://' in line or 'https://' in line:
            continue
            
        # Scan for each risk level
        results.high_risk.extend(
            scan_line_for_patterns(line, line_num, filepath, HIGH_RISK_PATTERNS, RiskLevel.HIGH)
        )
        results.medium_risk.extend(
            scan_line_for_patterns(line, line_num, filepath, MEDIUM_RISK_PATTERNS, RiskLevel.MEDIUM)
        )
        results.structural.extend(
            scan_line_for_patterns(line, line_num, filepath, STRUCTURAL_PATTERNS, RiskLevel.STRUCTURAL)
        )
        results.low_risk.extend(
            scan_line_for_patterns(line, line_num, filepath, LOW_RISK_PATTERNS, RiskLevel.LOW)
        )
    
    return results


def scan_directory(directory: Path, extensions: List[str] = None) -> Dict[Path, ScanResults]:
    """
    Recursively scan a directory for AI patterns.
    
    Args:
        directory: Directory to scan
        extensions: List of file extensions (default: .md, .txt, .rst)
        
    Returns:
        Dict mapping files to their ScanResults
    """
    if extensions is None:
        extensions = ['.md', '.txt', '.rst']
    
    results = {}
    
    for ext in extensions:
        for filepath in directory.rglob(f'*{ext}'):
            # Skip OLD_HW directories
            if 'OLD_HW' in str(filepath):
                continue
            scan_result = scan_file(filepath)
            if scan_result.total_count > 0:
                results[filepath] = scan_result
    
    return results


def calculate_authenticity_score(results: Dict[Path, ScanResults]) -> float:
    """
    Calculate an authenticity score based on detected patterns.
    
    Args:
        results: Dict with scan results per file
        
    Returns:
        Score from 0.0 to 10.0
    """
    total_high = sum(len(r.high_risk) for r in results.values())
    total_medium = sum(len(r.medium_risk) for r in results.values())
    total_structural = sum(len(r.structural) for r in results.values())
    total_low = sum(len(r.low_risk) for r in results.values())
    
    # Weighted calculation
    weighted_issues = (total_high * 2.0) + (total_medium * 1.0) + (total_structural * 0.5) + (total_low * 0.25)
    
    if weighted_issues == 0:
        return 10.0
    elif weighted_issues <= 2:
        return 9.5
    elif weighted_issues <= 5:
        return 9.0
    elif weighted_issues <= 10:
        return 8.5
    elif weighted_issues <= 20:
        return 8.0
    elif weighted_issues <= 35:
        return 7.0
    elif weighted_issues <= 50:
        return 6.0
    else:
        return max(5.0, 10.0 - (weighted_issues * 0.1))


def generate_summary_report(results: Dict[Path, ScanResults]) -> str:
    """
    Generate a summary report of AI fingerprint detection.
    
    Args:
        results: Dict with scan results per file
        
    Returns:
        Formatted summary report string
    """
    high_count = sum(len(r.high_risk) for r in results.values())
    medium_count = sum(len(r.medium_risk) for r in results.values())
    structural_count = sum(len(r.structural) for r in results.values())
    low_count = sum(len(r.low_risk) for r in results.values())
    
    total_issues = high_count + medium_count + structural_count + low_count
    score = calculate_authenticity_score(results)
    
    # Determine status
    if score >= 9.0:
        status = f"{Colours.GREEN}✅ PASS: Content appears authentic{Colours.NC}"
    elif score >= 7.0:
        status = f"{Colours.YELLOW}⚠️  REVIEW: Some AI patterns detected{Colours.NC}"
    else:
        status = f"{Colours.RED}❌ FAIL: Content likely contains significant AI-generated text{Colours.NC}"
    
    report = f"""
{Colours.BOLD}{'='*60}
  AI FINGERPRINT ANALYSIS REPORT
{'='*60}{Colours.NC}

{Colours.RED}HIGH-RISK{Colours.NC} patterns found:      {high_count:3d}
{Colours.YELLOW}MEDIUM-RISK{Colours.NC} patterns found:   {medium_count:3d}
{Colours.CYAN}STRUCTURAL{Colours.NC} patterns found:    {structural_count:3d}
{Colours.DIM}LOW-RISK{Colours.NC} patterns found:       {low_count:3d}
{'─'*40}
TOTAL patterns detected:        {total_issues:3d}

{Colours.BOLD}AUTHENTICITY SCORE: {score:.1f}/10{Colours.NC}

{status}
"""
    return report


def generate_detailed_report(results: Dict[Path, ScanResults], verbose: bool = True) -> str:
    """
    Generate a detailed text report with all findings.
    
    Args:
        results: Dict with scan results
        verbose: Whether to include full details
        
    Returns:
        Formatted report as string
    """
    lines = []
    lines.append(generate_summary_report(results))
    
    total_findings = sum(r.total_count for r in results.values())
    
    if total_findings == 0:
        return '\n'.join(lines)
    
    # Group by pattern for statistics
    pattern_counts: Dict[str, Dict[str, int]] = {
        'high': {},
        'medium': {},
        'structural': {},
        'low': {}
    }
    
    for scan_results in results.values():
        for f in scan_results.high_risk:
            pattern_counts['high'][f.pattern] = pattern_counts['high'].get(f.pattern, 0) + 1
        for f in scan_results.medium_risk:
            pattern_counts['medium'][f.pattern] = pattern_counts['medium'].get(f.pattern, 0) + 1
        for f in scan_results.structural:
            pattern_counts['structural'][f.pattern] = pattern_counts['structural'].get(f.pattern, 0) + 1
        for f in scan_results.low_risk:
            pattern_counts['low'][f.pattern] = pattern_counts['low'].get(f.pattern, 0) + 1
    
    lines.append("-" * 60)
    lines.append(f"{Colours.BOLD}SUMMARY BY PATTERN:{Colours.NC}")
    lines.append("-" * 60)
    
    if pattern_counts['high']:
        lines.append(f"\n{Colours.RED}HIGH-RISK:{Colours.NC}")
        for pattern, count in sorted(pattern_counts['high'].items(), key=lambda x: -x[1]):
            lines.append(f"  [{count:3d}x] {pattern}")
    
    if pattern_counts['medium']:
        lines.append(f"\n{Colours.YELLOW}MEDIUM-RISK:{Colours.NC}")
        for pattern, count in sorted(pattern_counts['medium'].items(), key=lambda x: -x[1]):
            lines.append(f"  [{count:3d}x] {pattern}")
    
    if pattern_counts['structural']:
        lines.append(f"\n{Colours.CYAN}STRUCTURAL:{Colours.NC}")
        for pattern, count in sorted(pattern_counts['structural'].items(), key=lambda x: -x[1]):
            lines.append(f"  [{count:3d}x] {pattern}")
    
    if verbose:
        lines.append("")
        lines.append("-" * 60)
        lines.append(f"{Colours.BOLD}DETAILS BY FILE:{Colours.NC}")
        lines.append("-" * 60)
        
        for filepath, scan_results in sorted(results.items()):
            lines.append(f"\n{Colours.CYAN}{filepath.relative_to(filepath.parent.parent.parent) if len(filepath.parts) > 3 else filepath.name}{Colours.NC}")
            
            all_findings = (
                [(f, 'HIGH') for f in scan_results.high_risk] +
                [(f, 'MEDIUM') for f in scan_results.medium_risk] +
                [(f, 'STRUCTURAL') for f in scan_results.structural]
            )
            
            for finding, level in sorted(all_findings, key=lambda x: x[0].line_num):
                colour = Colours.RED if level == 'HIGH' else Colours.YELLOW if level == 'MEDIUM' else Colours.CYAN
                lines.append(f"  L{finding.line_num:4d}: {colour}[{level}]{Colours.NC} {finding.pattern}")
                lines.append(f"         Context: \"{finding.context}\"")
                lines.append(f"         → Replace with: {Colours.GREEN}{finding.suggestion}{Colours.NC}")
    
    lines.append("")
    lines.append("=" * 60)
    
    return '\n'.join(lines)


def generate_json_report(results: Dict[Path, ScanResults]) -> str:
    """
    Generate a JSON report for programmatic use.
    
    Args:
        results: Dict with scan results
        
    Returns:
        JSON string with full results
    """
    output = {
        'summary': {
            'high_risk_count': sum(len(r.high_risk) for r in results.values()),
            'medium_risk_count': sum(len(r.medium_risk) for r in results.values()),
            'structural_count': sum(len(r.structural) for r in results.values()),
            'low_risk_count': sum(len(r.low_risk) for r in results.values()),
            'authenticity_score': calculate_authenticity_score(results),
            'files_with_issues': len(results)
        },
        'results': {}
    }
    
    for filepath, scan_results in results.items():
        output['results'][str(filepath)] = {
            'high_risk': [
                {'line': f.line_num, 'pattern': f.pattern, 'context': f.context, 'suggestion': f.suggestion}
                for f in scan_results.high_risk
            ],
            'medium_risk': [
                {'line': f.line_num, 'pattern': f.pattern, 'context': f.context, 'suggestion': f.suggestion}
                for f in scan_results.medium_risk
            ],
            'structural': [
                {'line': f.line_num, 'pattern': f.pattern, 'context': f.context, 'suggestion': f.suggestion}
                for f in scan_results.structural
            ],
            'low_risk': [
                {'line': f.line_num, 'pattern': f.pattern, 'context': f.context, 'suggestion': f.suggestion}
                for f in scan_results.low_risk
            ]
        }
    
    return json.dumps(output, indent=2, default=str)


def main():
    """Main entry point."""
    parser = argparse.ArgumentParser(
        description='AI Fingerprint Scanner - Detect LLM-generated patterns',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  %(prog)s docs/                     # Scan docs directory
  %(prog)s . --verbose               # Scan current directory with details
  %(prog)s . --output report.json    # Output JSON report
  %(prog)s . --no-color              # Disable colours
        """
    )
    
    parser.add_argument('directory', nargs='?', default='docs',
                       help='Directory to scan (default: docs)')
    parser.add_argument('--output', '-o', type=str,
                       help='Output file (JSON format if .json extension)')
    parser.add_argument('--verbose', '-v', action='store_true',
                       help='Show detailed findings per file')
    parser.add_argument('--no-color', action='store_true',
                       help='Disable coloured output')
    parser.add_argument('--extensions', '-e', type=str, default='.md,.txt,.rst',
                       help='Comma-separated file extensions to scan')
    
    args = parser.parse_args()
    
    if args.no_color:
        Colours.disable()
    
    target_dir = Path(args.directory)
    
    if not target_dir.exists():
        logger.error(f"Directory '{target_dir}' does not exist!")
        print(f"{Colours.RED}Error: Directory '{target_dir}' does not exist!{Colours.NC}")
        sys.exit(1)
    
    extensions = [ext.strip() if ext.startswith('.') else f'.{ext.strip()}' 
                  for ext in args.extensions.split(',')]
    
    logger.info(f"Scanning {target_dir} for AI patterns...")
    print(f"{Colours.BLUE}Scanning {target_dir} for AI patterns...{Colours.NC}\n")
    
    results = scan_directory(target_dir, extensions)
    
    # Generate and display report
    report = generate_detailed_report(results, verbose=args.verbose)
    print(report)
    
    # Save output if specified
    if args.output:
        if args.output.endswith('.json'):
            with open(args.output, 'w') as f:
                f.write(generate_json_report(results))
        else:
            with open(args.output, 'w') as f:
                # Strip ANSI codes for file output
                import re
                clean_report = re.sub(r'\033\[[0-9;]*m', '', report)
                f.write(clean_report)
        logger.info(f"Report saved to: {args.output}")
        print(f"\nReport saved to: {args.output}")
    
    # Calculate score for exit code
    score = calculate_authenticity_score(results)
    total_findings = sum(r.total_count for r in results.values())
    logger.info(f"Scan complete: {total_findings} patterns detected, score: {score:.1f}/10")
    
    # Exit code: 0 if score >= 9.0, 1 otherwise
    sys.exit(0 if score >= 9.0 else 1)


if __name__ == '__main__':
    main()
