# Step 6 — System Info & Monitoring (Ubuntu 24)

> **Type along** exactly as shown. Safe to run on your machine; nothing here makes persistent config changes (a few optional installs use `apt`).  
> **Estimated time:** ~15–20 minutes

---

## What you’ll learn
- Identify OS, kernel, uptime, and hardware at a glance
- Inspect **CPU**, **memory**, **disks/partitions**, and **network**
- Watch processes and system load with `top`/`htop`, `ps`, and `vmstat`
- Check running **services** with `systemd` (`systemctl`) and view **logs** (`journalctl`)
- Measure disk/CPU/IO hot spots with `iostat`, `pidstat`, `iotop`
- Run a quick “health sweep” to triage performance issues

> **Setup:** Use your lab folder:
> ```bash
> mkdir -p ~/playground && cd ~/playground
> ```

---

## 0) Snapshot: who, what, where
Start with the fastest high‑level checks.
```bash
whoami
hostnamectl          # hostname, OS, kernel
uname -rsm           # kernel: release + machine arch
cat /etc/os-release  # distro details
uptime -p            # human-friendly uptime
uptime               # load averages (1/5/15 min)
date                 # current time (TZ matters!)
```

> **Load average rule of thumb:** On a 4‑core machine, a 1‑minute load of ~4 means “fully busy”; much higher means queued work.

---

## 1) CPU & memory
### CPU facts
```bash
lscpu                 # sockets, cores, threads, flags
nproc                 # logical CPU count
cat /proc/cpuinfo | grep -m1 'model name'
```

### Memory / swap
```bash
free -h               # Mem/Swap usage (human units)
vmstat -s | head -20  # memory counters summary
swapon --show         # active swap areas
cat /proc/meminfo | sed -n '1,10p'
```

> **Tip:** High `si/so` (swap‑in/out) in `vmstat 1` output usually correlates with memory pressure.

---

## 2) Processes, load, and scheduling
### `top` basics (built‑in)
```bash
top
```
Useful keys inside **top**:
- `1`: show per‑CPU cores
- `M`: sort by memory; `P`: sort by CPU; `T`: by time
- `k`: kill a process (enter PID, then signal like `15`)
- `Shift+E`: change units (KiB/MiB)
- `q`: quit

### `htop` (nicer UI)
```bash
sudo apt update && sudo apt install -y htop
htop
```

### Point-in-time listings with `ps`
```bash
ps aux --sort=-%cpu | head -15
ps aux --sort=-%mem | head -15
pstree -a | head -40 || echo 'Install: sudo apt install -y psmisc'
```

### Niceness & signals (be careful)
```bash
nice -n 10 sleep 60 &                   # start lower priority
pid=$!
renice +5 -p "$pid"                    # increase niceness (lower priority)
kill -15 "$pid"                        # graceful
# kill -9 "$pid"  # last resort (commented)
```

---

## 3) Disks, partitions, and filesystem usage
### Layout & mounts
```bash
lsblk -f               # devices, filesystems, labels
mount | column -t | head -20
findmnt -t ext4,xfs    # mounted FS by type
```

### Space usage
```bash
df -hT                 # size, used, type per mount
# top 20 heavy dirs under /
sudo du -xh / | sort -h | tail -20
# top 10 heavy dirs under /var (faster)
sudo du -h -d1 /var | sort -h | tail -10
# inode pressure
df -i
```

> **When a disk looks full but `df -h` shows space free:** check **inodes** with `df -i`. Lots of tiny files can exhaust inodes.

### Disk performance (optional)
```bash
sudo apt install -y sysstat iotop
# per-disk stats, queue, utilization
iostat -xz 1 3
# per-process IO (press 'o' to filter active)
sudo iotop -oPa
```

---

## 4) Network quick checks
```bash
ip -br a              # brief addresses
ip r                  # routing table
hostname -I           # IPs only
resolvectl status | sed -n '1,40p'   # DNS view
```
Listening ports and sockets:
```bash
ss -tulpn | head -30  # TCP/UDP listeners with PIDs
ss -s                 # socket summary
```
Connectivity basics:
```bash
ping -c 3 8.8.8.8
ping -c 3 google.com
sudo apt install -y mtr-tiny dnsutils
mtr -rwbzc 50 google.com   # quick route quality report
dig +short google.com
curl -I https://example.com
```

> **If DNS is flaky:** try `dig @1.1.1.1 example.com` to bypass local resolvers.

---

## 5) Services with systemd
List running services and check status:
```bash
systemctl list-units --type=service --state=running | head -30
systemctl status ssh
systemctl is-enabled ssh
```
Restart a service (requires sudo):
```bash
sudo systemctl restart ssh
```
See boot performance & failures:
```bash
systemd-analyze time
systemd-analyze blame | head -20
systemctl --failed
```

