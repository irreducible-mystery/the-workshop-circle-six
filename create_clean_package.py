#!/usr/bin/env python3
"""
Create Clean Math Package
Extracts pure mathematical content from Lean files and documentation
"""
import os
import re
from pathlib import Path

def extract_math_from_lean(lean_file_path):
    """Extract mathematical structures, theorems, and definitions from Lean files"""
    with open(lean_file_path, 'r') as f:
        content = f.read()
    
    # Extract key mathematical components
    components = {
        'structures': [],
        'theorems': [],
        'definitions': [],
        'lemmas': [],
        'examples': []
    }
    
    # Extract structures
    structure_pattern = r'structure\s+(\w+)\s*(?:where\s+.*?|\:)'
    for match in re.finditer(structure_pattern, content, re.MULTILINE | re.DOTALL):
        components['structures'].append(match.group(1))
    
    # Extract theorems
    theorem_pattern = r'theorem\s+(\w+)\s*(?:\(.*?\))?\s*:'
    for match in re.finditer(theorem_pattern, content, re.MULTILINE):
        components['theorems'].append(match.group(1))
    
    # Extract definitions
    def_pattern = r'def\s+(\w+)\s*(?:\(.*?\))?\s*:'
    for match in re.finditer(def_pattern, content, re.MULTILINE):
        components['definitions'].append(match.group(1))
    
    # Extract lemmas
    lemma_pattern = r'lemma\s+(\w+)\s*(?:\(.*?\))?\s*:'
    for match in re.finditer(lemma_pattern, content, re.MULTILINE):
        components['lemmas'].append(match.group(1))
    
    return components

def create_clean_math_summary(lean_files):
    """Create a clean mathematical summary from Lean files"""
    summary = []
    summary.append("=" * 80)
    summary.append("CLEAN MATHEMATICAL SUMMARY")
    summary.append("Extracted from Lean formalizations")
    summary.append("=" * 80)
    summary.append("")
    
    for lean_file in lean_files:
        file_name = os.path.basename(lean_file)
        components = extract_math_from_lean(lean_file)
        
        if any(components.values()):  # Only include files with mathematical content
            summary.append(f"\n## {file_name}")
            summary.append("-" * 40)
            
            if components['structures']:
                summary.append("\n### Structures:")
                for struct in components['structures']:
                    summary.append(f"  - {struct}")
            
            if components['theorems']:
                summary.append("\n### Theorems:")
                for theorem in components['theorems']:
                    summary.append(f"  - {theorem}")
            
            if components['definitions']:
                summary.append("\n### Definitions:")
                for definition in components['definitions']:
                    summary.append(f"  - {definition}")
            
            if components['lemmas']:
                summary.append("\n### Lemmas:")
                for lemma in components['lemmas']:
                    summary.append(f"  - {lemma}")
    
    return "\n".join(summary)

def main():
    base_path = Path("/workspace/the-workshop-circle-six/GAP")
    
    # Find all Lean files
    lean_files = list(base_path.glob("**/*.lean"))
    
    print(f"Found {len(lean_files)} Lean files")
    
    # Create clean math summary
    clean_summary = create_clean_math_summary(lean_files)
    
    # Write summary
    output_path = Path("/workspace/the-workshop-circle-six/workshop_package/clean_math/lean_mathematical_summary.md")
    output_path.parent.mkdir(parents=True, exist_ok=True)
    
    with open(output_path, 'w') as f:
        f.write(clean_summary)
    
    print(f"Created clean mathematical summary: {output_path}")
    
    # Copy all Lean files to clean_math directory
    lean_dest = Path("/workspace/the-workshop-circle-six/workshop_package/lean_formalizations")
    lean_dest.mkdir(parents=True, exist_ok=True)
    
    for lean_file in lean_files:
        dest_file = lean_dest / lean_file.name
        # Handle duplicates by adding prefix if needed
        if dest_file.exists():
            prefix = lean_file.parent.name
            dest_file = lean_dest / f"{prefix}_{lean_file.name}"
        import shutil
        shutil.copy2(lean_file, dest_file)

    # Copy Python scripts
    python_files = list(base_path.glob("**/*.py"))
    scripts_dest = Path("/workspace/the-workshop-circle-six/workshop_package/scripts")
    scripts_dest.mkdir(parents=True, exist_ok=True)
    
    for py_file in python_files:
        dest_file = scripts_dest / py_file.name
        if dest_file.exists():
            prefix = py_file.parent.name
            dest_file = scripts_dest / f"{prefix}_{py_file.name}"
        import shutil
        shutil.copy2(py_file, dest_file)
    
    # Copy all PNG files
    png_files = list(base_path.glob("**/*.png"))
    viz_dest = Path("/workspace/the-workshop-circle-six/workshop_package/visualizations")
    viz_dest.mkdir(parents=True, exist_ok=True)
    
    for png_file in png_files:
        dest_file = viz_dest / png_file.name
        if dest_file.exists():
            prefix = png_file.parent.name
            dest_file = viz_dest / f"{prefix}_{png_file.name}"
        import shutil
        shutil.copy2(png_file, dest_file)
    
    print(f"Copied {len(lean_files)} Lean files to {lean_dest}")
    print(f"Copied {len(python_files)} Python scripts to {scripts_dest}")
    print(f"Copied {len(png_files)} visualizations to {viz_dest}")

if __name__ == "__main__":
    main()