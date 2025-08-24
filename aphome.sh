#!/bin/sh
# =========================================
# Alpine Linux 一键修改主机名脚本（交互式）
# =========================================

echo "请输入新的主机名:"
read -r NEW_HOSTNAME

# 检查是否输入为空
if [ -z "$NEW_HOSTNAME" ]; then
    echo "[ERROR] 主机名不能为空！"
    exit 1
fi

# 1. 临时修改
echo "[INFO] 临时修改主机名为: $NEW_HOSTNAME"
hostname "$NEW_HOSTNAME"

# 2. 永久修改 /etc/hostname
echo "[INFO] 永久修改 /etc/hostname"
echo "$NEW_HOSTNAME" > /etc/hostname

# 3. 更新 /etc/hosts
echo "[INFO] 更新 /etc/hosts"
if grep -q "127.0.0.1" /etc/hosts; then
    sed -i "s/127\.0\.0\.1.*/127.0.0.1   $NEW_HOSTNAME localhost/" /etc/hosts
else
    echo "127.0.0.1   $NEW_HOSTNAME localhost" >> /etc/hosts
fi

# 4. 重启 hostname 服务立即生效
if [ -x /etc/init.d/hostname ]; then
    /etc/init.d/hostname restart
fi

echo "[DONE] 主机名已修改为: $NEW_HOSTNAME"
