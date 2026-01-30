#!/usr/bin/env python3
"""
test_ai_fingerprint.py — Tests for AI Fingerprint Scanner

Operating Systems | ASE Bucharest — CSIE
Author: ing. dr. Antonio Clim
Version: 1.0 | January 2025

Tests the pattern detection accuracy and reliability of the AI fingerprint scanner.

Run with: pytest -v test_ai_fingerprint.py
"""

import sys
import tempfile
from pathlib import Path
from typing import List

import pytest

# Add the scripts/python directory to path
SCRIPTS_PATH = Path(__file__).parent.parent / 'scripts' / 'python'
sys.path.insert(0, str(SCRIPTS_PATH))

from S01_06_ai_fingerprint_scanner import (
    scan_file,
    scan_directory,
    scan_line_for_patterns,
    Finding,
    ScanResults,
    RiskLevel,
    HIGH_RISK_PATTERNS,
    MEDIUM_RISK_PATTERNS,
    STRUCTURAL_PATTERNS,
    LOW_RISK_PATTERNS
)


# =============================================================================
# Fixtures
# =============================================================================

@pytest.fixture
def temp_dir(tmp_path):
    """Provide a temporary directory for test files."""
    return tmp_path


@pytest.fixture
def clean_md_file(temp_dir):
    """Create a clean Markdown file with no AI patterns."""
    content = """# Technical Documentation

This document explains how processes work in Linux.

## Process Creation

When a process is created using fork(), the kernel copies the parent's address space.
The child process receives a copy of the file descriptors.

## Example Code

```bash
#!/bin/bash
# This script demonstrates process creation
echo "Parent PID: $$"
```

The script above shows basic process information.
"""
    filepath = temp_dir / "clean_doc.md"
    filepath.write_text(content)
    return filepath


@pytest.fixture
def ai_heavy_file(temp_dir):
    """Create a file with multiple AI patterns."""
    content = """# Comprehensive Overview

Let's delve into the myriad ways that operating systems foster innovation.

It's important to note that this groundbreaking technology paves the way for
cutting-edge solutions in today's world.

Furthermore, the seamless integration leverages robust methodologies that
culminate in a holistic approach.

In conclusion, I hope this sheds light on the topic.
"""
    filepath = temp_dir / "ai_heavy.md"
    filepath.write_text(content)
    return filepath


@pytest.fixture
def mixed_file(temp_dir):
    """Create a file with some AI patterns but also legitimate content."""
    content = """# Process Management Guide

This section explores process scheduling algorithms.

It's worth noting that the scheduler uses various heuristics.

## Round Robin

The round robin algorithm assigns time slices to each process.
Processes execute in a circular queue fashion.

Furthermore, preemption occurs when the time quantum expires.

## Code Example

```python
# The delve function (this should be ignored in code blocks)
def delve_into_process():
    pass
```
"""
    filepath = temp_dir / "mixed.md"
    filepath.write_text(content)
    return filepath


# =============================================================================
# TestScanFile
# =============================================================================

