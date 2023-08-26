#!/bin/bash

export BUILD_DIR=~/antodroid
export ANDROID_VERSION=13
export TARGET_ARCH=arm64
export OUT_DIR=${BUILD_DIR}/out/target/product/gsi_${TARGET_ARCH}
export GSI_IMAGE_NAME=antodroid
export APK_DIR=~/antodroid/apks
export BOOT_ANIMATION_DIR=~/antodroid/bold_loader.zip
export DARK_MODE_ENABLED=true
export DEVICE_NAME="Antodroid"
# export WALLPAPERS_DIR=~/antodroid/wallpapers # Soon to add
BUILD_DATE=$(date +'%d%m%y')
BUILD_TIME=$(date +'%H%M%S')
BUILD_NUMBER="antodroid-1.0 -${BUILD_DATE}-${BUILD_TIME}"
repo init -u https://github.com/LineageOS/android.git -b lineage-${ANDROID_VERSION}-phh
repo sync -j$(nproc --all)
source build/envsetup.sh
lunch lineage_${TARGET_ARCH}-userdebug
make -j$(nproc --all) systemimage
if [ ${DARK_MODE_ENABLED} == "true" ]; then
    sed -i 's/ro.build.version.codename=REL/ro.build.version.codename=REL\nro.build.version.ui=GoogleEdition/g' ${OUT_DIR}/system/build.prop
fi
sed -i "s/ro.product.model=Antodroid/ro.product.model=${DEVICE_NAME}/g" ${OUT_DIR}/system/build.prop
sed -i 's/qemu.hw.mainkeys=1/qemu.hw.mainkeys=0/g' ${OUT_DIR}/system/build.prop
sed -i 's/Welcome to LineageOS/Welcome to Antodroid Alpha/g' ${OUT_DIR}/system/etc/init/welcome.qti.rc
rm ${OUT_DIR}/system/media/lineageos_logo.png
rm ${OUT_DIR}/system/media/lineage_logo.png
find ${OUT_DIR}/system -type f -exec sed -i 's/LineageOS/Antodroid/g' {} +
sed -i 's/#6200EE/#1976D2/g' ${OUT_DIR}/system/product/overlay/accent.xml
sed -i 's/#03DAC5/#1976D2/g' ${OUT_DIR}/system/product/overlay/accent.xml
cp -r ${WALLPAPERS_DIR} ${OUT_DIR}/system/media/
echo "${BUILD_NUMBER}" > ${OUT_DIR}/system/build.prop
mkdir -p ${OUT_DIR}/gsi
cp ${OUT_DIR}/system.img ${OUT_DIR}/gsi/${GSI_IMAGE_NAME}.img
echo "build done"
