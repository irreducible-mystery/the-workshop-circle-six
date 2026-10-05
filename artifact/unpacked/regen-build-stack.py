#!/usr/bin/env python3
"""Regenerate 01-BUILD-STACK.md from lean/*.lean. verify.sh diffs its output
   against the committed file, so the doc cannot drift from the source."""
import re
out=["""# 01 — BUILD STACK

Generated from `lean/*.lean`. Every line below is extracted from the source, in
source order. If the source changes and this file is not regenerated,
`verify.sh` fails on drift.

Notation: `[]` = depends on no axiom. `dec` = closed by kernel evaluation
(`decide`). `trm` = closed by an explicit proof term.

---
"""]
for fn in ["lean/C6_Twist.lean","lean/C6_Gap.lean"]:
    src=open(fn).read(); out.append(f"\n## `{fn}`\n")
    lines=src.split("\n")
    for i,l in enumerate(lines):
        ms=re.match(r'^/-!\s*#*\s*(.+)$',l)
        if ms:
            t=ms.group(1).strip().rstrip('-/').strip().lstrip('# ').strip()
            if t: out.append(f"\n### {t}\n")
            continue
        md=re.match(r'^(def|abbrev|structure|inductive|instance)\s+([A-Za-z_][A-Za-z_0-9\']*)(.*)$',l)
        if md:
            kind,name,rest=md.groups(); body=rest.strip(); j=i
            while j+1<len(lines) and (body=="" or body.endswith((":=","where","|","(",","))) and j-i<4:
                j+=1; body=(body+" "+lines[j].strip()).strip()
            out.append(f"    {kind:<9} {name:<34} {body[:110]}"); continue
        mt=re.match(r'^theorem\s+([A-Za-z_][A-Za-z_0-9\']*)\s*(.*)$',l)
        if mt:
            name,rest=mt.groups(); stmt=rest; j=i
            while j+1<len(lines) and ':=' not in stmt and j-i<8:
                j+=1; stmt=(stmt+" "+lines[j].strip()).strip()
            how="dec" if "by decide" in stmt else "trm"
            stmt=re.sub(r'\s+',' ',re.split(r':=',stmt)[0].strip().lstrip(':').strip())
            out.append(f"    THEOREM   {name:<34} [{how}] []   {stmt[:120]}")
print("\n".join(out))