class TestScanFile:
    """Tests for the scan_file function."""
    
    def test_clean_file_returns_empty_results(self, clean_md_file):
        """A clean file should have no findings."""
        results = scan_file(clean_md_file)
        
        assert isinstance(results, ScanResults)
        assert results.total_count == 0
        assert len(results.high_risk) == 0
        assert len(results.medium_risk) == 0
    
    def test_ai_heavy_file_detects_multiple_patterns(self, ai_heavy_file):
        """A file with AI patterns should have findings."""
        results = scan_file(ai_heavy_file)
        
        assert results.total_count > 0
        # Should detect high-risk patterns like 'delve', 'myriad', 'foster'
        high_risk_patterns = [f.pattern for f in results.high_risk]
        assert 'delve' in high_risk_patterns or 'myriad' in high_risk_patterns
    
    def test_detects_delve(self, temp_dir):
        """Should detect 'delve' as high-risk pattern."""
        filepath = temp_dir / "test_delve.md"
        filepath.write_text("Let's delve into the topic.")
        
        results = scan_file(filepath)
        patterns = [f.pattern for f in results.high_risk]
        
        assert 'delve' in patterns
    
    def test_detects_its_important_to_note(self, temp_dir):
        """Should detect 'it's important to note' preamble."""
        filepath = temp_dir / "test_preamble.md"
        filepath.write_text("It's important to note that Linux is open source.")
        
        results = scan_file(filepath)
        high_patterns = [f.pattern for f in results.high_risk]
        
        assert "it's important to note" in high_patterns
    
    def test_detects_cutting_edge(self, temp_dir):
        """Should detect 'cutting-edge' buzzword."""
        filepath = temp_dir / "test_buzzword.md"
        filepath.write_text("This cutting-edge technology revolutionises computing.")
        
        results = scan_file(filepath)
        patterns = [f.pattern for f in results.high_risk]
        
        assert 'cutting-edge' in patterns
    
    def test_ignores_patterns_in_code_blocks(self, temp_dir):
        """Patterns inside code blocks should be ignored."""
        filepath = temp_dir / "test_codeblock.md"
        content = """
# Documentation

```python
def delve_into_data():
    # Let's delve deeper
    plethora_of_items = []
    return plethora_of_items
```

Normal text without patterns here.
"""
        filepath.write_text(content)
        
        results = scan_file(filepath)
        # Should not detect patterns from inside code block
        delve_findings = [f for f in results.high_risk if f.pattern == 'delve']
        
        # The word 'delve' in code block should be ignored
        assert len(delve_findings) == 0
    
    def test_ignores_patterns_in_urls(self, temp_dir):
        """Patterns inside URLs should be ignored."""
        filepath = temp_dir / "test_url.md"
        content = """
# Links

See https://example.com/delve-into-linux for more.
Also check http://fostering-innovation.org/guide.
"""
        filepath.write_text(content)
        
        results = scan_file(filepath)
        # Patterns in URLs should be ignored
        assert results.total_count == 0
    
    def test_finding_includes_context(self, temp_dir):
        """Findings should include surrounding context."""
        filepath = temp_dir / "test_context.md"
        filepath.write_text("The system delves into memory management deeply.")
        
        results = scan_file(filepath)
        
        assert len(results.high_risk) > 0
        finding = results.high_risk[0]
        assert 'delve' in finding.context.lower()
    
    def test_finding_includes_line_number(self, temp_dir):
        """Findings should include correct line number."""
        filepath = temp_dir / "test_linenum.md"
        content = """Line 1
Line 2
Let's delve into this on line 3.
Line 4
"""
        filepath.write_text(content)
        
        results = scan_file(filepath)
        finding = results.high_risk[0]
        
        assert finding.line_num == 3
    
    def test_finding_includes_suggestion(self, temp_dir):
        """Findings should include replacement suggestions."""
        filepath = temp_dir / "test_suggestion.md"
        filepath.write_text("A plethora of options exist.")
        
        results = scan_file(filepath)
        finding = results.high_risk[0]
        
        assert finding.suggestion is not None
        assert len(finding.suggestion) > 0
    
    def test_handles_nonexistent_file_gracefully(self, temp_dir):
        """Should handle missing files without crashing."""
        nonexistent = temp_dir / "does_not_exist.md"
        
        results = scan_file(nonexistent)
        
        assert isinstance(results, ScanResults)
        assert results.total_count == 0


# =============================================================================
# TestScanDirectory
# =============================================================================

class TestScanDirectory:
    """Tests for the scan_directory function."""
    
    def test_scans_all_md_files(self, temp_dir):
        """Should scan all .md files in directory."""
        # Create multiple files
        (temp_dir / "file1.md").write_text("Let's delve in.")
        (temp_dir / "file2.md").write_text("A myriad of options.")
        (temp_dir / "file3.txt").write_text("This plethora of choices.")
        
        results = scan_directory(temp_dir, extensions=['.md'])
        
        # Should have scanned 2 .md files
        assert len(results) == 2
    
    def test_scans_subdirectories(self, temp_dir):
        """Should recursively scan subdirectories."""
        subdir = temp_dir / "subdir" / "deep"
        subdir.mkdir(parents=True)
        
        (temp_dir / "root.md").write_text("Root file.")
        (subdir / "deep.md").write_text("Let's delve deep.")
        
        results = scan_directory(temp_dir, extensions=['.md'])
        
        assert len(results) == 2
    
    def test_skips_old_hw_directories(self, temp_dir):
        """Should skip OLD_HW directories."""
        old_hw = temp_dir / "OLD_HW"
        old_hw.mkdir()
        
        (temp_dir / "current.md").write_text("Current content.")
        (old_hw / "archived.md").write_text("Let's delve into archived stuff.")
        
        results = scan_directory(temp_dir, extensions=['.md'])
        
        # Should only have scanned current.md
        assert len(results) == 1
        assert any("current" in str(path) for path in results.keys())
    
    def test_respects_extension_filter(self, temp_dir):
        """Should only scan files with specified extensions."""
        (temp_dir / "doc.md").write_text("Markdown file with delve.")
        (temp_dir / "doc.txt").write_text("Text file with delve.")
        (temp_dir / "doc.rst").write_text("RST file with delve.")
        (temp_dir / "doc.py").write_text("# Python file with delve")
        
        results = scan_directory(temp_dir, extensions=['.md', '.txt'])
        
        assert len(results) == 2


# =============================================================================
# TestRiskLevels
# =============================================================================

