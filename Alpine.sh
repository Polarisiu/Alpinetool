#!/bin/bash
# ========================================
# Alpine/Ubuntu/Debian/CentOS 系统管理菜单
# 支持永久快捷键 A/a + 自调用循环菜单
# ========================================

GREEN="\033[32m"
YELLOW="\033[33m"
RED="\033[31m"
RESET="\033[0m"

# ================== 脚本路径 ==================
SCRIPT_PATH="/root/alpine.sh"
SCRIPT_URL="https://raw.githubusercontent.com/Polarisiu/Alpinetool/main/Alpine.sh"
BIN_LINK_DIR="/usr/local/bin"

# ================== 首次运行自动安装 ==================
if [ ! -f "$SCRIPT_PATH" ]; then
    echo -e "${YELLOW}首次运行，正在保存脚本到 $SCRIPT_PATH ...${RESET}"
    curl -fsSL -o "$SCRIPT_PATH" "$SCRIPT_URL"
    if [ $? -ne 0 ]; then
        echo -e "${RED}❌ 下载失败，请检查网络或 URL${RESET}"
        exit 1
    fi
    chmod +x "$SCRIPT_PATH"

    # 创建快捷键 A/a
    ln -sf "$SCRIPT_PATH" "$BIN_LINK_DIR/A"
    ln -sf "$SCRIPT_PATH" "$BIN_LINK_DIR/a"

    echo -e "${GREEN}✅ 安装完成${RESET}"
    echo -e "${GREEN}💡 快捷键已添加：A 或 a 可快速启动${RESET}"
fi

# ================== 菜单函数 ==================
menu() {
    echo -e "${GREEN}===  Alpine系统管理菜单 ===${RESET}"
    echo -e "${GREEN}[01] 系统更新${RESET}"
    echo -e "${GREEN}[02] 修改SSH端口${RESET}"
    echo -e "${GREEN}[03] 防火墙管理${RESET}"
    echo -e "${GREEN}[04] Fail2Ban${RESET}"
    echo -e "${GREEN}[05] 换源${RESET}"
    echo -e "${GREEN}[06] 系统清理${RESET}"
    echo -e "${GREEN}[07] 设置中文${RESET}"
    echo -e "${GREEN}[08] 修改主机名${RESET}"
    echo -e "${GREEN}[09] Docker 管理${RESET}"
    echo -e "${GREEN}[10] Hysteria2${RESET}"
    echo -e "${GREEN}[11] 3XUI 面板${RESET}"
    echo -e "${GREEN}[12] 代理工具${RESET}"
    echo -e "${GREEN}[13] 应用商店${RESET}"
    echo -e "${GREEN}-------------------------${RESET}"
    echo -e "${GREEN}[88] 更新脚本${RESET}"
    echo -e "${GREEN}[99] 卸载脚本${RESET}"
    echo -e "${GREEN}[ 0] 退出${RESET}"
    echo -e "${GREEN}-------------------------${RESET}"
    read -rp "$(echo -e "${RED}请输入操作编号: ${RESET}")" choice

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
        11) bash <(curl -sL https://raw.githubusercontent.com/Polarisiu/proxy/main/3xuiAlpine.sh) ;;
        12) bash <(curl -fsSL https://raw.githubusercontent.com/Polarisiu/proxy/main/proxy.sh) ;;
        13) bash <(curl -fsSL https://raw.githubusercontent.com/Polarisiu/app-store/main/store.sh) ;;
        88) echo -e "${GREEN}正在下载最新版本脚本...${RESET}"
            curl -sL "$SCRIPT_URL" -o "$SCRIPT_PATH"
            chmod +x "$SCRIPT_PATH"
            echo -e "${GREEN}✅ 脚本已更新完成,A 或 a 可快速启动${RESET}" ;;
        99) echo -e "${YELLOW}正在卸载脚本...${RESET}"
            rm -f "$SCRIPT_PATH" "$BIN_LINK_DIR/A" "$BIN_LINK_DIR/a"
            echo -e "${RED}✅ 卸载完成${RESET}"
            exit 0 ;;
        0) exit 0 ;;
        *) echo -e "${RED}无效选择，请重新输入!${RESET}" ;;
    esac

    read -rp $'\n\033[33m按回车返回菜单...\033[0m'
    menu
}


# ================== 主循环 ==================
menu
