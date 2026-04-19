# SET UP WSL TO BUILD FIRMWARE LOCALLY ON WINDOWS
> - DOWNLOAD & INSTALL THE Windows Terminal APP FROM THE Microsoft Store
> - OPEN PowerShell AS Administrator
> 	```
> 	wsl --install -d Debian
> 	```
> - RESTART YOUR COMPUTER
> - LAUNCH Terminal AND SIGN INTO Debian WSL INSTANCE FOR THE FIRST TIME
> - VERIFY WSL2 IS BEING USED
> 	```
> 	wsl -l -v
> 	```
> - UPDATE & UPGRADE WSL2 Debian
> 	```
> 	sudo apt update && sudo apt upgrade -y
> 	```
> - PREPARE THE LOCAL BUILD ENVIRONMENT
> 	```
> 	sudo apt install gcc-arm-none-eabi build-essential
> 	```
>

---

NOW YOU SHOULD BE ABLE TO FOLLOW THE STANDARD GUIDES<br>
FOR BUILDING THE KATAPULT & KLIPPER FIRMARES

> KATAPULT
> ```
> cd ~
> git clone https://github.com/Arksine/katapult
> cd katapult
> make menuconfig
> make clean
> make -j4
> cp ~/katapult/out/deployer.bin /mnt/c/Users/$(cmd.exe /c "echo %USERNAME%" | tr -d '\r\n')/Downloads/
> cp ~/katapult/out/katapult.bin /mnt/c/Users/$(cmd.exe /c "echo %USERNAME%" | tr -d '\r\n')/Downloads/
> ```


> KLIPPER
> ```
> cd ~
> git clone https://github.com/Klipper3d/klipper
> cd klipper
> make menuconfig
> make clean
> make -j4
> cp ~/klipper/out/klipper.bin /mnt/c/Users/$(cmd.exe /c "echo %USERNAME%" | tr -d '\r\n')/Downloads/
> ```
