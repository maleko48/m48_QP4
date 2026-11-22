# SCRIPT:&emsp;```HOST_OPTIMIZER.sh```
## PATH:&emsp;```!/home/mks/printer_data/config```
## ORIGINAL SCRIPT:<br>[https://github.com/qidi-community/Plus4-Wiki/blob/main/content/system-tuning/README.md](https://github.com/qidi-community/Plus4-Wiki/blob/main/content/system-tuning/README.md)
<br>

```
#!/bin/sh

### BEGIN INIT INFO
# Provides:       tuning
# Required-Start:    $local_fs $remote_fs $network $syslog $named
# Required-Stop:     $local_fs $remote_fs $network $syslog $named
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: tunes CPU performance and process affinity
# Description:       tunes CPU performance and process affinity
### END INIT INFO

PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
TASKSET=/usr/bin/taskset
RENICE=/usr/bin/renice
CPUFREQSET=/usr/bin/cpufreq-set
CPUFREQINFO=/usr/bin/cpufreq-info

test -x $TASKSET || exit 0
test -x $RENICE || exit 0

set_irq_affinity() {
        TTYS0=`grep ttyS0 < /proc/interrupts | awk -F: '{print $1}' | tr -d '[:blank:]'`
        TTYS2=`grep ttyS2 < /proc/interrupts | awk -F: '{print $1}' | tr -d '[:blank:]'`
        USB2=`grep "hcd:usb2" < /proc/interrupts | awk -F: '{print $1}' | tr -d '[:blank:]'`
        USB3=`grep "hcd:usb3" < /proc/interrupts | awk -F: '{print $1}' | tr -d '[:blank:]'`
        USB4=`grep "hcd:usb4" < /proc/interrupts | awk -F: '{print $1}' | tr -d '[:blank:]'`

        # Split MCU IRQs evenly between CPUs 1 and 2
        echo 4 > /proc/irq/${TTYS0}/smp_affinity
        echo 2 > /proc/irq/${TTYS2}/smp_affinity
        echo 8 > /proc/irq/${USB2}/smp_affinity
        echo 8 > /proc/irq/${USB3}/smp_affinity
        echo 8 > /proc/irq/${USB4}/smp_affinity
}

set_affinity() {
        AFFINITY_CPUS=$1
        COMMAND_NAME=$2

        echo "Setting CPU affinity for all $COMMAND_NAME threads to CPU $AFFINITY_CPUS"
        for p in `ps -eLf | grep -i $COMMAND_NAME | grep -v grep | awk '{print $4}'`
        do
                $TASKSET -cp $AFFINITY_CPUS $p
        done
}

make_nice() {
        NICE_LEVEL=$1
        COMMAND_NAME=$2

        echo "Setting all $COMMAND_NAME threads to niceness level $NICE_LEVEL"
        for p in `ps -eLf | grep $COMMAND_NAME | grep -v grep | awk '{print $4}'`
        do
                $RENICE $NICE_LEVEL $p
        done
}

tune_up() {
        # Put CPU into Performance Mode
        echo "Placing Printer CPU into Performance mode with fixed frequency"
        $CPUFREQSET -g performance
        $CPUFREQSET -d 1200Mhz
        $CPUFREQINFO

        # Isolate Klipper from xindi and mjpg-streamer
        echo "\nIsolating klipper from xindi, mjpg_streamer, moonraker, and nginx\n"
        set_affinity 0 /root/xindi/build/xindi
        set_affinity 1-2 klippy
        set_affinity 3 mjpg_streamer
        set_affinity 3 nginx
        set_affinity 3 moonraker

        set_irq_affinity

        # Set Niceness of xindi and mjpg_streamer
        echo "\nSetting niceness of xindi, mjpg_streamer, nginx\n"
        make_nice 1 /root/xindi/build/xindi
        make_nice 1 nginx
        make_nice 2 mjpg_streamer
}

tune_down() {
        # Put CPU into ondemand Mode
        echo "Placing Printer CPU into default ondemand and frequency scaling mode"
        $CPUFREQSET -g ondemand
        $CPUFREQSET -d 408Mhz
        $CPUFREQINFO

        # Unisolate Klipper, xindi, nginx, moonraker, and mjpg-streamer
        echo "Resetting klipper/mjpg_streamer/xindi/nginx/moonraker tuning to system default"
        set_affinity 0-3 klippy
        set_affinity 0-3 mjpg_streamer
        set_affinity 0-3 /root/xindi/build/xindi
        set_affinity 0-3 nginx
        set_affinity 0-3 moonraker

        echo "Resetting niceness of xindi, mjpg_streamer, nginx to system default"
        make_nice 0 /root/xindi/build/xindi
        make_nice 0 mjpg_streamer
        make_nice 0 nginx
}

case "$1" in
        start)
                sleep 60        # Wait for all the main printer processes to start up
                tune_up
                ;;

        reload)
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
```

