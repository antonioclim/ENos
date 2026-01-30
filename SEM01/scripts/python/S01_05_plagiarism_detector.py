#!/usr/bin/env python3
"""
Plagiarism Detector - Detects similarities between submissions
Operating Systems | ASE Bucharest - CSIE

Purpose: Identify submission pairs with suspicious similarity
Usage: python3 S01_05_plagiarism_detector.py <submissions_dir> [--threshold 0.85]

Algorithm:
1. Normalise code (remove comments, whitespace, sort lines)
2. Calculate similarity between all pairs
3. Detect AI-generated code patterns
4. Report pairs above threshold

Version: 2.1 - Added AI code pattern detection
"""

import logging
import sys
import re
import json
from pathlib import Path
from difflib import SequenceMatcher
from typing import List, Tuple, Dict, Optional
from dataclasses import dataclass, field
from datetime import datetime
import hashlib

# Logging setup — import shared utilities from kit lib
sys.path.insert(0, str(Path(__file__).parent.parent.parent.parent / 'lib'))
from logging_utils import setup_logging

logger = setup_logging(__name__)


@dataclass
class SimilarityResult:
    """Result of comparison between two files."""
    file1: Path
    file2: Path
    similarity: float
    student1: str
    student2: str
    method: str


@dataclass
class AIPatternResult:
    """Result of AI pattern detection for a single file."""
    filepath: Path
    student: str
    patterns_found: List[Tuple[str, int]]  # (pattern_name, line_number)
    ai_score: float  # 0.0 to 1.0


class Colours:
    RED = '\033[0;31m'
    GREEN = '\033[0;32m'
    YELLOW = '\033[1;33m'
    CYAN = '\033[0;36m'
    MAGENTA = '\033[0;35m'
    NC = '\033[0m'
    BOLD = '\033[1m'


# AI-generated code patterns commonly found in LLM outputs
AI_CODE_PATTERNS: List[Tuple[str, str]] = [
    # Overly explanatory comments
    (r'#\s*This (?:script|function|code) (?:will|does|is used to)', 'explanatory_this'),
    (r'#\s*(?:First|Next|Then|Finally|Now),?\s*we', 'step_narration'),
    (r'#\s*(?:Make sure|Be sure|Ensure) to', 'instructional_tone'),
    (r'#\s*Note:\s', 'parenthetical_note'),
    (r'#\s*This is (?:a |an )?(?:simple|basic|complete|comprehensive)', 'self_description'),
    
    # Generic placeholder TODOs
    (r'#\s*TODO:\s*(?:Add|Implement|Handle|Fix|Update)\s+', 'generic_todo'),
    
    # AI vocabulary in comments
    (r'#.*\b(?:comprehensive|robust|seamless|leverage)\b', 'ai_vocabulary'),
    (r'#.*\b(?:facilitate|utilize|enhance|streamline)\b', 'ai_vocabulary'),
    
    # Overly verbose variable descriptions
    (r'#\s*(?:Store|Save|Hold|Keep)s?\s+the\s+', 'verbose_var_comment'),
    
    # Templated error messages
    (r'echo\s+["\'](?:Error|Warning|Info):\s+', 'templated_message'),
    
    # Suspiciously complete header blocks
    (r'#\s*(?:Author|Date|Version|Description|Usage):\s*$', 'empty_header_field'),
    
    # Common LLM function patterns
    (r'function\s+\w+\s*\(\)\s*\{\s*\n\s*#\s*', 'func_with_immediate_comment'),
]


def detect_ai_patterns(content: str) -> List[Tuple[str, int]]:
    """
    Detect patterns typical of AI-generated code.
    
    Args:
        content: Script content to analyse
        
    Returns:
        List of (pattern_name, line_number) tuples
    """
    findings = []
    lines = content.split('\n')
    
    for line_num, line in enumerate(lines, 1):
        for pattern, name in AI_CODE_PATTERNS:
            if re.search(pattern, line, re.IGNORECASE):
                findings.append((name, line_num))
    
    return findings


