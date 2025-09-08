# Step 8 — Archiving & Compression (Ubuntu 24)

> **Type along** exactly as shown. Nothing here alters system config. Optional installs use `apt`.  
> **Estimated time:** ~20–25 minutes

---

## What you’ll learn
- The difference between **archiving** (tar) and **compressing** (gzip/xz/zstd/zip/7z)
- Create, list, verify, extract **tar** archives with and without compression
- Choose the right compressor for **speed** vs **size** (gzip, xz, zstd)
- Include/exclude paths, preserve ownership/permissions, and handle **symlinks** and **sparse files**
- Stream archives via **pipes** and **SSH**; split and rejoin large archives
- Verify integrity with `tar -tvf`/`-W` and `sha256sum`

> **Setup:** Work in a safe playground:
> ```bash
> mkdir -p ~/playground/arch && cd ~/playground/arch
> ```

---

## 0) Prepare sample data
Create a small tree with different file types:
```bash
mkdir -p src dirA/dirB
printf 'hello\n' > src/hello.txt
head -c 1M </dev/urandom > src/random.bin
ln -s ../src hello_link            # symlink
# create a sparse file (looks big, uses little disk)
truncate -s 500M src/sparse.img
# hidden file, and a file to exclude later
printf 'secret\n' > .env
printf 'ignore me\n' > src/tmp.log
```
Confirm structure:
```bash
find . -maxdepth 3 -printf '%M %u:%g %8s %p\n' | sed -n '1,40p'
```

---

