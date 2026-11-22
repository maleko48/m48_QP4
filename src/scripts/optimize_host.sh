#!/usr/bin/env bash
set -euo pipefail

if [ "$EUID" -ne 0 ]; then
    echo "Error: Please run with sudo (e.g., sudo bash $0)"
    exit 1
fi

BOOT_MODE=false
if [ "${1:-}" = "--boot" ]; then
    BOOT_MODE=true
fi

SCRIPT_URL="https://maleko48.github.io/m48_QP4/scripts/optimize_host.sh"
TARGET_USER="${SUDO_USER:-mks}"
TARGET_HOME=$(getent passwd "$TARGET_USER" | cut -d: -f6)
CONFIG_DIR="${TARGET_HOME}/printer_data/config"
SCRIPT_DIR="${CONFIG_DIR}/_SCRIPTS"
SCRIPT_DEST="${SCRIPT_DIR}/optimize_host.sh"
BACKUP_ROOT="${CONFIG_DIR}/_BACKUP"
ARCHIVE_DIR="${BACKUP_ROOT}/_ARCHIVE"
TIMESTAMP=$(date +"%Y-%m-%dT%H-%M-%S")
BACKUP_DIR="${BACKUP_ROOT}/${TIMESTAMP}"

echo "=== [1/8] Backing up printer configs and scripts to ${BACKUP_DIR} ==="
mkdir -p "$BACKUP_DIR"

