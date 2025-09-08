#!/usr/bin/env bash
set -euo pipefail

fail() { echo "FAIL: $1" >&2; exit 1; }
pass() { echo "PASS: Permissions Challenge completed successfully"; exit 0; }

ROOT="$HOME/playground/secure-project"

# 1) Check structure
[ -d "$ROOT/secrets" ] || fail "Missing directory: $ROOT/secrets"
[ -d "$ROOT/public" ]  || fail "Missing directory: $ROOT/public"
[ -f "$ROOT/secrets/plan.txt" ] || fail "Missing file: $ROOT/secrets/plan.txt"
[ -f "$ROOT/public/readme.txt" ] || fail "Missing file: $ROOT/public/readme.txt"

# 2) Check contents
grep -qx "TOP SECRET" "$ROOT/secrets/plan.txt" || fail "plan.txt content must be exactly: TOP SECRET"
grep -qx "Welcome to the project" "$ROOT/public/readme.txt" || fail "readme.txt content must be exactly: Welcome to the project"

# 3) Check permissions (octal)
perm_dir_secrets=$(stat -c "%a" "$ROOT/secrets")
[ "$perm_dir_secrets" = "700" ] || fail "secrets directory should be 700 (got $perm_dir_secrets)"

perm_plan=$(stat -c "%a" "$ROOT/secrets/plan.txt")
[ "$perm_plan" = "600" ] || fail "secrets/plan.txt should be 600 (got $perm_plan)"

perm_dir_public=$(stat -c "%a" "$ROOT/public")
[ "$perm_dir_public" = "755" ] || fail "public directory should be 755 (got $perm_dir_public)"

perm_readme=$(stat -c "%a" "$ROOT/public/readme.txt")
[ "$perm_readme" = "644" ] || fail "public/readme.txt should be 644 (got $perm_readme)"

pass
