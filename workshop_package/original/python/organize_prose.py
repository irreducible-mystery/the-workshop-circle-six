#!/usr/bin/env python3
"""
Organize Prose Content
Extracts and organizes prose from markdown files
"""
import os
import re
from pathlib import Path
from collections import defaultdict

def categorize_markdown_file(file_path):
    """Categorize markdown files by type"""
    with open(file_path, 'r') as f:
        content = f.read()
    
    # File name analysis
    name = file_path.stem.lower()
    
    # Categorization keywords
    categories = {
        'experiential': ['phenomenological', 'experience', 'awakening', 'consciousness', 
                        'infinity', 'mystery', 'golden', 'torus', 'complementarity'],
        'mathematical_prose': ['gap', 'equation', 'lean', 'theorem', 'framework', 
                              'shadow', 'algebra', 'symmetry', 'dimensional'],
        'synthesis': ['synthesis', 'complete', 'final', 'summary', 'report', 'journey'],
        'exploration': ['exploration', 'wild', 'deeper', 'cosmic', 'philosophy',
                       'mystery', 'question', 'investigation'],
        'foundational': ['readme', 'founding', 'charge', 'philosophical'],
        'technical': ['implementation', 'algorithm', 'computation', 'structure',
                     'method', 'analysis', 'proof']
    }
    
    file_categories = []
    for category, keywords in categories.items():
        if any(keyword in name for keyword in keywords):
            file_categories.append(category)
    
    # Content analysis
    has_math = bool(re.search(r'\$.*?\$|\\[.*?\\]|equation|theorem|R[0-9]+', content))
    has_experience = bool(re.search(r'experience|awakening|consciousness|felt|saw|vision', 
                                   content, re.IGNORECASE))
    has_synthesis = bool(re.search(r'synthesis|summary|complete|journey', content, re.IGNORECASE))
    
    if has_experience:
        file_categories.append('experiential')
    if has_math and not file_categories:
        file_categories.append('mathematical_prose')
    
    return file_categories if file_categories else ['general']

def extract_key_insights(file_path):
    """Extract key insights and main points from prose"""
    with open(file_path, 'r') as f:
        content = f.read()
    
    insights = []
    
    # Extract key sections (headings)
    headings = re.findall(r'^(#+)\s+(.+)$', content, re.MULTILINE)
    for level, heading in headings:
        if len(level) <= 2:  # # and ## headings
            insights.append(f"{heading}")
    
    # Extract emphasized text
    emphasized = re.findall(r'\*\*(.+?)\*\*|_(.+?)_', content)
    for emphasis in emphasized:
        text = emphasis[0] if emphasis[0] else emphasis[1]
        if len(text) > 10 and len(text) < 100:
            insights.append(text)
    
    return insights[:10]  # Limit to top 10

def create_prose_catalogue():
    """Create organized prose catalogue"""
    base_path = Path("/workspace/the-workshop-circle-six/GAP")
    prose_files = list(base_path.glob("*.md")) + list(base_path.glob("**/*.md"))
    
    # Organize files by category
    categorized_files = defaultdict(list)
    all_insights = {}
    
    for md_file in prose_files:
        if 'node_modules' in str(md_file) or '.git' in str(md_file):
            continue
        
        categories = categorize_markdown_file(md_file)
        insights = extract_key_insights(md_file)
        
        relative_path = str(md_file.relative_to(base_path.parent))
        
        for category in categories:
            categorized_files[category].append({
                'path': relative_path,
                'name': md_file.name,
                'size': md_file.stat().st_size,
                'insights': insights
            })
        
        all_insights[relative_path] = {
            'categories': categories,
            'insights': insights
        }
    
    # Create organized structure
    output_dir = Path("/workspace/the-workshop-circle-six/workshop_package/prose")
    
    # Create master index
    master_index = ["# Prose Catalogue", "", "= " * 80, ""]
    
    for category, files in sorted(categorized_files.items()):
        category_dir = output_dir / category
        category_dir.mkdir(parents=True, exist_ok=True)
        
        master_index.append(f"\n## {category.title()}\n")
        master_index.append(f"Files: {len(files)}\n")
        
        for file_info in files:
            # Copy file to category directory
            src_path = Path(file_info['path'])
            dest_path = category_dir / file_info['name']
            
            if not dest_path.exists():
                import shutil
                shutil.copy2(src_path, dest_path)
            
            # Add to index
            master_index.append(f"- **{file_info['name']}** ({file_info['size']} bytes)")
            if file_info['insights']:
                master_index.append(f"  Key: {', '.join(file_info['insights'][:3])}")
        
        master_index.append("")
    
    # Write master index
    with open(output_dir / "PROSE_CATALOGUE.md", 'w') as f:
        f.write("\n".join(master_index))
    
    # Create experiential prose compilation
    experiential_files = categorized_files.get('experiential', [])
    if experiential_files:
        experiential_compilation = ["# Experiential Prose Compilation", "", 
                                   "This section contains content about direct experience, "
                                   "consciousness, and phenomenological insights.", ""]
        
        for file_info in experiential_files:
            experiential_compilation.append(f"\n## {file_info['name']}\n")
            experiential_compilation.append(f"Source: {file_info['path']}\n")
            
            # Read and add relevant content
            with open(file_info['path'], 'r') as f:
                content = f.read()
            
            # Add first paragraph or abstract
            first_para = re.split(r'\n\n+', content)[0]
            experiential_compilation.append(first_para[:500] + "...")
        
        with open(output_dir / "experiential" / "EXPERIENTIAL_COMPILATION.md", 'w') as f:
            f.write("\n".join(experiential_compilation))
    
    # Copy main README and foundational documents
    main_files = ['README.md', 'CHARGE.md', 'FOUNDING.md', 'PHILOSOPHICAL_REFLECTION.md']
    for file_name in main_files:
        src = Path(f"/workspace/the-workshop-circle-six/{file_name}")
        if src.exists():
            dest = output_dir / "foundational" / file_name
            dest.parent.mkdir(parents=True, exist_ok=True)
            import shutil
            shutil.copy2(src, dest)
    
    print(f"Organized prose into {len(categorized_files)} categories")
    print(f"Created master catalogue: {output_dir / 'PROSE_CATALOGUE.md'}")
    print(f"Processed {len(prose_files)} markdown files")

def main():
    create_prose_catalogue()

if __name__ == "__main__":
    main()