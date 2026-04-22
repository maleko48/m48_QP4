# HELPFUL COMMANDS &amp; SNIPPETS

> ## UPDATE HOST LINUX SYSTEM
> ```
> sudo apt update && apt upgrade -y
> ```
> 
> ## LIST USB DEVICES
> ```
> lsusb
> ```
> 
> ## LIST SERIAL DEVICES
> ```
> ls /dev/serial/by-id/
> ```
> 
> ## SHUTDOWN
> ```
> sudo shutdown -h now
> ```
> 
> ### REBOOT
> ```
> sudo reboot now
> ```

---

> ## STOP KLIPPER:
> ```
> sudo service klipper stop
> ```
> ```
> sudo systemctrl stop klipper
> ```
 
---

> ## KATAPULT FLASHTOOL COMMANDS
> ```
> usage: flashtool.py [-h] [-d <serial device>] [-b <baud rate>]
>                     [-i <can interface>] [-f <klipper.bin>]
>                     [-u <uuid>] [-q] [-v] [-r]
> 
> Katapult Flash Tool
> 
> options:
>  -h, --help            show this help message and exit
>  -d <serial device>, --device <serial device>
>                        Serial Device
>  -b <baud rate>, --baud <baud rate>
>                        Serial baud rate
>  -i <can interface>, --interface <can interface>
>                        Can Interface
>  -f <klipper.bin>, --firmware <klipper.bin>
>                        Path to Klipper firmware file
>  -u <uuid>, --uuid <uuid>
>                        Can device uuid
>  -q, --query           Query Bootloader Device IDs (CANBus only)
>  -v, --verbose         Enable verbose responses
>  -r, --request-bootloader
>                        Requests the bootloader and exits
>  -s, --status          Connect to bootloader and print status
> ```

---

> ## REQUEST MAIN MCU BOOTLOADER:
> ```
> cd ~/katapult/scripts
> python3 flashtool.py -b 500000 -d /dev/ttyS0 -r
> ```
> 
> ## REQUEST TOOLHEAD MCU BOOTLOADER:
> ```
> cd ~/katapult/scripts
> python3 flashtool.py -b 500000 -d /dev/ttyS2 -r
> ```

---
 
> ## FLASH KATAPULT (BIN) TO MAIN MCU:
> ```
> cd ~/katapult/scripts
> python3 flashtool.py -b 500000 -d /dev/ttyS0 -f ~/katapult/out/katapult.bin
> ```
>
> ## FLASH KATAPULT (BIN) TO TOOLHEAD MCU:
> ```
> cd ~/katapult/scripts
> python3 flashtool.py -b 500000 -d /dev/ttyS2 -f ~/katapult/out/katapult.bin
> ```
 
 ---
 
> ## FLASH KATAPULT (DEPLOYER) TO MAIN MCU:
> ```
> cd ~/katapult/scripts
> python3 flashtool.py -b 500000 -d /dev/ttyS0 -f ~/katapult/out/deployer.bin
> ```
>
> ## FLASH KATAPULT (DEPLOYER) TO TOOLHEAD MCU:
> ```
> cd ~/katapult/scripts
> python3 flashtool.py -b 500000 -d /dev/ttyS2 -f ~/katapult/out/deployer.bin
> ```
 
 ---
 
> ## FLASH KLIPPER TO MAIN MCU:
> ```
> sudo service klipper stop
> cd ~/katapult/scripts
> python3 flashtool.py -b 500000 -d /dev/ttyS0 -f ~/klipper/out/klipper.bin
> ```
> 
> ## FLASH KLIPPER TO TOOLHEAD MCU:
> ```
> sudo service klipper stop
> cd ~/katapult/scripts
> python3 flashtool.py -b 500000 -d /dev/ttyS2 -f ~/klipper/out/klipper.bin
> ```
 
 ---

