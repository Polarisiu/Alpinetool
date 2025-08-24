#!/bin/sh
set -e

# ================== 颜色 ==================
GREEN="\033[32m"
RED="\033[31m"
YELLOW="\033[33m"
RESET="\033[0m"

info() { echo -e "${GREEN}[INFO] $1${RESET}"; }
warn() { echo -e "${YELLOW}[WARN] $1${RESET}"; }
error() { echo -e "${RED}[ERROR] $1${RESET}"; }

# ================== 通用函数 ==================
pause() {
    echo
    read -p "按回车键返回菜单..." dummy
}

wait_docker_ready() {
    info "等待 Docker daemon 就绪..."
    timeout=15
    while [ ! -S /var/run/docker.sock ] && [ $timeout -gt 0 ]; do
        sleep 1
        timeout=$((timeout-1))
    done

    if [ -S /var/run/docker.sock ]; then
        info "Docker daemon 已就绪"
    else
        warn "Docker daemon 仍未就绪，稍后可重启服务"
    fi
}

# ================== Docker 功能 ==================
install_docker() {
    info "更新 apk 源..."
    apk update
    apk upgrade

    info "安装 Docker..."
    apk add docker

    info "安装依赖..."
    apk add py3-pip curl

    info "安装 Docker Compose V2..."
    COMPOSE_LATEST=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep '"tag_name":' | sed -E 's/.*"v([^"]+)".*/\1/')
    curl -L "https://github.com/docker/compose/releases/download/v$COMPOSE_LATEST/docker-compose-linux-x86_64" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose

    info "设置 Docker 开机自启..."
    rc-update add docker boot

    info "清理旧 socket 和日志..."
    rm -f /var/run/docker.sock /var/log/docker.log

    info "启动 Docker 服务..."
    service docker start

    wait_docker_ready

    info "验证安装..."
    docker version
    docker-compose version
    pause
}

update_docker() {
    info "更新 apk 源..."
    apk update
    apk upgrade

    info "更新 Docker..."
    apk add --upgrade docker

    info "更新 Docker Compose V2..."
    COMPOSE_LATEST=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep '"tag_name":' | sed -E 's/.*"v([^"]+)".*/\1/')
    curl -L "https://github.com/docker/compose/releases/download/v$COMPOSE_LATEST/docker-compose-linux-x86_64" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose

    info "重启 Docker 服务..."
    service docker restart

    wait_docker_ready

    info "更新完成"
    docker version
    docker-compose version
    pause
}

uninstall_docker() {
    info "停止 Docker 服务..."
    service docker stop || true

    info "卸载 Docker 和 Docker Compose..."
    apk del docker py3-pip
    rm -f /usr/local/bin/docker-compose

    info "移除开机自启..."
    rc-update del docker

    info "卸载完成"
    pause
}

check_status() {
    if service docker status >/dev/null 2>&1; then
        info "Docker 服务正在运行"
    else
        warn "Docker 服务未运行"
    fi
    pause
}

restart_docker() {
    info "重启 Docker 服务..."
    service docker restart
    wait_docker_ready
    pause
}

# ================== 容器管理 ==================
container_menu() {
    echo -e "${GREEN}===== 容器管理 =====${RESET}"
    echo -e "${GREEN}1) 查看所有容器${RESET}"
    echo -e "${GREEN}2) 启动容器${RESET}"
    echo -e "${GREEN}3) 停止容器${RESET}"
    echo -e "${GREEN}4) 删除容器${RESET}"
    echo -e "${GREEN}0) 返回主菜单${RESET}"
    printf "${GREEN}请选择: ${RESET}"
    read c_choice
    case $c_choice in
        1)
            docker ps -a
            pause
            ;;
        2)
            echo -e "${GREEN}当前容器列表:${RESET}"
            docker ps -a
            echo
            read -p "请输入容器名称或ID: " cid
            if [ -z "$cid" ]; then
                warn "容器名称或ID不能为空"
            else
                docker start "$cid"
                info "容器 $cid 已启动"
            fi
            pause
            ;;
        3)
            echo -e "${GREEN}当前容器列表:${RESET}"
            docker ps -a
            echo
            read -p "请输入容器名称或ID: " cid
            if [ -z "$cid" ]; then
                warn "容器名称或ID不能为空"
            else
                docker stop "$cid"
                info "容器 $cid 已停止"
            fi
            pause
            ;;
        4)
            echo -e "${GREEN}当前容器列表:${RESET}"
            docker ps -a
            echo
            read -p "请输入容器名称或ID: " cid
            if [ -z "$cid" ]; then
                warn "容器名称或ID不能为空"
            else
                docker rm "$cid"
                info "容器 $cid 已删除"
            fi
            pause
            ;;
        0) return ;;
        *) warn "无效选项"; pause ;;
    esac
    container_menu
}

