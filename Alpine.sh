#!/bin/sh
# ========================================
# Alpine/Ubuntu/Debian/CentOS 系统管理菜单
# 支持永久别名 A/a + 自调用循环菜单 (ash/bash 兼容)
# ========================================

GREEN="\033[32m"
RED="\033[31m"
RESET="\033[0m"

SCRIPT_PATH="/root/alpine.sh"
SCRIPT_URL="https://raw.githubusercontent.com/Polarisiu/Alpinetool/main/Alpine.sh"
ALIAS_SCRIPT="/root/alpine_alias.sh"
FLAG_FILE="$HOME/.alpine_alias_created"

# ---------- 函数：添加别名 ----------
add_alias() {
    FILE="$1"
    if [ -f "$FILE" ]; then
        grep -q "alias A=" "$FILE" 2>/dev/null || {
            echo "alias A='$ALIAS_SCRIPT'" >> "$FILE"
            echo "alias a='$ALIAS_SCRIPT'" >> "$FILE"
        }
    fi
}

# ---------- 函数：移除别名 ----------
remove_alias() {
    FILE="$1"
    [ -f "$FILE" ] && sed -i '/alias A=/d;/alias a=/d' "$FILE"
}

# ---------- 下载主脚本 ----------
if [ ! -f "$SCRIPT_PATH" ]; then
    printf "${GREEN}正在下载主菜单脚本...${RESET}\n"
    curl -sL "$SCRIPT_URL" -o "$SCRIPT_PATH"
    chmod +x "$SCRIPT_PATH"
fi

# ---------- 创建别名启动脚本 ----------
if [ ! -f "$ALIAS_SCRIPT" ]; then
    echo "#!/bin/sh" > "$ALIAS_SCRIPT"
    echo "exec sh $SCRIPT_PATH" >> "$ALIAS_SCRIPT"
    chmod +x "$ALIAS_SCRIPT"
fi

# ---------- 设置永久别名 ----------
if [ ! -f "$FLAG_FILE" ]; then
    for f in ~/.bashrc ~/.bash_profile ~/.profile ~/.ashrc; do
        add_alias "$f"
    done
    alias A="$ALIAS_SCRIPT"
    alias a="$ALIAS_SCRIPT"
    # 不在这里打印提示，改到 menu() 显示，避免被 clear 覆盖
fi

# ---------- 菜单函数 ----------
menu() {
    clear
    # 首次运行提示
    if [ ! -f "$FLAG_FILE" ]; then
        printf "${GREEN}✅ 已创建快捷别名：A 和 a,重启终端生效${RESET}\n\n"
        touch "$FLAG_FILE"
    fi
    printf "${GREEN}=== 系统管理菜单 ===${RESET}\n"
    printf "${GREEN}[01] 系统更新${RESET}\n"
    printf "${GREEN}[02] 修改SSH端口${RESET}\n"
    printf "${GREEN}[03] 防火墙管理${RESET}\n"
    printf "${GREEN}[04] Fail2Ban${RESET}\n"
    printf "${GREEN}[05] 换源${RESET}\n"
    printf "${GREEN}[06] 系统清理${RESET}\n"
    printf "${GREEN}[07] 设置中文${RESET}\n"
    printf "${GREEN}[08] 修改主机名${RESET}\n"
    printf "${GREEN}[09] Docker 管理${RESET}\n"
    printf "${GREEN}[10] Hysteria2${RESET}\n"
    printf "${GREEN}[11] 3XUI 面板${RESET}\n"
    printf "${GREEN}[12] 代理工具${RESET}\n"
    printf "${GREEN}[13] 应用商店${RESET}\n"
    printf "${GREEN}[14] 更新脚本${RESET}\n"
    printf "${GREEN}[15] 卸载脚本${RESET}\n"
    printf "${GREEN}[0]  退出${RESET}\n\n"
    printf "${GREEN}请选择操作: ${RESET}"
    read choice
    case "$choice" in
        1) apk update && apk add --no-cache bash curl wget vim tar sudo git 2>/dev/null \
              || (apt update && apt install -y curl wget vim tar sudo git) \
              || (yum install -y curl wget vim tar sudo git) ;;
        2) bash <(curl -fsSL https://raw.githubusercontent.com/Polarisiu/Alpinetool/main/apsdk.sh) ;;
        3) bash <(curl -fsSL https://raw.githubusercontent.com/Polarisiu/Alpinetool/main/apfeew.sh) ;;
        4) bash <(curl -fsSL https://raw.githubusercontent.com/Polarisiu/Alpinetool/main/apFail2Ban.sh) ;;
        5) bash <(curl -fsSL https://raw.githubusercontent.com/Polarisiu/Alpinetool/main/aphuanyuan.sh) ;;
        6) bash <(curl -fsSL https://raw.githubusercontent.com/Polarisiu/Alpinetool/main/apql.sh) ;;
        7) bash <(curl -fsSL https://raw.githubusercontent.com/Polarisiu/Alpinetool/main/apcn.sh) ;;
        8) bash <(curl -fsSL https://raw.githubusercontent.com/Polarisiu/Alpinetool/main/aphome.sh) ;;
        9) bash <(curl -fsSL https://raw.githubusercontent.com/Polarisiu/Alpinetool/main/apdocker.sh) ;;
        10) bash <(curl -fsSL https://raw.githubusercontent.com/Polarisiu/proxy/main/aphy2.sh) ;;
        11) bash <(curl -sL  https://raw.githubusercontent.com/Polarisiu/proxy/main/3xuiAlpine.sh) ;;
        12) bash <(curl -fsSL https://raw.githubusercontent.com/Polarisiu/proxy/main/proxy.sh) ;;
        13) bash <(curl -fsSL https://raw.githubusercontent.com/Polarisiu/app-store/main/store.sh) ;;
        14) printf "${GREEN}正在下载最新版本脚本...${RESET}\n"
            curl -sL "$SCRIPT_URL" -o "$SCRIPT_PATH"
            chmod +x "$SCRIPT_PATH"
            printf "${GREEN}✅ 脚本已更新完成，正在重新启动菜单...${RESET}\n"
            sh "$SCRIPT_PATH"
            exit 0
            ;;
        15) printf "${GREEN}正在删除别名和脚本...${RESET}\n"
            for f in ~/.bashrc ~/.bash_profile ~/.profile ~/.ashrc; do
                remove_alias "$f"
            done
            rm -f "$SCRIPT_PATH" "$ALIAS_SCRIPT" "$FLAG_FILE"
            printf "${GREEN}✅ 卸载完成${RESET}\n"
            exit 0
            ;;
        0) exit 0 ;;
        *) printf "${RED}无效选择，请重新输入${RESET}\n" ;;
    esac
    printf "${RED}按回车键返回菜单...${RESET}\n"
    read
    menu
}

# ---------- 主程序 ----------
menu
