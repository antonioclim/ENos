#!/usr/bin/env python3
"""
PNG Diagram Generator from PlantUML Files
==========================================
Operating Systems course — ASE Bucharest CSIE

Usage:
    python generate_diagrams.py [--jar PATH] [--output DIR] [--dpi DPI]

Author: Revolvix | ASE Bucharest — CSIE
Version: 2.0
"""

from __future__ import annotations

import logging
import os
import sys
import subprocess
import urllib.request
import argparse
import tempfile
import shutil
from pathlib import Path
from concurrent.futures import ThreadPoolExecutor, as_completed
from typing import Optional

# Configuration
PLANTUML_JAR_URL = "https://github.com/plantuml/plantuml/releases/download/v1.2024.8/plantuml-1.2024.8.jar"
PLANTUML_JAR_NAME = "plantuml.jar"
DEFAULT_DPI = 200
DEFAULT_OUTPUT_DIR = "diagrams_png"

# Logging configuration
logging.basicConfig(
    level=logging.INFO,
    format="%(message)s"
)
logger = logging.getLogger(__name__)


def check_java() -> bool:
    """Check whether Java is installed and accessible."""
    try:
        result = subprocess.run(
            ["java", "-version"],
            capture_output=True,
            text=True,
            timeout=10
        )
        return result.returncode == 0
    except (FileNotFoundError, subprocess.TimeoutExpired):
        return False


def download_plantuml_jar(target_path: Path) -> bool:
    """
    Download PlantUML JAR if it does not exist.
    
    Args:
        target_path: Destination path for the JAR file
        
    Returns:
        True if JAR is available, False otherwise
    """
    if target_path.exists():
        logger.info("✓ PlantUML JAR found: %s", target_path)
        return True

    logger.info("⬇ Downloading PlantUML JAR from GitHub...")
    try:
        urllib.request.urlretrieve(PLANTUML_JAR_URL, target_path)
        logger.info("✓ PlantUML JAR downloaded: %s", target_path)
        return True
    except OSError as e:
        logger.error("✗ Download error: %s", e)
        return False


def find_puml_files(base_dir: Path) -> list[Path]:
    """
    Find all .puml files recursively, excluding skin.puml.
    
    Args:
        base_dir: Root directory to search
        
    Returns:
        Sorted list of paths to .puml files
    """
    puml_files: list[Path] = []
    excluded_dirs = {DEFAULT_OUTPUT_DIR, "__pycache__", ".git", "diagrams_png", "output_png"}

    for root, dirs, files in os.walk(base_dir):
        dirs[:] = [d for d in dirs if d not in excluded_dirs]
        for file in files:
            if file.endswith(".puml") and file != "skin.puml":
                puml_files.append(Path(root) / file)

    return sorted(puml_files)


def find_skin_file(base_dir: Path) -> Optional[Path]:
    """
    Find the skin.puml file for shared styling.
    
    Args:
        base_dir: Root directory to search
        
    Returns:
        Path to skin.puml if found, None otherwise
    """
    for root, _, files in os.walk(base_dir):
        if "skin.puml" in files:
            return Path(root) / "skin.puml"
    return None


def preprocess_puml(puml_file: Path, skin_content: Optional[str] = None) -> str:
    """
    Preprocess a PUML file by inlining !include directives.
    
    Args:
        puml_file: Path to the .puml file
        skin_content: Optional content of skin.puml to inline
        
    Returns:
        Preprocessed PlantUML content as string
    """
    content = puml_file.read_text(encoding="utf-8", errors="ignore")
    lines = content.split("\n")
    processed_lines: list[str] = []

    for line in lines:
        if line.strip().startswith("!include"):
            if skin_content and "skin.puml" in line:
                processed_lines.append("' [skin.puml content inlined]")
                processed_lines.append(skin_content)
            else:
                processed_lines.append(f"' SKIPPED: {line.strip()}")
        else:
            processed_lines.append(line)

    return "\n".join(processed_lines)


