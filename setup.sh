#!/bin/sh
# Description: Traffmonetizer Service Manager

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

# Root check
if [ "$(id -u)" != "0" ]; then
   echo -e "${RED}This script must be run as root${NC}" 
   exit 1
fi

# 安装函数
install() {
    if [ -z "$1" ]; then 
        echo -e "${RED}Error: Token is required for installation${NC}"
        echo -e "Usage: $0 install <your_token>"
        exit 1
    fi
    
    TOKEN="$1"
    echo -e "${GREEN}Starting Traffmonetizer installation...${NC}"

    # 安装依赖
    echo -e "${GREEN}Installing dependencies...${NC}"
    apk update
    apk add --no-cache libstdc++ libgcc icu-libs || {
        echo -e "${RED}Failed to install dependencies${NC}"
        exit 1
    }

    # 创建目录
    echo -e "${GREEN}Creating directory...${NC}"
    mkdir -p /root/traffmonetizer/ || {
        echo -e "${RED}Failed to create directory${NC}"
        exit 1
    }

    # 下载文件
    echo -e "${GREEN}Downloading Traffmonetizer client...${NC}"
    wget -P /root/traffmonetizer/ https://raw.githubusercontent.com/Garfyyy/sharenet/main/traffmonetizer/Cli || {
        echo -e "${RED}Failed to download Cli${NC}"
        exit 1
    }

    # 切换目录并设置权限
    cd /root/traffmonetizer/
    chmod 700 -R /root/traffmonetizer/ || {
        echo -e "${RED}Failed to set permissions${NC}"
        exit 1
    }

    # 创建服务文件
    echo -e "${GREEN}Creating service file...${NC}"
    cat > /etc/init.d/traffmonetizer << EOF
#!/sbin/openrc-run

supervisor=supervise-daemon
name="traffmonetizer"
description="Traffmonetizer Service"
command="/root/traffmonetizer/Cli"
command_args="start accept --token ${TOKEN}"
directory="/root/traffmonetizer"
supervise_daemon_args="--stdout /var/log/\${name}.log --stderr /var/log/\${name}.err"

EOF

    # 设置服务文件权限
    chmod +x /etc/init.d/traffmonetizer || {
        echo -e "${RED}Failed to set service file permission${NC}"
        exit 1
    }

    # 添加到开机启动
    echo -e "${GREEN}Adding service to startup...${NC}"
    rc-update add traffmonetizer default || {
        echo -e "${RED}Failed to add service to startup${NC}"
        exit 1
    }

    # # 启动服务
    # echo -e "${GREEN}Starting service...${NC}"
    # rc-service traffmonetizer start
    # sleep 2
    # rc-service traffmonetizer status

    # 启动服务
    echo -e "${GREEN}Starting service...${NC}"
    rc-service traffmonetizer start || {
        echo -e "${RED}Failed to start service${NC}"
        exit 1
    }
    sleep 2
    # 检查服务状态
    rc-service traffmonetizer status || {
        echo -e "${RED}Failed to check service status${NC}"
        exit 1
    }

    echo -e "${GREEN}Installation completed successfully${NC}"
    echo -e "Commands:"
    echo -e "  Start: rc-service traffmonetizer start"
    echo -e "  Stop: rc-service traffmonetizer stop"
    echo -e "  Restart: rc-service traffmonetizer restart"
    echo -e "  Status: rc-service traffmonetizer status"
}

# 卸载函数
uninstall() {
    echo -e "${GREEN}Starting Traffmonetizer uninstallation...${NC}"
    
    # 停止服务
    echo -e "Stopping service..."
    rc-service traffmonetizer stop || true
    
    # 移除开机启动
    echo -e "Removing from startup..."
    rc-update del traffmonetizer default || true
    
    # 删除文件
    echo -e "Removing files..."
    rm -rf /root/traffmonetizer
    rm -f /etc/init.d/traffmonetizer
    rm -f /var/log/traffmonetizer.*
    
    # 删除依赖
    echo -e "Removing dependencies..."
    apk del libstdc++ libgcc icu-libs
    
    echo -e "${GREEN}Uninstallation completed successfully${NC}"
}

# 显示菜单
show_menu() {
    echo -e "Please select an option:"
    echo -e "1) Install Traffmonetizer"
    echo -e "2) Uninstall Traffmonetizer"
    echo -e "3) Exit"
    echo
    read -p "Enter your choice (1-3): " choice
}

# 获取token
get_token() {
    read -p "Please enter your token: " token
    if [ -z "$token" ]; then
        echo -e "${RED}Error: Token is required${NC}"
        exit 1
    fi
    echo -e "$token"
}

# 主循环
while true; do
    show_menu
    
    case $choice in
        1)
            token=$(get_token)
            install "$token"
            break
            ;;
        2)
            uninstall
            break
            ;;
        3)
            echo -e "Exiting..."
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid option. Please try again.${NC}"
            ;;
    esac
done
