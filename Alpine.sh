#!/bin/bash

GREEN="\033[32m"
RED="\033[31m"
RESET="\033[0m"

menu() {
    clear
    echo -e "${GREEN}=== Alpine 系统管理菜单 ===${RESET}"
    echo -e "${GREEN}1) Alpine 防火墙管理${RESET}"
    echo -e "${GREEN}2) Alpine Fail2Ban${RESET}"
    echo -e "${GREEN}3) Alpine 换源${RESET}"
    echo -e "${GREEN}4) Alpine 清理${RESET}"
    echo -e "${GREEN}5) Alpine 修改中文${RESET}"
    echo -e "${GREEN}6) Alpine 修改主机名${RESET}"
    echo -e "${GREEN}7) Alpine Docker${RESET}"
    echo -e "${GREEN}8) Alpine Hysteria2)${RESET}"
    echo -e "${GREEN}0) 退出${RESET}"
    echo
    read -p $'\033[32m请选择操作 (0-8): \033[0m' choice
    case $choice in
        1)
            bash <(curl -fsSL https://raw.githubusercontent.com/Polarisiu/Alpinetool/main/apfeew.sh)
            pause
            ;;
        2)
            bash <(curl -fsSL https://raw.githubusercontent.com/Polarisiu/Alpinetool/main/apFail2Ban.sh)
            pause
            ;;
        3)
            bash <(curl -fsSL https://raw.githubusercontent.com/Polarisiu/Alpinetool/main/aphuanyuan.sh)
            pause
            ;;
        4)
            bash <(curl -fsSL https://raw.githubusercontent.com/Polarisiu/Alpinetool/main/apql.sh)
            pause
            ;;
        5)
            bash <(curl -fsSL https://raw.githubusercontent.com/Polarisiu/Alpinetool/main/apcn.sh)
            pause
            ;;
        6)
            bash <(curl -fsSL https://raw.githubusercontent.com/Polarisiu/Alpinetool/main/aphome.sh)
            pause
            ;;
        7)
            bash <(curl -fsSL https://raw.githubusercontent.com/Polarisiu/Alpinetool/main/apdocker.sh)
            pause
            ;;
        8)
            bash <(curl -fsSL https://raw.githubusercontent.com/Polarisiu//proxy/main/aphy2.sh)
            pause
            ;;
        0)
            exit 0
            ;;
        *)
            echo -e "${RED}无效选择，请重新输入${RESET}"
            sleep 1
            menu
            ;;
    esac
}

pause() {
    read -p $'\033[32m按回车键返回菜单...\033[0m'
    menu
}

menu