# ================== 镜像管理 ==================
image_menu() {
    echo -e "${GREEN}===== 镜像管理 =====${RESET}"
    echo -e "${GREEN}1) 查看镜像列表${RESET}"
    echo -e "${GREEN}2) 拉取镜像${RESET}"
    echo -e "${GREEN}3) 删除镜像${RESET}"
    echo -e "${GREEN}0) 返回主菜单${RESET}"
    printf "${GREEN}请选择: ${RESET}"
    read i_choice
    case $i_choice in
        1)
            docker images
            pause
            ;;
        2)
            read -p "请输入镜像名称: " img
            if [ -z "$img" ]; then
                warn "镜像名称不能为空"
            else
                docker pull "$img"
                info "镜像 $img 已拉取"
            fi
            pause
            ;;
        3)
            echo -e "${GREEN}当前镜像列表:${RESET}"
            docker images
            echo
            read -p "请输入镜像ID或名称: " img
            if [ -z "$img" ]; then
                warn "镜像ID或名称不能为空"
            else
                docker rmi "$img"
                info "镜像 $img 已删除"
            fi
            pause
            ;;
        0) return ;;
        *) warn "无效选项"; pause ;;
    esac
    image_menu
}

# ================== IPv6 开关 ==================
ipv6_menu() {
    IPV6_STATUS=$(cat /proc/sys/net/ipv6/conf/all/disable_ipv6)
    CURRENT_STATUS=$([ "$IPV6_STATUS" -eq 0 ] && echo "启用" || echo "禁用")

    echo -e "${GREEN}===== IPv6 设置 =====${RESET}"
    echo -e "${GREEN}当前 IPv6 状态: ${CURRENT_STATUS}${RESET}"
    echo -e "${GREEN}1) 启用 IPv6（临时 + 永久）${RESET}"
    echo -e "${GREEN}2) 禁用 IPv6（临时 + 永久）${RESET}"
    echo -e "${GREEN}0) 返回主菜单${RESET}"
    printf "${GREEN}请选择: ${RESET}"
    read ip_choice
    case $ip_choice in
        1)
            echo 0 > /proc/sys/net/ipv6/conf/all/disable_ipv6
            if ! grep -q "^net.ipv6.conf.all.disable_ipv6" /etc/sysctl.conf 2>/dev/null; then
                echo "net.ipv6.conf.all.disable_ipv6 = 0" >> /etc/sysctl.conf
            else
                sed -i 's/^net.ipv6.conf.all.disable_ipv6.*/net.ipv6.conf.all.disable_ipv6 = 0/' /etc/sysctl.conf
            fi
            sysctl -p >/dev/null 2>&1 || true
            info "IPv6 已启用（永久生效）"
            pause
            ;;
        2)
            echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6
            if ! grep -q "^net.ipv6.conf.all.disable_ipv6" /etc/sysctl.conf 2>/dev/null; then
                echo "net.ipv6.conf.all.disable_ipv6 = 1" >> /etc/sysctl.conf
            else
                sed -i 's/^net.ipv6.conf.all.disable_ipv6.*/net.ipv6.conf.all.disable_ipv6 = 1/' /etc/sysctl.conf
            fi
            sysctl -p >/dev/null 2>&1 || true
            info "IPv6 已禁用（永久生效）"
            pause
            ;;
        0) return ;;
        *) warn "无效选项"; pause ;;
    esac
    ipv6_menu
}

# ================== 一键清理 ==================
cleanup_docker() {
    echo -e "${GREEN}===== Docker 清理 =====${RESET}"
    echo -e "${YELLOW}1) 删除停止的容器${RESET}"
    echo -e "${YELLOW}2) 删除悬挂镜像（dangling images）${RESET}"
    echo -e "${YELLOW}3) 删除未使用的卷${RESET}"
    echo -e "${YELLOW}4) 一键全部清理${RESET}"
    echo -e "${YELLOW}0) 返回主菜单${RESET}"
    printf "${GREEN}请选择: ${RESET}"
    read clean_choice
    case $clean_choice in
        1)
            docker container prune -f
            info "停止的容器已清理"
            pause
            ;;
        2)
            docker image prune -f
            info "悬挂镜像已清理"
            pause
            ;;
        3)
            docker volume prune -f
            info "未使用的卷已清理"
            pause
            ;;
        4)
            docker system prune -af --volumes
            info "全部清理完成"
            pause
            ;;
        0) return ;;
        *) warn "无效选项"; pause ;;
    esac
    cleanup_docker
}

# ================== 主菜单 ==================
show_menu() {
    echo -e "${GREEN}==============================${RESET}"
    echo -e "${GREEN}  Alpine Docker 管理脚本${RESET}"
    echo -e "${GREEN}==============================${RESET}"
    echo -e "${GREEN}1) 安装 Docker + Docker Compose${RESET}"
    echo -e "${GREEN}2) 更新 Docker + Docker Compose${RESET}"
    echo -e "${GREEN}3) 卸载 Docker + Docker Compose${RESET}"
    echo -e "${GREEN}4) 查看 Docker 服务状态${RESET}"
    echo -e "${GREEN}5) 重启 Docker 服务${RESET}"
    echo -e "${GREEN}6) 容器管理${RESET}"
    echo -e "${GREEN}7) 镜像管理${RESET}"
    echo -e "${GREEN}8) IPv6 开关${RESET}"
    echo -e "${GREEN}9) Docker 清理${RESET}"
    echo -e "${GREEN}0) 退出${RESET}"
    printf "${GREEN}请选择: ${RESET}"
    read choice
    case $choice in
        1) install_docker ;;
        2) update_docker ;;
        3) uninstall_docker ;;
        4) check_status ;;
        5) restart_docker ;;
        6) container_menu ;;
        7) image_menu ;;
        8) ipv6_menu ;;
        9) cleanup_docker ;;
        0) exit 0 ;;
        *) warn "无效选项"; pause ;;
    esac
    show_menu
}

show_menu
