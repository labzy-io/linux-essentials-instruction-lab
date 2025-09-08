# Step 3 — Searching & Text Viewing (Ubuntu 24)

> **Type along** exactly as shown. This step is written for absolute beginners and assumes no prior Linux experience.  
> **Estimated time:** ~10–15 minutes

---

## What you’ll learn
- How to **view** text files (`cat`, `less`, `head`, `tail`)
- How to **search inside** files with `grep`
- How to **find files/folders** anywhere with `find`
- How to chain commands together with the **pipe** (`|`) for quick analysis
- How to avoid common mistakes (case, spaces, patterns)

This expands the original brief step to include **practical variations**, **safety notes**, and **troubleshooting**.

> **Setup:** Continue using your practice area from previous steps (recommended):  
> ```bash
> mkdir -p ~/playground && cd ~/playground
> ```

---

## 0) Create some sample files to search

We’ll set up a few files so your searches have something to find.

```bash
cd ~/playground
echo "Hello Linux" > hello.txt
echo "hello again" >> hello.txt
echo "Linux is powerful" > notes.txt
echo "HELLO CAPS" > caps.txt
mkdir -p logs
printf "alpha\nbeta\ngamma\nBeta\nGamma\n" > logs/mixed.txt
```

Verify:
```bash
ls -l
ls -l logs
```

---

## 1) View files quickly (`cat`) and with scrolling (`less`)

**A) View entire file now:**  
```bash
cat hello.txt
```
- `cat` prints the file to your screen immediately (great for short files).

**B) Scroll through long files:**  
```bash
less notes.txt
```
- **Keys:** Up/Down or PageUp/PageDown to move; `/word` to search; `n` for next match; `q` to quit.
- `less` doesn’t load the whole file at once — it’s ideal for big files and logfiles.

**C) Peek at the top/bottom only (useful for logs):**
```bash
head -n 3 hello.txt   # first 3 lines
tail -n 3 hello.txt   # last 3 lines
tail -f hello.txt     # follow new lines live; press Ctrl+C to stop
```

> **Tip:** Use `tail -f` while another process writes to a log to watch updates in real time.

---

## 2) Search inside files with `grep`

`grep` finds lines **containing** a pattern.

**A) Basic search (case-sensitive by default):**
```bash
grep "Hello" hello.txt
```
- Matches `Hello` but **not** `hello`.

**B) Case-insensitive search:**
```bash
grep -i "hello" hello.txt
```

**C) Show line numbers with matches:**
```bash
grep -n "hello" hello.txt
```

**D) Search multiple files at once:**
```bash
grep -n "linux" *.txt
```
- Matches lines containing `linux` in any `.txt` file (case-sensitive).

**E) Recursive search (search through folders):**
```bash
grep -Rni "beta" .
```
- `-R` = recursive, `-n` = show line numbers, `-i` = ignore case

**F) Show only the filenames that match:**
```bash
grep -Rl "hello" .
```

**G) Regex (advanced but useful):**  
Match `Hello` or `HELLO` or `hello` without `-i`, using an **extended** regex:
```bash
grep -En "(?i)hello" *.txt 2>/dev/null || grep -En "(H|h)ELLO|Hello|hello" *.txt 2>/dev/null
```
> Note: The `(?i)` flag is not supported in all `grep` versions; the fallback demonstrates alternation with `-E`. Beginners can skip this for now.

**H) Invert match (show lines that **do not** match):**
```bash
grep -v "hello" hello.txt
```

---

## 3) Find files/folders anywhere with `find`

`find` walks directories and lets you filter by **name**, **type**, **size**, **time**, and more.

**A) Find by name:**
```bash
find . -name "hello.txt"
find . -name "*.txt"
```

**B) Only files vs. only directories:**
```bash
find . -type f -name "*.txt"
find . -type d -name "logs"
```

**C) Limit depth to current folder only:**
```bash
find . -maxdepth 1 -type f -name "*.txt"
```

**D) Find by size (files larger than 1 megabyte):**
```bash
find . -type f -size +1M
```

**E) Find by modified time (edited within last 1 day):**
```bash
find . -type f -mtime -1
```

**F) Do something with each result (`-exec`):**  
Show file sizes for all `.txt` files:
```bash
find . -type f -name "*.txt" -exec wc -l {} \;
```
> `wc -l` counts lines; `{}` is replaced by each found file; `\;` ends the `-exec` command.

**G) Safer piping with null terminators (handles spaces in filenames):**
```bash
find . -type f -name "*.txt" -print0 | xargs -0 grep -n "hello"
```
- This combination searches **all** `.txt` files for `hello`, even if filenames contain spaces.

---

## 4) Combine tools with the pipe `|`

**A) Quick counts (how many matches?):**
```bash
grep -Rni "hello" . | wc -l
```
- `wc -l` counts how many **matching lines** were found.

**B) Sort and unique (e.g., see unique matching filenames):**
```bash
grep -Rl "hello" . | sort | uniq
```

**C) Show the 5 most common words in a file (simple demo):**
```bash
tr -cs '[:alnum:]' '\n' < hello.txt | tr '[:upper:]' '[:lower:]' | sort | uniq -c | sort -nr | head -n 5
```
- Splits text into words, lowercases, counts, and shows top 5.

> **Note:** The above is a mini data-processing pipeline — not required for beginners but fun to see what’s possible.

---

## 5) Practice tasks (do them now)

1) Show the **first** 2 lines of `logs/mixed.txt`.  
2) Show only the lines that contain “Gamma” (any case) in `logs/mixed.txt`.  
3) Find all `.txt` files **in this folder only** (not subfolders).  
4) Count how many lines in **all** `.txt` files mention “hello” (any case).  
5) Show the **filenames only** that contain the word “Linux” (case-insensitive) anywhere under the current folder.

**Hints:**
```bash
head -n 2 logs/mixed.txt
grep -i "gamma" logs/mixed.txt
find . -maxdepth 1 -type f -name "*.txt"
grep -Rni "hello" . | wc -l
grep -Rli "linux" .
```

---

## Troubleshooting

**Q: `grep: *.txt: No such file or directory`**  
A: Wildcards expand before grep runs. If nothing matches `*.txt`, your shell might pass the literal string. Make sure you’re in the right folder and that `.txt` files exist.

**Q: My search is case-sensitive, but I need any case.**  
A: Add `-i` to `grep` (e.g., `grep -i "hello"`).

**Q: `find` prints “Permission denied”.**  
A: You’re walking directories you don’t own (outside your home). For practice, stay inside `~/playground`.

**Q: `less` won’t quit.**  
A: Press `q` to exit `less`.

---

## Quick Quiz (1 minute)
- Which command opens a scrollable viewer?  
- How do you search recursively and ignore case with `grep`?  
- How do you show only filenames that match?  
- Which `find` option restricts search to current directory only?  
- What does `wc -l` do when piped after `grep`?

**Answers:** `less`; `grep -Rni "term" .`; `grep -Rl "term" .`; `-maxdepth 1`; counts matching lines.

---

## Next Step
Continue to **Step 4 — Process Management** to learn how to view, sort, and control running programs.
