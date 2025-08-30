#!/bin/bash

mkdir -p /system-info

OUTDIR="/system-info/diagnostics_$(date +%Y-%m-%d_%H-%M-%S)"
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

git stash push -u -m "Auto-stash before pulling for diagnostics" >/dev/null 2>&1

git pull --rebase origin main || git rebase --abort

git stash pop >/dev/null 2>&1

git add "%OUTDIR"
git commit -m "Add diagnostics snapshot $(date +%Y-%m-%d_%H:%M:%S)" || echo "Nothing to commit"
git push origin main 2>/dev/null || git push -u origin main

SNAPSHOTS_DIR="system_info"
cd "$SNAPSHOTS_DIR" || exit

ls -1dt diagnostics_* | tail -n +11 | xargs -r rm -rf

cd - >/dev/null

echo "Diagnostics collected and pushed to Github: $OUTDIR/"
echo "Old snapshots beyond the last 10 have been deleted."
