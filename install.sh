ROOT=$PWD
JETSON="Jetson_Linux_R35.4.1_aarch64.tbz2"
SOURCES="public_sources.tbz2"
ROOTFS="Tegra_Linux_Sample-Root-Filesystem_R35.4.1_aarch64.tbz2"
TOOLCHAIN="aarch64--glibc--stable-final.tar.gz"
TOOLCHAIN_DIR=$ROOT/l4t-gcc

echo "Extracting Linux_for_Tegra..."
tar -xjf $JETSON

echo "Extracting rootfs..."
cd $ROOT/Linux_for_Tegra/rootfs
sudo tar -xjf $ROOT/$ROOTFS

echo "Extracting source..."
cd $ROOT
tar -xjf $SOURCES

echo "Extracting toolchain..."
mkdir -p $TOOLCHAIN_DIR
tar -xzf $TOOLCHAIN -C $TOOLCHAIN_DIR

export CROSS_COMPILE_AARCH64_PATH=$TOOLCHAIN_DIR
export CROSS_COMPILE_AARCH64=$TOOLCHAIN_DIR/bin/aarch64-buildroot-linux-gnu-

echo "Extracting src kernel..."
cd $ROOT/Linux_for_Tegra/source/public
tar -xjf kernel_src.tbz2

echo "Applying rt-patch..."
./kernel/kernel-5.10/scripts/rt-patch.sh apply-patches

echo "Building src kernel..."
mkdir -p kernel_out
./nvbuild.sh -o $PWD/kernel_out
KERNEL_OUT="$PWD/kernel_out"

echo "Apply binariesl..."
cd $ROOT/Linux_for_Tegra
sudo ./apply_binaries.sh

echo "Copy from kernel_out..."
cd $ROOT/Linux_for_Tegra
sudo cp source/public/kernel_out/drivers/gpu/nvgpu/nvgpu.ko rootfs/usr/lib/modules/5.10.104-rt63-tegra/kernel/drivers/gpu/nvgpu/nvgpu.ko
cp -r source/public/kernel_out/arch/arm64/boot/dts/nvidia/* kernel/dtb/.
cp -r source/public/kernel_out/arch/arm64/boot/Image kernel/Image

echo "Make kernel_out modules..."
cd $ROOT/Linux_for_Tegra/source/public/kernel_out
sudo make INSTALL_MOD_PATH=$ROOT/Linux_for_Tegra/rootfs O= modules_install

echo "Extracting display drivers..."
cd $ROOT/Linux_for_Tegra/source/public
tar -xjf nvidia_kernel_display_driver_source.tbz2
cd NVIDIA-kernel-module-source-TempVersion

export LOCALVERSION="-tegra"
export IGNORE_PREEMPT_RT_PRESENCE=1

echo "Make display drivers for rt-patch..."
make \
    modules -j`nproc` \
    SYSSRC=$ROOT/Linux_for_Tegra/source/public/kernel/kernel-5.10 \
    SYSOUT=$ROOT/Linux_for_Tegra/source/public/kernel_out \
    CC=${CROSS_COMPILE_AARCH64}gcc \
    LD=${CROSS_COMPILE_AARCH64}ld.bfd \
    AR=${CROSS_COMPILE_AARCH64}ar \
    CXX=${CROSS_COMPILE_AARCH64}g++ \
    OBJCOPY=${CROSS_COMPILE_AARCH64}objcopy \
    TARGET_ARCH=aarch64 \
    ARCH=arm64

echo "Copy display drivers from kernel-open..."
DRIVER_DIR=$ROOT/Linux_for_Tegra/rootfs/lib/modules/5.10.104-rt63-tegra/extra/opensrc-disp
sudo mkdir -p $DRIVER_DIR
cd $ROOT/Linux_for_Tegra/source/public/NVIDIA-kernel-module-source-TempVersion/kernel-open
sudo cp nvidia-modeset.ko nvidia.ko nvidia-drm.ko $DRIVER_DIR

echo "Installing QEMU binary in rootfs"
cd $ROOT/Linux_for_Tegra
L4T_ROOTFS_DIR="$ROOT/Linux_for_Tegra/rootfs"
sudo cp "${KERNEL_OUT}/System.map" ${L4T_ROOTFS_DIR}
QEMU_BIN="/usr/bin/qemu-aarch64-static"
sudo install --owner=root --group=root "${QEMU_BIN}" "${L4T_ROOTFS_DIR}/usr/bin/"
pushd ${L4T_ROOTFS_DIR}
LC_ALL=C sudo chroot . depmod -a -F System.map 5.10.104-rt63-tegra
popd
echo "Removing QEMU binary from rootfs"
sudo rm -f "${L4T_ROOTFS_DIR}/usr/bin/qemu-aarch64-static"

echo "Flashing"
sudo ./flash.sh jetson-agx-xavier-devkit mmcblk0p1