def calculate_ai_score(patterns_found: List[Tuple[str, int]], total_lines: int) -> float:
    """
    Calculate an AI likelihood score based on patterns found.
    
    Args:
        patterns_found: List of detected patterns
        total_lines: Total lines in the script
        
    Returns:
        Score from 0.0 (likely human) to 1.0 (likely AI)
    """
    if total_lines == 0:
        return 0.0
    
    # Weight different pattern types
    weights = {
        'explanatory_this': 0.15,
        'step_narration': 0.20,
        'instructional_tone': 0.15,
        'parenthetical_note': 0.10,
        'self_description': 0.20,
        'generic_todo': 0.10,
        'ai_vocabulary': 0.25,
        'verbose_var_comment': 0.10,
        'templated_message': 0.05,
        'empty_header_field': 0.05,
        'func_with_immediate_comment': 0.10,
    }
    
    score = 0.0
    unique_patterns = set(p[0] for p in patterns_found)
    
    for pattern_name in unique_patterns:
        count = sum(1 for p in patterns_found if p[0] == pattern_name)
        weight = weights.get(pattern_name, 0.1)
        # Diminishing returns for repeated patterns
        score += weight * min(count, 3) / 3
    
    # Normalise by script length (longer scripts naturally have more comments)
    length_factor = min(total_lines / 50, 1.0)  # Scripts under 50 lines get full weight
    
    return min(score * length_factor, 1.0)


def normalise_bash_script(content: str) -> str:
    """
    Normalise a Bash script for comparison.
    
    Removes:
    - Comments (lines starting with #, except shebang)
    - Empty lines
    - Leading/trailing whitespace
    - Sorts lines (to detect reordering)
    
    Args:
        content: Original script content
        
    Returns:
        Normalised content for comparison
    """
    lines = content.split('\n')
    normalised = []
    
    for i, line in enumerate(lines):
        stripped = line.strip()
        
        # Keep shebang
        if i == 0 and stripped.startswith('#!'):
            normalised.append(stripped)
            continue
        
        # Remove comments
        if stripped.startswith('#'):
            continue
        
        # Remove empty lines
        if not stripped:
            continue
        
        # Remove inline comments (simplified: only if # not in quotes)
        if '#' in stripped and not ('"' in stripped or "'" in stripped):
            stripped = stripped.split('#')[0].strip()
        
        if stripped:
            normalised.append(stripped)
    
    # Sort to detect reordering
    return '\n'.join(sorted(normalised))


def normalise_for_structure(content: str) -> str:
    """
    Alternative normalisation preserving structure.
    Does not sort, only cleans.
    """
    lines = content.split('\n')
    normalised = []
    
    for i, line in enumerate(lines):
        stripped = line.strip()
        
        if i == 0 and stripped.startswith('#!'):
            normalised.append(stripped)
            continue
        
        if stripped.startswith('#') or not stripped:
            continue
        
        normalised.append(stripped)
    
    return '\n'.join(normalised)


def calculate_similarity(content1: str, content2: str) -> float:
    """
    Calculate similarity between two normalised texts.
    
    Uses SequenceMatcher from difflib.
    
    Args:
        content1: First normalised text
        content2: Second normalised text
        
    Returns:
        Similarity score between 0.0 and 1.0
    """
    return SequenceMatcher(None, content1, content2).ratio()


def calculate_hash_similarity(content1: str, content2: str) -> float:
    """Check if hashes are identical (exact copy)."""
    h1 = hashlib.md5(content1.encode()).hexdigest()
    h2 = hashlib.md5(content2.encode()).hexdigest()
    return 1.0 if h1 == h2 else 0.0


def extract_student_id(filepath: Path) -> str:
    """
    Extract student ID from file path.
    Assumes structure: submissions/StudentName/...
    """
    parts = filepath.parts
    for i, part in enumerate(parts):
        if part in ('submissions', 'homework', 'assignments'):
            if i + 1 < len(parts):
                return parts[i + 1]
    
    # Fallback: use parent directory
    return filepath.parent.name


