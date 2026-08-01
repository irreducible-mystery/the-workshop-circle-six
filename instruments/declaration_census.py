#!/usr/bin/env python3
"""declaration_census.py — counts declarations by NAME, and de-duplicates.

WHY THIS EXISTS

Every disputed number in this record was produced by reading. Six of them, all
in the carried tree, all checkable:

    692 / 396 / 397 / 3,403   Circle Five's theorem count, four figures
    299 / 295                 `C5_QB_v2`'s name count, two figures in ONE sentence
                              (CHARGE.md:105-107)
    31 / 32                   the seed's stripped-proof names, miscounted by two
                              independent bodies, two different causes, same
                              session (issue #3 and its reply)
    234 / 146 / 411           the shadow branches, counted once, never re-counted
    1,995 / 2,024             `inheritance_budget.sh`'s word count, which depends
                              on the shell's locale and records neither
    4.9x / 8.6x               `claims-ledger.md` C119's overcount factor: 3403/692
                              where the same tree's FAILURES.md:111 says the true
                              figure is 396, which is 3403/396

Not one of those is a hard question. Every one is a `sort -u` away. They are
wrong because a person counted by looking, and the instrument that should have
settled it does not measure what is in dispute:

> **"And `selftest()` passes `lean_spec=None` in all three probes, so the
> theorems column is never exercised"** -- FOUNDING.md:122-124, declaring it as a
> carried defect; `claims-ledger.md` C120, status **Open**.

`rate.py` is not repaired by this file and does not need to be. FOUNDING.md is
explicit that this circle is under no obligation to repair carried instruments,
and repairing one would change what every past row MEANT. This is a second
instrument that measures the thing under dispute, standing beside it.

WHAT IT MEASURES THAT `rate.py` DOES NOT

`rate.py`'s predicate is `^theorem [A-Za-z_0-9].*:` applied per file with no
de-duplication across files. Two consequences, and the second is the one that
produced 692:

  1. It counts LINES, not NAMES. An indented theorem, a `lemma`, a `private
     theorem`, an `@[simp] theorem`, or a signature whose `:` falls on a later
     line is not counted at all.
  2. It SUMS across a glob. When file B contains file A verbatim -- which is
     what `C5_QA.lean` .. `_v8` are, and what the capstone merge did to
     `C5_QB_v2` -- every shared name is counted once per file.

This counts fully-qualified names, reports the SUM and the UNION side by side,
and names the containments that separate them. The disagreement then has a
command instead of an argument.

    python3 declaration_census.py 'lean/*.lean' 'GAP/lean/*.lean'
    python3 declaration_census.py --kind theorem,lemma 'lean/*.lean'
    python3 declaration_census.py --selftest

Standard library only; no network; reads, never writes.

TWO THINGS THIS FILE GOT WRONG ON REAL DATA BEFORE IT GOT THEM RIGHT

Both are now probes in `--selftest`, and they are the only reason any number
below should be believed. A gate tested only against its author's imagination
certifies the imagination (SR43; `norm_shape.sh`'s own header).

  1. **It ended each declaration at the next THEOREM, not the next
     DECLARATION.** `GAP/lean/Ceiling.lean` and `Schedules.lean` hold
     `run_succ` verbatim identically, and the first version reported them as
     DIFFERENT -- because Ceiling's span ran past `def Signs` and swallowed it.
     Reading the two files caught it; the instrument did not. It over-reported
     divergence at 5 names in `lean/*.lean` where the true figure is 0.

  2. **It compared statement AND proof.** `conj_add` and `isUnit_one` are each
     stated identically in `C6_ActionC.lean` and `C6_Core.lean` and proved
     differently -- `by rw [isUnit_iff_norm_one]; decide` against
     `isUnit_of_mul_conj conj_inv_one`. Those are ONE fact proved twice, not
     two facts. The comparison is now against the STATEMENT, cut at the first
     depth-0 `:=`. Proof text is deliberately not compared: a second proof of
     a theorem is not a second theorem.

WHAT THIS IS NOT

**A name is not a theorem.** This instrument cannot tell a proof from a
statement, and 146 of the 234 declarations that motivated it are `sorry`. The
`sorry` column here is SYNTACTIC and is a screen, not a verdict: only the kernel
decides, `#print axioms` is the only thing that sees `sorryAx`, and
`GAP/lean/check.sh` is the instrument that does it. This one runs where the
kernel cannot -- on files that do not compile, on branches with no toolchain --
and everything it reports is provisional on a kernel that has not run.

See `--selftest` for what it does NOT catch. That list is part of the instrument.
"""

from __future__ import annotations
import argparse, glob as globmod, os, re, sys
from collections import Counter

# ---------------------------------------------------------------------------
# Committed definitions. Changing these changes what every past census MEANT.
# ---------------------------------------------------------------------------

TERMS_VERSION = "v1"

