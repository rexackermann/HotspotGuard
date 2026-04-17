# HotspotGuard

> **Extend your phone's ad-blocker to every device on your hotspot.**

A Magisk/KernelSU module that makes your existing ad-blocker (like [AdAway](https://adaway.org/), [Re-Malwack](https://github.com/user/Re-Malwack), or any hosts-file based blocker) work seamlessly across your Android hotspot — blocking ads, trackers, and bandwidth-hogging services for **all connected clients**.

## The Problem

You share your mobile data via hotspot, and your friends or family burn through your bandwidth watching Instagram Reels, TikTok, and YouTube Shorts. Your phone has ad-blocking via AdAway or Re-Malwack, but **none of that filtering reaches the devices connected to your hotspot**. They get raw, unfiltered internet — full of ads and infinite-scroll content that eats your data plan alive.

Android's tethering system uses its own internal DNS proxy that completely ignores your phone's hosts file. Even with root, the hotspot clients bypass all your carefully configured blocking.

## The Solution

HotspotGuard intercepts DNS queries from hotspot clients and routes them through a filtered DNS proxy (`dnsmasq`) that reads your phone's hosts file — the same one your ad-blocker manages. It also:

- **Removes Android's competing DNS proxy rules** that would bypass the filter
- **Flushes connection tracking** so existing connections get re-evaluated
- **Blocks IPv6 DNS leakage** on Mobile Data (forces IPv4 fallback where filtering works)

The result: every device on your hotspot gets the same ad & site blocking your phone has.

## Features

- 🛡️ **Extends AdAway / Re-Malwack / any hosts-based blocker** to all hotspot clients
- 🚫 **Block bandwidth-wasting services** (Reels, TikTok, etc.) via custom blocklist
- 🔄 **Toggle on/off** via KernelSU/Magisk Action button or terminal (`su -c hguard`)
- 📊 **Live status** on the module card (`[ACTIVE 🚀]` / `[INACTIVE 💤]`)
- 🌐 **IPv6 DNS leak protection** — prevents bypass on Mobile Data
- ⚡ **Conntrack-aware** — actively fights Android's tethering DNS proxy
- 📋 **Debug logging** at `/data/adb/modules/hotspot_blocker_ksu/service.log`

## Requirements

- Rooted Android device (Magisk or KernelSU)
- Native `dnsmasq` binary (present on most Android devices)
- A hosts-file based ad-blocker (AdAway, Re-Malwack, etc.) — optional but recommended

## Compatibility

- ✅ **Tested on Android 15**
- Should work on Android 10+ with root (Magisk/KernelSU)
- Requires native `dnsmasq` (check with `which dnsmasq` or look in `/apex/com.android.tethering/bin/`)

## Installation

1. Download the latest `hotspot_blocker_ksu.zip` from [Releases](../../releases)
2. Flash via KernelSU or Magisk Manager
3. Reboot
4. That's it — your hotspot clients are now filtered

## Usage

### Toggle via Manager
Tap the **Action** button on the module card in KernelSU/Magisk Manager.

### Toggle via Terminal
```bash
su -c hguard
```

### Check Status
```bash
cat /data/adb/hotspot_blocker_status   # 1 = ON, 0 = OFF
cat /data/adb/modules/hotspot_blocker_ksu/service.log
```

## Extending Your Ad-Blocker to Hotspot

HotspotGuard automatically reads `/system/etc/hosts`, which is the file managed by most hosts-based ad-blockers:

| Ad-Blocker | How it works with HotspotGuard |
|---|---|
| **AdAway** | AdAway modifies `/system/etc/hosts`. HotspotGuard picks it up automatically. |
| **Re-Malwack** | Re-Malwack maintains a comprehensive hosts file. HotspotGuard uses it seamlessly. |
| **Others** | Any module that writes to `/system/etc/hosts` will work out of the box. |

No extra configuration needed — if your phone blocks it, your hotspot clients block it too.

## Custom Blocklist (Bandwidth Saving)

Want to stop people from burning through your data on Reels and short-form video? Edit the blocklist:

```bash
# /data/adb/modules/hotspot_blocker_ksu/blocklist.txt
# Hosts-file format: block Instagram Reels, TikTok, YouTube Shorts, etc.

0.0.0.0 i.instagram.com
0.0.0.0 scontent.cdninstagram.com
0.0.0.0 www.tiktok.com
0.0.0.0 v16-webapp.tiktok.com
0.0.0.0 shorts.youtube.com
```

This is perfect for situations where you're sharing your limited mobile data and don't want it wasted on infinite-scroll content.

## How It Works (Technical)

1. Starts `dnsmasq` on port 5354 with your phone's hosts file as a blocklist
2. Inserts an `iptables` REDIRECT rule at the top of PREROUTING to intercept all DNS (UDP 53)
3. Deletes Android's built-in tethering DNAT rules that would bypass our filter
4. Flushes DNS conntrack entries so existing connections get re-evaluated
5. Blocks IPv6 DNS forwarding to prevent leak/bypass on Mobile Data
6. Re-enforces all rules every 10 seconds to survive hotspot toggles

## Building

```bash
make        # Creates hotspot_blocker_ksu.zip
make clean  # Removes the zip
```

## License

MIT
