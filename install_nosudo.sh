#!/bin/bash
# Fmie--primary 一键安装脚本（无 sudo 版本）

# 颜色定义
RED='\033[0;91m'
GREEN='\033[0;92m'
YELLOW='\033[0;33m'
RESET='\033[0m'

# 错误处理函数
handle_error() {
    echo -e "${RED}[错误]${RESET} $1" >&2
    exit 1
}

# 信息输出函数
print_info() {
    echo -e "${GREEN}[信息]${RESET} $1"
}

# 定义安装目录
PROJECT_DIR="$HOME/Fmie--primary"
BIN_DIR="$HOME/bin"

print_info "开始安装 Fmie--primary 框架..."

# 创建项目目录
mkdir -p "$PROJECT_DIR" || handle_error "无法创建项目目录: $PROJECT_DIR"

# 下载 start.sh 脚本
print_info "从 GitHub 下载最新框架代码..."
curl -Ls https://raw.githubusercontent.com/cfmcmj/Fmie--primary/main/start.sh -o "$PROJECT_DIR/start.sh" || handle_error "下载失败，请检查网络连接"

# 设置执行权限
chmod +x "$PROJECT_DIR/start.sh" || handle_error "无法设置执行权限"

# 创建快捷命令目录（如果不存在）
mkdir -p "$BIN_DIR" || handle_error "无法创建 bin 目录: $BIN_DIR"

# 创建快捷命令
print_info "创建快捷命令 'gg'..."
cat > "$BIN_DIR/gg" << EOF
#!/bin/bash
$PROJECT_DIR/start.sh "\$@"
EOF
chmod +x "$BIN_DIR/gg" || handle_error "无法设置快捷命令权限"

# 配置环境变量（改进版）
print_info "配置环境变量，使 'gg' 命令永久可用..."
ENV_FILE="$HOME/.bashrc"
if [ -f "$HOME/.bash_profile" ]; then
    ENV_FILE="$HOME/.bash_profile"  # 使用 .bash_profile 替代 .bashrc
fi

if ! grep -q "$BIN_DIR" "$ENV_FILE"; then
    echo "export PATH=\"$BIN_DIR:\$PATH\"" >> "$ENV_FILE"
    print_info "已将 'export PATH=\"$BIN_DIR:\$PATH\"' 添加到 $ENV_FILE"
else
    print_info "环境变量已配置，跳过此步骤"
fi

# 立即生效环境变量
print_info "尝试立即生效环境变量..."
if [ -f "$HOME/.bashrc" ]; then
    source "$HOME/.bashrc"
elif [ -f "$HOME/.bash_profile" ]; then
    source "$HOME/.bash_profile"
fi

# 验证安装结果
print_info "验证安装结果..."
if command -v gg &>/dev/null; then
    print_info "安装成功！'gg' 命令已可用。"
    gg --version
else
    print_info "安装完成，但 'gg' 命令尚未生效。"
    print_info "请尝试重新启动终端或执行: source $ENV_FILE"
fi