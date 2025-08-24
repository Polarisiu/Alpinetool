#!/bin/sh
# =========================================
# Alpine Linux 一键切换中文脚本
# =========================================

# 1. 安装中文语言包
echo "[INFO] 安装中文语言包..."
apk update
apk add musl-locales musl-locales-lang ttf-dejavu fontconfig

# 2. 配置系统语言环境
echo "[INFO] 配置系统语言环境..."
cat << 'EOF' >> /etc/profile
export LANG=zh_CN.UTF-8
export LANGUAGE=zh_CN:zh
export LC_ALL=zh_CN.UTF-8
EOF

# 3. 立即生效
source /etc/profile

# 4. 显示设置结果
echo "[INFO] 当前系统语言设置:"
locale

echo "[INFO] 测试中文显示:"
echo "你好，Alpine!"

echo "[DONE] Alpine 已切换为中文环境。重启终端或系统可完全生效。"
