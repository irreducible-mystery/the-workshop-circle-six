#!/usr/bin/env python3
"""
Lean Framework Implementation Organizer and Status Report
"""

import os
from pathlib import Path

def scan_lean_files():
    """Scan directory for Lean framework files and generate report."""
    base_path = Path("/workspace/the-workshop-circle-six/GAP/lean")
    
    if not base_path.exists():
        print(f"Error: Path {base_path} does not exist")
        return
    
    lean_files = sorted(list(base_path.glob("*.lean")))
    
    print("=" * 80)
    print("LEAN FRAMEWORK IMPLEMENTATION STATUS")
    print("=" * 80)
    print()
    
    # Main frameworks
    main_frameworks = ['CategoryGap', 'HomotopyGap', 'ThermodynamicGap']
    
    print("MAIN FRAMEWORKS:")
    print("-" * 80)
    
    for fw_name in main_frameworks:
        fw_file = base_path / f"{fw_name}.lean"
        if fw_file.exists():
            content = fw_file.read_text()
            size_kb = fw_file.stat().st_size / 1024
            lines = len(content.splitlines())
            has_proofs = 'theorem' in content
            has_definitions = 'def' in content or 'structure' in content
            has_sorry = 'sorry' in content
            
            print(f"✅ {fw_name}")
            print(f"   Size: {size_kb:.1f} KB | Lines: {lines}")
            print(f"   Has Proofs: {'✓' if has_proofs else '✗'}")
            print(f"   Has Definitions: {'✓' if has_definitions else '✗'}")
            print(f"   Complete (no sorry): {'✓' if not has_sorry else '✗'}")
            print()
        else:
            print(f"❌ {fw_name} not found")
            print()
    
    # Basic versions  
    print("BASIC VERSIONS (for compatibility):")
    print("-" * 80)
    
    for fw_name in main_frameworks:
        basic_file = base_path / f"{fw_name}_Basic.lean"
        if basic_file.exists():
            content = basic_file.read_text()
            size_kb = basic_file.stat().st_size / 1024
            lines = len(content.splitlines())
            
            print(f"✅ {fw_name}_Basic")
            print(f"   Size: {size_kb:.1f} KB | Lines: {lines}")
            print()
        else:
            print(f"❌ {fw_name}_Basic not found")
            print()
    
    # Other Lean files
    print("OTHER LEAN FILES:")
    print("-" * 80)
    
    all_file_names = [fw.stem for fw in lean_files]
    main_and_basic = set([fw for fw in main_frameworks] + [f"{fw}_Basic" for fw in main_frameworks])
    other_files = [fw for fw in lean_files if fw.stem not in main_and_basic]
    
    for fw_file in sorted(other_files, key=lambda x: x.name):
        size_kb = fw_file.stat().st_size / 1024
        print(f"✓ {fw_file.stem}: {size_kb:.1f} KB")
    
    print()
    print("=" * 80)
    
    # Key statistics
    print("STATISTICS:")
    print("-" * 80)
    print(f"Total Lean files: {len(lean_files)}")
    
    theorems_count = 0
    definitions_count = 0
    
    for fw_file in lean_files:
        content = fw_file.read_text()
        theorems_count += content.count('theorem ')
        # Count definitions roughly
        definitions_count += content.count('def ') + content.count('structure ')
    
    print(f"Total theorems defined: {theorems_count}")
    print(f"Total definitions/structures: {definitions_count}")
    print()
    print("=" * 80)



def main():
    scan_lean_files()

if __name__ == "__main__":
    main()