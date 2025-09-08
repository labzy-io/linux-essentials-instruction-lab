# Step 1 — Terminal Basics (Ubuntu 24)

> **Type along** exactly as shown. This step is written for absolute beginners and assumes no prior Linux experience.  
> **Estimated time:** ~10–15 minutes

---

## What you’ll learn
- What the *terminal* and the *shell* are
- How to open and close a terminal
- How to find your current shell and username
- How to run basic commands safely
- How to read the command prompt and use helpful keyboard shortcuts

This expands the original brief step (“Open terminal → echo $SHELL → whoami → exit”) into a guided mini-lesson with checks, expected outputs, and troubleshooting. 

---

## Prerequisites
- Ubuntu 24 (or a similar Linux distribution)
- A keyboard and mouse (no admin/sudo needed for this step)
- Willingness to try and make small mistakes (that’s normal!)

---

## 1) Open the Terminal

You can open the terminal in **three** easy ways — choose the one you like:

1. Press **Ctrl + Alt + T** (keyboard shortcut).  
2. Click **Activities** (top-left) → type `terminal` → click **Terminal**.  
3. Open **Applications** menu → **Terminal** (or **GNOME Terminal**).

**Expected view:** A window with a prompt like:
```
yourname@your-computer:~$
```
- `yourname` is your **username** (who you are)
- `your-computer` is the **hostname** (your machine’s name)
- `~` means your **home** directory (e.g., `/home/yourname`)
- `$` is the standard prompt for regular users (a `#` indicates the root/admin shell — you won’t use root here)

> If your prompt looks a bit different, that’s okay—Linux allows customization. The ideas are the same.

---

## 2) Meet Your Shell

The **shell** is a program that reads your commands and runs them. In Ubuntu it’s usually **Bash**.

**Find which shell you are using:**
```bash
echo $SHELL
```
**Expected output (typical):**
```
/bin/bash
```
- `echo` prints text
- `$SHELL` is an **environment variable** that stores the path to your current shell

**Alternative cross-check (nice to know):**
```bash
ps -p $$ -o comm=
```
- Prints the name of the program running your current shell (`bash`, `zsh`, etc.)

> Tip: Commands are **case-sensitive**. `Echo` or `ECHO` won’t work; use `echo` in lowercase.

---

## 3) Who Am I? Where Am I?

**Show your login name:**
```bash
whoami
```
**Expected output** (your actual username):
```
yourname
```

**Show your current folder (directory):**
```bash
pwd
```
**Expected output** (your home):
```
/home/yourname
```

> Remember: `~` is a shortcut for your home directory. `cd ~` and `cd` (with no arguments) both take you home.

---

## 4) Try a Few Safe Commands

Type each command and press **Enter**. Don’t worry—these are read-only.

```bash
date          # shows the current date and time
ls            # lists files/folders in the current directory
ls -la        # lists everything in long form, including hidden “dotfiles”
clear         # clears your screen (or press Ctrl+L)
```

If you want to see *what* a command does:
```bash
man ls        # the manual for ls (press q to quit)
ls --help     # quick built-in help for ls
help echo     # help for bash built-in command "echo"
```

> **How to read errors**: If you see a line like `command not found`, check your spelling and spaces. Linux cares about lowercase vs uppercase.

---

## 5) Keyboard Superpowers (Optional but Very Useful)

- **↑ / ↓**: browse history (commands you already typed)
- **Tab**: auto-complete file/command names (press twice to list options)
- **Ctrl + A**: jump to start of line
- **Ctrl + E**: jump to end of line
- **Ctrl + U**: clear from cursor *back* to start
- **Ctrl + K**: clear from cursor *forward* to end
- **Ctrl + W**: delete the previous word
- **Ctrl + L**: clear screen (same as `clear`)
- **Ctrl + C**: cancel/interrupt a running command (do not use while saving in editors)

**Try it:** Type `ec` then press **Tab** — if `echo` is the only match, your shell completes the word for you.

---

## 6) Practice: Your First Echo

`echo` prints whatever you give it. Try these:

```bash
echo Hello, Linux!
echo "Quoting keeps words together like this: two words"
echo $HOME           # prints your home directory path
echo $USER           # prints your username (same as whoami)
```

**What happened?**
- Without quotes, the shell splits by spaces
- With quotes `"..."`, the shell treats the content as one unit
- `$` means “expand this variable” (`$HOME`, `$USER`, `$SHELL`, `$PATH` are common ones)

---

## 7) Close the Terminal (Two Safe Ways)

1) Type:
```bash
exit
```
2) Or press **Ctrl + D** (sends “end-of-input”, which ends the shell)

If you had any running programs in the foreground, the shell will usually warn you.

---

## Troubleshooting

**Q: I typed `WhoAmI` and got “command not found.”**  
A: Commands are case-sensitive. Type `whoami` (all lowercase).

**Q: I see `Permission denied`.**  
A: You tried to access something you don’t have rights to. In this step, just practice with safe commands (`echo`, `whoami`, `pwd`).

**Q: My terminal is “stuck.”**  
A: A command might still be running. Press **Ctrl + C** to cancel. If that doesn’t work, close the terminal window.

**Q: My prompt ends with `#`. Is that bad?**  
A: That means you’re in a **root** (administrator) shell. Close the terminal and open a new one. For learning, stay as a regular user (`$` prompt).

---

## Quick Quiz (1 minute)

- What does `$SHELL` store?  
- How do you show your username?  
- What does `~` represent?  
- Which key shows your previous command?  
- Two ways to exit the terminal?

**Answers** (hover/select to reveal): `$SHELL` is your shell path; `whoami`; `~` = home directory; Up Arrow; `exit` and `Ctrl + D`.

---

## Next Step

You’re ready for **Step 2 — Navigation & File Operations**.  
Keep this terminal open; we’ll continue in the same window.

