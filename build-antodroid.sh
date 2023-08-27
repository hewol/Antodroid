#!/bin/bash

git clone https://github.com/AndyCGYan/lineage_patches_unified lineage_patches_unified -b lineage-20-light
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
repo init -u https://github.com/LineageOS/android.git -b lineage-20.0 --git-lfs
repo sync -j$(nproc --all)
source build/envsetup.sh
repopick 321337 -f # Deprioritize important developer notifications
repopick 321338 -f # Allow disabling important developer notifications
repopick 321339 -f # Allow disabling USB notifications
repopick 340916 # SystemUI: add burnIn protection
repopick 342860 # codec2: Use numClientBuffers to control the pipeline
repopick 342861 # CCodec: Control the inputs to avoid pipeline overflow
repopick 342862 # [WA] Codec2: queue a empty work to HAL to wake up allocation thread
repopick 342863 # CCodec: Use pipelineRoom only for HW decoder
repopick 342864 # codec2: Change a Info print into Verbose
# Temporarily revert "13-firewall" changes
(cd frameworks/base; git revert e91d98e3327a805d1914e7fb1617f3ac081c0689^..cfd9c1e4c8ea855409db5a1ed8f84f4287a37d75 --no-edit)
(cd packages/apps/Settings; git revert 406607e0c16ed23d918c68f14eb4576ce411bb73 --no-edit)
(cd packages/modules/Connectivity; git revert 386950b4ea592f2a8e4937444955c9b91ff1f277^..1fa42c03891ba203a321b597fb5709e3a9131f0e --no-edit)
(cd system/netd; git revert dbf5d67951a0cd6e9b76ca2c08cf2b39ae6d708d^..5c89ab94a797fce13bf858be0f96541bf9f3bfe7 --no-edit)
bash ./lineage_build_unified/apply_patches.sh ./lineage_patches_unified/${1}
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
lunch lineage_${TARGET}-userdebug
make installclean
make -j$(nproc --all) systemimage
mv $OUT/system.img ~/build-output/antodroid-1.0-system.img
mkdir -p ${OUT_DIR}/gsi
cp ${OUT_DIR}/system.img ${OUT_DIR}/gsi/${GSI_IMAGE_NAME}.img
echo "build done"