class TestRiskLevels:
    """Tests for proper risk level categorisation."""
    
    def test_high_risk_patterns_exist(self):
        """HIGH_RISK_PATTERNS should be defined."""
        assert len(HIGH_RISK_PATTERNS) > 0
    
    def test_medium_risk_patterns_exist(self):
        """MEDIUM_RISK_PATTERNS should be defined."""
        assert len(MEDIUM_RISK_PATTERNS) > 0
    
    def test_structural_patterns_exist(self):
        """STRUCTURAL_PATTERNS should be defined."""
        assert len(STRUCTURAL_PATTERNS) > 0
    
    def test_risk_level_enum_values(self):
        """RiskLevel enum should have expected values."""
        assert RiskLevel.HIGH.value == "high"
        assert RiskLevel.MEDIUM.value == "medium"
        assert RiskLevel.STRUCTURAL.value == "structural"
        assert RiskLevel.LOW.value == "low"
    
    def test_delve_is_high_risk(self, temp_dir):
        """'delve' should be categorised as high risk."""
        filepath = temp_dir / "test.md"
        filepath.write_text("We delve into this topic.")
        
        results = scan_file(filepath)
        
        assert len(results.high_risk) > 0
        assert any(f.pattern == 'delve' for f in results.high_risk)


# =============================================================================
# TestScanResults
# =============================================================================

class TestScanResults:
    """Tests for ScanResults dataclass."""
    
    def test_total_count_empty(self):
        """Empty results should have total_count of 0."""
        results = ScanResults()
        assert results.total_count == 0
    
    def test_total_count_with_findings(self):
        """total_count should sum all risk categories."""
        results = ScanResults()
        
        results.high_risk.append(
            Finding(Path("test"), 1, "test", "ctx", "sug", RiskLevel.HIGH)
        )
        results.medium_risk.append(
            Finding(Path("test"), 2, "test", "ctx", "sug", RiskLevel.MEDIUM)
        )
        results.medium_risk.append(
            Finding(Path("test"), 3, "test", "ctx", "sug", RiskLevel.MEDIUM)
        )
        
        assert results.total_count == 3


# =============================================================================
# TestFinding
# =============================================================================

class TestFinding:
    """Tests for Finding dataclass."""
    
    def test_finding_creation(self):
        """Should create Finding with all attributes."""
        finding = Finding(
            file=Path("/test/file.md"),
            line_num=42,
            pattern="delve",
            context="Let's delve into this",
            suggestion="explore, examine",
            risk_level=RiskLevel.HIGH
        )
        
        assert finding.file == Path("/test/file.md")
        assert finding.line_num == 42
        assert finding.pattern == "delve"
        assert finding.risk_level == RiskLevel.HIGH
    
    def test_finding_default_risk_level(self):
        """Default risk level should be LOW."""
        finding = Finding(
            file=Path("test.md"),
            line_num=1,
            pattern="test",
            context="ctx",
            suggestion="sug"
        )
        
        assert finding.risk_level == RiskLevel.LOW


# =============================================================================
# Integration Tests
# =============================================================================

class TestIntegration:
    """Integration tests for complete scanning workflow."""
    
    def test_full_scan_workflow(self, temp_dir):
        """Test complete directory scan and result analysis."""
        # Create a realistic directory structure
        docs = temp_dir / "docs"
        docs.mkdir()
        
        (docs / "chapter1.md").write_text("""
# Introduction

This chapter explores process management.

Let's delve into the fundamentals of how operating systems handle processes.
It's important to note that each process has a unique PID.
""")
        
        (docs / "chapter2.md").write_text("""
# Advanced Topics

Furthermore, the scheduler leverages various algorithms.
The seamless integration of these components culminates in efficient execution.
""")
        
        (docs / "chapter3.md").write_text("""
# Practical Examples

```bash
#!/bin/bash
# This script is clean
echo "Process ID: $$"
```

The code above demonstrates basic shell scripting.
""")
        
        # Scan the entire directory
        all_results = scan_directory(docs, extensions=['.md'])
        
        # Verify structure
        assert len(all_results) == 3
        
        # Count total findings
        total_high = sum(len(r.high_risk) for r in all_results.values())
        total_medium = sum(len(r.medium_risk) for r in all_results.values())
        
        # Should detect patterns in chapter1 and chapter2
        assert total_high > 0 or total_medium > 0
        
        # Chapter3 should be clean
        chapter3_results = [r for p, r in all_results.items() if "chapter3" in str(p)]
        assert len(chapter3_results) == 1
        assert chapter3_results[0].total_count == 0


# =============================================================================
# Entry Point
# =============================================================================

if __name__ == '__main__':
    pytest.main([__file__, '-v', '--tb=short'])