## UPDATED ORIGINAL SCRIPT:<br>(using cpupower instead of cpufrequtils, for FreeDi)
```
#!/bin/sh

### BEGIN INIT INFO
# Provides:       tuning
# Required-Start:    $local_fs $remote_fs $network $syslog $named
# Required-Stop:     $local_fs $remote_fs $network $syslog $named
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: tunes CPU performance and process affinity
# Description:       tunes CPU performance and process affinity
### END INIT INFO

PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
TASKSET=/usr/bin/taskset
RENICE=/usr/bin/renice
CPUPOWER=/usr/bin/cpupower
CPUPOWERFREQSET="/usr/bin/cpupower frequency-set"
CPUPOWERFREQINFO="/usr/bin/cpupower frequency-info"


test -x $TASKSET || exit 0
test -x $RENICE || exit 0

set_irq_affinity() {
        TTYS0=`grep ttyS0 < /proc/interrupts | awk -F: '{print $1}' | tr -d '[:blank:]'`
        TTYS2=`grep ttyS2 < /proc/interrupts | awk -F: '{print $1}' | tr -d '[:blank:]'`
        USB2=`grep "hcd:usb2" < /proc/interrupts | awk -F: '{print $1}' | tr -d '[:blank:]'`
        USB3=`grep "hcd:usb3" < /proc/interrupts | awk -F: '{print $1}' | tr -d '[:blank:]'`
        USB4=`grep "hcd:usb4" < /proc/interrupts | awk -F: '{print $1}' | tr -d '[:blank:]'`

        # Split MCU IRQs evenly between CPUs 1 and 2
        echo 4 > /proc/irq/${TTYS0}/smp_affinity
        echo 2 > /proc/irq/${TTYS2}/smp_affinity
        echo 8 > /proc/irq/${USB2}/smp_affinity
        echo 8 > /proc/irq/${USB3}/smp_affinity
        echo 8 > /proc/irq/${USB4}/smp_affinity
}

set_affinity() {
        AFFINITY_CPUS=$1
        COMMAND_NAME=$2

        echo "Setting CPU affinity for all $COMMAND_NAME threads to CPU $AFFINITY_CPUS"
        for p in `ps -eLf | grep -i $COMMAND_NAME | grep -v grep | awk '{print $4}'`
        do
                $TASKSET -cp $AFFINITY_CPUS $p
        done
}

make_nice() {
        NICE_LEVEL=$1
        COMMAND_NAME=$2

        echo "Setting all $COMMAND_NAME threads to niceness level $NICE_LEVEL"
        for p in `ps -eLf | grep $COMMAND_NAME | grep -v grep | awk '{print $4}'`
        do
                $RENICE $NICE_LEVEL $p
        done
}

tune_up() {
        # Put CPU into Performance Mode
        echo "Placing Printer CPU into Performance mode with fixed frequency"
        $CPUPOWERFREQSET -g performance
        $CPUPOWERFREQSET -d 1300Mhz
        $CPUPOWERFREQINFO

        # Isolate Klipper from ustreamer
        echo "\nIsolating klipper from ustreamer, moonraker, and nginx\n"
        set_affinity 1-2 klippy
        set_affinity 3 ustreamer
        set_affinity 3 nginx
        set_affinity 3 moonraker

        set_irq_affinity

        # Set Niceness of ustreamer
        echo "\nSetting niceness of ustreamer, nginx\n"
        make_nice 1 nginx
        make_nice 2 ustreamer
}

tune_down() {
        # Put CPU into ondemand Mode
        echo "Placing Printer CPU into default ondemand and frequency scaling mode"
        $CPUPOWERFREQSET -g ondemand
        $CPUPOWERFREQSET -d 408Mhz
        $CPUPOWERFREQINFO

        # Unisolate Klipper, nginx, moonraker, and ustreamer
        echo "Resetting klipper/ustreamer/nginx/moonraker tuning to system default"
        set_affinity 0-3 klippy
        set_affinity 0-3 ustreamer
        set_affinity 0-3 nginx
        set_affinity 0-3 moonraker

        echo "Resetting niceness of ustreamer, nginx to system default"
        make_nice 0 ustreamer
        make_nice 0 nginx
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
```

