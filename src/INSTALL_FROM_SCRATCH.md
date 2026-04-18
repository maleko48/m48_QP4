# INSTALL FROM SCRATCH

>## 1.) DOWNLOAD BASE IMAGE:
>
> - ### [https://github.com/Shadowrom2020/Qidi-X-6-X-7-Armbian/releases](https://github.com/Shadowrom2020/Qidi-X-6-X-7-Armbian/releases)
>
>### <br>TRUNK IMAGES
>**(no 3D printer software installed, just the base Host OS image)**
> - #### [https://github.com/Shadowrom2020/Qidi-X-6-X-7-Armbian/releases/download/26.05.0-trunk/Armbian-unofficial_26.05.0-trunk_Qidi-x6_trixie_current_6.18.21.img.xz](https://github.com/Shadowrom2020/Qidi-X-6-X-7-Armbian/releases/download/26.05.0-trunk/Armbian-unofficial_26.05.0-trunk_Qidi-x6_trixie_current_6.18.21.img.xz)
>
> - #### [https://github.com/Shadowrom2020/Qidi-X-6-X-7-Armbian/releases/download/26.05.0-trunk/Armbian-unofficial_26.05.0-trunk_Qidi-x6_trixie_edge_7.0.0-rc7.img.xz](https://github.com/Shadowrom2020/Qidi-X-6-X-7-Armbian/releases/download/26.05.0-trunk/Armbian-unofficial_26.05.0-trunk_Qidi-x6_trixie_edge_7.0.0-rc7.img.xz)
>### <br>FreeDi Beta IMAGE
> - #### [https://github.com/Shadowrom2020/Qidi-X-6-X-7-Armbian/releases/download/FreeDi-Beta/Armbian-unofficial_26.05.0-trunk_FreeDi_trixie_current_6.18.19.img.xz](https://github.com/Shadowrom2020/Qidi-X-6-X-7-Armbian/releases/download/FreeDi-Beta/Armbian-unofficial_26.05.0-trunk_FreeDi_trixie_current_6.18.19.img.xz)<br><br>

---

>## 2.) DOWNLOAD & INSTALL Win32 Disk Imager
> - ### [https://sourceforge.net/projects/win32diskimager/files/latest/download](https://sourceforge.net/projects/win32diskimager/files/latest/download)<br><br>

---

>## 3.) FLASH BASE IMAGE TO EMMC:
>![_IMAGE__Win32DiskImager_FlashEMMC.png](_IMAGE__Win32DiskImager_FlashEMMC.png)
>
>![_IMAGE__EMMC-AFTER-FLASHING-TRUNK-OS.png](_IMAGE__EMMC-AFTER-FLASHING-TRUNK-OS.png)<br><br>

---

>## 4.) FIRST BOOT  --  LOGIN AS ROOT VIA SSH:
>**INITIAL HOST NAME WILL BE <code>qidi-x6</code>**
>
>**MAC ADDRESS WILL BE RANDOM, CHECK YOUR ROUTER'S DHCP LEASES TO FIND IP ADDRESS GIVEN ON FIRST BOOT AND CREATE A STATIC DHCP RESERVATION FOR IT IN YOUR ROUTER**<br><br>
>**SSH IN USING <code>root</code> @ <IP_ADDRESS>**
><br>
>**WITH PASSWORD <code>1234</code>**
>![_IMAGE__First-Login-Initial-SSH.png](_IMAGE__First-Login-Initial-SSH.png)
><br><br>
>**PROCEED TO SET UP INITIAL BOOT ENVIRONMENT & NON-ROOT USER:**
>![_IMAGE__First-Login-User-Creation.png](_IMAGE__First-Login-User-Creation.png)
>![_IMAGE__Select-Locale.png](_IMAGE__Select-Locale.png)
>![_IMAGE__Select-Time-Zone.png](_IMAGE__Select-Time-Zone.png)
>![_IMAGE__Select-Country.png](_IMAGE__Select-Country.png)
>![_IMAGE__Select-Local-Time-Zone.png](_IMAGE__Select-Local-Time-Zone.png)
>![_IMAGE__Confirm-Time-Zone.png](_IMAGE__Confirm-Time-Zone.png)
>![_IMAGE__Generating-Locales.png](_IMAGE__Generating-Locales.png)
>![_IMAGE__First-Root-Login-After-Setup.png](_IMAGE__First-Root-Login-After-Setup.png)

