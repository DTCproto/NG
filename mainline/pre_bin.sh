#!/bin/sh
set -eux

### pre env

# env
USE_TARGETPLATFORM="${TARGETPLATFORM:-unknown}"
USE_ACCOUNT="${RELEASE_ACCOUNT:-DTCproto}"

# 判断CPU
### eg: linux/amd64,linux/arm64,linux/arm/v7
case "${USE_TARGETPLATFORM}" in
  "linux/amd64")
    CPU_TYPE_FILE_NAME="64"
    ;;
  "linux/arm64")
    CPU_TYPE_FILE_NAME="arm64-v8a"
    ;;
  *)
    echo "Unsupported platform: ${USE_TARGETPLATFORM}" >&2;
    exit 1
    ;;
esac
FILE_NAME="Xray-linux-${CPU_TYPE_FILE_NAME}"

# 定义版本变量
V2_RELEASE_ACCOUNT="DTCproto"
V2_RELEASE_REPO="NG"
V2_RELEASE_VERSION=$(nslookup api.github.com 8.8.4.4 | grep '^Address:' | grep -v 8.8.4.4 | sed 's/Address: //g' | head -n1 | xargs -I{} curl -ks --resolve api.github.com:443:{} "https://api.github.com/repos/DTCproto/NG/releases" | grep "tag_name" | head -n 1 | sed 's/\"//g;s/,//g;s/ //g;s/tag_name://g' | xargs -i echo '{}')

X_RELEASE_ACCOUNT="XTLS"
X_RELEASE_REPO="Xray-core"
X_RELEASE_VERSION=$(nslookup api.github.com 8.8.4.4 | grep '^Address:' | grep -v 8.8.4.4 | sed 's/Address: //g' | head -n1 | xargs -I{} curl -ks --resolve api.github.com:443:{} "https://api.github.com/repos/XTLS/Xray-core/releases" | grep "tag_name" | head -n 1 | sed 's/\"//g;s/,//g;s/ //g;s/tag_name://g' | xargs -i echo '{}')

# 获取下载链接
case "${USE_ACCOUNT}" in
  "XTLS")
    download_url="https://github.com/${X_RELEASE_ACCOUNT}/${X_RELEASE_REPO}/releases/download/${X_RELEASE_VERSION}/${FILE_NAME}.zip"
    ;;
  *)
    download_url="https://github.com/${V2_RELEASE_ACCOUNT}/${V2_RELEASE_REPO}/releases/download/${V2_RELEASE_VERSION}/${FILE_NAME}.zip"
    ;;
esac

# 下载文件预览链接
echo "Downloading from: ${download_url}"

### ==================文件操作=================== ###

# core路径
core_path="/usr/opt/core"

# 强制覆盖旧版本
rm -rf "${core_path}"
mkdir -p "${core_path}"

# 下载
curl -k -L -O "${download_url}"

unzip -d "${core_path}" "${FILE_NAME}.zip"

# 安装路径
asset_path="/usr/opt/asset"

# 强制覆盖旧版本
rm -rf "${asset_path}"
mkdir -p "${asset_path}"

# 下载
curl -k -L -O "https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat"
curl -k -L -O "https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geoip.dat"

mv *.dat "${asset_path}"

### 赋权
chmod 755 "${core_path}"/*
chmod 640 "${asset_path}"/*.dat