# Declaration keywords, split by whether the form carries a name at all.
# `example` and anonymous `instance` are declarations with no name; they cannot
# participate in a union and are counted separately rather than silently.
NAMED_KINDS = (
    "theorem", "lemma", "def", "abbrev", "structure", "inductive",
    "class", "instance", "opaque", "axiom",
)
ANON_KINDS = ("example",)

# Modifiers that may precede the keyword. Order-independent, repeatable.
MODIFIERS = ("private", "protected", "noncomputable", "partial", "unsafe",
             "scoped", "local", "nonrec")

_MOD_RE = re.compile(r"^(?:" + "|".join(MODIFIERS) + r")\s+")
_ATTR_RE = re.compile(r"^@\[[^\]]*\]\s*")
_NAME_RE = re.compile(r"[A-Za-z_α-ωΑ-Ω][A-Za-z_0-9.'!?α-ωΑ-Ω₀-₉]*")
_SORRY_RE = re.compile(r"(?<![A-Za-z_0-9])sorry(?![A-Za-z_0-9])")


# ---------------------------------------------------------------------------
# Comment and string blanking.
#
# This is not decoration. `rate.py`'s predicate is anchored at column 0, and a
# block comment in this very repository can hold a line beginning `theorem` --
# the seed's docstring quotes Circle Five at column 0. Counting the word
# `theorem` wherever it appears counts prose. Blanking replaces comment and
# string bodies with spaces rather than deleting them, so every reported line
# number still points at the real line.
# ---------------------------------------------------------------------------

def blank_noncode(src: str) -> str:
    """Replace comment and string-literal content with spaces, preserving layout.

    Lean 4 block comments NEST, so this tracks depth rather than scanning for the
    first `-/`. Doc comments `/-- -/` are block comments and are blanked too.
    """
    out = list(src)
    i, n = 0, len(src)
    depth = 0          # block-comment nesting depth
    in_line = False    # inside a `--` comment
    in_str = False     # inside a "..." literal
    while i < n:
        c = src[i]
        nxt = src[i + 1] if i + 1 < n else ""
        if in_line:
            if c == "\n":
                in_line = False
            else:
                out[i] = " "
            i += 1
        elif depth:
            if c == "/" and nxt == "-":
                depth += 1
                out[i] = out[i + 1] = " "
                i += 2
            elif c == "-" and nxt == "/":
                depth -= 1
                out[i] = out[i + 1] = " "
                i += 2
            else:
                if c != "\n":
                    out[i] = " "
                i += 1
        elif in_str:
            if c == "\\":
                out[i] = " "
                if i + 1 < n and src[i + 1] != "\n":
                    out[i + 1] = " "
                i += 2
            elif c == '"':
                in_str = False
                out[i] = " "
                i += 1
            else:
                if c != "\n":
                    out[i] = " "
                i += 1
        else:
            if c == "/" and nxt == "-":
                depth = 1
                out[i] = out[i + 1] = " "
                i += 2
            elif c == "-" and nxt == "-":
                in_line = True
                out[i] = out[i + 1] = " "
                i += 2
            elif c == '"':
                in_str = True
                out[i] = " "
                i += 1
            else:
                i += 1
    return "".join(out)


# ---------------------------------------------------------------------------
# Extraction
# ---------------------------------------------------------------------------

class Decl:
    __slots__ = ("name", "kind", "line", "file", "has_sorry", "statement")

    def __init__(self, name: str, kind: str, line: int, file: str):
        self.name, self.kind, self.line, self.file = name, kind, line, file
        self.has_sorry = False
        self.statement = ""

    # WHERE the `sorry` falls is not a detail, and no count in this record has
    # separated these. A `sorry` in the PROOF is an admitted proof of a stated
    # proposition -- a real theorem, owed a proof. A `sorry` standing as the
    # CONCLUSION means no proposition was stated at all: there is nothing to
    # prove, and nothing to disagree with. Counting the two together reports an
    # unstated theorem and an unproved one as the same object.
    @property
    def sorry_in_statement(self) -> bool:
        return bool(_SORRY_RE.search(self.statement))

    @property
    def sorry_is_conclusion(self) -> bool:
        return self.statement.rstrip().endswith("sorry")

    def __repr__(self) -> str:  # pragma: no cover - debugging aid
        return f"<{self.kind} {self.name} {self.file}:{self.line}>"


_OPEN, _CLOSE = "([{⟨⦃", ")]}⟩⦄"


def statement_of(text: str) -> str:
    """The signature, cut at the first depth-0 `:=`. The proof is not compared.

    A second proof of a theorem is not a second theorem. `isUnit_one` is stated
    identically in `C6_ActionC.lean` and `C6_Core.lean` and proved two different
    ways; comparing proof text called that two facts, and it is one.
    """
    depth = 0
    for i in range(len(text) - 1):
        c = text[i]
        if c in _OPEN:
            depth += 1
        elif c in _CLOSE:
            depth -= 1
        elif depth == 0 and c == ":" and text[i + 1] == "=":
            return " ".join(text[:i].split())
    return " ".join(text.split())