def find_all_scripts(submissions_dir: Path, pattern: str = '*.sh') -> List[Path]:
    """Find all scripts in the submissions directory."""
    return list(submissions_dir.rglob(pattern))


def analyse_ai_patterns(scripts: List[Path]) -> List[AIPatternResult]:
    """
    Analyse all scripts for AI-generated code patterns.
    
    Args:
        scripts: List of script paths
        
    Returns:
        List of AIPatternResult for scripts with AI indicators
    """
    results = []
    
    for script in scripts:
        try:
            content = script.read_text(encoding='utf-8')
            patterns = detect_ai_patterns(content)
            
            if patterns:
                total_lines = len(content.split('\n'))
                ai_score = calculate_ai_score(patterns, total_lines)
                
                results.append(AIPatternResult(
                    filepath=script,
                    student=extract_student_id(script),
                    patterns_found=patterns,
                    ai_score=ai_score
                ))
        except Exception:
            continue
    
    return sorted(results, key=lambda x: -x.ai_score)


def compare_all_pairs(
    scripts: List[Path],
    threshold: float = 0.85
) -> List[SimilarityResult]:
    """
    Compare all pairs of scripts.
    
    Args:
        scripts: List of scripts to compare
        threshold: Similarity threshold for reporting
        
    Returns:
        List of results above threshold
    """
    suspicious = []
    total_pairs = len(scripts) * (len(scripts) - 1) // 2
    checked = 0
    
    for i, script1 in enumerate(scripts):
        try:
            content1 = script1.read_text(encoding='utf-8')
            norm1_sorted = normalise_bash_script(content1)
            norm1_struct = normalise_for_structure(content1)
        except Exception:
            continue
        
        for script2 in scripts[i+1:]:
            checked += 1
            
            # Progress indicator
            if checked % 100 == 0:
                print(f"\r  Checked {checked}/{total_pairs} pairs...", end='')
            
            try:
                content2 = script2.read_text(encoding='utf-8')
                norm2_sorted = normalise_bash_script(content2)
                norm2_struct = normalise_for_structure(content2)
            except Exception:
                continue
            
            # Skip if from same directory (same student)
            student1 = extract_student_id(script1)
            student2 = extract_student_id(script2)
            if student1 == student2:
                continue
            
            # Check similarity
            # Method 1: With sorting (detects reordering)
            sim_sorted = calculate_similarity(norm1_sorted, norm2_sorted)
            
            # Method 2: Without sorting (identical structure)
            sim_struct = calculate_similarity(norm1_struct, norm2_struct)
            
            # Method 3: Exact hash
            sim_hash = calculate_hash_similarity(norm1_struct, norm2_struct)
            
            # Take maximum
            max_sim = max(sim_sorted, sim_struct, sim_hash)
            
            if max_sim >= threshold:
                method = 'EXACT' if sim_hash == 1.0 else (
                    'REORDERED' if sim_sorted > sim_struct else 'SIMILAR'
                )
                
                suspicious.append(SimilarityResult(
                    file1=script1,
                    file2=script2,
                    similarity=max_sim,
                    student1=student1,
                    student2=student2,
                    method=method
                ))
    
    print(f"\r  Checked {total_pairs}/{total_pairs} pairs    ")
    
    return sorted(suspicious, key=lambda x: -x.similarity)


