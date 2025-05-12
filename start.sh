#!/bin/bash
# Fmie--primary 框架主入口脚本（FreeBSD 兼容）

# 日志文件
PROJECT_DIR="$HOME/Fmie--primary"
LOG_FILE="$PROJECT_DIR/fmie.log"

# 检查依赖
check_dependencies() {
    MISSING=0
    for cmd in clear hostname cat df uname awk grep; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            echo -e "${RED}[警告]${RESET} 缺少必要命令: $cmd" >&2
            echo "[$(date)] WARN: Missing command $cmd" >> "$LOG_FILE" 2>/dev/null
            MISSING=1
        fi
    done
    for cmd in bc; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            echo -e "${YELLOW}[提示]${RESET} 缺少可选命令: $cmd，部分功能可能受限" >&2
            echo "[$(date)] INFO: Optional command $cmd missing" >> "$LOG_FILE" 2>/dev/null
        fi
    done
    if [ $MISSING -eq 1 ]; then
        echo -e "${RED}[错误]${RESET} 缺少必要命令，无法继续执行" >&2
        echo "[$(date)] ERROR: Missing required commands" >> "$LOG_FILE" 2>/dev/null
        exit 1
    fi
}

# 颜色定义
RED='\033[0;91m'
GREEN='\033[0;92m'
YELLOW='\033[0;33m'
BLUE='\033[0;94m'
MAGENTA='\033[0;95m'
CYAN='\033[0;96m'
RESET='\033[0m'

# 版本信息
VERSION="v1.0.1"

