<p align="center">
  <h1 align="center">🛡️ HotspotGuard</h1>
  <p align="center">
    <strong>Extend your phone's ad-blocker to every device on your hotspot.</strong>
  <p align="center">
    <img src="https://img.shields.io/badge/Security-Over Hotspot-green?style=for-the-badge&logo=shield" alt="Security">
    <img src="https://img.shields.io/badge/Platform-Android-brightgreen?style=for-the-badge&logo=android" alt="Android">
    <img src="https://img.shields.io/badge/Root-Magisk%20%7C%20KernelSU-orange?style=for-the-badge" alt="Root">
    <img src="https://img.shields.io/badge/License-MIT-blue?style=for-the-badge" alt="License">
    <img src="https://img.shields.io/badge/Version-2.0-purple?style=for-the-badge" alt="Version">
  </p>
</p>

---

## 😤 The Problem

You share your mobile data via hotspot, and your friends or family **burn through your bandwidth** watching Instagram Reels, TikTok, and YouTube Shorts — endlessly scrolling through your precious data plan.

Your phone has ad-blocking via AdAway or Re-Malwack, but **none of that filtering reaches the devices connected to your hotspot**. They get raw, unfiltered internet — full of ads, trackers, and infinite-scroll content that eats your data alive.

> 🤔 *Why?* Android's tethering system uses its own internal DNS proxy that **completely ignores** your phone's hosts file. Even with root, hotspot clients bypass all your carefully configured blocking.

---

## 💡 The Solution

**HotspotGuard** intercepts DNS queries from hotspot clients and routes them through a filtered DNS proxy that reads your phone's hosts file — the same one your ad-blocker manages.

```
📱 Your Phone (with AdAway/Re-Malwack)
 │
 ├── 🛡️ HotspotGuard (dnsmasq on port 5354)
 │    ├── 📋 /system/etc/hosts (your ad-blocker's blocklist)
 │    └── 📋 custom blocklist (Reels, TikTok, etc.)
 │
 ├── 📲 Client Device 1 ──► DNS intercepted ──► 🚫 Ads blocked!
 ├── 📲 Client Device 2 ──► DNS intercepted ──► 🚫 Reels blocked!
 └── 📲 Client Device 3 ──► DNS intercepted ──► 🚫 Trackers blocked!
```

---

## ✨ Features

| Feature | Description |
|---------|-------------|
| 🛡️ **Ad-Blocker Extension** | Extends AdAway / Re-Malwack / any hosts-based blocker to all hotspot clients |
| 🚫 **Bandwidth Saver** | Block Reels, TikTok, YouTube Shorts, and other data hogs via custom blocklist |
| 🔄 **One-Tap Toggle** | Turn on/off via KernelSU/Magisk Action button or `su -c hguard` |
| 📊 **Live Status** | Module card shows `[ACTIVE 🚀]` or `[INACTIVE 💤]` at a glance |
| 🌐 **IPv6 Leak Protection** | Blocks IPv6 DNS to prevent bypass on Mobile Data |
| ⚡ **Conntrack-Aware** | Actively fights Android's tethering DNS proxy to maintain control |
| 📋 **Debug Logging** | Full logs at `/data/adb/modules/hotspotguard/service.log` |
| 🔧 **Zero Config** | Works out of the box — just flash and reboot |

---

## 📦 Requirements

- 📱 Rooted Android device (**Magisk** or **KernelSU**)
- 🔧 Native `dnsmasq` binary (present on most Android devices)
- 🛡️ A hosts-file based ad-blocker (AdAway, Re-Malwack, etc.) — *optional but recommended*

---

## 🧪 Compatibility

| | Status |
|---|---|
| ✅ KernelSU | **Tested & Working** |
| 🟡 Magisk | Should work (requires native dnsmasq) |
| 🟡 Other root solutions | Untested, but likely compatible |

> 💡 **Tip:** Check if your device has dnsmasq: `which dnsmasq` or look in `/apex/com.android.tethering/bin/`

---

## 🚀 Installation

```bash
# 1. Download the latest HotspotGuard-v*.zip
# 2. Flash via KernelSU or Magisk Manager
# 3. Reboot
# 4. Done! Your hotspot clients are now filtered 🎉
```

---

## 🎮 Usage

### 🔘 Toggle via Manager
Tap the **Action** button on the module card in KernelSU/Magisk Manager.

### 💻 Toggle via Terminal
```bash
su -c hguard
```
```
****************************************
       HotspotGuard Control Center
****************************************
Status: [DISABLED] -> [ENABLING...]

[+] Hotspot protection is now ON.
[+] Firewall rules and DNS proxy starting.
****************************************
```

### 📊 Check Status
```bash
cat /data/adb/hotspotguard_status   # 1 = ON, 0 = OFF
cat /data/adb/modules/hotspotguard/service.log
```

---

## 🔗 Extending Your Ad-Blocker to Hotspot

HotspotGuard automatically reads `/system/etc/hosts`, which is the file managed by most hosts-based ad-blockers. **No extra configuration needed** — if your phone blocks it, your hotspot clients block it too.

| Ad-Blocker | Integration | Notes |
|---|---|---|
| 🟢 **AdAway** | ✅ Automatic | Modifies `/system/etc/hosts` — picked up instantly |
| 🟢 **Re-Malwack** | ✅ Automatic | Maintains a comprehensive hosts file — works seamlessly |
| 🟢 **Hosts-based blockers** | ✅ Automatic | Any module writing to `/system/etc/hosts` works out of the box |
| 🟡 **DNS-based blockers** | ⚠️ Manual | May need config adjustment if they don't use hosts file |

---

## 🚫 Custom Blocklist (Bandwidth Saving)

> *"My roommate burned 2GB in one hour watching Reels on my hotspot."*
>
> — Every hotspot owner, ever. 😭

Stop people from devouring your data on infinite-scroll content. Edit the blocklist:

```bash
# 📄 /data/adb/modules/hotspotguard/blocklist.txt
# Format: 0.0.0.0 <domain>

# 📸 Instagram Reels
0.0.0.0 i.instagram.com
0.0.0.0 scontent.cdninstagram.com

# 🎵 TikTok
0.0.0.0 www.tiktok.com
0.0.0.0 v16-webapp.tiktok.com

# ▶️ YouTube Shorts
0.0.0.0 shorts.youtube.com
```

---

## ⚙️ How It Works (Under the Hood)

```
1. 🔧 Starts dnsmasq on port 5354 with your hosts file
2. 🔀 Inserts iptables REDIRECT at top of PREROUTING (UDP 53 → 5354)
3. 🗑️ Deletes Android's built-in tethering DNAT rules
4. 🔄 Flushes DNS conntrack entries (forces re-evaluation)
5. 🌐 Blocks IPv6 DNS forwarding (prevents Mobile Data bypass)
6. ♻️ Re-enforces all rules every 10 seconds
```

---

## 🔨 Building from Source

```bash
make        # 📦 Creates HotspotGuard-v<version>.zip
make clean  # 🧹 Removes the zip
```

---

## 📄 License

This project is licensed under the **MIT License** — see the [LICENSE](LICENSE) file for details.

---

<p align="center">
  Made with ❤️ by <strong>Rex</strong>
</p>
<p align="center">
  <em>Because your data plan deserves better than someone else's Reels addiction.</em> 😤📵
</p>
