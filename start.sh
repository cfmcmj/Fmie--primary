#!/bin/bash

# 颜色定义 - 使用标准ANSI转义序列
RED=$'\033[0;91m'
GREEN=$'\033[0;92m'
YELLOW=$'\033[0;33m'
CYAN=$'\033[0;36m'
PURPLE=$'\033[0;95m'
BLUE=$'\033[0;94m'
RESET=$'\033[0m'

VERSION="1.0.0"

# 显示横幅 - 改进版，使用更可靠的颜色处理
showBanner() {
    clear
    echo -e "${GREEN}<----------------------------------------------------------------->\n"
    
    echo -e "    ${RED}███████ ███    ███ ██ ███████     ${BLUE}██████  ██    ██     "
    echo -e "    ${RED}██      ████  ████ ██ ██          ${BLUE}██   ██  ██  ██      "
    echo -e "    ${RED}█████   ██ ████ ██ ██ █████ ${GREEN}█████ ${BLUE}██████    ████       "
    echo -e "    ${RED}██      ██  ██  ██ ██ ██          ${BLUE}██         ██        "
    echo -e "    ${RED}██      ██      ██ ██ ███████     ${BLUE}██         ██        "
    echo -e "    ${RED}                                  ${BLUE}                  "
    echo -e "    ${RED}     当前版本号:${GREEN}v$VERSION    F${GREEN}M${YELLOW}I${BLUE}E${PURPLE}-${CYAN}P${RED}T${RESET} -- 自动化部署框架"
    
    echo -e "\n${GREEN}<----------------------------------------------------------------->\n"
    echo -e "${CYAN}使用方法:${RESET} gg [选项]"
    echo -e "${CYAN}选项:${RESET}"
    echo -e "  --help\t显示此帮助信息"
    echo -e "  --version\t显示版本信息"
    echo -e "  --test\t测试脚本功能"
    echo ""
}

# 显示帮助信息
showHelp() {
    showBanner
    echo -e "${CYAN}Fmie--primary 框架管理工具${RESET}"
    echo ""
    echo -e "${CYAN}主命令:${RESET}"
    echo -e "  gg\t\t启动框架菜单"
    echo -e "  gg --help\t显示此帮助信息"
    echo -e "  gg --version\t显示版本信息"
    echo -e "  gg --test\t测试脚本功能"
    echo ""
}

# 获取 FreeBSD 内存信息
get_freebsd_memory_info() {
    # 使用 vmstat 获取内存信息
    if command -v vmstat &>/dev/null; then
        # 解析 vmstat 输出
        vmstat_output=$(vmstat -s)
        total_mem=$(echo "$vmstat_output" | grep "total memory" | awk '{print $1}')
        active_mem=$(echo "$vmstat_output" | grep "active memory" | awk '{print $1}')
        free_mem=$(echo "$vmstat_output" | grep "free memory" | awk '{print $1}')
        
        # 转换为 MB
        total_mem_mb=$((total_mem / 1024 / 1024))
        active_mem_mb=$((active_mem / 1024 / 1024))
        free_mem_mb=$((free_mem / 1024 / 1024))
        
        echo -e "  总内存: ${total_mem_mb}MB"
        echo -e "  活跃内存: ${active_mem_mb}MB"
        echo -e "  空闲内存: ${free_mem_mb}MB"
    else
        echo -e "  ${YELLOW}[提示]${RESET} 缺少 'vmstat' 命令，无法显示内存信息"
    fi
}

# 系统信息
systemInfo() {
    showBanner
    echo -e "${CYAN}系统信息:${RESET}"
    echo -e "  主机名: $(hostname)"
    OS=$(uname)
    echo -e "  操作系统: $OS"
    
    if [ "$OS" = "FreeBSD" ]; then
        get_freebsd_memory_info
    else
        if command -v free &>/dev/null; then
            mem_info=$(free -m | awk 'NR==2 {printf "总内存: %sMB, 已用: %sMB, 空闲: %sMB\n", $2, $3, $4}')
            echo -e "  $mem_info"
        else
            echo -e "  ${YELLOW}[提示]${RESET} 缺少 'free' 命令，无法显示内存信息"
        fi
    fi
    
    # 磁盘空间（改进版，支持 FreeBSD）
    echo -e "${CYAN}磁盘空间:${RESET}"
    if [ "$OS" = "FreeBSD" ]; then
        echo "  /: $(df -h / | awk 'NR==2 {printf "总空间: %s, 已用: %s, 可用: %s, 使用率: %s\n", $2, $3, $4, $5}')"
    else
        echo "  /: $(df -h / | awk 'NR==2 {printf "总空间: %s, 已用: %s, 可用: %s, 使用率: %s\n", $2, $3, $4, $5}')"
    fi
    read -p "按 Enter 继续..."
}