def extract(src: str, path: str = "<mem>") -> list[Decl]:
    """Every declaration in `src`, fully qualified by its namespace stack.

    Qualification matters and is not cosmetic: `Un.mul_assoc'` and
    `Cochain.mul_assoc'` are two theorems. Counting short names silently merges
    them and UNDERCOUNTS -- the opposite error to the one this file was written
    for, and the one a naive de-duplication introduces.
    """
    code = blank_noncode(src)
    code_lines = code.splitlines()
    decls: list[Decl] = []
    ns: list[str] = []          # namespace stack
    opened: list[str | None] = []  # every `section`/`namespace` scope, in order

    for lineno, raw in enumerate(code_lines, start=1):
        line = raw.strip()

        if not line:
            continue

        m = re.match(r"^namespace\s+(\S+)", line)
        if m:
            ns.append(m.group(1))
            opened.append(m.group(1))
            continue

        m = re.match(r"^section(?:\s+(\S+))?\s*$", line)
        if m:
            opened.append(None)
            continue

        m = re.match(r"^end(?:\s+(\S+))?\s*$", line)
        if m:
            if opened:
                scope = opened.pop()
                if scope is not None and ns and ns[-1] == scope:
                    ns.pop()
            continue

        # Strip attributes and modifiers, repeatedly, then look for a keyword.
        head = line
        while True:
            new = _ATTR_RE.sub("", head)
            new = _MOD_RE.sub("", new)
            if new == head:
                break
            head = new

        m = re.match(r"^(" + "|".join(NAMED_KINDS + ANON_KINDS) + r")(?![A-Za-z_0-9'])\s*(.*)$", head)
        if not m:
            continue
        kind, rest = m.group(1), m.group(2)

        if kind in ANON_KINDS:
            decls.append(Decl("", kind, lineno, path))
            continue

        nm = _NAME_RE.match(rest)
        if not nm:
            # Anonymous `instance`. Real, nameless, and not unionable.
            if kind == "instance":
                decls.append(Decl("", kind, lineno, path))
            continue

        decls.append(Decl(".".join(ns + [nm.group(0)]), kind, lineno, path))

    # Spans, and the statement and `sorry` that fall inside them.
    #
    # A span ends at the next declaration OF ANY KIND. Ending it at the next
    # THEOREM was this file's first real-data defect: `Ceiling.lean`'s
    # `run_succ` then swallowed the `def Signs` that follows it, and compared
    # unequal to the verbatim-identical `run_succ` in `Schedules.lean`.
    for i, d in enumerate(decls):
        end = decls[i + 1].line - 1 if i + 1 < len(decls) else len(code_lines)
        body = "\n".join(code_lines[d.line - 1:end])
        d.statement = statement_of(body)
        d.has_sorry = bool(_SORRY_RE.search(body))

    return decls


# ---------------------------------------------------------------------------
# Census
# ---------------------------------------------------------------------------

# ---------------------------------------------------------------------------
# Referenced but not defined.
#
# A file extracted mechanically from a larger one leaves holes: names its
# surviving definitions still call, whose definitions did not come with them.
# Counting those holes is the same problem as counting declarations and it has
# the same history here -- issue #3 published 31 with a list of 32; its reply
# published 32 with a total of 45 whose own per-name figures cannot sum below
# 65. Both were counted by reading.
#
# Sound only for a file that imports nothing: with no imports, every name that
# is neither defined here nor a Lean core builtin nor locally bound is a hole.
# `--undefined` refuses to run on a file with an `import` line, because there
# the answer would be "everything Mathlib provides" and the instrument would be
# confidently wrong rather than silent.
# ---------------------------------------------------------------------------

_KEYWORDS = set("""
def let intro intros exact funext induction refine using cases show structure apply rw
rewrite simp constructor rcases obtain calc have suffices ext subst rfl trivial sorry admit
decide native_decide omega ring unfold dsimp split rintro use left right exists first
all_goals repeat try skip done fun match with do return by where deriving this if then else
from at to in for instance abbrev inductive class theorem lemma example namespace end open
section variable universe mutual partial private protected noncomputable cond xor and or not
ite dite id congrArg congr trans symm Exists Classical
""".split())

_CORE = set("""
Int Bool Nat Prop Type List String Option Array Char And Or Not Eq Iff True False Decidable
DecidableEq Repr BEq Inhabited Subtype Sigma Prod Fin Unit Empty PUnit Function Set Ne HEq
Quot Quotient Setoid Std Lean Except StateM abs toString Sum
""".split())


