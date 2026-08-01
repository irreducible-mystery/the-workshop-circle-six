#!/bin/sh
# cross_repo_exit.sh — the exit check, run in the direction the rule forbids.
#
# WHY
#   `exit_gate.sh` enforces one property and states it exactly:
#
#       THE CUMULATIVE RECORD MAY NOT CITE THE SANDBOX.
#
#   It cannot enforce it here, and issue #1 is right about why. It models the
#   sandbox as a DIRECTORY INSIDE the record's own tree and greps that tree for
#   the string "<dir>/". Circle Six is not a directory; it is a separate
#   repository, and the record would cite it as `the-workshop-circle-six` --
#   a repository name, never a path under its own tree. There is no value of
#   $dir that makes that gate see the citation it exists to catch.
#
#   Pointed at this repository's real subdirectories it does not degrade, it
#   INVERTS: it fires on the compartment citing ITSELF, which is the one
#   direction the exit permits, and stays silent on the direction it forbids.
#
#   This gate takes the OTHER repository as its argument. It is the same rule,
#   measured across a repository boundary instead of a directory boundary.
#
# WHO RUNS IT, which is issue #1's actual question
#   Not the record. A gate that lives in the sandbox and is invoked by the
#   cumulative record is itself a citation of the sandbox -- the rule would be
#   broken by the act of checking it. So this runs FROM the sandbox, POINTED AT
#   a checkout of the record, and the record never names it. The compartment
#   audits its own containment; nothing outside has to know this file exists.
#
#   That is also the honest answer to "what enforces the exit": not this. This
#   reports. Enforcement is whoever reads the report and drops the citation,
#   and no gate in any of these repositories changes that.
#
# TWO NAMES, because the first version only had one and was blind on real data
#   Pointed at `workshop2`, the first version of this file reported a clean
#   mention-class. There are three mentions, and it saw none of them: the
#   record does not write `the-workshop-circle-six`, it writes **Circle Six**.
#   A gate that greps only for the repository name is blind to the only form
#   the prose actually uses -- issue #1's defect in a new coat, in the file
#   written to fix issue #1's defect. Both spellings are now scanned and the
#   probe is in --selftest.
#
# usage:  cross_repo_exit.sh <path-to-cumulative-record> [repo-name] [prose-alias]
#         cross_repo_exit.sh --selftest
set -u

NAME_DEFAULT=the-workshop-circle-six
ALIAS_DEFAULT='[Cc]ircle[ -][Ss]ix'

check() {
    record=$1; name=$2; alias=${3:-$ALIAS_DEFAULT}
    if [ ! -d "$record" ]; then
        echo "NO RECORD at $record -- nothing was checked."
        echo "Refusing to report an unrun check as a pass. This is the defect"
        echo "issue #1 filed: a green that means 'I found nothing to check' is"
        echo "indistinguishable at the exit from a green that means 'nothing leaked'."
        return 2
    fi

    # RETRIEVABLE: a citation a reader could follow back into the sandbox --
    # a path into the repo, or a URL naming it. This is what the rule forbids:
    # it makes sandbox content load-bearing in the record.
    deep=$(grep -rIn --exclude-dir=.git -E \
            "$name/[A-Za-z0-9_.-]|github\.com/[A-Za-z0-9_-]+/$name" \
            "$record" 2>/dev/null | grep -v "cross_repo_exit" || true)

    # BARE: the repository named, with no path after it. Weaker. A record may
    # legitimately record that a sandbox exists and that its work does not
    # enter except by rebuilding -- FOUNDING.md's own exit clause has to be
    # writable somewhere. Reported separately, never merged with the above.
    bare=$(grep -rIn --exclude-dir=.git -E "$name|$alias" "$record" 2>/dev/null \
            | grep -vE "$name/[A-Za-z0-9_.-]|github\.com/[A-Za-z0-9_-]+/$name" \
            | grep -v "cross_repo_exit" || true)

    nd=$(printf '%s' "$deep" | grep -c . || true)
    nb=$(printf '%s' "$bare" | grep -c . || true)

    echo "record : $record"
    echo "sandbox: $name"
    echo

    if [ "$nd" -gt 0 ]; then
        echo "LEAK -- the record cites RETRIEVABLE sandbox content ($nd):"
        printf '%s\n' "$deep" | sed "s|^$record/|  |"
        echo
        echo "Rewrite it where the canon applies, or drop it. A sandbox the"
        echo "record cites is not a sandbox; it is a second record with a"
        echo "lower standard, and the freedom to be wrong goes with it."
    else
        echo "no retrievable citation -- the record cites no path into $name"
    fi

    if [ "$nb" -gt 0 ]; then
        echo
        echo "MENTIONED BY NAME ONLY ($nb) -- reported, NOT judged:"
        printf '%s\n' "$bare" | sed "s|^$record/|  |" | head -40
        echo
        echo "Naming that a sandbox exists is not citing its contents. Whether"
        echo "any of these crosses the line is a reading, and this gate does"
        echo "not make readings."
    fi

    [ "$nd" -gt 0 ] && return 1
    return 0
}

