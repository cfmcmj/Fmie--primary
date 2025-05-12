#!/bin/bash

# Fmie--primary 一键安装脚本（无 sudo 版本）

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

# 定义安装目录（用户目录下）
PROJECT_DIR="$HOME/Fmie--primary"
BIN_DIR="$HOME/bin"

info "开始安装 Fmie--primary 框架..."

# 创建项目目录
mkdir -p "$PROJECT_DIR" || error "无法创建项目目录"

# 下载 start.sh 脚本
info "从 GitHub 下载最新框架代码..."
curl -Ls https://raw.githubusercontent.com/cfmcmj/Fmie--primary/main/start.sh -o "$PROJECT_DIR/start.sh" || error "下载失败"

# 设置执行权限
chmod +x "$PROJECT_DIR/start.sh" || error "无法设置执行权限"

# 创建快捷命令目录（如果不存在）
mkdir -p "$BIN_DIR"

# 创建快捷命令
info "创建快捷命令 'gg'..."
echo "#!/bin/bash" > "$BIN_DIR/gg"
echo "$PROJECT_DIR/start.sh" >> "$BIN_DIR/gg"
chmod +x "$BIN_DIR/gg" || error "无法设置快捷命令权限"

# 添加 bin 目录到 PATH（临时）
export PATH="$BIN_DIR:$PATH"

info "安装完成！"
info "现在你可以通过执行 '$BIN_DIR/gg' 命令启动 Fmie--primary 框架。"
info "为了永久使用 'gg' 命令，请将以下行添加到你的 ~/.bashrc 或 ~/.profile 文件中："
info "  export PATH=\"$BIN_DIR:\$PATH\""