def undefined_names(src: str) -> dict[str, int]:
    """Names a surviving definition calls that this file does not define."""
    code = blank_noncode(src)

    defined: set[str] = set()
    for d in extract(src):
        if d.name:
            defined.add(d.name)
            defined.add(d.name.split(".")[-1])
    for m in re.finditer(r"^\s{2,}([a-zA-Z_][A-Za-z_0-9']*)\s*:(?!=)", code, re.M):
        defined.add(m.group(1))                       # structure fields
    for m in re.finditer(r"^\s*\|\s*([a-zA-Z_][A-Za-z_0-9']*)", code, re.M):
        defined.add(m.group(1))                       # constructors / match arms

    bound: set[str] = set()
    for pat in (r"[({⦃]\s*([a-zA-Z_][A-Za-z_0-9'\s]*?)\s*:",
                r"fun\s+([a-zA-Z_][A-Za-z_0-9']*)",
                r"[∀∃]\s*([a-zA-Z_][A-Za-z_0-9'\s]*?)[,:]",
                r"let\s+([a-zA-Z_][A-Za-z_0-9']*)"):
        for m in re.finditer(pat, code):
            bound.update(m.group(1).split())

    hits: dict[str, int] = {}
    for m in re.finditer(r"(?<![.\w'])([a-zA-Z_][A-Za-z_0-9']*"
                         r"(?:\.[a-zA-Z_][A-Za-z_0-9']*)*)", code):
        n = m.group(1)
        head, tail = n.split(".")[0], n.split(".")[-1]
        # A dotted name whose HEAD is defined is projection notation: the head
        # being present says nothing about the tail. Checking the head here is
        # what hid the four `Un.*'` holes and turned 32 into 28.
        if n in defined or tail in defined:
            continue
        if n in bound or head in bound:
            continue
        if n in _KEYWORDS or head in _KEYWORDS or n in _CORE or head in _CORE:
            continue
        if len(n) < 3:
            continue
        hits[n] = hits.get(n, 0) + 1
    return hits


def census(files: list[str], kinds: tuple[str, ...]) -> dict:
    per_file: dict[str, list[Decl]] = {}
    for f in files:
        try:
            src = open(f, encoding="utf-8", errors="replace").read()
        except OSError as e:
            per_file[f] = []
            print(f"  UNREADABLE {f}: {e}", file=sys.stderr)
            continue
        per_file[f] = [d for d in extract(src, f) if d.kind in kinds]

    named: dict[str, set[str]] = {}
    anon: dict[str, int] = {}
    for f, ds in per_file.items():
        named[f] = {d.name for d in ds if d.name}
        anon[f] = sum(1 for d in ds if not d.name)

    union: set[str] = set()
    for s in named.values():
        union |= s

    total_decls = sum(len(ds) for ds in per_file.values())
    sum_named = sum(len(s) for s in named.values())
    total_anon = sum(anon.values())

    # Containment: which files are wholly contained in another. This is the
    # cumulative-superset trap, reported by name instead of argued about.
    contained: list[tuple[str, str, int]] = []
    for a in files:
        if not named.get(a):
            continue
        for b in files:
            if a == b or not named.get(b):
                continue
            if named[a] < named[b]:
                contained.append((a, b, len(named[a])))
                break
            if named[a] == named[b] and files.index(a) > files.index(b):
                contained.append((a, b, len(named[a])))
                break

    dup = Counter()
    for s in named.values():
        for nm in s:
            dup[nm] += 1

    # Distinct FACTS: a name plus the statement it carries. A name appearing in
    # two files with the SAME statement is one fact carried twice -- the 692
    # error. A name appearing with DIFFERENT statements is two facts colliding,
    # and there the union UNDERCOUNTS. The instrument must not merge those two
    # cases, because they need opposite corrections.
    stmts: dict[str, set[str]] = {}
    for ds in per_file.values():
        for d in ds:
            if d.name:
                stmts.setdefault(d.name, set()).add(d.statement)
    facts = sum(len(v) for v in stmts.values())
    collisions = {k: len(v) for k, v in stmts.items() if len(v) > 1}

    return {
        "files": files,
        "per_file": per_file,
        "named": named,
        "anon": anon,
        "union": union,
        "facts": facts,
        "collisions": collisions,
        "total_decls": total_decls,
        "sum_named": sum_named,
        "total_anon": total_anon,
        "contained": contained,
        "multi": {k: v for k, v in dup.items() if v > 1},
        "terms": TERMS_VERSION,
    }


