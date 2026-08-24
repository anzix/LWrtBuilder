#!/bin/bash
#
# Copyright (c) 2019-2020 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
#

# Define target directory
TARGET_DIR="$PWD/package/custom"

# Define repositories and branches to clone
# INFO: At the end, after =, it's a branch.
declare -A REPOS=(

    # Сетевой оптимизатор для OpenWrt роутера
    # Used by: CONFIG_PACKAGE_luci-app-turboacc=y
    ["https://github.com/chenmozhijin/turboacc"]=""

    # Регулировщик вентиляторов на роутере (если есть)
    # Used by: CONFIG_PACKAGE_fancontrol=y
    ["https://github.com/m0eak/fancontrol"]=""

    # Автоматически получает отформатированное расширение раздела и автоматически
    # монтирует его
    # Used by: CONFIG_PACKAGE_luci-app-partexp=y
    # ["https://github.com/sirpdboy/luci-app-partexp"]=""

    # Данный репозиторий отсюда более новый и с исправлениями, в отличие от
    # официального репозитория ImmortalWrt
    # Used by: CONFIG_PACKAGE_luci-app-tailscale-community=y
    # ["https://github.com/Tokisaki-Galaxy/luci-app-tailscale-community.git"]=""

    # Used by: CONFIG_PACKAGE_luci-app-nikki=y
    ["https://github.com/nikkinikki-org/OpenWrt-nikki"]=""

    # Used by: CONFIG_PACKAGE_luci-app-momo=y
    ["https://github.com/nikkinikki-org/OpenWrt-momo"]=""

    # Used by: CONFIG_PACKAGE_luci-proto-amneziawg=y
    ["https://github.com/Slava-Shchipunov/awg-openwrt"]=""
)

CONFLICTING_MAKEFILE_KEYWORDS=()

# Fix rust build error
patch_rust_makefile() {
    if [ -e "feeds/packages/lang/rust/Makefile" ]; then
        sed -i 's/--set=llvm\.download-ci-llvm=true/--set=llvm.download-ci-llvm=false/' feeds/packages/lang/rust/Makefile
    fi
}

reset_custom_package_dir() {
    if [ -z "$TARGET_DIR" ] || [ "$TARGET_DIR" = "/" ]; then
        echo "Error: TARGET_DIR is abnormal and refuses to delete: '$TARGET_DIR'"
        exit 1
    fi

    rm -rf "$TARGET_DIR"
    mkdir -p "$TARGET_DIR"
}

remove_conflicting_makefiles() {
    local keyword
    local file
    local file_lower

    echo "Start cleaning up makefiles in feeds that will be overwritten by package/custom"
    find . -type f -name "Makefile" ! -path "$TARGET_DIR/*" -print0 |
    while IFS= read -r -d $'\0' file; do
        file_lower="${file,,}"
        for keyword in "${CONFLICTING_MAKEFILE_KEYWORDS[@]}"; do
            if [[ "$file_lower" == *"$keyword"* ]]; then
                echo "Delete conflict Makefile: $file"
                rm -f "$file"
                break
            fi
        done
    done
    echo "Conflict Makefile cleanup is complete"
}

# Clone repositories
clone_repo() {
    local repo_url=$1
    local repo_branch=${REPOS[$repo_url]}
    local repo_name
    local repo_dir

    repo_name="$(basename -s .git "$repo_url")"
    repo_dir="$TARGET_DIR/$repo_name"

    if [ -d "$repo_dir" ]; then
        echo "The directory $repo_dir already exists, skip cloning"
        return 0
    fi

    echo "Cloning repository: $repo_name, URL: $repo_url, Branch: ${repo_branch:-default_branch}"
    if [ -z "$repo_branch" ]; then
        git clone --single-branch --depth 1 "$repo_url" "$repo_dir"
    else
        git clone --single-branch --depth 1 -b "$repo_branch" "$repo_url" "$repo_dir"
    fi
}

# Iterate over REPOS array and clone
clone_custom_repos() {
    local repo
    local failed=0

    echo "Starting to clone custom repositories"
    for repo in "${!REPOS[@]}"; do
        if clone_repo "$repo"; then
            echo "Repository cloned successfully: $(basename -s .git "$repo")"
        else
            echo "Failed to clone repository: $repo"
            failed=$((failed + 1))
        fi
    done

    if [ "$failed" -ne 0 ]; then
        echo "Error: $failed custom repositories failed to clone"
        exit 1
    fi
    echo "All custom repositories cloned successfully"
}

verify_turboacc_makefile() {
    local turboacc_luci_dir

    turboacc_luci_dir="$(find "$TARGET_DIR/turboacc" -maxdepth 1 -type d -name 'luci-app*' | head -n 1)"
    if [ -z "$turboacc_luci_dir" ] || [ ! -f "$turboacc_luci_dir/Makefile" ]; then
        echo "TurboACC luci-app Makefile not found, terminating GitHub Action"
        exit 1
    fi

    echo "TurboACC Makefile found, continuing"
}

patch_rust_makefile
reset_custom_package_dir
remove_conflicting_makefiles
clone_custom_repos
verify_turboacc_makefile
