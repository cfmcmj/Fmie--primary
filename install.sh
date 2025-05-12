#!/bin/bash

# Fmie--primary 一键安装脚本

# 颜色定义
RED='\033[0;91m'
GREEN='\033[0;92m'
YELLOW='\033[0;33m'
RESET='\033[0m'

# 错误处理函数
error() {
    echo -e "${RED}[错误]${RESET} $1" >&2
    exit 1
}

# 信息输出函数
info() {
    echo -e "${GREEN}[信息]${RESET} $1"
}

# 警告输出函数
warning() {
    echo -e "${YELLOW}[警告]${RESET} $1"
}

# 检查是否为root用户
if [ "$(id -u)" -ne 0 ]; then
    warning "安装过程需要root权限，将尝试使用sudo执行"
    SUDO="sudo"
else
    SUDO=""
fi

# 定义安装目录
INSTALL_DIR="/usr/local/bin"
PROJECT_DIR="/opt/Fmie--primary"

info "开始安装 Fmie--primary 框架..."

# 创建项目目录
$SUDO mkdir -p "$PROJECT_DIR" || error "无法创建项目目录"

# 下载 start.sh 脚本
info "从 GitHub 下载最新框架代码..."
curl -Ls https://raw.githubusercontent.com/cfmcmj/Fmie--primary/main/start.sh -o "$PROJECT_DIR/start.sh" || error "下载失败"

# 设置执行权限
$SUDO chmod +x "$PROJECT_DIR/start.sh" || error "无法设置执行权限"

# 创建快捷命令
info "创建快捷命令 'gg'..."
echo "#!/bin/bash" > /tmp/gg
echo "$PROJECT_DIR/start.sh" >> /tmp/gg
$SUDO mv /tmp/gg "$INSTALL_DIR/gg" || error "无法创建快捷命令"
$SUDO chmod +x "$INSTALL_DIR/gg" || error "无法设置快捷命令权限"

info "安装完成！"
info "现在你可以在任何位置通过执行 'gg' 命令启动 Fmie--primary 框架。"