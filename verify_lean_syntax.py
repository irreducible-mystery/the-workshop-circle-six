#!/usr/bin/env python3
"""
Lean Syntax Verification Script

This script performs basic syntax validation of Lean files by checking for:
1. Proper imports
2. Correct namespace usage
3. Basic theorem/definition structure
4. Common syntax errors
"""

import re
import sys
from pathlib import Path
from typing import List, Tuple, Dict

class LeanSyntaxChecker:
    def __init__(self):
        self.issues = []
        self.warnings = []
    
    def check_file(self, filepath: str) -> List[Tuple[str, int, str]]:
        """Check a single Lean file for syntax issues."""
        issues = []
        
        try:
            with open(filepath, 'r', encoding='utf-8') as f:
                content = f.read()
                lines = content.split('\n')
        except Exception as e:
            return [(filepath, 0, f"File read error: {e}")]
        
        # Check for basic Lean structure
        self._check_imports(filepath, lines, issues)
        self._check_namespace(filepath, lines, issues)
        self._check_theorem_structure(filepath, lines, issues)
        self._check_definition_structure(filepath, lines, issues)
        self._check_common_errors(filepath, lines, issues)
        self._check_proof_obligations(filepath, lines, issues)
        
        return issues
    
    def _check_imports(self, filepath: str, lines: List[str], issues: List[Tuple[str, int, str]]):
        """Check import statements."""
        import_pattern = r'^import\s+Mathlib\.'
        has_import = any(re.match(import_pattern, line.strip()) for line in lines)
        
        if not has_import:
            issues.append((filepath, 0, "WARNING: No Mathlib imports found"))
        
        # Check for duplicate imports
        imports = []
        for i, line in enumerate(lines, 1):
            if line.strip().startswith('import '):
                imports.append((i, line.strip()))
        
        if len(imports) != len(set(imp[1] for imp in imports)):
            issues.append((filepath, 0, "WARNING: Duplicate imports detected"))
    
    def _check_namespace(self, filepath: str, lines: List[str], issues: List[Tuple[str, int, str]]):
        """Check namespace structure."""
        namespace_pattern = r'^namespace\s+\w+'
        end_namespace_pattern = r'^end\s+\w+'
        
        has_namespace = any(re.match(namespace_pattern, line.strip()) for line in lines)
        has_end_namespace = any(re.match(end_namespace_pattern, line.strip()) for line in lines)
        
        if has_namespace and not has_end_namespace:
            issues.append((filepath, 0, "ERROR: Namespace opened but not closed"))
        
        # Check namespace naming
        for i, line in enumerate(lines, 1):
            if re.match(namespace_pattern, line.strip()):
                namespace_name = line.strip().split()[1]
                if not namespace_name.isidentifier():
                    issues.append((filepath, i, f"Invalid namespace name: {namespace_name}"))
    
    def _check_theorem_structure(self, filepath: str, lines: List[str], issues: List[Tuple[str, int, str]]):
        """Check theorem/lemma structure."""
        theorem_pattern = r'^\s*(theorem|lemma)\s+\w+'
        
        for i, line in enumerate(lines, 1):
            if re.match(theorem_pattern, line.strip()):
                # Check if theorem has colon (expected in Lean)
                if ':' not in line and ':=' not in line:
                    issues.append((filepath, i, f"Theorem/lemma missing type annotation"))
                
                # Check if theorem has proof body
                remaining_lines = lines[i:]
                has_proof = False
                for j, check_line in enumerate(remaining_lines, i):
                    if check_line.strip().startswith(':='):
                        has_proof = True
                        break
                    if re.match(r'^\s*(theorem|lemma|def|structure)\s+', check_line.strip()):
                        break  # Hit next definition
                
                if not has_proof:
                    issues.append((filepath, i, f"Theorem/lemma missing proof body"))
    
    def _check_definition_structure(self, filepath: str, lines: List[str], issues: List[Tuple[str, int, str]]):
        """Check definition structure."""
        def_pattern = r'^\s*def\s+\w+'
        struct_pattern = r'^\s*structure\s+\w+'
        
        for i, line in enumerate(lines, 1):
            if re.match(def_pattern, line.strip()) or re.match(struct_pattern, line.strip()):
                # Check if definition has type annotation
                if ':' not in line and ':=' not in line:
                    issues.append((filepath, i, f"Definition/structure missing type annotation"))
    
    def _check_common_errors(self, filepath: str, lines: List[str], issues: List[Tuple[str, int, str]]):
        """Check for common Lean syntax errors."""
        
        # Check for mismatched parentheses
        for i, line in enumerate(lines, 1):
            if line.count('(') != line.count(')'):
                # This might be multi-line, so just warn
                # issues.append((filepath, i, f"WARNING: Possible mismatched parentheses"))
                pass
            
            # Check for mismatched braces
            if line.count('{') != line.count('}'):
                # Again, might be multi-line
                pass
        
        # Check for proper use of := vs =
        for i, line in enumerate(lines, 1):
            if 'def ' in line and ':=' not in line and ':' in line and '=' not in line:
                issues.append((filepath, i, f"Definition may be missing ':='"))
    
    def _check_proof_obligations(self, filepath: str, lines: List[str], issues: List[Tuple[str, int, str]]):
        """Check for incomplete proof obligations (sorry)."""
        sorry_count = sum(1 for line in lines if 'sorry' in line)
        
        if sorry_count > 0:
            issues.append((filepath, 0, f"INFO: Contains {sorry_count} incomplete proof obligations (sorry)"))

def main():
    """Main verification function."""
    lean_files = [
        "GAP/lean/CompleteSelfReference.lean",
        "GAP/lean/CompletionGapMinimum.lean", 
        "GAP/lean/ShadowCastingFormal.lean",
        "GAP/lean/MissingTheoremsFormalized.lean"
    ]
    
    checker = LeanSyntaxChecker()
    all_issues = []
    
    print("=== Lean Syntax Verification ===\n")
    
    for lean_file in lean_files:
        filepath = Path(lean_file)
        if not filepath.exists():
            print(f"❌ File not found: {lean_file}")
            continue
            
        print(f"📄 Checking: {lean_file}")
        issues = checker.check_file(str(filepath))
        all_issues.extend(issues)
        
        if not issues:
            print(f"✅ No syntax issues found\n")
        else:
            for file, line, message in issues:
                if line == 0:
                    print(f"  {message}")
                else:
                    print(f"  Line {line}: {message}")
            print()
    
    print("=== Summary ===")
    total_issues = len(all_issues)
    if total_issues == 0:
        print("✅ All files passed basic syntax checks")
    else:
        print(f"⚠️  Found {total_issues} potential issues")
        
        # Categorize issues
        errors = [i for i in all_issues if 'ERROR' in i[2]]
        warnings = [i for i in all_issues if 'WARNING' in i[2]]
        info = [i for i in all_issues if 'INFO' in i[2]]
        
        print(f"  - Errors: {len(errors)}")
        print(f"  - Warnings: {len(warnings)}")
        print(f"  - Info: {len(info)}")
    
    return 0 if total_issues == 0 else 1

if __name__ == "__main__":
    sys.exit(main())