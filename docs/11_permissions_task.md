# Step 11 — Permissions Challenge (Validation Task)

> **Goal:** Configure secure permissions for a small project so only the owner can read “secret” files, while a public folder stays readable by others.
> **Type:** Task with validator (solution is **not** in this doc). Use the helper if you’re stuck.

## Scenario
Your team stores notes in a project called `secure-project`. You must:
- Create the directories and files
- Apply **correct permissions** so secrets are private and public readme is world‑readable
- Run the validator to confirm

## Requirements

1) Create folders (under your home practice area):
   - `~/playground/secure-project/secrets`
   - `~/playground/secure-project/public`

2) Create files with exact contents:
   - `~/playground/secure-project/secrets/plan.txt` containing: `TOP SECRET`
   - `~/playground/secure-project/public/readme.txt` containing: `Welcome to the project`

3) Set permissions **exactly**:
   - Directory `secrets`: `700`
   - File `secrets/plan.txt`: `600`
   - Directory `public`: `755`
   - File `public/readme.txt`: `644`

4) Optional (nice to have, not required for pass):  
   - Show octal + owner/group using: `stat -c "%A %a %U %G %n" <path>`

## Hints (partial)
- Create folders: `mkdir -p ...`
- Create files: `echo "TEXT" > file`
- Set directory perms: `chmod 700 DIR` (owner `rwx`, others none)
- Set file perms: `chmod 600 FILE` (owner `rw`, others none)
- Public readable directory: `chmod 755 DIR`
- Public readable file: `chmod 644 FILE`

## How to validate
From your terminal, run the validator:

```bash
bash validate/11_permissions_task.sh
```

If everything is correct, it will print **PASS**. Otherwise it prints a helpful **FAIL** message so you can adjust and re‑run.
