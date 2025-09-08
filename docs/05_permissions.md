# Step 5 — Permissions & Ownership (Ubuntu 24)

> **Type along** exactly as shown. This step is written for absolute beginners and assumes no prior Linux experience.  
> **Estimated time:** ~10–15 minutes

---

## What you’ll learn
- How to **read** Linux permissions and ownership
- How to **change** permissions with `chmod` (symbolic & octal)
- How to change **owner** and **group** with `chown` / `chgrp`
- How **directory** permissions differ from **file** permissions
- How **umask** affects default permissions
- (Optional) What **setuid**, **setgid**, and **sticky** bits do
- (Optional) How to use **ACLs** for fine‑grained access

> **Setup:** Continue using your practice area (recommended):
> ```bash
> mkdir -p ~/playground && cd ~/playground
> ```

---

## 0) Primer: Users, Groups, and the `rwx` model
Linux tracks access for three classes:
- **u** (user/owner) — typically who created the file
- **g** (group) — collaborators who share a group
- **o** (others) — everyone else

Each class can have:
- **r** (read)
- **w** (write)
- **x** (execute for files / *enter* for directories)

**Example:**
```
-rw-r----- 1 alice devs  42 Sep  8 12:00 notes.txt
```
- Leading `-` = regular **file** (use `d` for directory)  
- `rw-` (user), `r--` (group), `---` (others)  
- Owner = `alice`, Group = `devs`

> **Tip:** For **directories**, `x` means you can *enter* the directory and access filenames inside. Without `x`, even if you have `r`, you can list names but may not open files.

---

## 1) View permissions & ownership
Create a couple of files and a directory:
```bash
printf 'hello\n' > hello.txt
printf '#!/usr/bin/env bash\necho hi\n' > hello.sh
mkdir project
```
Show long listing:
```bash
ls -l hello.txt hello.sh project
```
Show numeric (octal) permissions and type:
```bash
stat -c '%A  %a  %U:%G  %n' hello.txt hello.sh project
```
See your user and groups:
```bash
id
# or
groups
```

**Expected:** You’ll see owner = your username, group = your primary group, and default perms (e.g., `644` for files, `755` for new directories on many systems).

---

## 2) Change permissions with `chmod`
`chmod` can use **symbolic** or **octal** modes.

### A) Symbolic mode
Add **execute** for owner on the script, remove execute for others:
```bash
chmod u+x,o-x hello.sh
ls -l hello.sh
```
Set **exact** bits (owner `rw`, group `r`, others `-`):
```bash
chmod u=rw,g=r,o= hello.txt
ls -l hello.txt
```
Give **group** write on directory for collaboration:
```bash
chmod g+w project
ls -ld project
```

### B) Octal mode
- `r=4`, `w=2`, `x=1` → Sum them per class: `u g o`

Make a common script mode `755` (rwx r-x r-x):
```bash
chmod 755 hello.sh
stat -c '%A %a %n' hello.sh
```
Set a private file `600` (rw- --- ---):
```bash
chmod 600 hello.txt
stat -c '%A %a %n' hello.txt
```

### C) Recurse (be careful!)
Apply to all items beneath a directory:
```bash
mkdir -p project/sub
touch project/sub/todo.txt
chmod -R g+rw project
```
> **Warning:** Recursive changes can break apps. Prefer targeted changes.

---

## 3) Ownership: `chown` and `chgrp`
Ownership is stored as **user:group**.

Change owner (requires privileges if not your own):
```bash
# Example only; may require sudo depending on target user
sudo chown $USER:$USER hello.txt
```
Change **group** when collaborating:
```bash
# switch group ownership to e.g. `devs` (must be a group you’re in)
sudo chgrp devs project || echo "Try a group you belong to"
ls -ld project
```
Change owner:group recursively (careful):
```bash
# Example – change group across a tree
sudo chown -R :devs project
```

> **Rule of thumb:** Use `chgrp` to hand a folder to a **team group**, then use directory permissions to control access.

---

