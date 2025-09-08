# Step 10 — Basic Scripting (Bash on Ubuntu 24)

> **Type along** exactly as shown. We’ll use **Bash** throughout. Nothing here modifies system config unless stated.  
> **Estimated time:** ~30–40 minutes

---

## What you’ll learn
- Write and run your first **Bash** scripts safely
- Use variables, quoting, arithmetic, and **exit codes**
- Branching (`if`), loops (`for`, `while`), and **functions**
- Handle **arguments** (`$1…`, `"$@"`, `getopts`), and **I/O** (stdin/stdout/stderr)
- Robust practices: shebangs, `set -Eeuo pipefail`, `trap`, `ShellCheck`
- Read files line‑by‑line, use pipes, and compose small utilities

> **Setup:**
> ```bash
> mkdir -p ~/playground/scripting && cd ~/playground/scripting
> ```

---

## 0) Shebang, permissions, and running
Create a minimal script and execute it.
```bash
cat > hello.sh <<'EOF'
#!/usr/bin/env bash
# Minimal script
printf 'Hello, %s!\n' "${1:-world}"
EOF

chmod +x hello.sh
./hello.sh
./hello.sh Raghu
```

**Notes**
- `#!/usr/bin/env bash` finds Bash via `$PATH`.  
- `chmod +x` makes it executable.  
- Use `./script.sh` or full path; **don’t** rely on `.` being in `$PATH`.

---

## 1) Safer defaults for real scripts
Create a template with error handling.
```bash
cat > template.sh <<'EOF'
#!/usr/bin/env bash
set -Eeuo pipefail
# ^ E: trap ERR on subshells, e: exit on error, u: unset var error, o pipefail: pipeline fails early
IFS=$'\n\t'

# --- globals ---
SCRIPT_NAME=${0##*/}
VERSION=1.0.0

# --- cleanup & error handling ---
cleanup() {
  # runs on EXIT; delete temp files here
  :
}
trap cleanup EXIT

err() {
  local code=$?
  printf 'ERROR(%s): command failed (exit=%d)\n' "$SCRIPT_NAME" "$code" >&2
}
trap err ERR

usage() {
  cat <<USAGE
Usage: $SCRIPT_NAME [-n NAME] [-v]
  -n NAME   who to greet (default: world)
  -v        print version and exit
USAGE
}

name="world"
while getopts ':n:v' opt; do
  case "$opt" in
    n) name=$OPTARG ;;
    v) printf '%s %s\n' "$SCRIPT_NAME" "$VERSION"; exit 0 ;;
    :) printf 'Option -%s requires an argument\n' "$OPTARG" >&2; exit 2 ;;
    \?) usage; exit 2 ;;
  esac
done
shift $((OPTIND-1))

printf 'Hello, %s!\n' "$name"
EOF

chmod +x template.sh
./template.sh -n Labzy
./template.sh -v
```

> **Reality check:** `set -e` can surprise you with commands that legally return non‑zero (e.g., `grep` no matches). Either guard them (`grep ... || true`) or test conditionally (`if grep -q ...; then ... fi`).

---

## 2) Variables, quoting, and arithmetic
```bash
name=Raghu           # no spaces around =
num=5
msg="Hi $name"      # double quotes expand variables
printf '%s (%d)\n' "$msg" "$num"

# arithmetic
((sum = num + 10))
printf 'sum=%d\n' "$sum"
((sum++))

# command substitution
now=$(date +%F)
printf 'Today: %s\n' "$now"

# arrays (indexed)
fruits=(apple banana cherry)
printf '%s\n' "${fruits[@]}"

# associative arrays (bash >= 4)
declare -A ages=([alice]=30 [bob]=27)
printf 'Alice=%s Bob=%s\n' "${ages[alice]}" "${ages[bob]}"
```

**Quoting rules you’ll actually use**
- Always **double‑quote** variables: `"$var"` (prevents word splitting & globbing)
- Prefer `"${arr[@]}"` to expand arrays safely
- Use single quotes for **literal** strings: `'*.log'`

---

## 3) Conditions and loops
```bash
# if/elif/else
x=7
if (( x > 10 )); then
  echo 'big'
elif (( x == 7 )); then
  echo 'lucky'
else
  echo 'small'
fi

# string tests and files
f='hello.sh'
if [[ -f $f && -x $f ]]; then echo 'script is executable'; fi

# case
case "$1" in
  start) echo starting ;;
  stop)  echo stopping ;;
  *)     echo usage: $0 '{start|stop}' ;;
esac

# for loop (files)
for p in *.sh; do
  printf 'script: %s\n' "$p"
done

# while read loop (robust)
printf 'a\nb\nc\n' > lines.txt
while IFS= read -r line; do
  printf 'line=[%s]\n' "$line"
done < lines.txt
```

---

## 4) Functions, returns, and exit codes
```bash
is_port_open() {
  local host=$1 port=$2
  (echo > /dev/tcp/$host/$port) >/dev/null 2>&1
}

if is_port_open 127.0.0.1 22; then
  echo 'ssh seems open'
else
  echo 'ssh closed'
fi

# explicit exit codes
some_check() {
  [[ -d $1 ]] || return 2   # custom non-zero means a specific failure
}

some_check /nope || echo "some_check failed with: $?"
```

> **Guideline:** exit codes: `0=success`, `1=generic`, `2=bad usage`, `>2` command‑specific.

---

## 5) Stdout vs stderr, pipes, and redirection
```bash
# send normal output to a file
./hello.sh > output.txt
# send errors to a file
./template.sh -z 2> errors.log || true
# merge stderr into stdout
./template.sh -z > all.log 2>&1 || true
# pipelines
seq 1 10 | paste -sd+ - | bc
```

