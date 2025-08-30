#!/bin/bash

mkdir -p diagnostics/system-info

OUTDIR="diagnostics/system-info/diagnostics_$(date +%Y-%m-%d_%H-%M-%S)"
mkdir -p "$OUTDIR"

uname -a > "$OUTDIR/kernel_info.txt"
lsb_release -a > "$OUTDIR/os_info.txt" 2>/dev/null || cat /etc/*release > "$OUTDIR/os_info.txt"

lscpu > "$OUTDIR/cpu_info.txt"
free -h > "$OUTDIR/memory_info.txt"
lsblk > "$OUTDIR/disks.txt"
lspci > "$OUTDIR/lspci.txt"
lsusb > "$OUTDIR/lsusb.txt"

ip addr show > "$OUTDIR/network_interfaces.txt"
ip route show > "$OUTDIR/network_routes.txt"
nmcli dev status > "$OUTDIR/nmcli_devices.txt" 2>/dev/null || true

lsmod > "$OUTDIR/loaded_modules.txt"
dmesg | tail -n 200 > "$OUTDIR/dmesg_tail.txt"

systemctl list-units --type=service --state=running > "$OUTDIR/running_services.txt"

git add diagnostics/system-info/
git commit -m "Add diagnostics snapshot $(date +%Y-%m-%d_%H:%M:%S)" || echo "Nothing to commit"
git pull --rebase origin main 2>/dev/null || true
git push origin main 2>/dev/null || git push -u origin main

echo "Diagnostics collected and pushed to Github: $OUTDIR/"
