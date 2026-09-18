#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
IMAGES_DIR="${SCRIPT_DIR}/output/images"
PACK_DIR="${SCRIPT_DIR}/output/update_pack"

rm -rf "${PACK_DIR}"
mkdir -p "${PACK_DIR}"

# Use the bootloader binaries and partition map from sysdrv tools
SYSDRV_PACK="/home/hspencer/luckfox-pico/sysdrv/tools/linux/Linux_Pack_Firmware/rockchip"
TOOLS_DIR="/home/hspencer/luckfox-pico/tools/linux/Linux_Pack_Firmware/rockchip"

cp /home/hspencer/luckfox-pico/output/image/MiniLoaderAll.bin "${PACK_DIR}/"
cp /home/hspencer/luckfox-pico/output/image/uboot.img "${PACK_DIR}/"
cp /home/hspencer/luckfox-pico/output/image/env.img "${PACK_DIR}/" 2>/dev/null || true
cp /home/hspencer/luckfox-pico/output/image/parameter.txt "${PACK_DIR}/"
cp "${IMAGES_DIR}/zboot.img" "${PACK_DIR}/boot.img"
cp "${IMAGES_DIR}/rootfs.ext4" "${PACK_DIR}/rootfs.img"

# Package package-file
cat << 'PFILE' > "${PACK_DIR}/package-file"
# NAME		Relative path
package-file	package-file
bootloader	MiniLoaderAll.bin
parameter	parameter.txt
uboot		uboot.img
boot		boot.img
rootfs		rootfs.img
PFILE

"${TOOLS_DIR}/afptool" -pack "${PACK_DIR}" "${IMAGES_DIR}/update_raw.img"
"${TOOLS_DIR}/rkImageMaker" -RK1106 "${PACK_DIR}/MiniLoaderAll.bin" "${IMAGES_DIR}/update_raw.img" "${IMAGES_DIR}/update.img" -os_type:androidos
rm -f "${IMAGES_DIR}/update_raw.img"
echo "==> Self-contained OpenIPC update.img created at: ${IMAGES_DIR}/update.img"
