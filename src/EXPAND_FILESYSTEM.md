# EXPAND FILESYSTEM

## using armbian-resize-filesystem (recommended)
Enable the automatic resizing of the filesystem on boot:
```
sudo systemctl enable armbian-resize-filesystem
```


And restart the system to apply changes:
```
sudo reboot
```

##### NOTE:
Please allow some time for the system to boot and to resize the file system. This process needs some time and will be done while the system is running (I have not measured it but I estimate something around 15-20min after booting).