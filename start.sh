#!/bin/bash
# Fmie--primary 框架启动脚本

# 颜色定义
RED='\033[0;91m'
GREEN='\033[0;92m'
YELLOW='\033[0;33m'
CYAN='\033[0;96m'
BLUE='\033[0;94m'
PURPLE='\033[0;95m'
RESET='\033[0m'

# 框架版本
VERSION="1.0.0"

# 显示横幅
showBanner() {
    clear
    echo -e "$(cat << EOF
${GREEN}<----------------------------------------------------------------->

    ${RED}███████ ███    ███ ██ ███████     ${BLUE}██████  ██    ██     
    ${RED}██      ████  ████ ██ ██          ${BLUE}██   ██   ██  ██      
    ${RED}█████   ██ ████ ██ ██ █████ ${GREEN}█████ ${BLUE}██████     ████       
    ${RED}██      ██  ██  ██ ██ ██          ${BLUE}██          ██        
    ${RED}██      ██      ██ ██ ███████     ${BLUE}██         ██        
    ${RED}                                  ${BLUE}                  
    ${RED}     当前版本号:${GREEN}v$VERSION    F${GREEN}M${YELLOW}I${BLUE}E${PURPLE}-${CYAN}P${RED}T${RESET} -- 自动化部署框架
${GREEN}<----------------------------------------------------------------->                                                       
EOF
)"
}

# 系统信息 - 增强版
systemInfo() {
    showBanner
    echo -e "${CYAN}系统信息:${RESET}"
    
    # 主机信息
    echo -e "${CYAN}主机信息:${RESET}"
    echo -e "  主机名: $(hostname)"
    echo -e "  完整域名: $(hostname -f 2>/dev/null || echo "N/A")"
    echo -e "  IP 地址: $(hostname -I | awk '{print $1}')"
    
    # 操作系统信息
    echo -e "\n${CYAN}操作系统:${RESET}"
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        echo -e "  发行版: $PRETTY_NAME"
        echo -e "  版本 ID: $VERSION_ID"
    elif [ -f /etc/lsb-release ]; then
        . /etc/lsb-release
        echo -e "  发行版: $DISTRIB_DESCRIPTION"
    elif [ -f /etc/debian_version ]; then
        echo -e "  发行版: Debian $(cat /etc/debian_version)"
    elif [ -f /etc/redhat-release ]; then
        echo -e "  发行版: $(cat /etc/redhat-release)"
    else
        OS=$(uname -s)
        VER=$(uname -r)
        echo -e "  系统: $OS $VER"
    fi
    
    # 内核信息
    echo -e "\n${CYAN}内核信息:${RESET}"
    echo -e "  内核版本: $(uname -r)"
    echo -e "  架构: $(uname -m)"
    echo -e "  编译时间: $(uname -v)"
    
    # CPU 信息
    echo -e "\n${CYAN}CPU 信息:${RESET}"
    if [ -f /proc/cpuinfo ]; then
        CPU_MODEL=$(grep 'model name' /proc/cpuinfo | head -1 | cut -d ':' -f2 | sed 's/^[ \t]*//')
        CPU_CORES=$(grep 'processor' /proc/cpuinfo | wc -l)
        CPU_FREQ=$(grep 'cpu MHz' /proc/cpuinfo | head -1 | cut -d ':' -f2 | sed 's/^[ \t]*//')
        echo -e "  型号: $CPU_MODEL"
        echo -e "  核心数: $CPU_CORES"
        echo -e "  频率: $CPU_FREQ MHz"
    else
        echo -e "  CPU 信息: $(sysctl -n hw.model 2>/dev/null || echo "N/A")"
    fi
    
    # 内存信息
    echo -e "\n${CYAN}内存信息:${RESET}"
    if command -v free &>/dev/null; then
        mem_info=$(free -h | awk 'NR==2 {printf "总内存: %s, 已用: %s, 空闲: %s, 使用率: %s\n", $2, $3, $4, $5}')
        echo -e "  $mem_info"
        
        # 交换空间
        swap_info=$(free -h | awk 'NR==3 {printf "交换空间: %s, 已用: %s, 空闲: %s, 使用率: %s\n", $2, $3, $4, $5}')
        echo -e "  $swap_info"
    else
        echo -e "  ${YELLOW}[提示]${RESET} 缺少 'free' 命令，无法显示详细内存信息"
    fi
    
    # 磁盘空间
    echo -e "\n${CYAN}磁盘空间:${RESET}"
    echo "  /: $(df -h / | awk 'NR==2 {printf "总空间: %s, 已用: %s, 可用: %s, 使用率: %s\n", $2, $3, $4, $5}')"
    
    # 挂载的文件系统
    echo -e "\n${CYAN}挂载的文件系统:${RESET}"
    df -hT | grep -vE '^Filesystem|tmpfs|udev'
    
    # 网络信息
    echo -e "\n${CYAN}网络信息:${RESET}"
    if command -v ifconfig &>/dev/null; then
        ifconfig | grep -A2 'inet '
    elif command -v ip &>/dev/null; then
        ip -4 addr show | grep -A2 'inet '
    else
        echo -e "  ${YELLOW}[提示]${RESET} 缺少网络工具，无法显示网络信息"
    fi
    
    # 系统运行时间
    echo -e "\n${CYAN}系统运行时间:${RESET}"
    echo -e "  $(uptime | sed 's/^.*up //; s/, [0-9]* users.*//')"
    
    # 用户信息
    echo -e "\n${CYAN}当前登录用户:${RESET}"
    whoami
    
    read -p "按 Enter 继续..."
}

