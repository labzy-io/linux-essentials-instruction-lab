# Step 9 — Package Management (Ubuntu 24)

> **Type along** exactly as shown. Focuses on APT (Debian/Ubuntu). Optional bits cover `snap` and `flatpak`.  
> **Estimated time:** ~25–30 minutes

---

## What you’ll learn
- Discover, install, remove, and upgrade software with **APT**
- Inspect package **metadata**, **versions**, **deps**, and **files**
- Roll back to a **specific version**, **hold** packages, and clean cache
- Diagnose broken packages and locks; read APT/DPKG **logs**
- (Optional) Add third‑party **repositories** safely with modern **keyrings**
- (Optional) Use **snap** and **flatpak** where appropriate

> **Setup:** Use a lab VM or a machine where you can install harmless utilities like `cowsay`, `sl`, `tree`. Production hosts should follow change control.

---

## 0) Refresh indexes & basic system hygiene
```bash
sudo apt update                    # refresh package lists
apt list --upgradable              # see pending upgrades (no sudo needed)
sudo apt upgrade -y                # safe upgrade of installed packages
sudo apt autoremove -y             # remove unused deps
sudo apt clean                     # drop cached .deb files
```
> **Tip:** Use `sudo apt full-upgrade` (aka `dist-upgrade`) to allow kernel or dependency changes that add/remove packages.

---

## 1) Find packages
Search by name/description:
```bash
apt search htop | sed -n '1,20p'         # quick text search
```
Show detailed metadata:
```bash
apt show htop | sed -n '1,40p'
```
See available versions & repository **origin**:
```bash
apt policy htop
```
List reverse deps (who depends on whom):
```bash
apt-cache rdepends --installed bash | sed -n '1,20p'
```

---

## 2) Install & remove packages
Install with confirmation and see what else will be pulled in:
```bash
sudo apt install -y htop tree
```
Remove software but keep config files:
```bash
sudo apt remove -y tree
```
Remove **and** purge config files:
```bash
sudo apt purge -y tree
```

### Verify installation contents
Which files did a package install?
```bash
dpkg -L htop | sed -n '1,40p'    # list files owned by installed package
```
Which package owns a file path?
```bash
dpkg -S /usr/bin/htop
```
Find package **for an uninstalled** file path (requires apt-file):
```bash
sudo apt install -y apt-file
sudo apt-file update
apt-file search bin/ncdu | head -10
```

---

## 3) Versions: pin, hold, and roll back
See available versions across repos:
```bash
apt policy openssh-server
```
Install a **specific version**:
```bash
sudo apt install openssh-server=1:9.6p1-3ubuntu13    # example; use a version shown by `apt policy`
```
Temporarily **hold** at current version (don’t upgrade):
```bash
sudo apt-mark hold openssh-server
apt-mark showhold
# later, unhold
sudo apt-mark unhold openssh-server
```

### Advanced: pin priority (optional)
Create a pin to prefer Ubuntu main over a PPA for a package (edit safely):
```bash
sudo mkdir -p /etc/apt/preferences.d
sudo tee /etc/apt/preferences.d/openssh.pref >/dev/null <<'EOF'
Package: openssh-server
Pin: release a=noble
Pin-Priority: 600
EOF
```
> **Rules of thumb:** Priority >1000 forces downgrade if needed; 500 is default; 600 prefers that source.

---

## 4) Inspect dependencies & health
Show dependencies:
```bash
apt-cache depends htop | sed -n '1,40p'
```
Simulate an install (no changes):
```bash
sudo apt -s install ncdu
```
Check package status (installed?, config state):
```bash
dpkg -s htop | sed -n '1,40p'
```

---

## 5) Fix common issues
### Broken dependencies / interrupted dpkg
```bash
sudo dpkg --configure -a    # finish interrupted installs
sudo apt -f install         # attempt to fix broken deps
```
### Lock is held
If another process is using APT/DPKG (GUI updater, unattended‑upgrades):
```bash
ps aux | egrep 'apt|dpkg|unattended' | egrep -v 'egrep'
# Wait for it to finish or stop the offending process if safe.
```
### Stuck half‑installed package
```bash
sudo apt purge -y <packagename>
sudo apt install -y <packagename>
```
### Where to read logs
```bash
sudo tail -n 100 /var/log/apt/history.log
sudo tail -n 100 /var/log/dpkg.log
```

