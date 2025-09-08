# Step 2 — Navigation & File Operations (Ubuntu 24)

> **Type along** exactly as shown. This step is written for absolute beginners and assumes no prior Linux experience.  
> **Estimated time:** ~10–15 minutes

---

## What you’ll learn
- What a *path* is (absolute vs. relative)
- How to **move around** with `cd`
- How to **create**, **inspect**, **copy**, **move/rename**, and **delete** files and folders
- How to work safely (confirmation prompts), and handle names with **spaces**
- How to verify your actions with `ls -l`

This expands the original brief step (pwd → mkdir → cd → create file → ls -l) into a guided mini-lesson with checks, expected outputs, and troubleshooting.

---

## 0) Setup (recommended)

Create a clean practice area so you don’t accidentally change other files:

```bash
mkdir -p ~/playground && cd ~/playground
```

- `~` is your **home** directory (e.g., `/home/yourname`).
- `mkdir -p` creates all missing parent folders safely.
- `cd` changes your current working directory.

If something goes wrong, you can reset this folder later:
```bash
cd ~ && rm -rf ~/playground && mkdir -p ~/playground && cd ~/playground
```

---

## 1) Where am I? (Print Working Directory)

```bash
pwd
```

**Expected output:** the full path of your current directory (e.g., `/home/yourname/playground`).  
This is called an **absolute path** (it starts with `/`).

---

## 2) Create folders (directories)

Create a single folder:
```bash
mkdir projects
```

Create a **nested** folder tree in one go:
```bash
mkdir -p projects/alpha
```

Verify:
```bash
ls -la
```

- `-l` = long list (permissions, owner, size, date)
- `-a` = include hidden items (names starting with a dot)

> Hidden files often store settings and are called **dotfiles** (e.g., `.bashrc`).

---

## 3) Move around with `cd`

Change into the new folder:
```bash
cd projects
pwd
```

Go **down** another level:
```bash
cd alpha
pwd
```

Go **up** one level:
```bash
cd ..
pwd
```

Jump **home** quickly:
```bash
cd ~
pwd
```

Return to your last directory:
```bash
cd -
```

> Think of `cd` as “change directory” — just like opening folders in a file explorer.

---

## 4) Create files (3 common ways)

Make sure you’re inside `~/playground` (use `pwd` to check), then:

**A) Create with content (overwrite if exists):**
```bash
echo "Hello Linux" > hello.txt
```

**B) Append more content (keeps existing lines):**
```bash
echo "Second line" >> hello.txt
```

**C) Create an empty file:**
```bash
touch empty.txt
```

**D) Create and edit with a text editor (nano):**
```bash
nano notes.txt
# Type: My first notes line.
# Save: Ctrl+O, Enter.  Exit: Ctrl+X
```

Check what you made:
```bash
ls -l
cat hello.txt
```

> `>` writes/overwrites; `>>` appends. `touch` creates an empty file or updates the timestamp if it already exists.

---

## 5) Inspect details with `ls`

List files with extra info:
```bash
ls -l
```

You’ll see lines like:
```
-rw-r--r-- 1 yourname yourname   12 Sep  8 10:00 hello.txt
```
- `-rw-r--r--` → **permissions**
- first `yourname` → **owner**
- second `yourname` → **group**
- `12` → file size in bytes
- `hello.txt` → file name

Try human-readable sizes:
```bash
ls -lh
```

Show hidden files too:
```bash
ls -la
```

---

## 6) Copy, move/rename, and delete files

**Copy a file:**
```bash
cp hello.txt hello.bak
ls -l hello*
```

**Move/rename a file (same command):**
```bash
mv hello.bak projects/alpha/
mv empty.txt empty-renamed.txt
ls -l projects/alpha
ls -l empty-renamed.txt
```

**Delete a file (interactive/safe):**
```bash
rm -i empty-renamed.txt
```

> `-i` asks **“remove regular file…?”** before deleting — excellent for beginners.

**Delete a folder tree (careful!):**
```bash
rm -r projects/alpha
mkdir -p projects/alpha  # recreate it for the next step
```

> `rm -r` removes directories **recursively** (everything inside). Use with caution.

---

## 7) Names with spaces

Two safe methods:

**Quotes:**
```bash
mkdir "my notes"
echo "a line" > "my notes/file with space.txt"
ls -l "my notes"
```

**Escaping spaces with backslashes:**
```bash
echo "another line" > my\ notes/another\ file.txt
ls -l my\ notes
```

> If you forget quotes/backslashes, the shell will think you’re typing **multiple arguments** and show an error like “No such file or directory”.

---

## 8) Wildcards (globbing)

List all `.txt` files:
```bash
ls -l *.txt
```

List everything that starts with `he`:
```bash
ls -l he*
```

> If a wildcard matches nothing, the shell may pass the literal pattern to the command (e.g., `ls: cannot access '*.txt': No such file or directory`). That’s normal.

---

## 9) Verify what you did (mini-checklist)

- Where are you?
  ```bash
  pwd
  ```
- Do you see the files you created?
  ```bash
  ls -la
  ```
- Do you see the content you wrote?
  ```bash
  cat hello.txt
  ```
- Is there a copy in `projects/alpha/`?
  ```bash
  ls -l projects/alpha
  ```

---

## 10) Cleanup (optional)

If you want to start fresh:
```bash
cd ~ && rm -rf ~/playground && mkdir -p ~/playground && cd ~/playground
```

---

## Troubleshooting

**Q: `Permission denied` when creating files?**  
A: Ensure you’re working inside your home (e.g., `~/playground`) where you have write permission.

**Q: `No such file or directory` when using spaces?**  
A: Use quotes `"like this"` or escape spaces: `my\ notes/that\ file.txt`.

**Q: I ran `rm -r` in the wrong place!**  
A: This is why we practice in `~/playground`. In real life, **double-check** paths before you press Enter.

---

## Quick Quiz (1 minute)
- How do you print the current directory path?
- What’s the difference between `>` and `>>`?
- Which command *renames* a file?
- Show a long listing including hidden files—what options do you use?
- Two ways to handle file names with spaces?

**Answers:** `pwd`; `>` overwrites, `>>` appends; `mv`; `ls -la`; quotes or backslashes.

---

## Next Step
Continue to **Step 3 — Searching & Text Viewing** to learn `grep`, `find`, `less`, and more!
