# Changelog

## v2.0 (Stable Release)
- **First Stable Release**: Fully tested and optimized DNS interception module allowing AdAway and Re-Malwack blocking to propagate seamlessly over tethering.
- Guaranteed compatibility with Android 10-15 via KernelSU and Magisk.
- Hardware offload and DNAT caching bypasses officially resolved via aggressive flushing intervals.

## v1.8
- **Massive Filtering Upgrade**: Replaced hardware-specific network target with a unified drop-flush system. Now intercepts connections across all possible tethering hardware interfaces (WLAN, ccmni, ap0, rndis).
- Extends phone-level hosts blocking (AdAway / Re-Malwack) natively to hotspot clients.
- Prevents bypasses by purging Android's internal DNS conntrack caching every 10 seconds.
- Integrated IPv6 gateway disabling for hotspot clients.
- Brand new HotspotGuard design and naming format.