## 1) Archiving 101 — `tar` without compression
Create an archive of **src/** and **dirA/**:
```bash
# c=create, v=verbose, f=filename
 tar -cvf lab.tar src dirA
 ls -lh lab.tar
```
List contents without extracting:
```bash
 tar -tvf lab.tar | head -20
```
Extract into a new folder and compare:
```bash
 mkdir extract && tar -xvf lab.tar -C extract
 diff -qr src extract/src && echo 'src matches extract/src'
```
> **Note:** `tar` stores paths relative to where you run it; use `-C` to control base paths.

---

## 2) Compressors quick tour
Install common tools:
```bash
sudo apt update && sudo apt install -y zstd xz-utils gzip zip unzip p7zip-full
```
Single‑file compression (no tar):
```bash
# gzip (fast, widespread)
gzip -k src/hello.txt        # keeps original with -k
ls -lh src/hello.txt*
# xz (smallest, slower)
xz -k src/random.bin
# zstd (balanced, very fast; levels 1–19; -T0 = all cores)
zstd -k -T0 src/random.bin
```
Inspect compression ratios:
```bash
gzip -l src/hello.txt.gz
xz -l src/random.bin.xz
zstd -lv src/random.bin.zst
```
> **Rule of thumb:** `zstd` is great default for speed; `xz` for maximum shrink (archives) when time is okay; `gzip` for legacy compatibility.

---

## 3) Tar + compression combos
### Easiest: let `tar` drive the compressor
```bash
# gzip
 tar -czvf lab.tar.gz src dirA
# xz
 tar -cJvf lab.tar.xz src dirA
# zstd (modern)
 tar --zstd -cvf lab.tar.zst src dirA
```
**List** without extracting:
```bash
 tar -tvf lab.tar.gz | head -10
 tar -tvf lab.tar.xz | head -10
 tar -tvf lab.tar.zst | head -10
```

### Custom compressor flags with `-I`
```bash
# zstd level 19, all cores
 tar -I 'zstd -T0 -19' -cvf lab-max.tar.zst src dirA
# parallel gzip if `pigz` is installed
# sudo apt install -y pigz
 tar -I pigz -cvf lab.tar.gz src dirA
```

---

## 4) Extracting safely
Basic extraction into a target directory:
```bash
mkdir -p /tmp/lab_extract
sudo tar -xvpf lab.tar.zst --zstd -C /tmp/lab_extract
```
Flags used:
- `x` extract, `v` verbose, `p` **preserve perms**, `f` filename  
- `--same-owner` (root only) to preserve ownership exactly

Strip leading path components (handy when archive contains a top‑level folder):
```bash
mkdir clean && tar -xvf lab.tar.gz --strip-components=1 -C clean
```
Extract **one** item:
```bash
tar -xvf lab.tar.zst --zstd src/hello.txt -C extract_one
```

---

## 5) Excludes, includes, and quoting
Create an archive but **exclude** logs and hidden files:
```bash
 tar --exclude='*.log' --exclude='.*' -cvf lab_nohidden.tar src dirA
 tar -tvf lab_nohidden.tar | grep -E '\.log|/\.' || echo 'No logs/hidden files included'
```
Use an **exclude‑from** file (one pattern per line):
```bash
printf '*.log\n.env\n*.tmp\n' > exclude.txt
 tar --exclude-from=exclude.txt -cvf lab_filtered.tar src dirA
```
> **Quoting tip:** Quote globs (`'*.log'`) so your shell doesn’t expand them before `tar` sees them.

---

## 6) Sparse files & symlinks
The sample `src/sparse.img` is **sparse**. Use `--sparse` to store holes efficiently:
```bash
 tar --sparse -cvf sparse.tar src/sparse.img
 ls -lh sparse.tar
```
Control how symlinks are handled:
```bash
# default: store symlink as link (recommended)
 tar -cvf links.tar hello_link
# follow symlinks (stores target content)
 tar -h -cvf links_follow.tar hello_link
 tar -tvf links_follow.tar | head -3
```

---

## 7) Streaming: pipes & SSH
Create and compress on the fly, no temp file:
```bash
 tar -c src | zstd -T0 -19 -o src.tar.zst
```
Send to a remote host over SSH (requires SSH access):
```bash
# on local machine
 tar -c src | ssh user@remote 'tar -x -C /tmp'
# or with compression on the wire
 tar -c src | zstd -T0 | ssh user@remote 'zstd -d | tar -x -C /tmp'
```

---

## 8) Integrity: list, verify, checksum
**List** is your first sanity check:
```bash
 tar -tvf lab.tar.zst --zstd | head -5
```
Ask `tar` to **verify** after writing (`-W`):
```bash
 tar --zstd -cvWf lab_verify.tar.zst src dirA
```
Create a strong **checksum** alongside the archive:
```bash
sha256sum lab_verify.tar.zst > lab_verify.tar.zst.sha256
sha256sum -c lab_verify.tar.zst.sha256   # verify later
```

---

## 9) Split & rejoin large archives
Split into ~200 MiB parts:
```bash
 tar --zstd -cvf big.tar.zst src dirA
 split -b 200M big.tar.zst big.tar.zst.part-
 ls -lh big.tar.zst.part-*
```
Rejoin and verify:
```bash
 cat big.tar.zst.part-* > big.rejoined.tar.zst
 cmp big.tar.zst big.rejoined.tar.zst && echo 'Parts rejoined OK'
```

---

## 10) `zip` and `7z` (cross‑platform)
### zip
```bash
zip -r lab.zip src dirA . -x '*.log' .env
unzip -l lab.zip | head -10
unzip lab.zip -d unzip_out
```
### 7‑Zip / 7z (high ratio, solid archives)
```bash
7z a -t7z -m0=lzma2 -mx=9 lab.7z src dirA
7z l lab.7z | head -15
7z x lab.7z -o7z_out -y
```

---

## 11) Ownership, perms, and umask
- `tar` records **modes, owners, groups, times**. Extraction as non‑root maps owners to **your** user unless you use `sudo` + `--same-owner`.
- Use `-p` to **preserve permissions** even if your `umask` would change them.
- For shared/team archives, consider setting a consistent `umask` before creating, e.g., `umask 022`.

---

## 12) Clean up (optional)
```bash
rm -rf extract extract_one clean unzip_out 7z_out *.tar* *.gz *.xz *.zst *.zip *.7z *.sha256 big.rejoined.tar.zst src dirA hello_link exclude.txt .env
```

---

## 13) Practice tasks (do these now)
1) Create `proj.tar.zst` from `src/` **excluding** `*.log` and hidden files. List its contents.  
2) Extract only `src/hello.txt` into `~/playground/arch/single/` and verify checksum with `sha256sum`.  
3) Make a **sparse** 1 GiB file and build a space‑efficient archive of it; compare `.tar` size with and without `--sparse`.  
4) Stream‑extract `src/` to `/tmp/arch_stream/` without creating a local archive file.  
5) Split `proj.tar.zst` into 100 MiB parts, rejoin, and verify with `cmp`.  
6) (Optional) Create `lab.zip` and `lab.7z`, list both, extract to separate folders, and compare with the original tree using `diff -qr`.

---

## 14) Troubleshooting
- **“file changed as we read it”** during tar: the file mutated mid‑archive; rerun when idle, or snapshot first.
- **Permissions wrong after extract**: add `-p` and (if root) `--same-owner`; check `umask`.
- **Symlinks unexpectedly dereferenced**: you probably used `-h`; remove it to store links as links.
- **Archive too slow**: use `zstd -T0` (multi‑threaded) or `pigz` for gzip; avoid `xz` for huge trees if you care about speed.
- **Disk full**: prefer streaming (`tar | zstd -o /mnt/big/…`) or `-C` to write on a larger filesystem; check free space with `df -h`.

---

## 15) Quick quiz (1 minute)
- Does `tar` compress by default?  
- Which compressor is fastest on multi‑core systems at decent ratios?  
- Which `tar` option keeps original file modes on extract?  
- How do you exclude all hidden files?  
- What’s the safest way to copy to a remote host without writing a local archive file?

**Answers:** No, `tar` only archives unless you add a compressor; `zstd -T0`; `-p` (and `--same-owner` when root); `--exclude='.*'`; `tar -c dir | ssh host 'tar -x -C /dest'` (optionally compress in the middle).

---

## Next Step
Proceed to **Step 9 — Users & Authentication** (local users, groups, passwords, SSH basics). If your curriculum orders differ, update the previous step’s “Next Step” pointer to this page.

