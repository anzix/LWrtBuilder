#!/bin/bash
#
# Copyright (c) 2019-2020 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part1.sh
# Description: OpenWrt DIY script part 1 (Before Update feeds)

# --- Debugging information: Prints all possible environment variables ---
echo "--- The script has started executing and is checking environment variables ---"
echo "WORKFLOW_NAME: $WORKFLOW_NAME" # This is the most important
echo "TAG (from LiBwrt): $TAG"
echo "------------------------------------------"

if [[ "$WORKFLOW_NAME" == "AXT-1800" ]]; then
   echo ">>> Device detected: $WORKFLOW_NAME. Starting to execute LibWrt-specific modifications"

   # The logic below always executes, as the workflow is configured for AXT-1800
   # Define path to kernel-6.12 file
   KERNEL_FILE="./target/linux/generic/kernel-6.12"
   cat $KERNEL_FILE

   # Check if file exists
   if [ ! -f "$KERNEL_FILE" ]; then
     echo "Error: File $KERNEL_FILE not found"
     exit 1
   fi

   # Extract major and minor version number, then assemble full kernel version number
   MAJOR_VERSION=$(grep -oP 'LINUX_VERSION-\K[0-9.]+' "$KERNEL_FILE" | head -1)
   MINOR_VERSION=$(grep -oP 'LINUX_VERSION-[0-9.]+ = \K.[0-9]+' "$KERNEL_FILE" | head -1)
   KERNEL_VERSION="${MAJOR_VERSION}${MINOR_VERSION}"

   # Check version format and outputs it
   if [[ ! "$KERNEL_VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
     echo "Error: Failed to extract correct kernel version number"
     exit 1
   fi
   echo "Extracted kernel version: $KERNEL_VERSION"

   # Update the Golang version (currently deprecated; comments are retained for easy rollback)
   # rm -rf feeds/packages/lang/golang && echo "Removing old golang"
   # git clone https://github.com/sbwml/packages_lang_golang -b 25.x feeds/packages/lang/golang
   # cat feeds/packages/lang/golang/golang/Makefile

   # Получаем совместимую версию ядра Vermagic из ImmortalWrt
   REMOTE_IMM_KERNEL_VERSION=$(curl -s "https://downloads.immortalwrt.org/releases/25.12-SNAPSHOT/targets/qualcommax/ipq60xx/kmods/" \
     | grep -oP "$KERNEL_VERSION" | head -n 1)

   # Сравнение
   if [ "$KERNEL_VERSION" = "$REMOTE_IMM_KERNEL_VERSION" ]; then
     echo "Kernel version matches ✅, downloading IMM vermagic MD5 hash file ..."
     wget -qO- "https://downloads.immortalwrt.org/releases/25.12-SNAPSHOT/targets/qualcommax/ipq60xx/kmods/" | \
        grep -oP "$KERNEL_VERSION-1-\K[0-9a-f]+"  | head -n 1 > vermagic && \
        echo "Download successful, current vermagic:" && cat vermagic
     # Saving variables
     VERMAGIC=$(cat vermagic)
     echo "VERMAGIC_FIX=${VERMAGIC}" >> $GITHUB_ENV
   else
     echo "Kernel version mismatch ❌"
     echo "Probably there is no such kernel "$KERNEL_VERSION" in the repository, or the url is broken"
     exit 1
   fi

   # Patching the kernel
   #
   # Download patches and move to cloned LiBwrt in corresponding path.
   wget https://raw.githubusercontent.com/m0eak/openwrt_patch/refs/heads/main/gl-axt1800/9999-gl-axt1800-dts-change-cooling-level.patch \
      -O ./target/linux/qualcommax/patches-6.12/9999-gl-axt1800-dts-change-cooling-level.patch \
      && echo "Download successful" || echo "Download error"

   # Modify vermagic
   #
   # Проверка если вдруг наш vermagic не создался
   if [ ! -s ./vermagic ]; then
     echo "None vermagic"
   else
     # Первое, убирает строку связанную с созданием OpenWrt'шного vermagic с MD5
     # хешем, и второе, вставляет ниже рядом строку которая будет использовать
     # наш собственный vermagic файла с MD5 хешем
     echo "Modifying vermagic to our ..."
     sed -i '/grep '\''=\[ym\]'\'' $(LINUX_DIR)\/\.config\.set | LC_ALL=C sort | $(MKHASH) md5 > $(LINUX_DIR)\/\.vermagic/s/^/# /' ./include/kernel-defaults.mk
     sed -i '/$(LINUX_DIR)\/\.vermagic/a \\tcp $(TOPDIR)/vermagic $(LINUX_DIR)/.vermagic' ./include/kernel-defaults.mk
     echo "Modification successful"
   fi
fi
