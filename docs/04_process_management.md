# Step 4 — Process Management (Ubuntu 24)

> **Type along** exactly as shown. This step is written for absolute beginners and assumes no prior Linux experience.  
> **Estimated time:** ~10–15 minutes

---

## What you’ll learn
- What a **process** is and how to list them
- How to watch the system in real time with **top**
- How to start programs in the **background** and bring them to the **foreground**
- How to **stop/kill** a process safely
- How to view **PIDs** (Process IDs) and understand **signals**
- (Optional) How to adjust priority with **nice/renice**

This expands the original brief step (ps/top/background jobs/kill) into a guided mini-lesson with checks, expected outputs, and troubleshooting.

> **Setup:** Continue using your practice area from previous steps (recommended):  
> ```bash
> mkdir -p ~/playground && cd ~/playground
> ```

---

## 0) What’s a “process”?

A **process** is a running program (like the terminal, a text editor, a web browser tab, or a background task).  
Linux gives every process a unique number called a **PID** (Process ID). You use the PID to control the process (e.g., to stop it).

---

## 1) List processes with `ps`

Show the first few running processes (system-wide view):
```bash
ps aux | head -n 15
```
- `a` = show processes for **all** users
- `u` = show the user/owner
- `x` = include processes without a controlling terminal

**More readable columns (top 10 by PID):**
```bash
ps -o pid,ppid,user,%cpu,%mem,stat,cmd --sort=pid | head -n 10
```
- `pid` = Process ID
- `ppid` = Parent Process ID
- `%cpu`, `%mem` = CPU and memory usage
- `stat` = state (e.g., `S` sleeping, `R` running, `T` stopped)
- `cmd` = the command used to start the process

---

## 2) Real-time view with `top`

Open an updating view of processes:
```bash
top
```
**Keys you can try inside `top`:**
- `P` = sort by CPU
- `M` = sort by memory
- `1` = show all CPU cores
- `q` = quit

> Optional: Install **htop** (`sudo apt install -y htop`) for a friendlier view. Launch with `htop`, quit with `q`.

---

## 3) Create a background process and manage jobs

Start a harmless background job:
```bash
sleep 300 &
```
- `sleep 300` waits for 300 seconds (5 minutes). The `&` runs it **in the background** so you get your prompt back.

List your jobs:
```bash
jobs
```

Bring the job to the **foreground** (if there’s one job, it’s usually `%1`):
```bash
fg %1
```
Now your terminal is “busy” waiting for `sleep` to finish. Press **Ctrl + C** to stop it.

Start it again in the background and **suspend**, **resume** flow:
```bash
sleep 300 &      # start in background
jobs             
fg %1            # bring to foreground
# Press Ctrl+Z   # suspend the foreground job
bg %1            # resume it in the background
jobs
```

> **Ctrl+Z** = “pause” the foreground process.  
> **bg** = continue a paused job in the background.  
> **fg** = bring a background job to the foreground.

---

## 4) Find PIDs and kill a process safely

Create a background process to practice on:
```bash
sleep 400 &
```

Find its PID(s):
```bash
pgrep sleep
```
You’ll see one or more numbers (PIDs).

**Ask a process to exit nicely (SIGTERM 15):**
```bash
kill 15 <PID>
```
If it doesn’t exit after a few seconds, you can **force** it (SIGKILL 9):
```bash
kill -9 <PID>
```
> Use `-9` only if normal signals fail; it doesn’t let programs clean up.

**Alternative: kill by name (use carefully):**
```bash
pkill sleep        # stops all 'sleep' processes you own
# or
killall sleep
```

Confirm it’s gone:
```bash
pgrep sleep || echo "No sleep process found"
```

---

## 5) (Optional) Priority: nice and renice

Every process has a **priority** (niceness). Higher nice values (e.g., `+10`) = **lower** priority (more “polite”).  
Lower nice values (e.g., `-5`) = **higher** priority (less “polite”). Negative values may require `sudo`.

Start a nice process:
```bash
nice -n 10 sleep 200 &
```
Check niceness (NI column):
```bash
ps -o pid,ni,cmd -p $(pgrep -n sleep)
```
Change niceness of a running process to be **more polite** (higher number):
```bash
renice +15 -p <PID>
ps -o pid,ni,cmd -p <PID>
```
> To set a **negative** niceness (higher priority), you typically need `sudo`.

Stop leftover sleep processes:
```bash
pkill sleep
```

---

## 6) Practice tasks (do them now)

1) Start `sleep 180 &`. Then show your jobs, bring it to the foreground, suspend it, and resume it in the background.  
2) Use `pgrep sleep` to find the PID and then terminate the process **politely**. Verify it’s gone.  
3) Launch a “polite” (low-priority) task with `nice` and confirm the NI column shows the expected value.  
4) Open `top`, press `P` to sort by CPU and `M` to sort by memory. Quit `top`.  

**Hints:**
```bash
sleep 180 &; jobs; fg %1;  # then Ctrl+Z
bg %1; jobs
pgrep sleep; kill 15 <PID>; pgrep sleep || echo "done"
nice -n 10 sleep 120 &; ps -o pid,ni,cmd -p $(pgrep -n sleep)
top  # then P, M, q
```

---

## Troubleshooting

**Q: I lost my job number. How do I get the PID?**  
A: Use `pgrep <name>` (e.g., `pgrep sleep`). Then use `kill` with the PID.

**Q: `kill` didn’t stop the process.**  
A: Try `kill 15 <PID>` again, wait a moment, then `kill -9 <PID>` as a last resort.

**Q: I see “Operation not permitted” with `renice`.**  
A: Negative nice values (higher priority) generally require `sudo`. Increasing the niceness (e.g., `+10`, `+15`) is allowed.

**Q: `top` won’t exit.**  
A: Press `q` to quit `top`.

---

## Quick Quiz (1 minute)
- What command shows an updating, real-time view of processes?  
- Which key in `top` sorts by CPU usage?  
- How do you start a command in the background?  
- How do you bring job `%1` to the foreground?  
- What’s the difference between `kill 15 <PID>` and `kill -9 <PID>`?

**Answers:** `top`; `P`; add `&` at the end; `fg %1`; `15` asks nicely, `-9` forces.

---

## Next Step
Continue to **Step 5 — Permissions & Ownership** to learn how to read and change file permissions and ownership safely.