shopt -s nullglob
CONFIG_FILES=("${CONFIG_DIR}"/*.cfg "${CONFIG_DIR}"/*.conf)
shopt -u nullglob

if [ "${#CONFIG_FILES[@]}" -gt 0 ]; then
    for cfg in "${CONFIG_FILES[@]}"; do
        if [ -f "$cfg" ]; then
            cp -p "$cfg" "${BACKUP_DIR}/"
            echo "  Backed up $(basename "$cfg")"
        fi
    done
else
    echo "  No .cfg or .conf files found in ${CONFIG_DIR}"
fi

if [ -d "$SCRIPT_DIR" ]; then
    cp -rp "$SCRIPT_DIR" "${BACKUP_DIR}/_SCRIPTS"
    echo "  Backed up _SCRIPTS/ folder"
else
    echo "  Skipped _SCRIPTS/ folder (not found)"
fi

# Keep the 10 most recent backups in _BACKUP and move older ones to _BACKUP/_ARCHIVE
mapfile -t OLD_BACKUPS < <(
    find "$BACKUP_ROOT" -mindepth 1 -maxdepth 1 -type d ! -name "_ARCHIVE" -printf '%f\n' \
    | sort -r \
    | tail -n +11
)

if [ "${#OLD_BACKUPS[@]}" -gt 0 ]; then
    mkdir -p "$ARCHIVE_DIR"
    for old_dir in "${OLD_BACKUPS[@]}"; do
        mv "${BACKUP_ROOT}/${old_dir}" "${ARCHIVE_DIR}/"
        echo "  Archived older backup: ${old_dir}"
    done
fi

chown -R "${TARGET_USER}:${TARGET_USER}" "$BACKUP_ROOT"

echo "=== [2/8] Installing linux-cpupower ==="
if ! command -v cpupower >/dev/null 2>&1; then
    apt-get update -qq
    apt-get install -y -qq linux-cpupower
else
    echo "cpupower is already installed."
fi

echo "=== [3/8] Creating /etc/init.d/tuning ==="
cat << 'EOF' > /etc/init.d/tuning
#!/bin/sh

### BEGIN INIT INFO
# Provides:          tuning
# Required-Start:    $local_fs $remote_fs $network $syslog $named
# Required-Stop:     $local_fs $remote_fs $network $syslog $named
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: optimized host cpu & process tuning
# Description:       tunes CPU performance and hardware IRQ affinity
### END INIT INFO

PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
CPUPOWER=/usr/bin/cpupower
CPUPOWERFREQSET="/usr/bin/cpupower frequency-set"
CPUPOWERFREQINFO="/usr/bin/cpupower frequency-info"

test -x $CPUPOWER || exit 0

set_irq_affinity() {
    TTYS0=$(grep ttyS0 /proc/interrupts | awk -F: '{print $1}' | tr -d '[:blank:]')
    TTYS1=$(grep ttyS1 /proc/interrupts | awk -F: '{print $1}' | tr -d '[:blank:]')
    TTYS2=$(grep ttyS2 /proc/interrupts | awk -F: '{print $1}' | tr -d '[:blank:]')

    # MCU serial distribution
    [ -n "$TTYS2" ] && echo 2 > /proc/irq/$TTYS2/smp_affinity   # CPU1 (heavy load)
    [ -n "$TTYS0" ] && echo 4 > /proc/irq/$TTYS0/smp_affinity   # CPU2
    [ -n "$TTYS1" ] && echo 4 > /proc/irq/$TTYS1/smp_affinity   # CPU2

    # USB controllers (Beacon probe + webcam)
    USB_IRQS=$(grep -E 'xhci|dwc2|ehci|ohci' /proc/interrupts | awk -F: '{print $1}' | tr -d '[:blank:]')
    for irq in $USB_IRQS; do
        echo 8 > /proc/irq/$irq/smp_affinity   # CPU3
    done
}

tune_up() {
    if command -v systemctl >/dev/null 2>&1 && systemctl list-unit-files irqbalance.service >/dev/null 2>&1; then
        systemctl stop irqbalance 2>/dev/null || true
        systemctl disable irqbalance 2>/dev/null || true
    fi

    echo "Placing Printer CPU into Performance mode at 1.30 GHz"
    $CPUPOWERFREQSET -g performance >/dev/null
    $CPUPOWERFREQSET -d 1300MHz >/dev/null
    $CPUPOWERFREQINFO

    set_irq_affinity
}

tune_down() {
    if command -v systemctl >/dev/null 2>&1 && systemctl list-unit-files irqbalance.service >/dev/null 2>&1; then
        systemctl enable irqbalance 2>/dev/null || true
        systemctl start irqbalance 2>/dev/null || true
    fi

    echo "Placing Printer CPU into default ondemand mode"
    $CPUPOWERFREQSET -g ondemand >/dev/null
    $CPUPOWERFREQSET -d 408MHz >/dev/null
    $CPUPOWERFREQINFO
}

case "$1" in
    start|reload)
        tune_up
        ;;
    stop)
        tune_down
        ;;
    *)
        exit 0
        ;;
esac

exit 0
EOF

chmod 755 /etc/init.d/tuning
ln -sf /etc/init.d/tuning /etc/rc3.d/S99tuning

echo "=== [4/8] Disabling conflicting tuning & applying systemd overrides ==="
if systemctl list-unit-files service_tuning.service >/dev/null 2>&1; then
    systemctl stop service_tuning.service 2>/dev/null || true
    systemctl disable service_tuning.service 2>/dev/null || true
    systemctl mask service_tuning.service 2>/dev/null || true
    echo "  Stopped and masked conflicting service_tuning.service (Qidi-Tuning)"
fi

apply_override() {
    local service="$1"
    local affinity="$2"
    local nice_val="$3"

    if systemctl list-unit-files "${service}.service" >/dev/null 2>&1; then
        mkdir -p "/etc/systemd/system/${service}.service.d"
        cat << EOF > "/etc/systemd/system/${service}.service.d/override.conf"
[Service]
CPUAffinity=${affinity}
Nice=${nice_val}
EOF
        echo "  Configured ${service}.service (CPUAffinity=${affinity}, Nice=${nice_val})"
    else
        echo "  Skipped ${service}.service (not installed)"
    fi
}

apply_override "klipper"   "1-2" "-5"
apply_override "moonraker" "3"   "0"
apply_override "nginx"     "3"   "1"
apply_override "crowsnest" "3"   "2"
apply_override "FreeDi"    "0"   "1"

echo "=== [5/8] Patching /etc/nginx/nginx.conf ==="
if [ -f /etc/nginx/nginx.conf ]; then
    cp -n /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bak
    sed -i 's/^\s*worker_processes\s\+.*;/worker_processes 1;/' /etc/nginx/nginx.conf
    sed -i 's/^\s*\(worker_cpu_affinity\s\+.*;\)/#\1/' /etc/nginx/nginx.conf
    nginx -t
fi

echo "=== [6/8] Saving local copy to ${SCRIPT_DEST} ==="
mkdir -p "$SCRIPT_DIR"
if [ -f "${0:-}" ] && [ "$(realpath "$0" 2>/dev/null || true)" != "$(realpath "$SCRIPT_DEST" 2>/dev/null || true)" ]; then
    cp -f "$0" "$SCRIPT_DEST"
elif [ "$BOOT_MODE" = false ]; then
    curl -fsSL "$SCRIPT_URL" -o "$SCRIPT_DEST" || echo "Warning: Could not download local copy from $SCRIPT_URL"
fi
chmod +x "$SCRIPT_DEST"
chown -R "${TARGET_USER}:${TARGET_USER}" "$SCRIPT_DIR"

echo "=== [7/8] Installing systemd boot service (optimize-host.service) ==="
cat << EOF > /etc/systemd/system/optimize-host.service
[Unit]
Description=Run optimize_host.sh on boot
Before=klipper.service moonraker.service nginx.service crowsnest.service FreeDi.service
After=local-fs.target

[Service]
Type=oneshot
ExecStart=/usr/bin/env bash ${SCRIPT_DEST} --boot
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable optimize-host.service

echo "=== [8/8] Applying tuning & verifying ==="
/etc/init.d/tuning reload

if [ "$BOOT_MODE" = false ]; then
    systemctl restart klipper moonraker nginx crowsnest 2>/dev/null || true
    if systemctl list-unit-files FreeDi.service >/dev/null 2>&1; then
        systemctl restart FreeDi 2>/dev/null || true
    fi

    echo "Waiting 3 seconds for services and sub-processes (ustreamer) to initialize..."
    sleep 3

    echo ""
    echo "=== VERIFICATION ==="
    for proc in klippy.py moonraker nginx ustreamer FreeDiLCD/start.py; do
        echo "--- $proc ---"
        raw_pids=$(pgrep -f "$proc" || true)
        pids=$(echo "$raw_pids" | tr '\n' ',' | sed 's/,$//')
        if [ -n "$pids" ]; then
            ps -T -o pid,tid,ni,comm -p "$pids"
            for p in $raw_pids; do
                taskset -cp "$p"
            done
        else
            echo "Not running"
        fi
    done
else
    echo "Boot mode complete: configs backed up and host tuning applied before service startup."
fi
