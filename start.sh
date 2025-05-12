#!/bin/bash
# Fmie--primary 框架主入口脚本（FreeBSD 兼容版）

# 捕获中断信号（Ctrl+C）
trap 'echo -e "\n${RED}[信息]${RESET} 已中断操作"; exit 1' SIGINT SIGTERM

# 颜色定义
RED='\033[0;91m'
GREEN='\033[0;92m'
YELLOW='\033[0;33m'
BLUE='\033[0;94m'
MAGENTA='\033[0;95m'
CYAN='\033[0;96m'
RESET='\033[0m'

# 版本信息
VERSION="v1.0.0"

# 显示横幅
showBanner() {
  clear
  echo -e "$(cat << EOF
${GREEN}<----------------------------------------------------------------->

    ${RED}███████ ███    ███ ██ ███████     ${BLUE}██████  ██    ██     
    ${RED}██      ████  ████ ██ ██          ${BLUE}██   ██  ██  ██      
    ${RED}█████   ██ ████ ██ ██ █████ ${GREEN}█████ ${BLUE}██████    ████       
    ${RED}██      ██  ██  ██ ██ ██          ${BLUE}██         ██        
    ${RED}██      ██      ██ ██ ███████     ${BLUE}██         ██        
    ${RED}                                  ${BLUE}                  
    ${RED}                             F${GREEN}M${YELLOW}I${BLUE}E${PURPLE}-${CYAN}P${RED}T${RESET} -- 自动化部署框架"
${GREEN}<----------------------------------------------------------------->                                                       
EOF
)"
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
        
        # 计算百分比
        if [ $total_mem -gt 0 ]; then
            used_percent=$((active_mem * 100 / total_mem))
        else
            used_percent=0
        fi
        
        echo "  总内存: ${total_mem_mb} MB"
        echo "  已用内存: ${active_mem_mb} MB"
        echo "  空闲内存: ${free_mem_mb} MB"
        echo "  使用率: ${used_percent}%"
    elif [ -r "/compat/linux/proc/meminfo" ]; then
        # 兼容 Linux 子系统的情况
        total=$(grep "MemTotal:" /compat/linux/proc/meminfo | awk '{print $2}')
        free=$(grep "MemFree:" /compat/linux/proc/meminfo | awk '{print $2}')
        available=$(grep "MemAvailable:" /compat/linux/proc/meminfo | awk '{print $2}')
        
        if [ -n "$total" ] && [ -n "$free" ] && [ -n "$available" ]; then
            used=$((total - free))
            percent=$((used * 100 / total))
            
            echo "  总内存: $(echo "scale=2; $total/1024" | bc -l | awk '{printf "%.2f MB\n", $1}')"
            echo "  可用内存: $(echo "scale=2; $available/1024" | bc -l | awk '{printf "%.2f MB\n", $1}')"
            echo "  使用率: ${percent}%"
        else
            echo -e "  ${YELLOW}[提示]${RESET} 无法获取详细内存信息"
        fi
    else
        echo -e "  ${YELLOW}[提示]${RESET} 缺少 'vmstat' 命令，无法显示内存信息"
    fi
}

# 系统信息
systemInfo() {
  echo -e "${CYAN}系统信息:${RESET}"
  echo "主机名: $(hostname)"
  
  # 获取操作系统信息
  OS=$(uname)
  case $OS in
    Linux)
      echo "操作系统: $(cat /etc/os-release | grep PRETTY_NAME | cut -d= -f2 | tr -d '"')"
      ;;
    FreeBSD)
      echo "操作系统: FreeBSD $(uname -r)"
      ;;
    *)
      echo "操作系统: $OS $(uname -r)"
      ;;
  esac
  
  echo "内核版本: $(uname -r)"
  
  # 内存信息（改进版，支持 FreeBSD）
  echo -e "${CYAN}内存信息:${RESET}"
  if [ "$OS" = "FreeBSD" ]; then
      get_freebsd_memory_info
  else
      if command -v free &>/dev/null; then
          echo "  $(free -h | grep Mem | awk '{printf "总内存: %s, 已用: %s, 空闲: %s, 使用率: %s\n", $2, $3, $4, $5}')"
      else
          if [ -f "/proc/meminfo" ]; then
              total=$(grep "MemTotal:" /proc/meminfo | awk '{print $2}')
              free=$(grep "MemFree:" /proc/meminfo | awk '{print $2}')
              available=$(grep "MemAvailable:" /proc/meminfo | awk '{print $2}')
              
              if [ -n "$total" ] && [ -n "$free" ] && [ -n "$available" ]; then
                  used=$((total - free))
                  percent=$((used * 100 / total))
                  
                  echo "  总内存: $(echo "scale=2; $total/1024/1024" | bc -l | awk '{printf "%.2f GB\n", $1}')"
                  echo "  可用内存: $(echo "scale=2; $available/1024/1024" | bc -l | awk '{printf "%.2f GB\n", $1}')"
                  echo "  使用率: ${percent}%"
              else
                  echo -e "  ${YELLOW}[提示]${RESET} 无法获取详细内存信息"
              fi
          else
              echo -e "  ${YELLOW}[提示]${RESET} 缺少 'free' 命令，无法显示内存信息"
          fi
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
    1) echo "创建新项目..." ;;
    2) echo "部署现有项目..." ;;
    3) echo "更新项目..." ;;
    4) echo "删除项目..." ;;
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
    1) echo "修改系统配置..." ;;
    2) echo "管理用户账户..." ;;
    3) echo "设置环境变量..." ;;
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
    1) echo "文件管理器..." ;;
    2) echo "日志查看器..." ;;
    3) echo "系统监控..." ;;
    4) echo "网络工具..." ;;
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
    # 模拟更新过程
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