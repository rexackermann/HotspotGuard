#!/system/bin/sh
# TetherShield Service Script
MODDIR=${0%/*}
STATUS_FILE="/data/adb/hotspot_blocker_status"
DNSMASQ_CONF="$MODDIR/dnsmasq.conf"
PID_FILE="$MODDIR/dnsmasq.pid"
LOG_FILE="$MODDIR/service.log"

# Function for clean logging
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# Clear old log
echo "--- Service Started ---" > "$LOG_FILE"

# Wait for boot
until [ "$(getprop sys.boot_completed)" = "1" ]; do
    sleep 5
done
sleep 5

# Locate native dnsmasq
DNSMASQ_BIN=""
for path in $(command -v dnsmasq) /system/bin/dnsmasq /apex/com.android.tethering/bin/dnsmasq; do
    if [ -x "$path" ]; then
        DNSMASQ_BIN="$path"
        break
    fi
done

if [ -z "$DNSMASQ_BIN" ]; then
    log "FATAL: dnsmasq binary not found"
    exit 1
fi

apply_rules() {
    # 1. Ensure dnsmasq proxy is running
    PID=""
    [ -f "$PID_FILE" ] && PID=$(cat "$PID_FILE")
    if [ -z "$PID" ] || ! kill -0 "$PID" 2>/dev/null; then
        log "Starting dnsmasq..."
        $DNSMASQ_BIN --conf-file="$DNSMASQ_CONF" --pid-file="$PID_FILE" 2>> "$LOG_FILE" &
    fi

    # 2. Aggressive IPv4 Redirection (port 5354 to avoid mdnsd conflict)
    iptables -t nat -D PREROUTING -p udp --dport 53 -j REDIRECT --to-ports 5354 2>/dev/null
    iptables -t nat -I PREROUTING -p udp --dport 53 -j REDIRECT --to-ports 5354 2>> "$LOG_FILE"

    # 3. Delete Android's competing DNAT rules for hotspot DNS
    # These point to Android's internal DNS proxy and steal our traffic via conntrack
    iptables-save -t nat 2>/dev/null | grep -E "\-A PREROUTING.*ap[0-9].*dport 53.*DNAT" | while IFS= read -r line; do
        rule=$(echo "$line" | sed 's/^-A /-D /')
        iptables -t nat $rule 2>/dev/null
    done

    # 4. Flush DNS conntrack entries so existing connections get re-evaluated
    conntrack -D -p udp --dport 53 2>/dev/null
    conntrack -D -p tcp --dport 53 2>/dev/null

    # 5. Block IPv6 DNS only (not all IPv6 traffic)
    for chain in FORWARD tetherctrl_FORWARD; do
        if ip6tables -S "$chain" 2>/dev/null >/dev/null; then
            ip6tables -D "$chain" -p udp --dport 53 -j DROP 2>/dev/null
            ip6tables -I "$chain" -p udp --dport 53 -j DROP 2>> "$LOG_FILE"
            ip6tables -D "$chain" -p tcp --dport 53 -j DROP 2>/dev/null
            ip6tables -I "$chain" -p tcp --dport 53 -j DROP 2>> "$LOG_FILE"
        fi
    done
}

remove_rules() {
    log "Stopping services and flushing rules..."
    # Kill the custom dnsmasq instance
    if [ -f "$PID_FILE" ]; then
        PID=$(cat "$PID_FILE")
        kill -9 "$PID" 2>/dev/null
        rm -f "$PID_FILE"
    fi
    
    # Clean up rules
    iptables -t nat -D PREROUTING -p udp --dport 53 -j REDIRECT --to-ports 5354 2>/dev/null
    for chain in FORWARD tetherctrl_FORWARD; do
        ip6tables -D "$chain" -p udp --dport 53 -j DROP 2>/dev/null
        ip6tables -D "$chain" -p tcp --dport 53 -j DROP 2>/dev/null
    done
}


# Initial status setup
[ -f "$STATUS_FILE" ] || echo "1" > "$STATUS_FILE"

# Sync UI description
ENABLED_BOOT=$(cat "$STATUS_FILE")
STATUS_UI="[ACTIVE 🚀]"
[ "$ENABLED_BOOT" = "0" ] && STATUS_UI="[INACTIVE 💤]"
BASE_DESC="TetherShield — DNS-based ad & site blocking for hotspot clients."
sed -i "s/^description=.*/description=$STATUS_UI $BASE_DESC/" "$MODDIR/module.prop"

# Main enforcement loop
while true; do
    ENABLED=$(cat "$STATUS_FILE")
    if [ "$ENABLED" = "1" ]; then
        apply_rules
    else
        remove_rules
    fi
    sleep 10
done
