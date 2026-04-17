#!/system/bin/sh
ui_print "- Checking for built-in dnsmasq..."
if ! command -v dnsmasq >/dev/null 2>&1 && [ ! -x "/system/bin/dnsmasq" ]; then
    ui_print "*********************************************************"
    ui_print "! WARNING: dnsmasq was not found in your system path!   !"
    ui_print "! This module requires the native Android dnsmasq binary. !"
    ui_print "! It will install, but the service might fail to run.   !"
    ui_print "*********************************************************"
else
    ui_print "- Built-in dnsmasq found! Native blocking will work."
fi

ui_print "- Copying files..."
