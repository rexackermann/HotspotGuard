# Changelog

## v1.8 (Latest)
- **Massive Filtering Upgrade**: Replaced hardware-specific network target with a unified drop-flush system. Now intercepts connections across all possible tethering hardware interfaces (WLAN, ccmni, ap0, rndis).
- Extends phone-level hosts blocking (AdAway / Re-Malwack) natively to hotspot clients.
- Prevents bypasses by purging Android's internal DNS conntrack caching every 10 seconds.
- Integrated IPv6 gateway disabling for hotspot clients.
- Brand new HotspotGuard design and naming format.
