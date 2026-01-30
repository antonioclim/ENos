#!/usr/bin/env python3
"""
PNG Diagram Generator from PlantUML Files - CORRECTED VERSION
==============================================================
Script for the Operating Systems course - ASE Bucharest CSIE

PROBLEM RESOLVED: !include paths that were not resolving correctly

Usage:
    python generate_diagrams_FIXED.py [--jar PATH] [--output DIR] [--dpi DPI]

Author: Revolvix | ASE Bucharest - CSIE
"""

import os
import sys
import subprocess
import urllib.request
import argparse
import tempfile
import shutil
from pathlib import Path
from concurrent.futures import ThreadPoolExecutor, as_completed

# Configuration
PLANTUML_JAR_URL = "https://github.com/plantuml/plantuml/releases/download/v1.2024.8/plantuml-1.2024.8.jar"
PLANTUML_JAR_NAME = "plantuml.jar"
DEFAULT_DPI = 200
DEFAULT_OUTPUT_DIR = "output_png"

def check_java():
    """Check whether Java is installed."""
    try:
        result = subprocess.run(["java", "-version"], capture_output=True, text=True)
        return result.returncode == 0
    except FileNotFoundError:
        return False

def download_plantuml_jar(target_path: Path):
    """Download PlantUML JAR if it does not exist."""
    if target_path.exists():
        print(f"✓ PlantUML JAR found: {target_path}")
        return True
    
    print(f"⬇ Downloading PlantUML JAR from GitHub...")
    try:
        urllib.request.urlretrieve(PLANTUML_JAR_URL, target_path)
        print(f"✓ PlantUML JAR downloaded: {target_path}")
        return True
    except Exception as e:
        print(f"✗ Download error: {e}")
        return False

def find_puml_files(base_dir: Path) -> list:
    """Find all .puml files recursively."""
    puml_files = []
    for root, dirs, files in os.walk(base_dir):
        dirs[:] = [d for d in dirs if d not in [DEFAULT_OUTPUT_DIR, '__pycache__', '.git']]
        for file in files:
            if file.endswith('.puml') and file != 'skin.puml':
                puml_files.append(Path(root) / file)
    return sorted(puml_files)

def find_skin_file(base_dir: Path) -> Path:
    """Find the skin.puml file."""
    for root, dirs, files in os.walk(base_dir):
        for file in files:
            if file == 'skin.puml':
                return Path(root) / file
    return None

def preprocess_puml(puml_file: Path, skin_content: str = None) -> str:
    """
    Preprocess a PUML file - RESOLVES THE !include PROBLEM
    
    Strategy: Replace !include with actual content or remove it
    """
    content = puml_file.read_text(encoding='utf-8', errors='ignore')
    
    # Remove !include lines (skin.puml is optional, diagrams have inline styles)
    lines = content.split('\n')
    processed_lines = []
    
    for line in lines:
        # Skip lines with !include
        if line.strip().startswith('!include'):
            # If we have skin_content, insert it instead of !include
            if skin_content and 'skin.puml' in line:
                processed_lines.append('\'  [skin.puml content inlined below]')
                processed_lines.append(skin_content)
            else:
                processed_lines.append(f"' REMOVED: {line.strip()}")
            continue
        processed_lines.append(line)
    
    return '\n'.join(processed_lines)

def generate_png(puml_file: Path, jar_path: Path, output_dir: Path, dpi: int, skin_content: str = None) -> tuple:
    """
    Generate PNG from a PlantUML file.
    
    Returns: (success: bool, message: str)
    """
    output_dir.mkdir(parents=True, exist_ok=True)
    
    try:
        # Preprocess the PUML file
        processed_content = preprocess_puml(puml_file, skin_content)
        
        # Create temporary file with processed content
        with tempfile.NamedTemporaryFile(mode='w', suffix='.puml', delete=False, encoding='utf-8') as tmp:
            tmp.write(processed_content)
            tmp_path = tmp.name
        
        try:
            # Generate PNG from temporary file
            cmd = [
                "java",
                "-DPLANTUML_LIMIT_SIZE=16384",
                "-jar", str(jar_path),
                "-tpng",
                f"-Sdpi={dpi}",
                "-o", str(output_dir.absolute()),
                tmp_path
            ]
            
            result = subprocess.run(cmd, capture_output=True, text=True, timeout=120)
            
            # Rename output file to have the original name
            tmp_png = output_dir / (Path(tmp_path).stem + ".png")
            final_png = output_dir / (puml_file.stem + ".png")
            
            if tmp_png.exists():
                if final_png.exists():
                    final_png.unlink()
                tmp_png.rename(final_png)
            
            if result.returncode == 0 and final_png.exists():
                size = final_png.stat().st_size / 1024
                return (True, f"✓ {puml_file.name} → {final_png.name} ({size:.0f}KB)")
            else:
                error_msg = result.stderr[:200] if result.stderr else "PNG was not generated"
                return (False, f"✗ {puml_file.name}: {error_msg}")
                
        finally:
            # Clean up temporary file
            if os.path.exists(tmp_path):
                os.unlink(tmp_path)
            
    except subprocess.TimeoutExpired:
        return (False, f"✗ {puml_file.name}: Timeout (diagram too complex?)")
    except Exception as e:
        return (False, f"✗ {puml_file.name}: {str(e)[:200]}")