# 检查更新
checkUpdate() {
    showBanner
    echo -e "${CYAN}检查更新:${RESET}"
    
    # 获取当前版本和最新版本
    CURRENT_VERSION="$VERSION"
    
    # 从 GitHub 获取最新版本信息
    echo -e "${YELLOW}[信息]${RESET} 正在检查最新版本..."
    LATEST_VERSION=$(curl -s https://raw.githubusercontent.com/cfmcmj/Fmie--primary/main/VERSION)
    
    if [ -z "$LATEST_VERSION" ]; then
        echo -e "${RED}[错误]${RESET} 无法获取最新版本信息，请检查网络连接。"
        read -p "按 Enter 继续..."
        return
    fi
    
    if [ "$CURRENT_VERSION" = "$LATEST_VERSION" ]; then
        echo -e "${GREEN}[成功]${RESET} 您使用的是最新版本 ($CURRENT_VERSION)"
    else
        echo -e "${YELLOW}[更新]${RESET} 有新版本可用: $LATEST_VERSION (当前版本: $CURRENT_VERSION)"
        read -p "是否更新到最新版本？(y/N): " update_choice
        if [ "$update_choice" = "y" ]; then
            echo -e "${YELLOW}[信息]${RESET} 正在更新框架..."
            # 从 GitHub 下载最新的 start.sh
            curl -Ls https://raw.githubusercontent.com/cfmcmj/Fmie--primary/main/start.sh -o "$HOME/Fmie--primary/start.sh.new"
            if [ $? -eq 0 ]; then
                # 验证下载的文件是否有效
                if grep -q "Fmie--primary" "$HOME/Fmie--primary/start.sh.new"; then
                    # 备份旧文件
                    cp "$HOME/Fmie--primary/start.sh" "$HOME/Fmie--primary/start.sh.bak"
                    # 替换为新文件
                    mv "$HOME/Fmie--primary/start.sh.new" "$HOME/Fmie--primary/start.sh"
                    # 设置执行权限
                    chmod +x "$HOME/Fmie--primary/start.sh"
                    echo -e "${GREEN}[成功]${RESET} 框架已更新到 $LATEST_VERSION"
                    echo -e "${YELLOW}[提示]${RESET} 请重新启动框架以使更新生效。"
                else
                    echo -e "${RED}[错误]${RESET} 下载的文件无效，更新失败。"
                    rm -f "$HOME/Fmie--primary/start.sh.new"
                fi
            else
                echo -e "${RED}[错误]${RESET} 下载更新失败，请检查网络连接。"
            fi
        fi
    fi
    
    read -p "按 Enter 继续..."
}

# 运行框架
runFramework() {
    showBanner
    echo -e "${CYAN}正在运行 Fmie--primary 框架...${RESET}"
    
    # 这里是框架的主要功能代码
    # 由于不清楚具体框架功能，这里仅作为示例
    
    echo -e "${YELLOW}[信息]${RESET} 框架核心已启动..."
    echo -e "${YELLOW}[信息]${RESET} 加载配置文件..."
    echo -e "${YELLOW}[信息]${RESET} 初始化环境..."
    
    # 模拟框架运行
    echo -e "${GREEN}[成功]${RESET} 框架已成功启动！"
    
    # 框架主循环示例
    while true; do
        echo -e "\n${CYAN}Fmie--primary 控制台${RESET}"
        echo -e "1) 执行任务"
        echo -e "2) 查看日志"
        echo -e "3) 配置设置"
        echo -e "0) 返回主菜单"
        
        read -p "请选择 [0-3]: " choice
        
        case $choice in
            1)
                echo -e "${YELLOW}[信息]${RESET} 执行任务..."
                # 执行任务的代码
                sleep 1
                echo -e "${GREEN}[成功]${RESET} 任务已完成！"
                ;;
            2)
                echo -e "${YELLOW}[信息]${RESET} 查看日志..."
                # 查看日志的代码
                ;;
            3)
                echo -e "${YELLOW}[信息]${RESET} 配置设置..."
                # 配置设置的代码
                ;;
            0)
                break
                ;;
            *)
                echo -e "${RED}[错误]${RESET} 无效选择"
                ;;
        esac
    done
}

# 框架帮助
showHelp() {
    showBanner
    echo -e "${CYAN}Fmie--primary 框架帮助:${RESET}"
    echo -e "这是一个功能强大的开发框架，提供以下功能:\n"
    echo -e "  1. 系统信息查看 - 显示详细的系统信息"
    echo -e "  2. 框架更新 - 自动检查并更新到最新版本"
    echo -e "  3. 框架运行 - 启动框架主程序"
    echo -e "  4. 帮助信息 - 显示此帮助菜单\n"
    echo -e "${YELLOW}[提示]${RESET} 使用数字键选择相应的功能。"
    read -p "按 Enter 继续..."
}

# 主菜单
mainMenu() {
    while true; do
        showBanner
        echo -e "${CYAN}主菜单:${RESET}"
        echo -e "1) 查看系统信息"
        echo -e "2) 检查更新"
        echo -e "3) 运行框架"
        echo -e "4) 帮助"
        echo -e "0) 退出"
        
        read -p "请选择 [0-4]: " choice
        
        case $choice in
            1)
                systemInfo
                ;;
            2)
                checkUpdate
                ;;
            3)
                runFramework
                ;;
            4)
                showHelp
                ;;
            0)
                echo -e "${YELLOW}[信息]${RESET} 感谢使用 Fmie--primary 框架！"
                exit 0
                ;;
            *)
                echo -e "${RED}[错误]${RESET} 无效选择"
                sleep 1
                ;;
        esac
    done
}

# 测试命令
if [ "$1" = "--test" ]; then
    exit 0
fi

# 启动主菜单
mainMenu