if [ "${1:-}" = "--selftest" ]; then
    tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT; ok=0
    S=the-workshop-circle-six

    mkdir -p "$tmp/clean" "$tmp/deep" "$tmp/bare"
    printf 'the record, citing nothing outside itself\n' > "$tmp/clean/RECORD.md"

    # PLANT 1 — the citation the old gate cannot see at any $dir.
    printf 'as shown in the-workshop-circle-six/lean/C6_Core.lean we conclude\n' \
        > "$tmp/deep/RECORD.md"
    # PLANT 2 — the same leak wearing a URL.
    printf 'see https://github.com/irreducible-mystery/the-workshop-circle-six\n' \
        >> "$tmp/deep/RECORD.md"
    # FALSE-POSITIVE PROBE — a record MUST be able to say a sandbox exists.
    printf 'Work enters by being rebuilt here; the-workshop-circle-six is not cited.\n' \
        > "$tmp/bare/RECORD.md"
    # REAL DATA — the form workshop2 actually uses, which v1 could not see.
    mkdir -p "$tmp/prose"
    printf 'clean falsifier: if Circle Six inherits 5,000 words instead of 18,000\n' \
        > "$tmp/prose/RECORD.md"

    echo "1. record citing nothing              -> $(check "$tmp/clean" $S >/dev/null 2>&1; echo exit=$?)"
    echo "2. PLANTED path + URL citation        -> $(check "$tmp/deep"  $S >/dev/null 2>&1; echo exit=$?)"
    echo "3. name only, no path (must NOT fire) -> $(check "$tmp/bare"  $S >/dev/null 2>&1; echo exit=$?)"
    echo "4. record that does not exist         -> $(check "$tmp/nope"  $S >/dev/null 2>&1; echo exit=$?)"
    echo "5. prose 'Circle Six' is SEEN as a mention -> $(check "$tmp/prose" $S 2>/dev/null | grep -c 'MENTIONED BY NAME ONLY') section(s)"

    check "$tmp/clean" $S >/dev/null 2>&1 || { echo "FAIL 1: clean record flagged"; ok=1; }
    check "$tmp/deep"  $S >/dev/null 2>&1 && { echo "FAIL 2: PLANTED leak not caught"; ok=1; }
    check "$tmp/bare"  $S >/dev/null 2>&1 || { echo "FAIL 3: bare mention treated as a leak"; ok=1; }
    check "$tmp/nope"  $S >/dev/null 2>&1; [ $? -eq 2 ] || { echo "FAIL 4: missing record not exit 2"; ok=1; }
    check "$tmp/prose" $S 2>/dev/null | grep -q 'MENTIONED BY NAME ONLY' \
        || { echo "FAIL 5: prose 'Circle Six' invisible -- v1's real-data blindness"; ok=1; }
    check "$tmp/clean" $S 2>/dev/null | grep -q 'MENTIONED BY NAME ONLY' \
        && { echo "FAIL 6: mention reported where there is none"; ok=1; }

    [ $ok -eq 0 ] && echo "SELFTEST PASS -- both plants caught, prose mention seen, clean and bare silent, absent refused"
    echo
    echo "NOT CAUGHT:"
    echo "  1. AN IDEA CARRIED BY RETYPING, with no name and no path. Inherited"
    echo "     whole from exit_gate.sh, and it is the larger hole in both: this"
    echo "     record's oldest convicted species (norm 13) is invisible to any"
    echo "     gate that greps for references."
    echo "  2. A CITATION IN A REPOSITORY NOBODY POINTS THIS AT. It checks the"
    echo "     tree it is given. There is no registry of cumulative records."
    echo "  3. ANY BRANCH BUT THE ONE ON DISK, and anything outside a git tree"
    echo "     entirely -- a crossing artifact in a ferry directory with no git"
    echo "     home is invisible here, the same corridor the gates never covered."
    echo "  4. THE TERM. This circle has one; this gate does not enforce it."
    echo "  5. WHETHER A BARE MENTION IS REALLY BARE. Class two is reported and"
    echo "     not judged, on purpose. A sentence naming the sandbox and then"
    echo "     quoting its result is a leak this gate calls a mention."
    exit $ok
fi

check "${1:?usage: cross_repo_exit.sh <path-to-record> [sandbox-repo-name] | --selftest}" \
      "${2:-$NAME_DEFAULT}"