---

>## 5.) SHUTDOWN PRINTER, REBOOT ROUTER, & LOG IN TO PRINTER AS NON-ROOT USER VIA SSH
>**SHUTDOWN USING THE COMMAND `sudo shutdown -h now`**
>![_IMAGE__Shutdown-Printer.png](_IMAGE__Shutdown-Printer.png)
><br><br>
>**ADJUST YOUR ROUTER'S DHCP RESERVATION FOR DESIRED IP ADDRESS IF NECESSARY.**
><br><br>
>**REBOOT YOUR ROUTER WHILE YOUR PRINTER IS POWERED OFF.**
><br><br>
>**ONCE YOUR ROUTER IS BACK UP, POWER ON YOUR PRINTER AGAIN.**
><br><br>
>**LOG INTO PRINTER AT YOUR KNOWN, SPECIFIED, RESERVED IP ADDRESS AS THE NON-ROOT USER YOU CREATED EARLIER.**
><br><br>
>**NOTE:<br>IF YOU HAVE ALREADY SSH'd INTO YOUR PRINTER AT THE SAME IP ADDRESS IN THE PAST YOU WILL GET THE FOLLOWING ERROR**
>![_IMAGE__SSH-Login-Error.png](_IMAGE__SSH-Login-Error.png)
><br><br>
>**RUN THE CODE SNIPPET PROVIDED BY THE TERMINAL TO FIX**
><br>
><hint>(don't forget to swap out the `<USER>` and `<IP_ADDRESS>` for your own or just copy and paste the provided snippet as is from your terminal)</hint>
><br>
><code>ssh-keygen -f '/home/**`<USER>`**/.ssh/known_hosts' -R '**<IP_ADDRESS>**'</code>
>![_IMAGE__Fix-SSH-Error.png](_IMAGE__Fix-SSH-Error.png)
><br><br>
>**FINALLY, LOG IN AS NON-ROOT USER**
>![_IMAGE__First-Login-As-User.png](_IMAGE__First-Login-As-User.png)

---

>## 6.) UPDATE HOST NAME
>**SET THE NEW HOSTNAME**
>`sudo hostnamectl set-hostname qidi-plus4`
><br><br>
>![_IMAGE__Set-Hostname-Qidi-Plus4.png](_IMAGE__Set-Hostname-Qidi-Plus4.png)
><br><br>
>**MANUALLY UPDATE THE `/etc/hosts` FILE TO PREVENT ERRORS**
><br><br>
>`sudo nano /etc/hosts`
><br><br>
>![_IMAGE__Nano-etc-hosts.png](_IMAGE__Nano-etc-hosts.png)
><br><br>
>**UPDATE LINE #2 & #3 TO READ `qidi-plus4`**
>![_IMAGE__Update-Hosts-File-Using-Nano.png](_IMAGE__Update-Hosts-File-Using-Nano.png)
>**PRESS `CTRL + X`**
>![_IMAGE__Nano-Footer.png](_IMAGE__Nano-Footer.png)
>**PRESS `Y`**
><br>
>![_IMAGE__Nano-Save-On-Exit.png](_IMAGE__Nano-Save-On-Exit.png)
><br>
>**PRESS `ENTER` TO SAVE & WRITE THE CHANGES OUT TO THE HOSTS FILE**
><br>
>![_IMAGE__Nano-Write-To-File.png](_IMAGE__Nano-Write-To-File.png)
>![_IMAGE__After-Hosts-File-Update.png](_IMAGE__After-Hosts-File-Update.png)