# 项目管理
projectManager() {
    echo -e "${CYAN}项目管理:${RESET}"
    echo "1) 创建新项目"
    echo "2) 部署现有项目"
    echo "3) 更新项目"
    echo "4) 删除项目"
    echo "0) 返回主菜单"
    
    # FreeBSD 兼容的 read 命令
    read -p "请选择: " choice
    
    case $choice in
        1) 
            echo "请输入新项目名称: "
            read project_name
            # 这里添加创建新项目的具体逻辑
            echo "创建新项目: $project_name..." 
            ;;
        2) 
            echo "请输入要部署的项目名称: "
            read project_name
            # 这里添加部署现有项目的具体逻辑
            echo "部署现有项目: $project_name..." 
            ;;
        3) 
            echo "请输入要更新的项目名称: "
            read project_name
            # 这里添加更新项目的具体逻辑
            echo "更新项目: $project_name..." 
            ;;
        4) 
            echo "请输入要删除的项目名称: "
            read project_name
            # 这里添加删除项目的具体逻辑
            echo "删除项目: $project_name..." 
            ;;
        0) return ;;
        *) echo "无效选择!" ;;
    esac
    read -p "按 Enter 继续..."
}

# 配置设置
configSettings() {
    echo -e "${CYAN}配置设置:${RESET}"
    echo "1) 修改系统配置"
    echo "2) 管理用户账户"
    echo "3) 设置环境变量"
    echo "0) 返回主菜单"
    
    # FreeBSD 兼容的 read 命令
    read -p "请选择: " choice
    
    case $choice in
        1) 
            # 这里添加修改系统配置的具体逻辑
            echo "修改系统配置..." 
            ;;
        2) 
            # 这里添加管理用户账户的具体逻辑
            echo "管理用户账户..." 
            ;;
        3) 
            echo "请输入要设置的环境变量名称: "
            read var_name
            echo "请输入环境变量的值: "
            read var_value
            # 这里添加设置环境变量的具体逻辑
            echo "设置环境变量 $var_name=$var_value..." 
            ;;
        0) return ;;
        *) echo "无效选择!" ;;
    esac
    read -p "按 Enter 继续..."
}

# 工具集
toolkit() {
    echo -e "${CYAN}工具集:${RESET}"
    echo "1) 文件管理器"
    echo "2) 日志查看器"
    echo "3) 系统监控"
    echo "4) 网络工具"
    echo "0) 返回主菜单"
    
    # FreeBSD 兼容的 read 命令
    read -p "请选择: " choice
    
    case $choice in
        1) 
            # 这里添加文件管理器的具体逻辑
            echo "文件管理器..." 
            ;;
        2) 
            # 这里添加日志查看器的具体逻辑
            echo "日志查看器..." 
            ;;
        3) 
            # 这里添加系统监控的具体逻辑
            echo "系统监控..." 
            ;;
        4) 
            # 这里添加网络工具的具体逻辑
            echo "网络工具..." 
            ;;
        0) return ;;
        *) echo "无效选择!" ;;
    esac
    read -p "按 Enter 继续..."
}

# 更新框架
updateFramework() {
    echo -e "${CYAN}更新框架:${RESET}"
    echo "正在检查更新..."
    
    # 模拟更新检查
    sleep 2
    echo "发现新版本! 是否更新? (y/n)"
    
    # FreeBSD 兼容的 read 命令
    read -p "选择: " confirm
    
    if [ "$confirm" = "y" ]; then
        echo "正在更新框架..."
        # 这里添加更新框架的具体逻辑
        sleep 3
        echo "更新完成!"
    else
        echo "更新已取消。"
    fi
    read -p "按 Enter 继续..."
}

# 测试脚本
testScript() {
    if ! type showBanner &>/dev/null; then
        echo -e "${RED}[错误]${RESET} showBanner 函数未定义" >&2
        exit 1
    fi
    showBanner
    echo -e "${GREEN}脚本测试通过！${RESET}"
    exit 0
}

# 主菜单（FreeBSD 兼容版）
mainMenu() {
    while true; do
        showBanner
        echo "请选择一个选项:"
        echo "---------------------"
        echo "1) 系统信息"
        echo "2) 项目管理"
        echo "3) 配置设置"
        echo "4) 工具集"
        echo "5) 更新框架"
        echo "0) 退出"
        echo "---------------------"
        
        # FreeBSD 兼容的 read 命令（禁用超时）
        read -p "请选择: " choice
        
        case $choice in
            1) systemInfo ;;
            2) projectManager ;;
            3) configSettings ;;
            4) toolkit ;;
            5) updateFramework ;;
            0) echo -e "${GREEN}感谢使用 Fmie-pry 框架，再见!${RESET}"; return 0 ;;
            *) echo -e "${RED}无效选择，请重新输入!${RESET}" ;;
        esac
        sleep 0.5  # 短暂延迟，避免刷屏
    done
}

# 脚本入口
case "$1" in
    --help|-h)
        showHelp
        exit 0
        ;;
    --version|-v)
        echo "Fmie-pry 框架版本 $VERSION"
        exit 0
        ;;
    --test)
        testScript
        ;;
    *)
        # 如果没有参数或参数无效，显示主菜单
        mainMenu
        ;;
esac    