> ## CPU TUNE SCRIPT
> 
> **INSTALL WITH**
> ```
> sudo bash
> sudo apt update
> sudo apt install linux-cpupower -y
> ```
> (CREATE `/etc/init.d/tuning` FILE AND PASTE SCRIPT CONTENTS BELOW INTO FILE)
> ```
> chmod 755 /etc/init.d/tuning
> ln -sf /etc/init.d/tuning /etc/rc3.d/S99tuning
> /etc/init.d/tuning reload
> ```
> 
> **SCRIPT CONTENTS**
> ```
> #!/bin/sh
> 
> ### BEGIN INIT INFO
> # Provides:       tuning
> # Required-Start:    $local_fs $remote_fs $network $syslog $named
> # Required-Stop:     $local_fs $remote_fs $network $syslog $named
> # Default-Start:     2 3 4 5
> # Default-Stop:      0 1 6
> # Short-Description: tunes CPU performance and process affinity
> # Description:       tunes CPU performance and process affinity
> ### END INIT INFO
> 
> PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
> TASKSET=/usr/bin/taskset
> RENICE=/usr/bin/renice
> CPUPOWER=/usr/bin/cpupower
> CPUPOWERFREQSET="/usr/bin/cpupower frequency-set"
> CPUPOWERFREQINFO="/usr/bin/cpupower frequency-info"
> 
> 
> test -x $TASKSET || exit 0
> test -x $RENICE || exit 0
> 
> set_irq_affinity() {
>     TTYS0=$(grep ttyS0 /proc/interrupts | awk -F: '{print $1}' | tr -d '[:blank:]')
>     TTYS1=$(grep ttyS1 /proc/interrupts | awk -F: '{print $1}' | tr -d '[:blank:]')
>     TTYS2=$(grep ttyS2 /proc/interrupts | awk -F: '{print $1}' | tr -d '[:blank:]')
> 
>     # MCU distribution
>     [ -n "$TTYS2" ] && echo 2 > /proc/irq/$TTYS2/smp_affinity   # CPU1 (heavy load)
>     [ -n "$TTYS0" ] && echo 4 > /proc/irq/$TTYS0/smp_affinity   # CPU2
>     [ -n "$TTYS1" ] && echo 4 > /proc/irq/$TTYS1/smp_affinity   # CPU2
> 
>     # USB controllers (match ALL real ones)
>     USB_IRQS=$(grep -E 'xhci|dwc2|ehci|ohci' /proc/interrupts | awk -F: '{print $1}' | tr -d '[:blank:]')
>     
>     for irq in $USB_IRQS; do
>         echo 8 > /proc/irq/$irq/smp_affinity   # CPU3
>     done
> }
> 
> set_affinity() {
>         AFFINITY_CPUS=$1
>         COMMAND_NAME=$2
> 
>         echo "Setting CPU affinity for all $COMMAND_NAME threads to CPU $AFFINITY_CPUS"
>         for p in `ps -eLf | grep -i $COMMAND_NAME | grep -v grep | awk '{print $4}'`
>         do
>                 $TASKSET -cp $AFFINITY_CPUS $p
>         done
> }
> 
> make_nice() {
>         NICE_LEVEL=$1
>         COMMAND_NAME=$2
> 
>         echo "Setting all $COMMAND_NAME threads to niceness level $NICE_LEVEL"
>         for p in `ps -eLf | grep $COMMAND_NAME | grep -v grep | awk '{print $4}'`
>         do
>                 $RENICE $NICE_LEVEL $p
>         done
> }
> 
> tune_up() {
>         # Disable irqbalance so it doesn't override manual IRQ affinity
>         if command -v systemctl >/dev/null 2>&1 && systemctl list-unit-files | grep -q '^irqbalance'; then
>                 echo "Disabling irqbalance service"
>                 systemctl stop irqbalance
>                 systemctl disable irqbalance
>         fi
> 
>         # Put CPU into Performance Mode
>         echo "Placing Printer CPU into Performance mode with fixed frequency"
>         $CPUPOWERFREQSET -g performance
>         $CPUPOWERFREQSET -d 1300Mhz
>         $CPUPOWERFREQINFO
> 
>         # Isolate Klipper from mjpg-streamer, nginx, and moonraker
>         echo "\nIsolating klipper from mjpg_streamer, moonraker, and nginx\n"
>         set_affinity 1-2 klippy
>         set_affinity 3 mjpg_streamer
>         set_affinity 3 nginx
>         set_affinity 3 moonraker
> 
>         set_irq_affinity
> 
>         # Set Niceness of mjpg_streamer and nginx
>         echo "\nSetting niceness of mjpg_streamer, nginx\n"
>         make_nice 1 nginx
>         make_nice 2 mjpg_streamer
> }
> 
> tune_down() {
>         # Re-enable irqbalance
>         if command -v systemctl >/dev/null 2>&1 && systemctl list-unit-files | grep -q '^irqbalance'; then
>                 echo "Re-enabling irqbalance service"
>                 systemctl enable irqbalance 2>/dev/null
>                 systemctl start irqbalance 2>/dev/null
>         fi
> 
>         # Put CPU into ondemand Mode
>         echo "Placing Printer CPU into default ondemand and frequency scaling mode"
>         $CPUPOWERFREQSET -g ondemand
>         $CPUPOWERFREQSET -d 408Mhz
>         $CPUPOWERFREQINFO
> 
>         # Unisolate Klipper, nginx, moonraker, and mjpg-streamer
>         echo "Resetting klipper/mjpg_streamer/nginx/moonraker tuning to system default"
>         set_affinity 0-3 klippy
>         set_affinity 0-3 mjpg_streamer
>         set_affinity 0-3 nginx
>         set_affinity 0-3 moonraker
> 
>         echo "Resetting niceness of mjpg_streamer, nginx to system default"
>         make_nice 0 mjpg_streamer
>         make_nice 0 nginx
> }
> 
> case "$1" in
>         start)
>                 sleep 120        # Wait for all the main printer processes to start up
>                 tune_up
>                 ;;
> 
>         reload)
>                 tune_up
>                 ;;
>         stop)
>                 tune_down
>                 ;;
>         *)
>                 exit 0
>                 ;;
> esac
> 
> exit 0
> ```
> 