# jetson_rt_kernel_installation
Procedures of installing RT kernel on Jetson (for NVIDIA L4T 35.1 or above) (from [Nivida Developer forums](https://forums.developer.nvidia.com/t/jetpack-5-1-rt-patch-not-working/247771))
1. Put the target board into Recovery Mode and connect with a USB Type-C cable to another Ubuntu device(the host). Ann perform steps 2-5 on the host.  
**Example connection for Jetson Agx Xavier:**  
   1. Connect the Linux host computer to the front USB Type-C connector on the target board. (i.e. J512.)
   2. Ensure the board is powered off.
   3. Press and hold down the Force Recovery button. (middle one)
   4. Press and hold down the Power button. (left one)
   5. Release both buttons.
   > To determine whether the board is in Force Recovery Mode, see [page](https://docs.nvidia.com/jetson/archives/r34.1/DeveloperGuide/text/IN/QuickStart.html#to-determine-whether-the-developer-kit-is-in-force-recovery-mode)
   
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
5. Replace `5.10.104-rt63-tegra` according to existing folder under `Linux_for_Tegra/rootfs/usr/lib/modules/`.
6. Run the shell script on Terminal
```
chmod +x install.sh
sudo ./install.sh
```

## Enable kernel modules without reflash the system
Follow steps from [here](https://forums.developer.nvidia.com/t/no-ttyusb-ttyacm-shown-after-installed-jetpack6-0/299191/13)
*  ch341 module is needed for RS485  
*  gs_usb module is needed for canable  
### Verify if the module is enabled
The module is enabled if `sudo modprobe` with no error shown.
   e.g. `sudo modprobe gs_usb`