# 显示横幅
showBanner() {
    clear
    echo -e "$(cat << EOF
${CYAN}╔══════════════════════════════════════════════════╗
${CYAN}║${RESET}                                              ${CYAN}║
${CYAN}║${RESET}    ${RED}_____          ${GREEN}_                             ${BLUE}_      ${RESET}    ${CYAN}║
${CYAN}║${RESET}   ${RED}|  ___| __ ___ ${GREEN}(_) ___             ${BLUE}_ __  _ __(${BLUE}_)${YELLOW}_ __ ___   ${MAGENTA}__ _ ${RESET}    ${CYAN}║
${CYAN}║${RESET}   ${RED}| |_ | '_ \` _ \ ${GREEN}| |/ _ \_____ ${BLUE}_____| '_ \| '__|${YELLOW}| '_ \` _ \ ${MAGENTA}/ _\` |${RESET}    ${CYAN}║
${CYAN}║${RESET}   ${RED}|  _|| | | | | | ${GREEN}| |  __/_____|${BLUE}_____| |_) | |  |${YELLOW}| | | | | | ${MAGENTA}| (_| |${RESET}    ${CYAN}║
${CYAN}║${RESET}   ${RED}|_|  |_| |_| |_|${GREEN}_|\___|           ${BLUE}| .__/|_|  |${YELLOW}|_| |_| |_| ${MAGENTA}\__,_|${RESET}    ${CYAN}║
${CYAN}║${RESET}                                  ${BLUE}|_|                                ${MAGENTA}|___/${RESET}    ${CYAN}║
${CYAN}║${RESET}                                              ${CYAN}║
${CYAN}║${RESET}       ${MAGENTA}项目名称: Fmie-pry ${VERSION}${RESET}                     ${CYAN}║
${CYAN}║${RESET}       ${GREEN}一个全新的自动化部署框架${RESET}                     ${CYAN}║
${CYAN}║${RESET}                                              ${CYAN}║
${CYAN}╚══════════════════════════════════════════════════╝
${RESET}
EOF
)"
    echo -e "${CYAN}使用方法:${RESET} gg [选项]"
    echo -e "${CYAN}选项:${RESET}"
    echo -e "  --help\t显示帮助信息"
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
    echo -e "  gg --help\t显示帮助信息"
    echo -e "  gg --version\t显示版本信息"
    echo -e "  gg --test\t测试脚本功能"
    echo ""
}

# 系统信息
systemInfo() {
    echo -e "${CYAN}系统信息:${RESET}"
    echo "主机名: $(hostname)"
    echo "操作系统: $(uname -sr)"
    echo "内核版本: $(uname -r)"
    
    echo -e "${CYAN}内存信息:${RESET}"
    if sysctl hw.physmem >/dev/null 2>&1; then
        total_mem=$(sysctl -n hw.physmem)
        usermem=$(sysctl -n hw.usermem 2>/dev/null || echo $total_mem)
        used_mem=$((total_mem - usermem))
        total_mb=$((total_mem / 1024 / 1024))
        used_mb=$((used_mem / 1024 / 1024))
        free_mb=$((usermem / 1024 / 1024))
        percent=$((used_mem * 100 / total_mem))
        echo "  总内存: ${total_mb} MB"
        echo "  已用: ${used_mb} MB"
        echo "  空闲: ${free_mb} MB"
        echo "  使用率: ${percent}%"
    else
        echo -e "  ${YELLOW}[提示]${RESET} 无法获取内存信息"
    fi
    
    echo -e "${CYAN}磁盘空间:${RESET}"
    if df -h / >/dev/null 2>&1; then
        echo "  /: $(df -h / | awk 'NR==2 {printf "总空间: %s, 已用: %s, 可用: %s, 使用率: %s\n", $2, $3, $4, $5}')"
    else
        echo -e "  ${YELLOW}[提示]${RESET} 无法获取磁盘信息"
    fi
}

# 部署 sun-panel（占位实现）
deploy_sun_panel() {
    echo -e "${CYAN}部署 sun-panel...${RESET}"
    SUN_PANEL_URL="https://raw.githubusercontent.com/cfmcmj/Fmie--primary/main/sun-panel"
    SUN_PANEL_DIR="$PROJECT_DIR/sun-panel"
    mkdir -p "$SUN_PANEL_DIR" || { echo -e "${RED}无法创建目录${RESET}"; return 1; }
    if command -v fetch >/dev/null 2>&1; then
        fetch -o "$SUN_PANEL_DIR/sun-panel" "$SUN_PANEL_URL" 2>>"$LOG_FILE" || { echo -e "${RED}下载失败${RESET}"; return 1; }
    elif command -v curl >/dev/null 2>&1; then
        curl -Ls "$SUN_PANEL_URL" -o "$SUN_PANEL_DIR/sun-panel" 2>>"$LOG_FILE" || { echo -e "${RED}下载失败${RESET}"; return 1; }
    else
        echo -e "${RED}需要 fetch 或 curl${RESET}"
        return 1
    fi
    chmod +x "$SUN_PANEL_DIR/sun-panel" 2>>"$LOG_FILE" || { echo -e "${RED}无法设置执行权限${RESET}"; return 1; }
    echo "sun-panel 已部署到 $SUN_PANEL_DIR"
    echo "运行: $SUN_PANEL_DIR/sun-panel"
}

# 项目管理
projectManager() {
    echo -e "${CYAN}项目管理:${RESET}"
    echo "1) 部署 sun-panel"
    echo "0) 返回主菜单"
    read -p "请选择: " choice
    if ! echo "$choice" | grep -q '^[0-1]$'; then
        echo -e "${RED}无效选择，请输入 0-1${RESET}"
        return 1
    fi
    case $choice in
        1) deploy_sun_panel ;;
        0) return ;;
    esac
}

# 配置设置
configSettings() {
    echo -e "${CYAN}配置设置:${RESET}"
    echo "1) 设置环境变量"
    echo "0) 返回主菜单"
    read -p "请选择: " choice
    if ! echo "$choice" | grep -q '^[0-1]$'; then
        echo -e "${RED}无效选择，请输入 0-1${RESET}"
        return 1
    fi
    case $choice in
        1) echo "请输入变量名和值 (如 PATH=$HOME/bin):"
           read -r env_var
           echo "export $env_var" >> "$HOME/.profile" 2>>"$LOG_FILE"
           echo "已添加 $env_var 到 $HOME/.profile"
           ;;
        0) return ;;
    esac
}

# 工具集
toolkit() {
    echo -e "${CYAN}工具集:${RESET}"
    echo "1) 文件管理器 (ls -l)"
    echo "2) 日志查看器 (tail)"
    echo "0) 返回主菜单"
    read -p "请选择: " choice
    if ! echo "$choice" | grep -q '^[0-2]$'; then
        echo -e "${RED}无效选择，请输入 0-2${RESET}"
        return 1
    fi
    case $choice in
        1) ls -l "$HOME" ;;
        2) tail -n 10 "$LOG_FILE" 2>/dev/null || echo "无日志文件" ;;
        0) return ;;
    esac
}

# 更新框架
updateFramework() {
    echo -e "${CYAN}检查更新...${RESET}"
    REMOTE_VERSION=$(curl -Ls https://raw.githubusercontent.com/cfmcmj/Fmie--primary/main/VERSION 2>/dev/null || fetch -o - https://raw.githubusercontent.com/cfmcmj/Fmie--primary/main/VERSION 2>/dev/null)
    if [ -n "$REMOTE_VERSION" ] && [ "$REMOTE_VERSION" != "$VERSION" ]; then
        echo "发现新版本 $REMOTE_VERSION，当前版本 $VERSION"
        read -p "是否更新? (y/n): " confirm
        if [ "$confirm" = "y" ]; then
            if command -v fetch >/dev/null 2>&1; then
                fetch -o "$PROJECT_DIR/start.sh.new" https://raw.githubusercontent.com/cfmcmj/Fmie--primary/main/start.sh 2>>"$LOG_FILE" || { echo -e "${RED}下载失败${RESET}"; return 1; }
            elif command -v curl >/dev/null 2>&1; then
                curl -Ls https://raw.githubusercontent.com/cfmcmj/Fmie--primary/main/start.sh -o "$PROJECT_DIR/start.sh.new" 2>>"$LOG_FILE" || { echo -e "${RED}下载失败${RESET}"; return 1; }
            fi
            mv "$PROJECT_DIR/start.sh.new" "$PROJECT_DIR/start.sh" 2>>"$LOG_FILE"
            chmod +x "$PROJECT_DIR/start.sh" 2>>"$LOG_FILE"
            echo "更新完成！"
        else
            echo "更新取消"
        fi
    else
        echo "当前已是最新版本 $VERSION"
    fi
}

# 测试脚本
testScript() {
    if ! type showBanner >/dev/null 2>&1; then
        echo -e "${RED}[错误]${RESET} showBanner 函数未定义" >&2
        echo "[$(date)] ERROR: showBanner undefined" >> "$LOG_FILE" 2>/dev/null
        exit 1
    fi
    showBanner
    echo -e "${GREEN}脚本测试通过！${RESET}"
    exit 0
}

# 主菜单
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
        read -p "请选择: " choice
        if ! echo "$choice" | grep -q '^[0-5]$'; then
            echo -e "${RED}无效选择，请输入 0-5${RESET}"
            continue
        fi
        case $choice in
            1) systemInfo ;;
            2) projectManager ;;
            3) configSettings ;;
            4) toolkit ;;
            5) updateFramework ;;
            0) echo -e "${GREEN}感谢使用 Fmie-pry 框架，再见!${RESET}"; exit 0 ;;
        esac
    done
}

# 捕获 Ctrl+C
trap 'echo -e "\n${GREEN}退出框架...${RESET}"; exit 0' INT

# 脚本入口
check_dependencies

case "$1" in
    --help|-h) showHelp; exit 0 ;;
    --version|-v) echo "Fmie-pry 框架版本 $VERSION"; exit 0 ;;
    --test) testScript ;;
    *) mainMenu ;;
esac