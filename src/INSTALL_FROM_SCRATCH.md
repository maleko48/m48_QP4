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