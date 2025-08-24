#!/bin/bash
set -e

echo "开始系统自动清理..."

# 检测系统类型
if [ -f /etc/alpine-release ]; then
    OS="alpine"
else
    OS="other"
fi

echo "检测到 $OS 系统"

# 清理日志文件（保留最近 7 天）
echo "清理日志文件（保留最近 7 天）..."
if [ "$OS" = "alpine" ]; then
    find /var/log -type f -mtime +7 -exec truncate -s 0 {} \;
    echo "[INFO] Alpine 系统，旧日志已清空"
else
    if command -v journalctl >/dev/null 2>&1; then
        journalctl --vacuum-time=7d
        echo "[INFO] systemd 日志已清理"
    else
        echo "[WARN] journalctl 未安装，跳过 systemd 日志清理"
    fi
fi

# 清理临时文件
echo "清理临时文件..."
rm -rf /tmp/* /var/tmp/*

# 清理缓存（仅针对 apk）
if [ "$OS" = "alpine" ]; then
    echo "清理 apk 缓存..."
    apk cache clean
fi

echo "系统清理完成！"