## MY CUSTOM, UPDATED SCRIPT (`/etc/init.d/tuning`):
```sh
#!/bin/sh

### BEGIN INIT INFO
# Provides:          tuning
# Required-Start:    \$local_fs \(remote_fs\)network syslog named
# Required-Stop:     \$local_fs \(remote_fs\)network syslog named
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: optimized host cpu & process tuning
# Description:       tunes CPU performance and hardware IRQ affinity
### END INIT INFO

PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
CPUPOWER=/usr/bin/cpupower
CPUPOWERFREQSET="/usr/bin/cpupower frequency-set"
CPUPOWERFREQINFO="/usr/bin/cpupower frequency-info"

test -x \$CPUPOWER || exit 0

set_irq_affinity() {
    TTYS0=\$(grep ttyS0 /proc/interrupts | awk -F: '{print \$1}' | tr -d '[:blank:]')
    TTYS1=\$(grep ttyS1 /proc/interrupts | awk -F: '{print \$1}' | tr -d '[:blank:]')
    TTYS2=\$(grep ttyS2 /proc/interrupts | awk -F: '{print \$1}' | tr -d '[:blank:]')

    # MCU distribution
    [ -n "\(TTYS2" ] && echo 2 > /proc/irq/\)TTYS2/smp_affinity   # CPU1 (heavy load)
    [ -n "\(TTYS0" ] && echo 4 > /proc/irq/\)TTYS0/smp_affinity   # CPU2
    [ -n "\(TTYS1" ] && echo 4 > /proc/irq/\)TTYS1/smp_affinity   # CPU2

    # USB controllers (match ALL real ones)
    USB_IRQS=\$(grep -E 'xhci|dwc2|ehci|ohci' /proc/interrupts | awk -F: '{print \$1}' | tr -d '[:blank:]')
    for irq in \$USB_IRQS; do
        echo 8 > /proc/irq/\$irq/smp_affinity   # CPU3
    done
}

tune_up() {
    # Disable irqbalance so it doesn't override manual IRQ affinity
    if command -v systemctl >/dev/null 2>&1 && systemctl list-unit-files | grep -q '^irqbalance'; then
        echo "Disabling irqbalance service"
        systemctl stop irqbalance
        systemctl disable irqbalance
    fi

    # Put CPU into Performance Mode
    echo "Placing Printer CPU into Performance mode with fixed frequency"
    \$CPUPOWERFREQSET -g performance
    \(CPUPOWERFREQSET -d 1300MHz\)CPUPOWERFREQINFO

    set_irq_affinity
}

tune_down() {
    # Re-enable irqbalance
    if command -v systemctl >/dev/null 2>&1 && systemctl list-unit-files | grep -q '^irqbalance'; then
        echo "Re-enabling irqbalance service"
        systemctl enable irqbalance 2>/dev/null
        systemctl start irqbalance 2>/dev/null
    fi

    # Put CPU into ondemand Mode
    echo "Placing Printer CPU into default ondemand and frequency scaling mode"
    \$CPUPOWERFREQSET -g ondemand
    \(CPUPOWERFREQSET -d 408MHz\)CPUPOWERFREQINFO
}

case "\$1" in
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
```

