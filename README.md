# TetherShield

A Magisk/KernelSU module that blocks ads and custom domains for devices connected to your Android hotspot using native `dnsmasq` DNS filtering.

## Features

- 🚀 **DNS-based ad & site blocking** for all hotspot clients
- 🔄 **Toggle on/off** via KernelSU/Magisk Action Button or terminal (`su -c hsblock`)
- 📊 **Live status** shown on the module card (`[ACTIVE 🚀]` / `[INACTIVE 💤]`)
- 🛡️ **IPv6 DNS leak protection** — forces clients to use filtered IPv4 DNS
- ⚡ **Conntrack-aware** — actively removes Android's competing DNS rules
- 📋 **Debug logging** at `/data/adb/modules/hotspot_blocker_ksu/service.log`

## How It Works

1. Starts a `dnsmasq` DNS proxy on port 5354 using the system hosts file and a custom blocklist
2. Redirects all hotspot client DNS queries (UDP port 53) to our filtered proxy via `iptables`
3. Removes Android's built-in tethering DNS proxy rules that would bypass our filter
4. Flushes conntrack entries to ensure all DNS connections use our proxy
5. Blocks IPv6 DNS to prevent leak/bypass on Mobile Data

## Requirements

- Rooted Android device (Magisk or KernelSU)
- Native `dnsmasq` binary (present on most Android devices)

## Installation

1. Download the latest `hotspot_blocker_ksu.zip` from [Releases](../../releases)
2. Flash via KernelSU or Magisk Manager
3. Reboot

## Usage

### Toggle via Manager
Tap the **Action** button on the module card in KernelSU/Magisk Manager.

### Toggle via Terminal
```bash
su -c hsblock
```

### Check Status
```bash
cat /data/adb/hotspot_blocker_status   # 1 = ON, 0 = OFF
cat /data/adb/modules/hotspot_blocker_ksu/service.log
```

## Custom Blocklist

Edit `/data/adb/modules/hotspot_blocker_ksu/blocklist.txt` with hosts-file format entries:

```
0.0.0.0 ads.example.com
0.0.0.0 tracker.example.com
```

## Building

```bash
make        # Creates hotspot_blocker_ksu.zip
make clean  # Removes the zip
```

## License

MIT