def print_summary(results: list):
    """Display the generation summary."""
    success = sum(1 for r in results if r[0])
    failed = len(results) - success
    
    print(f"\n{'='*60}")
    print(f"PNG GENERATION SUMMARY")
    print(f"{'='*60}")
    print(f"  Total files:    {len(results)}")
    print(f"  ✓ Generated:    {success}")
    print(f"  ✗ Failed:       {failed}")
    
    if failed > 0:
        print(f"\nFiles with errors:")
        for success_flag, msg in results:
            if not success_flag:
                print(f"  {msg}")

def main():
    parser = argparse.ArgumentParser(
        description="Generate PNG diagrams from PlantUML files (corrected version)",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  python generate_diagrams_FIXED.py                    # Generate all PNGs
  python generate_diagrams_FIXED.py --dpi 150          # Lower DPI
  python generate_diagrams_FIXED.py --output ./images  # Custom output directory
        """
    )
    
    parser.add_argument("--jar", type=Path, default=Path(__file__).parent / PLANTUML_JAR_NAME)
    parser.add_argument("--output", "-o", type=Path, default=Path(__file__).parent / DEFAULT_OUTPUT_DIR)
    parser.add_argument("--dpi", type=int, default=DEFAULT_DPI)
    parser.add_argument("--workers", "-j", type=int, default=4)
    parser.add_argument("--clean", action="store_true", help="Delete existing output")
    
    args = parser.parse_args()
    
    print("""
╔════════════════════════════════════════════════════════════════╗
║     OS Kit - PlantUML Diagram Generator → PNG (FIXED)          ║
║                    ASE Bucharest - CSIE                        ║
╚════════════════════════════════════════════════════════════════╝
    """)
    
    # Checks
    if not check_java():
        print("✗ Java is not installed!")
        sys.exit(1)
    print("✓ Java available")
    
    if not download_plantuml_jar(args.jar):
        sys.exit(1)
    
    # Find files
    base_dir = Path(__file__).parent
    puml_files = find_puml_files(base_dir)
    
    if not puml_files:
        print("✗ No .puml files found!")
        sys.exit(1)
    
    print(f"✓ Found {len(puml_files)} .puml files")
    
    # Find skin.puml (optional)
    skin_file = find_skin_file(base_dir)
    skin_content = None
    if skin_file:
        print(f"✓ skin.puml found: {skin_file}")
        skin_content = skin_file.read_text(encoding='utf-8', errors='ignore')
    else:
        print("⚠ skin.puml not found (default styles will be used)")
    
    # Prepare output
    if args.clean and args.output.exists():
        shutil.rmtree(args.output)
    args.output.mkdir(parents=True, exist_ok=True)
    
    # Generation
    print(f"\nGenerating PNGs (DPI={args.dpi})...")
    print("-" * 60)
    
    results = []
    with ThreadPoolExecutor(max_workers=args.workers) as executor:
        futures = {
            executor.submit(generate_png, f, args.jar, args.output, args.dpi, skin_content): f 
            for f in puml_files
        }
        
        for future in as_completed(futures):
            result = future.result()
            results.append(result)
            print(result[1])
    
    print_summary(results)
    
    print(f"""
{'='*60}
DONE! Diagrams are in: {args.output}
{'='*60}
    """)

if __name__ == "__main__":
    main()