def generate_report(
    similarity_results: List[SimilarityResult],
    ai_results: List[AIPatternResult],
    output_path: Optional[Path] = None
) -> str:
    """Generate combined similarity and AI detection report."""
    lines = []
    lines.append("=" * 70)
    lines.append("  PLAGIARISM & AI DETECTION REPORT - SEMINAR 1")
    lines.append(f"  Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    lines.append("=" * 70)
    lines.append("")
    
    # AI Detection Section
    high_ai = [r for r in ai_results if r.ai_score >= 0.5]
    medium_ai = [r for r in ai_results if 0.25 <= r.ai_score < 0.5]
    
    if high_ai or medium_ai:
        lines.append(f"{Colours.MAGENTA}{'-'*70}{Colours.NC}")
        lines.append(f"{Colours.MAGENTA}AI-GENERATED CODE INDICATORS:{Colours.NC}")
        lines.append(f"{Colours.MAGENTA}{'-'*70}{Colours.NC}")
        
        if high_ai:
            lines.append(f"\n{Colours.RED}HIGH LIKELIHOOD (score >= 0.5):{Colours.NC}")
            for r in high_ai:
                lines.append(f"  * {r.student}: {r.ai_score:.0%} AI likelihood")
                lines.append(f"    File: {r.filepath.name}")
                pattern_summary = {}
                for p, _ in r.patterns_found:
                    pattern_summary[p] = pattern_summary.get(p, 0) + 1
                lines.append(f"    Patterns: {dict(pattern_summary)}")
        
        if medium_ai:
            lines.append(f"\n{Colours.YELLOW}MEDIUM LIKELIHOOD (0.25 <= score < 0.5):{Colours.NC}")
            for r in medium_ai:
                lines.append(f"  * {r.student}: {r.ai_score:.0%} AI likelihood")
                lines.append(f"    File: {r.filepath.name}")
        
        lines.append("")
    else:
        lines.append(f"{Colours.GREEN}[OK] No significant AI patterns detected{Colours.NC}")
        lines.append("")
    
    # Similarity Section
    if not similarity_results:
        lines.append(f"{Colours.GREEN}[OK] No suspicious similarities detected!{Colours.NC}")
    else:
        lines.append(f"{Colours.RED}[!] {len(similarity_results)} SUSPICIOUS PAIRS DETECTED{Colours.NC}")
        lines.append("")
        
        # Group by severity
        exact_copies = [r for r in similarity_results if r.method == 'EXACT']
        reordered = [r for r in similarity_results if r.method == 'REORDERED']
        similar = [r for r in similarity_results if r.method == 'SIMILAR']
        
        if exact_copies:
            lines.append(f"{Colours.RED}{'-'*70}{Colours.NC}")
            lines.append(f"{Colours.RED}EXACT COPIES (100% identical):{Colours.NC}")
            lines.append(f"{Colours.RED}{'-'*70}{Colours.NC}")
            for r in exact_copies:
                lines.append(f"  * {r.student1} <-> {r.student2}")
                lines.append(f"    Files: {r.file1.name} | {r.file2.name}")
            lines.append("")
        
        if reordered:
            lines.append(f"{Colours.YELLOW}{'-'*70}{Colours.NC}")
            lines.append(f"{Colours.YELLOW}REORDERED (same lines, different order):{Colours.NC}")
            lines.append(f"{Colours.YELLOW}{'-'*70}{Colours.NC}")
            for r in reordered:
                lines.append(f"  * {r.student1} <-> {r.student2}: {r.similarity*100:.1f}%")
                lines.append(f"    Files: {r.file1.name} | {r.file2.name}")
            lines.append("")
        
        if similar:
            lines.append(f"{Colours.CYAN}{'-'*70}{Colours.NC}")
            lines.append(f"{Colours.CYAN}SIMILAR (above threshold):{Colours.NC}")
            lines.append(f"{Colours.CYAN}{'-'*70}{Colours.NC}")
            for r in similar:
                lines.append(f"  * {r.student1} <-> {r.student2}: {r.similarity*100:.1f}%")
                lines.append(f"    Files: {r.file1.name} | {r.file2.name}")
            lines.append("")
    
    lines.append("=" * 70)
    lines.append("RECOMMENDATIONS:")
    lines.append("  1. Manually verify pairs marked EXACT")
    lines.append("  2. For high AI likelihood: ask about code logic during oral")
    lines.append("  3. Request explanations for design decisions")
    lines.append("  4. Use S01_04_ORAL_VERIFICATION_LOG.md for documentation")
    lines.append("=" * 70)
    
    report = '\n'.join(lines)
    
    if output_path:
        # Save JSON version for further processing
        json_data = {
            'generated_at': datetime.now().isoformat(),
            'total_suspicious_pairs': len(similarity_results),
            'exact_copies': len([r for r in similarity_results if r.method == 'EXACT']),
            'ai_high_likelihood': len(high_ai),
            'ai_medium_likelihood': len(medium_ai),
            'similarity_results': [
                {
                    'student1': r.student1,
                    'student2': r.student2,
                    'file1': str(r.file1),
                    'file2': str(r.file2),
                    'similarity': r.similarity,
                    'method': r.method,
                }
                for r in similarity_results
            ],
            'ai_results': [
                {
                    'student': r.student,
                    'file': str(r.filepath),
                    'ai_score': r.ai_score,
                    'patterns': [{'name': p[0], 'line': p[1]} for p in r.patterns_found],
                }
                for r in ai_results if r.ai_score >= 0.25
            ]
        }
        json_path = output_path.with_suffix('.json')
        json_path.write_text(json.dumps(json_data, indent=2))
        print(f"[OK] JSON report saved: {json_path}")
    
    return report


def main():
    if len(sys.argv) < 2:
        print("Usage: python3 S01_05_plagiarism_detector.py <submissions_dir> [--threshold 0.85]")
        print("\nExample:")
        print("  python3 S01_05_plagiarism_detector.py ./submissions/")
        print("  python3 S01_05_plagiarism_detector.py ./homework/ --threshold 0.75")
        print("\nFeatures:")
        print("  - Detects exact copies, reordering, and structural similarity")
        print("  - Identifies AI-generated code patterns")
        print("  - Generates JSON report for records")
        sys.exit(1)
    
    submissions_dir = Path(sys.argv[1])
    
    if not submissions_dir.exists():
        logger.error(f"Directory '{submissions_dir}' does not exist!")
        print(f"{Colours.RED}Error: Directory '{submissions_dir}' does not exist!{Colours.NC}")
        sys.exit(1)
    
    # Parse threshold
    threshold = 0.85
    if '--threshold' in sys.argv:
        idx = sys.argv.index('--threshold')
        if idx + 1 < len(sys.argv):
            threshold = float(sys.argv[idx + 1])
    
    logger.info(f"Scanning {submissions_dir} for similarities and AI patterns...")
    print(f"{Colours.CYAN}Scanning {submissions_dir} for similarities and AI patterns...{Colours.NC}")
    print(f"Similarity threshold: {threshold*100:.0f}%\n")
    
    # Find all scripts
    scripts = find_all_scripts(submissions_dir)
    logger.info(f"Found {len(scripts)} .sh scripts")
    print(f"Found {len(scripts)} .sh scripts")
    
    if len(scripts) < 1:
        logger.warning("No scripts found for analysis.")
        print("No scripts found for analysis.")
        sys.exit(0)
    
    # AI pattern analysis
    logger.info("Analysing AI patterns...")
    print("\n>>> Analysing AI patterns...")
    ai_results = analyse_ai_patterns(scripts)
    ai_count = len([r for r in ai_results if r.ai_score >= 0.25])
    logger.info(f"Found {ai_count} scripts with AI indicators")
    print(f"  Found {ai_count} scripts with AI indicators")
    
    # Similarity comparison (only if multiple scripts)
    similarity_results = []
    if len(scripts) >= 2:
        logger.info("Comparing pairs for similarity...")
        print("\n>>> Comparing pairs for similarity...")
        similarity_results = compare_all_pairs(scripts, threshold)
    
    # Generate report
    report_path = Path(f'plagiarism_report_{datetime.now():%Y%m%d_%H%M%S}.txt')
    report = generate_report(similarity_results, ai_results, report_path)
    print(report)
    
    report_path.write_text(report)
    logger.info(f"Report saved: {report_path}")
    print(f"\n[OK] Report saved: {report_path}")
    
    # Exit code for CI (non-zero if issues found)
    has_issues = bool(similarity_results) or any(r.ai_score >= 0.5 for r in ai_results)
    sys.exit(1 if has_issues else 0)


if __name__ == '__main__':
    main()
