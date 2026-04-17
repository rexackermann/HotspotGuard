#!/system/bin/sh
# HotspotGuard Action Script for Magisk/KSU
MODDIR=${0%/*}
STATUS_FILE="/data/adb/hotspotguard_status"
PROP_FILE="$MODDIR/module.prop"

# Initialize if not exists
[ -f "$STATUS_FILE" ] || echo "1" > "$STATUS_FILE"

CURRENT=$(cat "$STATUS_FILE")

update_ui() {
    local state="$1" # "1" or "0"
    local status_msg="[ACTIVE 🚀]"
    [ "$state" = "0" ] && status_msg="[INACTIVE 💤]"
    
    local base_desc="HotspotGuard — DNS-based ad & site blocking for hotspot clients."
    sed -i "s/^description=.*/description=$status_msg $base_desc/" "$PROP_FILE"
}

echo "****************************************"
echo "       HotspotGuard Control Center        "
echo "****************************************"

if [ "$CURRENT" = "1" ]; then
    echo "0" > "$STATUS_FILE"
    update_ui "0"
    echo "Status: [ENABLED] -> [DISABLING...]"
    echo ""
    echo "[-] Hotspot protection is now OFF."
    echo "[-] Rules will be flushed immediately."
else
    echo "1" > "$STATUS_FILE"
    update_ui "1"
    echo "Status: [DISABLED] -> [ENABLING...]"
    echo ""
    echo "[+] Hotspot protection is now ON."
    echo "[+] Firewall rules and DNS proxy starting."
fi

echo "****************************************"