def report(c: dict, kinds: tuple[str, ...], show_names: bool = False) -> None:
    print(f"\nDECLARATION CENSUS — terms {c['terms']}, kinds: {','.join(kinds)}\n")
    w = max([len(os.path.basename(f)) for f in c["files"]] + [24])
    print(f"  {'file':<{w}}  {'named':>6} {'unique':>7} {'anon':>5} {'sorry':>6}")
    print("  " + "-" * (w + 29))
    for f in c["files"]:
        ds = c["per_file"][f]
        n_named = sum(1 for d in ds if d.name)
        n_sorry = sum(1 for d in ds if d.has_sorry)
        print(f"  {os.path.basename(f):<{w}}  {n_named:>6} {len(c['named'][f]):>7} "
              f"{c['anon'][f]:>5} {n_sorry:>6}")
    print("  " + "-" * (w + 29))
    print(f"  {'SUM of per-file':<{w}}  {c['sum_named']:>6}"
          f"          <- what a per-file count reports")
    print(f"  {'UNION of names':<{w}}  {len(c['union']):>6}")
    print(f"  {'DISTINCT name+statement':<{w}}  {c['facts']:>6}"
          f"          <- the honest figure")
    over = c["sum_named"] - c["facts"]
    print(f"  {'DOUBLE-COUNTED':<{w}}  {over:>6}", end="")
    if c["facts"]:
        print(f"          ({c['sum_named'] / c['facts']:.2f}x)")
    else:
        print()

    if c["collisions"]:
        print("\n  NAME COLLISIONS — same name, DIFFERENT statement:")
        for nm, k in sorted(c["collisions"].items()):
            print(f"    {nm}  ({k} distinct statements)")
        print("  Here the union UNDERCOUNTS. These are different theorems sharing")
        print("  a name, and no de-duplication by name can tell them apart.")
    elif c["sum_named"] != len(c["union"]):
        print("\n  No name collisions: every repeated name carries the SAME statement,")
        print("  so the union is EXACT and the excess above is carried duplication.")
    if c["total_anon"]:
        print(f"\n  {c['total_anon']} anonymous declaration(s) (example / unnamed instance) —")
        print("  counted, never unioned: a nameless declaration cannot be de-duplicated,")
        print("  so a file full of them defeats this instrument. Stated, not hidden.")

    allds = [d for ds in c["per_file"].values() for d in ds]
    n_sorry = sum(1 for d in allds if d.has_sorry)
    if n_sorry:
        concl = [d for d in allds if d.sorry_is_conclusion]
        term = [d for d in allds if d.sorry_in_statement and not d.sorry_is_conclusion]
        print(f"\n  `sorry` — {n_sorry} of {c['total_decls']} declarations"
              f" ({100 * n_sorry / c['total_decls']:.0f}%):")
        print(f"    {n_sorry - len(concl) - len(term):>5}  in the PROOF only"
              "        — a stated proposition, admitted")
        print(f"    {len(term):>5}  a TERM in the statement  — stated, but over admitted data")
        print(f"    {len(concl):>5}  the CONCLUSION"
              "          — NO PROPOSITION IS STATED")
        for d in concl:
            print(f"           {os.path.basename(d.file)}:{d.line}  {d.name}")
        print("  SCREEN, NOT VERDICT — only `#print axioms` sees `sorryAx`.")

    if c["contained"]:
        print("\n  CONTAINMENT — the cumulative-superset trap, by name:")
        for a, b, k in c["contained"]:
            print(f"    {os.path.basename(a)}  ⊆  {os.path.basename(b)}"
                  f"   ({k} names, 0 unique to the left)")
        print("  A file wholly contained in another contributes nothing to the union.")
        print("  Adding its count to a sum is the error that produced 692.")
    elif len(c["files"]) > 1:
        print("\n  CONTAINMENT — none. No file's names are a subset of another's.")

    if show_names and c["multi"]:
        print("\n  NAMES APPEARING IN MORE THAN ONE FILE:")
        for nm, k in sorted(c["multi"].items(), key=lambda kv: (-kv[1], kv[0])):
            print(f"    {k}x  {nm}")


# ---------------------------------------------------------------------------

