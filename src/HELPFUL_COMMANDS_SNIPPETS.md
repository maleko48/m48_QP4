# HELPFUL COMMANDS &amp; SNIPPETS

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
 
---

> ## FLASHTOOL COMMANDS
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