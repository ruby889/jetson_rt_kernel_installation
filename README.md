# jetson_rt_kernel_installation
Procedures of installing RT kernel on Jetson (for NVIDIA L4T 35.1 or above) (from [Nivida Developer forums](https://forums.developer.nvidia.com/t/jetpack-5-1-rt-patch-not-working/247771))
1. Put the target board into Recovery Mode and connect with a USB Type-C cable to another Ubuntu device(the host). e.g. Port J512 is used for Jetson Agx Xavier.
   The following actions are performed on the host.

3. Go to [Jetson Linux Archive](https://developer.nvidia.com/embedded/jetson-linux-archive), download the following files for your release.  
* Driver Package (BSP)
* Sample Root Filesystem
* Driver Package (BSP) Sources
* Bootlin Toolchain gcc 9.3
3. Edit the corresponding lines in _install.sh_.
```
JETSON="Jetson_Linux_R35.4.1_aarch64.tbz2"
SOURCES="public_sources.tbz2"
ROOTFS="Tegra_Linux_Sample-Root-Filesystem_R35.4.1_aarch64.tbz2"
TOOLCHAIN="aarch64--glibc--stable-final.tar.gz"
```
> JETSON: Driver Package (BSP)  
> ROOTFS: Sample Root Filesystem  
> SOURCES: Driver Package (BSP) Sources  
> TOOLCHAIN: Bootlin Toolchain gcc 9.3
4. Edit the following line in _install.sh_ for target board, as described in [Basic Flashing Script Usage](https://docs.nvidia.com/jetson/archives/r34.1/DeveloperGuide/text/SD/FlashingSupport.html#basic-flashing-script-usage).
```
sudo ./flash.sh jetson-agx-xavier-devkit mmcblk0p1
```
5. Run the shell script on Terminal
```
chmod +x install.sh
./install.sh
```