NOT_CAUGHT = """\
WHAT THIS INSTRUMENT DOES NOT CATCH
  Written down because a gate tested only against the failures its author
  imagined certifies the author's imagination (SR43; and `norm_shape.sh`'s own
  header, whose first version passed its self-test while wrong on real data).

  1. WHETHER ANYTHING IS PROVED. This counts names. `sorry` here is syntactic.
     A file of 234 admitted theorems and a file of 234 proved ones are the same
     number to this instrument. `GAP/lean/check.sh` is the one that decides, and
     it needs a kernel and a file that elaborates. Where those exist, IT is the
     instrument and this one is a screen in front of it.
  2. RESTATEMENT. Two files with disjoint names may prove the same theorem
     twice. The union is a floor on duplication, never a ceiling. De-duplicating
     by name cannot see mathematics.
  3. A RENAMED CARRIED PREFIX. Circle Four's F-A -- a carried prefix inside a
     file -- survives this if the names were changed on the way in. Name
     identity is the whole mechanism and the whole limit.
  4. WHETHER THE GLOB IS THE RIGHT GLOB. `rate.py`'s item 4, inherited whole.
     A census over the wrong files is a census about something else, not a wrong
     census -- which is why every run prints the specs it used.
  5. `sorry` REACHED THROUGH A MACRO OR TACTIC. The regex sees the token. A
     tactic that admits without writing it is invisible here, and so is an
     `axiom` used as one. `admit` is not matched, and neither is a `sorry`
     produced by elaboration rather than written down.
  5b. WHERE THE `sorry` FALLS, past the easy cases. "The conclusion" is decided
     by asking whether the statement ENDS in `sorry`, which is a syntactic
     proxy for a semantic question. `P → sorry ∧ Q` states no useful
     proposition either and is not flagged; a statement ending in a `sorry`
     that elaboration would discharge from context would be flagged wrongly.
     The five it currently reports were each read by eye before this sentence
     was written, and the proxy held for all five. It is a proxy nonetheless.
  6. GAMING. Split a file in two and the union does not move but the sum does;
     merge two and the reverse. If a circle starts steering by the difference,
     delete this -- do not refine it (`rate.py`'s standing rule, and it binds
     here).
  7. ANY BRANCH BUT THE ONE ON DISK, and anything git does not track if you
     hand it a glob that misses it.
  8. IT DOES NOT SETTLE 396 vs 397. Nothing in these three repositories holds
     `C5_QA_v8` or `C5_QB_v2`; issue #2 is right that only Circle Five can close
     Part 1. This makes the question answerable in one command on the tree that
     has the files. It does not answer it from here, and a census that claimed
     to would be the fourth wrong figure.
"""