---

## 6) Logs: journald and friends
Live/system logs:
```bash
journalctl -n 200 --no-pager             # last 200 lines
journalctl -f                            # follow
journalctl -p warning --since '1 hour ago'
```
Service-specific logs:
```bash
journalctl -u ssh --since 'today' --no-pager
```
Kernel messages and last boot:
```bash
journalctl -k --since '1 hour ago'
journalctl -b -1 --no-pager              # previous boot
```
Legacy file logs (some distros still write to these):
```bash
sudo tail -n 200 /var/log/syslog
sudo grep -i 'oom' /var/log/kern.log || true
```

> **Tip:** Use `-g PATTERN` to grep inside `journalctl`, e.g., `journalctl -g "Out of memory" -k`.

---

## 7) Resource pressure signals (advanced but handy)
Linux exposes PSI (Pressure Stall Information):
```bash
cat /proc/pressure/{cpu,io,memory}
```
If you see sustained **some**/**full** memory or IO pressure, correlate with `iostat`, `vmstat`, and logs (possible OOMs or slow disks).

OOM killer evidence:
```bash
journalctl -k -g 'Out of memory' --since '1 day ago'
dmesg -T | grep -i 'killed process' | tail -n 10
```

---

## 8) Quick health sweep (copy/paste)
Run this as a one‑shot collection for triage (prints to screen):
```bash
{ echo '=== SNAPSHOT ===';
  date; hostnamectl | sed -n '1,8p'; uname -rsm; uptime; echo;
  echo '=== CPU/MEM ==='; lscpu | sed -n '1,8p'; free -h; vmstat 1 3; echo;
  echo '=== DISK ==='; df -hT; iostat -xz 1 2 2>/dev/null || true; echo;
  echo '=== TOP PROCS ==='; ps aux --sort=-%cpu | head -10; ps aux --sort=-%mem | head -10; echo;
  echo '=== NET ==='; ip -br a; ss -tulpn | head -20; echo;
  echo '=== SERVICES ==='; systemctl --failed || true; systemd-analyze time || true; echo;
  echo '=== LOGS (last 50) ==='; journalctl -n 50 --no-pager;
} | sed 's/\x1b\[[0-9;]*m//g'
```
> **Note:** Some parts need packages (`sysstat`) or privileges; missing tools will be gracefully skipped.

---

## 9) Practice tasks (do these now)
1) Find your CPU core/thread count and current load.  
   *Hint:* `lscpu`, `uptime`, `top` (`1` key).
2) Identify the **top 5** memory‑hungry processes and the **top 5** CPU‑hungry processes.  
   *Hint:* `ps aux --sort=-%mem` / `--sort=-%cpu`.
3) Determine which directory under `/var` consumes the most space.  
   *Hint:* `sudo du -h -d1 /var | sort -h | tail -5`.
4) List all listening TCP sockets with owning PIDs.  
   *Hint:* `ss -tulpn`.
5) Check logs for **ssh** in the last hour and restart the service.  
   *Hint:* `journalctl -u ssh --since '1 hour ago'`, then `sudo systemctl restart ssh`.
6) (Optional) Install `sysstat` and run `iostat -xz 1 3`; identify any device >90% util.

---

## 10) Troubleshooting quick guide
- **High load avg with low CPU** → usually **IO wait** or many blocked procs. Check `iostat -xz`, `ps` with `STAT` column (`D` = uninterruptible IO sleep).
- **Memory spikes / OOM** → check `journalctl -k -g 'Out of memory'`, watch `free -h`, consider which process grew via `ps --sort=-rss`.
- **Disk full** → use `df -hT`; then `du` to find culprits; also check **inodes** (`df -i`).
- **Service down** → `systemctl status <svc>` then `_journalctl -u <svc>_` to see the why; look for ExecStart errors, missing ports.
- **No DNS resolution** → `resolvectl status`, try `dig @1.1.1.1 example.com`; if that works, local resolver is suspect.
- **Network seems fine but web fails** → check outbound firewall/proxy, test raw IP `curl -I http://1.1.1.1`.

---

## 11) Quick quiz (1 minute)
- What do the **three** numbers in `uptime` represent?  
- Which tool shows **per‑disk** queue and utilization quickly?  
- How do you list services that **failed** on boot?  
- One command to show **listening** sockets with PIDs?  
- Where do you look for **OOM killer** events?

**Answers:** 1/5/15‑min load avgs; `iostat -xz`; `systemctl --failed`; `ss -tulpn`; `journalctl -k -g 'Out of memory'` (or `dmesg`).

---

## Next Step
Proceed to **Step 7 — Users & Authentication** to manage local users, groups, passwords, and SSH hardening.