def generate_png(
    puml_file: Path,
    jar_path: Path,
    output_dir: Path,
    dpi: int,
    skin_content: Optional[str] = None
) -> tuple[bool, str]:
    """
    Generate PNG from a PlantUML file.
    
    Args:
        puml_file: Source .puml file
        jar_path: Path to PlantUML JAR
        output_dir: Output directory for PNG
        dpi: Resolution in dots per inch
        skin_content: Optional skin.puml content
        
    Returns:
        Tuple of (success: bool, message: str)
    """
    output_dir.mkdir(parents=True, exist_ok=True)

    try:
        processed_content = preprocess_puml(puml_file, skin_content)

        with tempfile.NamedTemporaryFile(
            mode="w",
            suffix=".puml",
            delete=False,
            encoding="utf-8"
        ) as tmp:
            tmp.write(processed_content)
            tmp_path = Path(tmp.name)

        try:
            cmd = [
                "java",
                "-DPLANTUML_LIMIT_SIZE=16384",
                "-jar", str(jar_path),
                "-tpng",
                f"-Sdpi={dpi}",
                "-o", str(output_dir.absolute()),
                str(tmp_path)
            ]

            result = subprocess.run(
                cmd,
                capture_output=True,
                text=True,
                timeout=120
            )

            tmp_png = output_dir / f"{tmp_path.stem}.png"
            final_png = output_dir / f"{puml_file.stem}.png"

            if tmp_png.exists():
                if final_png.exists():
                    final_png.unlink()
                tmp_png.rename(final_png)

            if result.returncode == 0 and final_png.exists():
                size_kb = final_png.stat().st_size / 1024
                return (True, f"✓ {puml_file.name} → {final_png.name} ({size_kb:.0f} KB)")

            error_msg = result.stderr[:200] if result.stderr else "PNG not generated"
            return (False, f"✗ {puml_file.name}: {error_msg}")

        finally:
            if tmp_path.exists():
                tmp_path.unlink()

    except subprocess.TimeoutExpired:
        return (False, f"✗ {puml_file.name}: Timeout (diagram too complex?)")
    except OSError as e:
        return (False, f"✗ {puml_file.name}: {str(e)[:200]}")


def print_summary(results: list[tuple[bool, str]]) -> None:
    """Display the generation summary."""
    success_count = sum(1 for r in results if r[0])
    failed_count = len(results) - success_count

    logger.info("")
    logger.info("=" * 60)
    logger.info("PNG GENERATION SUMMARY")
    logger.info("=" * 60)
    logger.info("  Total files:    %d", len(results))
    logger.info("  ✓ Generated:    %d", success_count)
    logger.info("  ✗ Failed:       %d", failed_count)

    if failed_count > 0:
        logger.info("\nFiles with errors:")
        for success_flag, msg in results:
            if not success_flag:
                logger.info("  %s", msg)


def main() -> int:
    """
    Main entry point.
    
    Returns:
        Exit code (0 for success, 1 for failure)
    """
    parser = argparse.ArgumentParser(
        description="Generate PNG diagrams from PlantUML files",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  python generate_diagrams.py                    # Generate all PNGs
  python generate_diagrams.py --dpi 150          # Lower resolution
  python generate_diagrams.py --output ./images  # Custom output
        """
    )

    parser.add_argument(
        "--jar",
        type=Path,
        default=Path(__file__).parent / PLANTUML_JAR_NAME,
        help="Path to PlantUML JAR file"
    )
    parser.add_argument(
        "--output", "-o",
        type=Path,
        default=Path(__file__).parent / DEFAULT_OUTPUT_DIR,
        help="Output directory for PNG files"
    )
    parser.add_argument(
        "--dpi",
        type=int,
        default=DEFAULT_DPI,
        help="Resolution in DPI (default: 200)"
    )
    parser.add_argument(
        "--workers", "-j",
        type=int,
        default=4,
        help="Number of parallel workers"
    )
    parser.add_argument(
        "--clean",
        action="store_true",
        help="Delete existing output before generation"
    )

    args = parser.parse_args()

    logger.info("""
╔════════════════════════════════════════════════════════════════╗
║       OS Kit — PlantUML Diagram Generator → PNG                ║
║                    ASE Bucharest — CSIE                        ║
╚════════════════════════════════════════════════════════════════╝
    """)

    # Prerequisite checks
    if not check_java():
        logger.error("✗ Java is not installed!")
        return 1
    logger.info("✓ Java available")

    if not download_plantuml_jar(args.jar):
        return 1

    # Find source files
    base_dir = Path(__file__).parent
    puml_files = find_puml_files(base_dir)

    if not puml_files:
        logger.error("✗ No .puml files found!")
        return 1

    logger.info("✓ Found %d .puml files", len(puml_files))

    # Load shared skin
    skin_file = find_skin_file(base_dir)
    skin_content: Optional[str] = None
    if skin_file:
        logger.info("✓ skin.puml found: %s", skin_file)
        skin_content = skin_file.read_text(encoding="utf-8", errors="ignore")
    else:
        logger.warning("⚠ skin.puml not found (using default styles)")

    # Prepare output directory
    if args.clean and args.output.exists():
        shutil.rmtree(args.output)
    args.output.mkdir(parents=True, exist_ok=True)

    # Generate PNGs
    logger.info("\nGenerating PNGs (DPI=%d)...", args.dpi)
    logger.info("-" * 60)

    results: list[tuple[bool, str]] = []
    with ThreadPoolExecutor(max_workers=args.workers) as executor:
        futures = {
            executor.submit(
                generate_png, f, args.jar, args.output, args.dpi, skin_content
            ): f
            for f in puml_files
        }

        for future in as_completed(futures):
            result = future.result()
            results.append(result)
            logger.info(result[1])

    print_summary(results)

    failed_count = sum(1 for r in results if not r[0])
    logger.info("""
%s
DONE! Diagrams saved to: %s
%s
    """, "=" * 60, args.output, "=" * 60)

    return 1 if failed_count > 0 else 0


if __name__ == "__main__":
    sys.exit(main())