**Here‑docs and here‑strings**
```bash
cat <<'TXT' > note.txt
multi-line text
with $variables left alone
TXT

# here-string passes a single line as stdin
read -r first <<< "$(head -n1 note.txt)"
```

---

## 6) Mini project: a tiny backup script
Create directories and a script that tars + compresses a folder with date stamps.
```bash
mkdir -p data backups
printf 'demo\n' > data/file1.txt

cat > backup.sh <<'EOF'
#!/usr/bin/env bash
set -Eeuo pipefail
shopt -s nullglob
SRC=${1:-data}
OUT=${2:-backups}
mkdir -p "$OUT"
stamp=$(date +%Y%m%d-%H%M%S)
archive="$OUT/${SRC##*/}-$stamp.tar.zst"

# require tar and zstd
command -v tar >/dev/null || { echo 'tar missing' >&2; exit 127; }
command -v zstd >/dev/null || { echo 'zstd missing: sudo apt install zstd' >&2; exit 127; }

tar --zstd -cvf "$archive" "$SRC" >/dev/null
printf 'Created %s (%s)\n' "$archive" "$(du -h "$archive" | cut -f1)"
EOF

chmod +x backup.sh
./backup.sh data backups
ls -lh backups | tail -n +1
```

**Restore one archive**
```bash
mkdir -p restore
latest=$(ls -1 backups/*.tar.zst | tail -n1)
tar --zstd -xvf "$latest" -C restore
```

---

## 7) Argument parsing with `getopts`
```bash
cat > args_demo.sh <<'EOF'
#!/usr/bin/env bash
set -Eeuo pipefail
usage() { echo "Usage: $0 [-c COUNT] [-o OUTDIR] file"; }
count=1; out=out
while getopts ':c:o:h' opt; do
  case "$opt" in
    c) count=$OPTARG ;;
    o) out=$OPTARG ;;
    h) usage; exit 0 ;;
    :) echo "Option -$OPTARG needs an argument" >&2; exit 2 ;;
    \?) usage; exit 2 ;;
  esac
done
shift $((OPTIND-1))
file=${1:-}
[[ -n $file ]] || { usage; exit 2; }
mkdir -p "$out"
for i in $(seq 1 "$count"); do
  cp -a "$file" "$out/${file##*/}.$i"
done
echo "Wrote $count copies to $out"
EOF

chmod +x args_demo.sh
./args_demo.sh -c 3 -o copies hello.sh
ls -l copies
```

---

## 8) Reusable helpers and style
Create a tiny **lib** and reuse it.
```bash
cat > lib.sh <<'EOF'
#!/usr/bin/env bash
set -Eeu -o pipefail
log() { printf '[%(%F %T)T] %s\n' -1 "$*"; }
require() { command -v "$1" >/dev/null || { log "need $1"; exit 127; }; }
EOF

cat > use_lib.sh <<'EOF'
#!/usr/bin/env bash
set -Eeuo pipefail
. ./lib.sh
require curl
log "Fetching example.com headers"
curl -I https://example.com >/dev/null
log done
EOF

chmod +x use_lib.sh
./use_lib.sh
```

**Lint your scripts** (highly recommended):
```bash
sudo apt update && sudo apt install -y shellcheck
shellcheck hello.sh template.sh backup.sh args_demo.sh use_lib.sh
```

---

## 9) Cron and scheduling (optional)
Run a script every day at 02:15.
```bash
crontab -e
# add the line below, save & exit
15 2 * * * /home/$USER/playground/scripting/backup.sh /home/$USER/data /home/$USER/backups >>/home/$USER/backup.log 2>&1
```
Check logs or output files to confirm it ran.

---

## 10) Practice tasks (do these now)
1) Add a `-d`/`--dry-run` option to `backup.sh` that prints what would be archived but doesn’t create a file.  
2) Modify `args_demo.sh` to accept `-p PREFIX` and include it in the output filenames.  
3) Write `checksum.sh` that prints a SHA256 for each file passed as arguments; exit `2` if any file doesn’t exist.  
4) Create `filter.sh` that reads stdin and prints only lines containing a supplied pattern (case‑insensitive) – use `grep -i` properly with `set -e`.  
5) (Optional) Write `netcheck.sh host port` that returns `0` if TCP is open using the `/dev/tcp` trick; otherwise `1`.

---

## 11) Troubleshooting quick guide
- **Permission denied** → forgot `chmod +x`; or directory lacks `+x` for traversal.  
- **`command not found`** → incorrect shebang; missing dependency (use `require` helper).  
- **Script exits early with `set -e`** → a command returned non‑zero; handle expected failures with `|| true` or `if` guards.  
- **Arguments with spaces break** → missing quotes; always use `"$var"` and `"$@"`.  
- **Cron works manually but not via cron** → PATH/env differences; use absolute paths and redirect stderr.

---

## 12) Quick quiz (1 minute)
- Why prefer `#!/usr/bin/env bash` over `#!/bin/bash`?  
- What does `set -Eeuo pipefail` do in plain English?  
- How do you safely loop over lines in a file?  
- What’s the difference between `$*` and `"$@"`?  
- Which tool flags common Bash mistakes automatically?

**Answers:** Finds Bash via PATH (portable across distros); stricter error handling and earlier failure; `while IFS= read -r line; do …; done < file`; `$*` joins words (unsafe), `"$@"` preserves argument boundaries; **ShellCheck**.

---

## Next Step
Proceed to **Step 11 — Users & Authentication** (or the next topic in your curriculum). Update previous steps’ “Next Step” pointers if needed.