def selftest() -> int:
    """Bite it. Every probe is a defect this instrument is REQUIRED to catch.

    Probes 9 and 10 are false-positive probes, and they are here because the
    first version of THIS file failed both on real data: it counted the word
    `theorem` inside `C6_SEED.lean`'s docstring, where Circle Five's quoted
    instruction begins at column 0, and it counted `Un.mul_assoc'` and
    `Cochain.mul_assoc'` as one name. Probe 11 is the vacuity probe, which is
    issue #1's species -- a green that means "I found nothing to check" is
    indistinguishable at the exit from a green that means "nothing is wrong."
    """
    print("SELF-TEST — every probe is a defect this instrument must catch\n")
    ok = True

    def check(label: str, got, want) -> None:
        nonlocal ok
        good = got == want
        ok &= good
        print(f"  [{'PASS' if good else 'FAIL'}] {label:<58} got {got!r}, want {want!r}")

    # 1 — THE ONE `rate.py` HAS NOT GOT. A verbatim superset must not be summed.
    a = "theorem alpha : True := trivial\ntheorem beta : True := trivial\n"
    b = a + "theorem gamma : True := trivial\n"
    import tempfile
    tmp = tempfile.mkdtemp()
    pa, pb = os.path.join(tmp, "A.lean"), os.path.join(tmp, "B.lean")
    open(pa, "w").write(a); open(pb, "w").write(b)
    c = census([pa, pb], ("theorem", "lemma"))
    check("superset trap: SUM of per-file", c["sum_named"], 5)
    check("superset trap: UNION is the honest figure", len(c["union"]), 3)
    check("superset trap: distinct facts agree with the union", c["facts"], 3)
    check("superset trap: containment named", len(c["contained"]), 1)
    check("superset trap: no false collision", c["collisions"], {})

    # 1b — REAL DATA, `lean/*.lean`: same statement, two different proofs.
    # Comparing proof text called this two facts. It is one.
    pc, pd = os.path.join(tmp, "C.lean"), os.path.join(tmp, "D.lean")
    open(pc, "w").write("theorem isUnit_one : IsUnit one := by\n  rw [h]; decide\n")
    open(pd, "w").write("theorem isUnit_one : IsUnit one := isUnit_of_mul_conj h\n")
    c2 = census([pc, pd], ("theorem", "lemma"))
    check("same statement, DIFFERENT proof: one fact, not two", c2["facts"], 1)
    check("same statement, different proof: not a collision", c2["collisions"], {})

    # 1c — the opposite case, which must NOT be merged.
    pe1, pe2 = os.path.join(tmp, "E.lean"), os.path.join(tmp, "F.lean")
    open(pe1, "w").write("theorem clash : P := proof\n")
    open(pe2, "w").write("theorem clash : Q := proof\n")
    c3 = census([pe1, pe2], ("theorem", "lemma"))
    check("same name, DIFFERENT statement: two facts", c3["facts"], 2)
    check("same name, different statement: collision named",
          set(c3["collisions"]), {"clash"})

    # 1d — REAL DATA, `GAP/lean`: a span must end at the next DECLARATION OF ANY
    # KIND. Ending it at the next THEOREM swallowed `def Signs` and made two
    # verbatim-identical `run_succ` compare unequal.
    pg1, pg2 = os.path.join(tmp, "G.lean"), os.path.join(tmp, "H.lean")
    open(pg1, "w").write("theorem run_succ : R := rfl\n\n"
                         "def Signs : Prop := True\n\n"
                         "theorem later : T := rfl\n")
    open(pg2, "w").write("theorem run_succ : R := rfl\n\n"
                         "def minus : Int := -1\n")
    c4 = census([pg1, pg2], ("theorem", "lemma"))
    check("span ends at the next DECLARATION, not the next theorem",
          c4["collisions"], {})
    check("intervening `def` does not fabricate a divergence", c4["facts"], 2)

    # 2-8 — shapes `^theorem [A-Za-z_0-9].*:` does not see.
    def names(src: str, kinds=("theorem", "lemma")) -> set[str]:
        return {d.name for d in extract(src) if d.kind in kinds}

    check("`lemma` is a declaration",
          names("lemma foo : True := trivial\n"), {"foo"})
    check("indented theorem (inside a section)",
          names("section\n  theorem indented : True := trivial\nend\n"), {"indented"})
    check("signature whose `:` is on a later line",
          names("theorem multiline\n    (x : Nat)\n    (y : Nat) :\n    x = x := rfl\n"),
          {"multiline"})
    check("`@[simp] private theorem`",
          names("@[simp] private theorem attributed : True := trivial\n"),
          {"attributed"})
    check("namespaced name is QUALIFIED",
          names("namespace Un\ntheorem mul_assoc' : True := trivial\nend Un\n"),
          {"Un.mul_assoc'"})
    check("namespace closes: name after `end` is bare",
          names("namespace Un\ntheorem a : True := trivial\nend Un\n"
                "theorem b : True := trivial\n"),
          {"Un.a", "b"})
    check("`sorry` is attributed to its own declaration",
          {d.name for d in extract(
              "theorem proved : True := trivial\n"
              "theorem admitted : True := by\n  sorry\n") if d.has_sorry},
          {"admitted"})

    # REAL DATA, the shadow branches: `monodromy_exchange : ∀ G₀ : ℂ, G₀ ≠ -1 →
    # sorry` states no proposition. An unstated theorem and an unproved one are
    # not the same object and no count in this record had separated them.
    pos = extract("theorem unproved : P := by sorry\n"
                  "theorem unstated : ∀ x : T, x ≠ y → sorry := by admit\n"
                  "theorem overAdmitted : f ⟨n, sorry⟩ = g := by rfl\n")
    check("`sorry` in the PROOF: statement is intact",
          [d.name for d in pos if d.has_sorry and not d.sorry_in_statement],
          ["unproved"])
    check("`sorry` as the CONCLUSION: no proposition stated",
          [d.name for d in pos if d.sorry_is_conclusion], ["unstated"])
    check("`sorry` as a TERM: stated, over admitted data",
          [d.name for d in pos if d.sorry_in_statement and not d.sorry_is_conclusion],
          ["overAdmitted"])

    # 9 — FALSE POSITIVE, found on real data: a docstring at column 0.
    docstring = ('/-- A quoted instruction:\ntheorem this_is_prose : True := trivial\n-/\n'
                 'theorem real_one : True := trivial\n')
    check("prose in a doc comment is NOT a declaration",
          names(docstring), {"real_one"})
    check("nested block comments close correctly",
          names("/- outer /- inner -/ theorem hidden : True := trivial -/\n"
                "theorem visible : True := trivial\n"), {"visible"})
    check("`theorem` inside a string literal is not a declaration",
          names('def s : String := "theorem fake : True"\ntheorem live : True := trivial\n'),
          {"live"})

    # 10 — FALSE POSITIVE: same short name, two namespaces, must NOT merge.
    two_ns = ("namespace Un\ntheorem mul_assoc' : True := trivial\nend Un\n"
              "namespace Cochain\ntheorem mul_assoc' : True := trivial\nend Cochain\n")
    check("same short name in two namespaces is TWO names",
          len(names(two_ns)), 2)

    # 11 — VACUITY. Issue #1's species, applied to this instrument.
    empty = census([], ("theorem", "lemma"))
    check("empty glob yields an empty union (caller must refuse it)",
          len(empty["union"]), 0)
    pe = os.path.join(tmp, "Empty.lean")
    open(pe, "w").write("-- no declarations here\n")
    check("a file with no declarations is reported as zero, not skipped",
          len(census([pe], ("theorem", "lemma"))["per_file"][pe]), 0)

    # 13 — `--undefined`. The dotted-name probe is the bug that turned 32 into
    # 28: `Un` IS defined (`def Un : Type := ...`), so checking the HEAD of
    # `Un.mul_assoc'` hid four holes that account for 24 of 69 occurrences.
    u = undefined_names(
        "def Un : Type := Nat\n"
        "def one' : Un := ⟨one, IsUnit_one⟩\n"
        "def unitGroup : AbGroup Un where\n"
        "  op := Un.mul'\n"
        "  assoc := Un.mul_assoc'\n")
    check("hole under a DEFINED head is still a hole",
          "Un.mul_assoc'" in u, True)
    check("a name defined in the file is not a hole", "one'" in u, False)
    check("`def`/`where` keywords are not holes",
          any(k in u for k in ("def", "where")), False)

    pu = os.path.join(tmp, "U.lean")
    open(pu, "w").write("def f : Nat := missing_proof\n")
    check("undefined-mode reports the hole",
          set(undefined_names(open(pu).read())), {"missing_proof"})
    check("docstring mention is not a reference",
          "only_in_prose" in undefined_names(
              "/-- calls only_in_prose -/\ndef f : Nat := 0\n"), False)

    # 12 — anonymous declarations are counted but never unioned.
    anon_src = "example : True := trivial\nexample : True := trivial\n"
    pan = os.path.join(tmp, "Anon.lean")
    open(pan, "w").write(anon_src)
    ca = census([pan], ("theorem", "lemma", "example"))
    check("two `example`s: 0 unionable names, 2 anonymous",
          (len(ca["union"]), ca["total_anon"]), (0, 2))

    import shutil
    shutil.rmtree(tmp, ignore_errors=True)

    print(f"\n  self-test: {'PASS' if ok else 'FAIL'}\n")
    print(NOT_CAUGHT)
    return 0 if ok else 1


