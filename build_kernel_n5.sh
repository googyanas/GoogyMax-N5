#!/bin/sh
export KERNELDIR=`readlink -f .`
export PARENT_DIR=`readlink -f ..`
export CROSS_COMPILE=/usr/bin/aarch64-linux-gnu-
export KCONFIG_NOTIMESTAMP=true

VER="\"-Googy-Max-N5-v$1\""
cp -f /home/anas/N5/Kernel/arch/arm64/configs/googymax-n5_defconfig /home/anas/N5/googymax-n5_defconfig
sed "s#^CONFIG_LOCALVERSION=.*#CONFIG_LOCALVERSION=$VER#" /home/anas/N5/googymax-n5_defconfig > /home/anas/N5/Kernel/arch/arm64/configs/googymax-n5_defconfig

export ARCH=arm64
export SUBARCH=arm64

find -name '*.ko' -exec rm -rf {} \;

rm -f /home/anas/N5/Kernel/arch/arm64/boot/Image*.*
rm -f /home/anas/N5/Kernel/arch/arm64/boot/.Image*.*
make googymax-n5_defconfig || exit 1

make -j4 || exit 1

mkdir -p /home/anas/N5/Release/system/lib/modules
rm -rf /home/anas/N5/Release/system/lib/modules/*
find -name '*.ko' -exec cp -av {} /home/anas/N5/Release/system/lib/modules/ \;
${CROSS_COMPILE}strip --strip-unneeded /home/anas/N5/Release/system/lib/modules/*

./tools/dtbtool -o /home/anas/N5/Out/dt.img -s 4096 -p ./scripts/dtc/ arch/arm64/boot/dts/

cd /home/anas/N5/Out
./packimg.sh

cd /home/anas/N5/Release
zip -r ../Googy-Max-N5_Kernel_${1}.zip .

adb push /home/anas/N5/Googy-Max-N5_Kernel_${1}.zip /sdcard/Googy-Max-N5_Kernel_${1}.zip

adb kill-server

echo "Googy-Max-N5_Kernel_${1}.zip READY !"
