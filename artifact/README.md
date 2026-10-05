# artifact/

`circle-six-gap-proof.zip` — the travelling artifact. Self-contained,
kernel-checkable, verifies itself in one command.

    unzip circle-six-gap-proof.zip
    cd circle-six-gap-proof
    sh verify.sh ; echo "EXIT=$?"

Needs Lean 4.22.0 and nothing else — no Mathlib, no lakefile; the proofs import
nothing. `verify.sh` prints the install line if `lean` is missing. Takes ~7
minutes, almost all of it recompiling `C6_Twist.lean` three times for the audit.

`unpacked/` is the same tree, expanded, so the zip's contents are readable in
the repository without extracting.

**Clean-room tested**: extracted into an empty directory with nothing carried
over, `verify.sh` exits 0.

What the artifact does NOT establish is in its `NOT-PROVED.md`. The 65536-symbol
sweep is compiler-checked only and no theorem depends on it.
