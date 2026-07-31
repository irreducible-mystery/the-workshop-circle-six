#!/bin/sh
# bootstrap_kernel.sh — put a kernel in the compartment.
#
# WHY THIS EXISTS
#   CHARGE.md's terminal condition is "the kernel decides, not a seat and not a
#   letter." At the counter-prover's session start there was no kernel: no
#   `lean`, no `elan`, and `leanprover.github.io` refused at the egress proxy
#   (403 on CONNECT). The charge was unsatisfiable for reasons no instrument in
#   the carried set measures — every carried gate reads the tree, and none of
#   them can see that the thing which decides is absent.
#
#   So this is not an instrument. It does not gate anything and it has no
#   verdict. It is the thing that makes the instruments' verdicts POSSIBLE, and
#   it is committed so the next body does not spend its first hour discovering
#   the same hole.
#
# WHAT IT DOES NOT DO
#   No Mathlib. The seal imports nothing — `lean/C6_SEED.lean` declares no
#   imports and no instances, which is the reason a 400MB core toolchain is the
#   whole dependency. If a later file in this compartment needs Mathlib, that is
#   a change to the inheritance and should be argued, not scripted.
#
# usage:  sh bootstrap_kernel.sh [version] [prefix]
#         sh bootstrap_kernel.sh --check
set -eu

VER="${1:-4.22.0}"
PREFIX="${2:-/home/user/toolchain}"
DIR="$PREFIX/lean-$VER-linux"
URL="https://github.com/leanprover/lean4/releases/download/v$VER/lean-$VER-linux.tar.zst"

if [ "${1:-}" = "--check" ]; then
    if command -v lean >/dev/null 2>&1; then
        lean --version
        t=$(mktemp -d); trap 'rm -rf "$t"' EXIT
        # A kernel that answers is not the same as a kernel that DISAGREES when
        # it should. Both probes, or the check certifies an echo.
        printf 'theorem probe_true : 2 + 2 = 4 := by decide\n' > "$t/ok.lean"
        printf 'theorem probe_false : 2 + 2 = 5 := by decide\n' > "$t/no.lean"
        lean "$t/ok.lean" >/dev/null 2>&1 || { echo "KERNEL REJECTS A TRUTH -- not usable"; exit 1; }
        lean "$t/no.lean" >/dev/null 2>&1 && { echo "KERNEL ACCEPTS A FALSEHOOD -- not usable"; exit 1; }
        echo "kernel live: accepts 2+2=4, rejects 2+2=5"
        exit 0
    fi
    echo "no kernel on PATH"; exit 1
fi

if [ -x "$DIR/bin/lean" ]; then
    echo "already present at $DIR"
else
    # zstd is not in the base image and Python 3.11 has no stdlib zstd
    # (compression.zstd lands in 3.14). pypi reaches the proxy directly.
    command -v zstd >/dev/null 2>&1 || python3 -c 'import zstandard' 2>/dev/null \
        || pip install --quiet zstandard

    mkdir -p "$PREFIX"
    echo "fetching Lean $VER (~400MB compressed, ~2GB extracted)"
    curl -sSL -o "$PREFIX/lean.tar.zst" "$URL"

    if command -v zstd >/dev/null 2>&1; then
        zstd -d -f "$PREFIX/lean.tar.zst" -o "$PREFIX/lean.tar"
    else
        python3 - "$PREFIX" <<'PY'
import sys, zstandard
p = sys.argv[1]
with open(p + '/lean.tar.zst', 'rb') as f, open(p + '/lean.tar', 'wb') as o:
    with zstandard.ZstdDecompressor().stream_reader(f) as r:
        while True:
            b = r.read(1 << 22)
            if not b:
                break
            o.write(b)
PY
    fi
    tar -xf "$PREFIX/lean.tar" -C "$PREFIX"
    rm -f "$PREFIX/lean.tar" "$PREFIX/lean.tar.zst"
fi

for b in lean lake leanc; do ln -sf "$DIR/bin/$b" "/usr/local/bin/$b"; done
sh "$0" --check

cat <<'NOTE'

The seal imports nothing, so files compile with no project and no lakefile:

    lean lean/C6_SEED.lean ; echo "EXIT=$?"

Exit 0 is the only evidence this compartment recognises. `native_decide` is
not it -- it trusts the compiler rather than the kernel, and a compartment
whose one rule is "something outside the prose decides" cannot spend its
verdict on a faster oracle.
NOTE