## 4) Executable scripts: shebang & run
Make sure the script starts with a **shebang** line and is executable:
```bash
head -n1 hello.sh
chmod u+x hello.sh
./hello.sh
```
If you see `Permission denied`, check `ls -l hello.sh` and ensure the containing directory has `x`.

---

## 5) Defaults with `umask`
`umask` subtracts permissions from new files/directories.

Show current umask:
```bash
umask
```
Make a new file/dir and check modes:
```bash
printf 'tmp\n' > new.txt
mkdir newdir
stat -c '%a %n' new.txt newdir
```
Temporarily set a stricter umask for this shell (e.g., disallow “others”):
```bash
umask 007
printf 'secret\n' > secret.txt
stat -c '%a %n' secret.txt
```
> **Typical defaults:** Files start from `666` (rw rw rw) and directories from `777` (rwx rwx rwx), then your `umask` removes bits.

---

## 6) Special bits (advanced)
### setuid (`4xxx` on files)
- Executed with the file **owner’s** privileges.
- Common on system tools like `passwd`.
> **Don’t set setuid on your own scripts**; it’s risky and often ignored for scripts.

### setgid (`2xxx` on files/dirs)
- On **directories**, new files inherit the directory’s **group**, improving collaboration.

Enable setgid on a shared project folder:
```bash
sudo chgrp devs project
sudo chmod g+ws project   # the 's' shows setgid on the group bit
ls -ld project
```
New files in `project/` will have group `devs` automatically.

### sticky bit (`1xxx` on dirs)
- On directories like `/tmp`, users can only delete **their own** files even if the dir is world-writable.

Add sticky to a shared drop folder:
```bash
mkdir -p shared_drop
chmod 1777 shared_drop
ls -ld shared_drop
```

---

## 7) ACLs (Access Control Lists) — optional
ACLs allow per‑user or per‑group overrides beyond the basic `u/g/o` model.

Inspect ACLs:
```bash
getfacl hello.txt || echo "Install acl package if missing"
```
Grant **alice** read/write:
```bash
setfacl -m u:alice:rw hello.txt
getfacl hello.txt | sed -n '1,20p'
```
Set a **default ACL** on a directory (applies to new files):
```bash
setfacl -m d:u:alice:rwx project
getfacl project | sed -n '1,50p'
```
Remove an entry or clear all:
```bash
setfacl -x u:alice hello.txt
setfacl -b hello.txt   # wipe all ACLs
```
> **Note:** On Ubuntu, ACL support is usually enabled by default. If commands are missing: `sudo apt update && sudo apt install -y acl`.

---

## 8) Practice tasks (do these now)
1) Make `hello.sh` executable for **owner only**, and run it.  
   *Hint:* `chmod 700 hello.sh`
2) Make `hello.txt` readable by **group**, but **no access** for others. Verify with `stat`.
3) Create `project/docs/` and ensure the **group** keeps inheriting on new files.  
   *Hint:* `chmod g+ws project` and set group ownership.
4) Create a shared `shared_drop/` so **anyone** can write but only delete their own files.  
   *Hint:* `chmod 1777 shared_drop`
5) (Optional) Give a specific teammate **rw** on `hello.txt` using **ACLs**, then remove it.

---

## Troubleshooting
- **Permission denied**: Check both the **file** and its **directory** for execute (`x`) where needed.
- **Operation not permitted**: Ownership changes or privileged bits may require `sudo`.
- **Script won’t run**: Ensure `#!/usr/bin/env bash` shebang and `chmod +x`. Also check the mount isn’t `noexec`.
- **Group changes don’t “stick”**: Use **setgid** on the directory and correct group ownership.
- **ACLs ignored?** Ensure filesystem supports ACLs and the tools are installed.

---

## Quick Quiz (1 minute)
- What does the **x** bit mean on a **directory**?  
- Translate `-rwxr-x---` to octal.  
- Which command changes just the **group** of a file?  
- What does **setgid** on a directory do?  
- How does `umask` affect new files?

**Answers:** enter/traverse; `750`; `chgrp`; new files inherit the directory’s group; it subtracts bits from default perms.

---

## Next Step
Continue to **Step 6 — System Info & Monitoring** to learn how to inspect CPU, memory, disk, and logs effectively.