---

## 6) Repositories the **right** way (modern keyrings) — optional
> Avoid legacy `apt-key`. Use per‑repo **keyrings** and `signed-by=`.

Example: add a vendor repo safely (replace placeholders with a real vendor’s URLs):
```bash
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://vendor.example.com/keys/repo.gpg | \
  sudo gpg --dearmor -o /etc/apt/keyrings/vendor.gpg

# Add source list (adjust codename e.g., noble, jammy)
. /etc/os-release
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/vendor.gpg] \
https://vendor.example.com/apt $VERSION_CODENAME main" | \
  sudo tee /etc/apt/sources.list.d/vendor.list >/dev/null

sudo apt update
apt policy vendor-package-name
```
Remove the repo cleanly later:
```bash
sudo rm -f /etc/apt/sources.list.d/vendor.list /etc/apt/keyrings/vendor.gpg
sudo apt update
```

### PPAs (Launchpad) — optional
```bash
sudo apt install -y software-properties-common
sudo add-apt-repository -y ppa:graphics-drivers/ppa
sudo apt update
```
Remove:
```bash
sudo add-apt-repository -r ppa:graphics-drivers/ppa
sudo apt update
```

---

## 7) Kernel & reboot awareness
List kernels and check if a reboot is pending:
```bash
dpkg -l 'linux-image*' | sed -n '1,20p'
[ -f /var/run/reboot-required ] && echo 'Reboot required' || echo 'No reboot pending'
```

---

## 8) Snap & Flatpak (optional)
### Snap
```bash
snap list
snap find jq | head -10
sudo snap install jq
sudo snap remove jq
```
### Flatpak
```bash
sudo apt install -y flatpak
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak search org.gnome.Calculator | head -5
sudo flatpak install -y flathub org.gnome.Calculator
flatpak list
sudo flatpak uninstall -y org.gnome.Calculator
```
> **When to use:** Prefer APT for system packages; `snap/flatpak` for sandboxed desktop apps or when newer versions are only available there.

---

## 9) Cleanup & space management
```bash
sudo apt autoremove --purge -y
sudo apt clean
sudo du -h /var/cache/apt/archives | tail -1
```

---

## 10) Practice tasks (do these now)
1) **Search** for `ncdu`, inspect details (`apt show`), and install it.  
2) Use `dpkg -L ncdu` to list files; find which package owns `/usr/bin/ncdu` (`dpkg -S`).  
3) Install `jq` at a **specific version** if multiple are available (`apt policy`, then `apt install jq=…`).  
4) **Hold** `jq`, show holds, then **unhold** it.  
5) Install `apt-file`, search which package provides `bin/htop`.  
6) (Optional) Add a PPA, install a package from it, then remove the PPA and revert using pins or by installing the Ubuntu version.  
7) Read the last 50 lines of both APT and DPKG logs.

---

## 11) Troubleshooting quick guide
- **Broken deps** → `sudo dpkg --configure -a`, `sudo apt -f install`, then inspect `/var/log/apt/history.log`.
- **Held or pinned versions** blocking upgrades → check `apt-mark showhold`, and files under `/etc/apt/preferences.d`.
- **Repo GPG errors** → ensure you used keyrings + `signed-by=…`; check permissions on `/etc/apt/keyrings/*.gpg` (0644).
- **“Package not found”** → verify `apt update`, correct **codename** in source (`noble`, `jammy`), and architecture matches.
- **Lock files busy** → another process is running (`unattended-upgrades`, GUI), or left stale lock after crash. Confirm with `ps` and wait/kill cautiously.

---

## 12) Quick quiz (1 minute)
- Which command shows all **available versions** for a package and where they come from?  
- What’s the difference between `remove` and `purge`?  
- How do you **prevent** a package from upgrading?  
- Which logs help you reconstruct what APT did recently?  
- Why is `apt-key` deprecated and what should you use instead?

**Answers:** `apt policy`; `remove` keeps config files, `purge` deletes them; `apt-mark hold` (and pins for repo preference); `/var/log/apt/history.log` and `/var/log/dpkg.log`; use per‑repo **keyrings** with `signed-by=`.

---

## Next Step
Proceed to **Step 10 — Users & Authentication** (local users, groups, passwords, SSH basics). If your curriculum orders differ, update the previous step’s “Next Step” pointers accordingly.