## INSTALLATION INSTRUCTIONS:
Run this command over SSH on your Qidi Plus 4 to install `linux-cpupower`, configure `systemd` CPU core isolation, patch Nginx, and set serial/USB IRQ affinities automatically:

```bash
curl -fsSL https://github.io | sudo bash
```

## Full Script (`optimize_host.sh`)

```bash
{{#include scripts/optimize_host.sh}}
```




























1. **Install `cpupower`:**
   ```bash
   sudo apt update
   sudo apt install -y linux-cpupower
   ```

2. **Create `systemd` drop-in overrides:**
   ```bash
   sudo mkdir -p /etc/systemd/system/klipper.service.d
   printf "[Service]\nCPUAffinity=1-2\nNice=-5\n" | sudo tee /etc/systemd/system/klipper.service.d/override.conf

   sudo mkdir -p /etc/systemd/system/moonraker.service.d
   printf "[Service]\nCPUAffinity=3\nNice=0\n" | sudo tee /etc/systemd/system/moonraker.service.d/override.conf

   sudo mkdir -p /etc/systemd/system/nginx.service.d
   printf "[Service]\nCPUAffinity=3\nNice=1\n" | sudo tee /etc/systemd/system/nginx.service.d/override.conf

   sudo mkdir -p /etc/systemd/system/crowsnest.service.d
   printf "[Service]\nCPUAffinity=3\nNice=2\n" | sudo tee /etc/systemd/system/crowsnest.service.d/override.conf
   ```

3. **Update `/etc/nginx/nginx.conf` (top lines):**
   Edit `/etc/nginx/nginx.conf` (`sudo nano /etc/nginx/nginx.conf`) so it uses 1 worker and inherits `CPUAffinity=3` from `systemd`:
   ```nginx
   user www-data;
   #worker_processes auto;    # default spawns 4 workers that clutter isolated cores
   worker_processes 1;
   #worker_cpu_affinity auto; # commented out so worker inherits CPUAffinity from systemd
   #worker_cpu_affinity 1000; # optional manual bitmask for CPU3 (1000 binary = CPU3)
   pid /run/nginx.pid;
   ```
   Test Nginx syntax:
   ```bash
   sudo nginx -t
   ```

4. **Create and enable `/etc/init.d/tuning`:**
   ```bash
   sudo nano /etc/init.d/tuning
   ```
   Paste the script from above, save, and enable it:
   ```bash
   sudo chmod 755 /etc/init.d/tuning
   sudo ln -sf /etc/init.d/tuning /etc/rc3.d/S99tuning
   ```

5. **Reload `systemd` and apply everything immediately:**
   ```bash
   sudo systemctl daemon-reload
   sudo /etc/init.d/tuning reload
   sudo systemctl restart klipper moonraker nginx crowsnest
   ```

6. **Verify results:**
   ```bash
   for proc in klippy moonraker nginx ustreamer; do
     echo "=== \$proc ==="
     pids=\$(pgrep -f "\(proc" \vert{} tr '\n' ',' \vert{} sed 's/,\)//')
     if [ -n "\$pids" ]; then
       ps -T -o pid,tid,ni,comm -p "\$pids"
       for p in (pgrep -f "proc"); do taskset -cp \$p; done
     else
       echo "Not running"
     fi
   done
   ```
