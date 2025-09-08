# Step 7 — Networking Basics (Ubuntu 24)

> **Type along** exactly as shown. These are safe, read‑mostly commands. Optional tools will prompt for `sudo apt install`.  
> **Estimated time:** ~20–25 minutes

---

## What you’ll learn
- Read your **IP configuration**, MAC, and default route
- Test connectivity at each layer: **link → IP → DNS → TCP/UDP → app**
- Inspect **listening ports** and active connections with `ss`
- Use **DNS tools** (`resolvectl`, `dig`) effectively
- Trace paths and check packet loss with **`mtr`/`traceroute`**
- Do quick HTTP checks with **`curl`** and simple servers (Python, `nc`)
- (Optional) Basics of **firewall** (`ufw`) and **packet capture** (`tcpdump`)

> **Setup:** Use your lab folder:
> ```bash
> mkdir -p ~/playground && cd ~/playground
> ```

---

## 0) A quick model: test from low → high
1) **Link up?** (interface present, carrier)  
2) **IP/route OK?** (address/gateway)  
3) **DNS OK?** (names resolve)  
4) **Transport OK?** (TCP/UDP reach port)  
5) **App OK?** (HTTP responds, SSH banner, etc.)

You’ll follow this order every time; it prevents wild goose chases.

---

## 1) Interfaces & addresses
### See links and addresses
```bash
ip -br link            # link names + state (brief)
ip -br a               # addresses (IPv4/IPv6) per interface
hostname -I            # IPs only (no names)
```
Show details for your primary interface (replace `eth0`/`ens3`/`enp0s3` with yours):
```bash
ip addr show enp0s3 | sed -n '1,30p'
```

### MAC address & media info (optional)
```bash
sudo apt update && sudo apt install -y ethtool
sudo ethtool -P enp0s3   # permanent MAC
sudo ethtool enp0s3 | sed -n '1,25p'  # speed/duplex/link
```

> **Tip:** Interface names vary across platforms (e.g., `wlp3s0` for Wi‑Fi). Use `ip -br link` to discover yours.

---

## 2) Routing: where packets go
Show routes and default gateway:
```bash
ip route
ip r get 8.8.8.8       # which interface/gateway would handle this dest?
```
See neighbors/ARP cache:
```bash
ip neigh | head -10
```

> **Rule of thumb:** If `ip r get 8.8.8.8` errors or returns the wrong interface, your default route or subnet mask is wrong.

---

## 3) How you got an IP: DHCP or static (read‑only)
### On servers (systemd‑networkd)
```bash
networkctl
networkctl status -a | sed -n '1,80p'
```
### On desktops (NetworkManager)
```bash
nmcli device status
nmcli device show enp0s3 | sed -n '1,80p'
```
View netplan config (do **not** edit during the lab):
```bash
sudo ls /etc/netplan/
sudo sed -n '1,120p' /etc/netplan/*.yaml 2>/dev/null || true
```

---

## 4) Connectivity tests
### Ping (ICMP)
```bash
ping -c 3 1.1.1.1         # raw IP – tests routing only
ping -c 3 google.com      # adds DNS to the chain
ping -6 -c 3 google.com   # IPv6, if available
```
If ping to hostname fails but IP works, it’s a **DNS** issue, not routing.

### Trace the path (prefer `mtr`)
```bash
sudo apt install -y mtr-tiny
mtr -rwbzc 50 8.8.8.8     # summarize 50 pings across the route
mtr -rwbzc 50 google.com  # includes DNS + any CDN hops
```

---

## 5) Name resolution like a pro
### System view (resolvectl)
```bash
resolvectl status | sed -n '1,80p'
resolvectl query example.com
```
### Query types with `dig`
```bash
sudo apt install -y dnsutils
# A/AAAA
dig +short A example.com
dig +short AAAA example.com
# MX/NS/CNAME
dig +short MX example.com
dig +short NS example.com
# Bypass local DNS to test upstream directly
dig @1.1.1.1 +short A example.com
```
Hosts database (rare but handy):
```bash
getent hosts localhost example.com | sed -n '1,10p'
```

---

## 6) Sockets & ports: who’s listening?
List listeners by protocol with owning PIDs:
```bash
ss -tulpn | head -30     # TCP/UDP listeners
ss -s                    # socket summary
```
Filter for a specific port/service:
```bash
ss -tlpn 'sport = :22'   # who owns TCP port 22
```

