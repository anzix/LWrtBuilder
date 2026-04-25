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
#

# --- Debugging information: Prints all possible environment variables ---
echo "--- The script has started executing and is checking environment variables ---"
echo "WORKFLOW_NAME: $WORKFLOW_NAME" # This is the most important
echo "TAG (from libwrt): $TAG"
echo "TAG2 (from immortalwrt): $TAG2"
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
   echo "HINT: You can use this version via the \$KERNEL_VERSION variable"

   # Change the default IP, for AXT1800 it's 192.168.8.1
   # WARN: Если тут будет больше ipq60xx устройств то надо делать if elif условие
   sed -i 's/192.168.1.1/192.168.8.1/g' package/base-files/files/bin/config_generate
   echo "AXT-1800 IP changed to 192.168.8.1"

   # Update the Golang version (currently deprecated; comments are retained for easy rollback)
   # rm -rf feeds/packages/lang/golang && echo "Removing old golang"
   # git clone https://github.com/sbwml/packages_lang_golang -b 25.x feeds/packages/lang/golang
   # cat feeds/packages/lang/golang/golang/Makefile

   # Download the corresponding kernel version of Vermagic
   wget -qO- "https://downloads.immortalwrt.org/snapshots/targets/qualcommax/ipq60xx/kmods/" | grep -oP "$KERNEL_VERSION-1-\K[0-9a-f]+" | head -n 1 > vermagic && echo "Current Vermagic:" && cat vermagic
   wget https://raw.githubusercontent.com/m0eak/openwrt_patch/refs/heads/main/gl-axt1800/9999-gl-axt1800-dts-change-cooling-level.patch && echo "Download successful" || echo "Download error"
   mv 9999-gl-axt1800-dts-change-cooling-level.patch ./target/linux/qualcommax/dts/9999-gl-axt1800-dts-change-cooling-level.patch && echo "Move successful" || echo "Move error"

   VERMAGIC=$(cat vermagic)
   echo "VERMAGIC_FIX=${VERMAGIC}" >> $GITHUB_ENV

   # Modify vermagic
   if [ ! -s ./vermagic ]; then
     echo "none vermagic"
   else
     sed -i '/grep '\''=\[ym\]'\'' $(LINUX_DIR)\/\.config\.set | LC_ALL=C sort | $(MKHASH) md5 > $(LINUX_DIR)\/\.vermagic/s/^/# /' ./include/kernel-defaults.mk
     sed -i '/$(LINUX_DIR)\/\.vermagic/a \\tcp $(TOPDIR)/vermagic $(LINUX_DIR)/.vermagic' ./include/kernel-defaults.mk
   fi

   # --- Logic Block 2: Processing x86 immortalwrt ---
# elif [[ "$WORKFLOW_NAME" == "x86_immortalwrt" ]]; then
#     echo ">>> Detected: $WORKFLOW_NAME. Initiating specific modifications to x86 immortalwrt"
#
#     # The immortalwrt workflow defines TAG2, so VERSION2 is now valid!
#     VERSION2=${TAG2#v}
#     echo "immortalwrt 当前版本 (VERSION2): $VERSION2"
#
#     # Update the Golang version (currently deprecated; comments are retained for easy rollback)
#     # rm -rf feeds/packages/lang/golang && echo "Removing old golang"
#     # git clone https://github.com/sbwml/packages_lang_golang -b 25.x feeds/packages/lang/golang
#     # cat feeds/packages/lang/golang/golang/Makefile
#
#     # Change the default IP
#     sed -i 's/192.168.1.1/192.168.100.1/g' package/base-files/files/bin/config_generate
#     echo "Change the x86 IP address to 192.168.100.1"
#
#     # Download the corresponding kernel version of Vermagic
#     if [ -n "$VERSION2" ]; then
#         sed -i "s/replace/$VERSION2/g" $GITHUB_WORKSPACE/files/etc/uci-defaults/zzz && echo "VERSION replacement successful"
#     else
#         echo "Warning: VERSION2 is empty, unable to download vermagic."
#     fi
#
#     # Download the corresponding kernel version of Vermagic
#     if [ -n "$VERSION2" ]; then
#         curl -s "https://downloads.immortalwrt.org/releases/$VERSION2/targets/x86/64/immortalwrt-$VERSION2-x86-64.manifest" | grep kernel | awk '{print $3}' | sed -E 's/.*~([0-9a-f]+)-r[0-9]+$/\1/; s/.*-([0-9a-f]+)$/\1/' > vermagic && echo "Immortalwrt Vermagic Done" && echo "Current Vermagic: " && cat vermagic
#     else
#         echo "Warning: VERSION2 is empty, unable to download vermagic."
#     fi
#
#     # Modify Vermagic
#     if [ -s ./vermagic ]; then
#         sed -i '/grep '\''=\[ym\]'\'' $(LINUX_DIR)\/\.config\.set | LC_ALL=C sort | $(MKHASH) md5 > $(LINUX_DIR)\/\.vermagic/s/^/# /' ./include/kernel-defaults.mk
#         sed -i '/$(LINUX_DIR)\/\.vermagic/a \\tcp $(TOPDIR)/vermagic $(LINUX_DIR)/.vermagic' ./include/kernel-defaults.mk
#     else
#         echo "none Vermagic, skip the modification."
#     fi
fi