# ---------------------------------------------------------------------------

def main() -> int:
    ap = argparse.ArgumentParser(
        description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("specs", nargs="*", help="glob(s) for Lean files")
    ap.add_argument("--repo", default=".", help="root the globs are relative to")
    ap.add_argument("--kind", default="theorem,lemma",
                    help="declaration kinds to count "
                         f"(any of: {','.join(NAMED_KINDS + ANON_KINDS)}; or 'all')")
    ap.add_argument("--names", action="store_true",
                    help="list every name appearing in more than one file")
    ap.add_argument("--fail-on-containment", action="store_true",
                    help="exit 1 if any file's names are a subset of another's")
    ap.add_argument("--undefined", action="store_true",
                    help="report names a surviving definition calls but the file "
                         "does not define (import-free files only)")
    ap.add_argument("--selftest", action="store_true")
    a = ap.parse_args()

    if a.selftest:
        return selftest()

    if not a.specs:
        ap.error("give at least one glob (or --selftest)")

    kinds = (NAMED_KINDS + ANON_KINDS if a.kind == "all"
             else tuple(k.strip() for k in a.kind.split(",") if k.strip()))
    bad = [k for k in kinds if k not in NAMED_KINDS + ANON_KINDS]
    if bad:
        ap.error(f"unknown kind(s): {','.join(bad)}")

    files: list[str] = []
    for spec in a.specs:
        hits = sorted(globmod.glob(os.path.join(a.repo, spec), recursive=True))
        files += [f for f in hits if f not in files]

    # Vacuity is a failure, not a zero. A census over no files must not be
    # mistaken for a census that found nothing wrong -- that is exactly the
    # shape issue #1 filed against `exit_gate.sh`, and it costs one line here.
    if not files:
        print(f"NOTHING TO MEASURE — {a.specs!r} under {a.repo!r} matched no files.")
        print("Refusing to report a census of zero files as a census.")
        return 2

    print(f"  specs   : {' '.join(a.specs)}")
    print(f"  repo    : {os.path.abspath(a.repo)}")
    print(f"  matched : {len(files)} file(s)")

    if a.undefined:
        rc = 0
        for f in files:
            src = open(f, encoding="utf-8", errors="replace").read()
            if re.search(r"^\s*import\s", src, re.M):
                print(f"\n  REFUSING {os.path.basename(f)} — it has an `import` line.")
                print("  With imports, 'not defined here' means 'defined somewhere I")
                print("  cannot see', and the answer would be confidently wrong.")
                rc = 2
                continue
            hits = undefined_names(src)
            print(f"\n  {os.path.basename(f)} — REFERENCED, NOT DEFINED HERE: "
                  f"{len(hits)} names, {sum(hits.values())} occurrences")
            for n, k in sorted(hits.items(), key=lambda kv: (-kv[1], kv[0])):
                print(f"    {k:>3}x  {n}")
        return rc

    c = census(files, kinds)
    report(c, kinds, show_names=a.names)
    print()
    if a.fail_on_containment and c["contained"]:
        print("  exit 1 — containment found and --fail-on-containment was given.\n")
        return 1
    return 0


if __name__ == "__main__":
    try:
        rc = main()
    except BrokenPipeError:
        # An instrument that prints a traceback when read partially teaches its
        # reader to distrust its output. `rate.py`'s reasoning, and it is right.
        try:
            sys.stdout.close()
        except Exception:
            pass
        os._exit(0)
    sys.exit(rc)