### Mini lab: create a test port and connect
Start a listener (background):
```bash
nc -lv 127.0.0.1 9000 & echo $! > /tmp/nc9000.pid
sleep 1
ss -tlpn 'sport = :9000'
```
Connect to it:
```bash
printf 'hello from client\n' | nc -v 127.0.0.1 9000
```
Clean up:
```bash
kill "$(cat /tmp/nc9000.pid)" 2>/dev/null || true
rm -f /tmp/nc9000.pid
```

> **Why this matters:** When an app “won’t start,” check whether the port is already taken (`ss -tulpn`).

---

## 7) Quick HTTP checks
Spin up a tiny web server (Python 3’s stdlib):
```bash
python3 -m http.server 8080 --bind 127.0.0.1 & echo $! > /tmp/http8080.pid
sleep 1
ss -tlpn 'sport = :8080'
```
Probe it with `curl`:
```bash
curl -I http://127.0.0.1:8080/
```
Stop the server:
```bash
kill "$(cat /tmp/http8080.pid)" 2>/dev/null || true
rm -f /tmp/http8080.pid
```

> **TLS tip:** To inspect certificates/handshakes: `openssl s_client -connect example.com:443 -servername example.com -brief`.

---

## 8) Firewalls (optional, lab VM only)
Ubuntu ships **UFW** as a front‑end to `nftables`.
```bash
sudo ufw status verbose
```
Allow a temporary lab port and verify:
```bash
sudo ufw allow 8080/tcp
sudo ufw status numbered
ss -tlpn 'sport = :8080'
# cleanup
sudo ufw delete allow 8080/tcp
```
> **Caution:** Don’t enable/alter firewalls on production hosts without change control. In the lab it’s fine.

---

## 9) Packet capture (optional but powerful)
```bash
sudo apt install -y tcpdump
# watch ICMP for a few packets
sudo tcpdump -n -c 5 icmp
# capture just port 8080 traffic (run while your test server is up)
sudo tcpdump -n -i any 'tcp port 8080' -c 10
```
> **Privacy note:** Packet captures can include sensitive data. Only capture on systems and networks you own or have permission to test.

---

## 10) Common gotchas & fixes
- **No network**: `ip -br link` shows `DOWN` → `sudo ip link set enp0s3 up` (or ensure VM NIC attached).  
- **Can ping IP but not hostname**: DNS issue → `resolvectl status`, `dig @1.1.1.1 example.com`.  
- **Service won’t bind**: Port already in use → `ss -tulpn | grep :PORT`, stop the conflicting process.  
- **Intermittent timeouts**: Check path with `mtr`; look for loss on the last 2–3 hops; also check host load (`top`) and disk (`iostat -xz`).  
- **Works locally, not remotely**: Local firewall/NAT/security groups. Verify `ufw`, cloud SGs, and that service binds to the **right address** (0.0.0.0 vs 127.0.0.1).

---

## 11) Practice tasks (do these now)
1) Identify your **primary interface**, IPv4/IPv6 addresses, and default gateway.  
   *Hint:* `ip -br a`, `ip route`.
2) Show the exact route used to reach **1.1.1.1** and **google.com**.  
   *Hint:* `ip r get`, `mtr -rwbc 30`.
3) Resolve `example.com` to A and AAAA records using **your** resolver and **1.1.1.1**.  
   *Hint:* `dig +short`, `dig @1.1.1.1`.
4) Start the Python HTTP server on port **8080**, verify with `ss` and `curl`, then stop it.  
5) Create a local TCP listener on **9000** with `nc`, send a line of text from a client, confirm it appears, and clean up.  
6) (Optional) Add a temporary UFW rule for **8080/tcp**, verify access, then remove it.

---

## 12) Quick quiz (1 minute)
- Which command shows **listening sockets with PIDs**?  
- Which tool gives you **route plus packet loss** over time?  
- Name two commands to test **DNS** quickly.  
- If a hostname fails but an IP succeeds, which layer is broken?  
- What does `ip r get 8.8.8.8` tell you?

**Answers:** `ss -tulpn`; `mtr` (or `traceroute` for path only); `resolvectl`, `dig` (also `getent hosts`); DNS; which interface/gateway will carry traffic to that destination.

---

## Next Step
Proceed to **Step 8 — Users & Authentication** (local users, groups, passwords, SSH basics). If your curriculum orders topics differently, adjust the previous step’s “Next Step” pointer to match this page.

