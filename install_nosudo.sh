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
ALIAS_CMD="gg"  # 快捷命令名称

# 开始安装
print_info "开始安装 Fmie--primary 框架..."

# 创建项目目录
mkdir -p "$PROJECT_DIR" || handle_error "无法创建项目目录: $PROJECT_DIR"

# 下载 start.sh 脚本
print_info "从 GitHub 下载最新框架代码..."
curl -Ls https://raw.githubusercontent.com/cfmcmj/Fmie--primary/main/start.sh -o "$PROJECT_DIR/start.sh" || handle_error "下载失败，请检查网络连接"

# 处理 Windows 换行符问题（增强版）
print_info "确保脚本使用 Unix 格式换行符..."
SED_SUCCESS=0

# 尝试使用最常见的 sed 语法
if sed -i 's/\r$//' "$PROJECT_DIR/start.sh" 2>/dev/null; then
    SED_SUCCESS=1
# 尝试 macOS/BSD 版本的 sed
elif sed -i '' 's/\r$//' "$PROJECT_DIR/start.sh" 2>/dev/null; then
    SED_SUCCESS=1
# 尝试使用双引号版本的 sed 命令
elif sed -i "" 's/\r$//' "$PROJECT_DIR/start.sh" 2>/dev/null; then
    SED_SUCCESS=1
fi

if [ $SED_SUCCESS -eq 0 ]; then
    print_info "警告: sed 命令失败，尝试替代方法..."
    # 使用 tr 命令替代
    if tr -d '\r' < "$PROJECT_DIR/start.sh" > "$PROJECT_DIR/start.sh.tmp"; then
        mv "$PROJECT_DIR/start.sh.tmp" "$PROJECT_DIR/start.sh" || handle_error "无法修复换行符问题"
        chmod +x "$PROJECT_DIR/start.sh"
    else
        handle_error "无法修复换行符问题，请检查文件权限"
    fi
else
    print_info "成功转换换行符"
fi

# 设置执行权限
chmod +x "$PROJECT_DIR/start.sh" || handle_error "无法设置执行权限"

# 创建快捷命令（使用 alias）
print_info "创建快捷命令 '$ALIAS_CMD'..."
ALIAS_LINE="alias $ALIAS_CMD=\"$PROJECT_DIR/start.sh\""

# 配置环境变量
print_info "配置环境变量..."
ENV_FILE="$HOME/.bashrc"
if [ -f "$HOME/.bash_profile" ]; then
    ENV_FILE="$HOME/.bash_profile"
fi

# 添加 alias 到环境文件
if ! grep -q "$ALIAS_LINE" "$ENV_FILE"; then
    echo "$ALIAS_LINE" >> "$ENV_FILE"
    print_info "已将 '$ALIAS_LINE' 添加到 $ENV_FILE"
else
    print_info "alias 已配置，跳过此步骤"
fi

# 清除命令缓存
print_info "清除命令缓存..."
hash -d $ALIAS_CMD 2>/dev/null

# 立即生效环境变量
print_info "尝试立即加载环境变量..."
if [ -f "$HOME/.bashrc" ]; then
    source "$HOME/.bashrc"
elif [ -f "$HOME/.bash_profile" ]; then
    source "$HOME/.bash_profile"
fi

# 验证安装结果
print_info "验证安装结果..."
if bash -c "source $ENV_FILE && type $ALIAS_CMD &>/dev/null"; then
    print_info "安装成功！'$ALIAS_CMD' 命令已可用。"
    
    # 测试脚本是否能正常执行
    if bash -c "source $ENV_FILE && $ALIAS_CMD --test &>/dev/null"; then
        print_info "框架脚本测试通过！"
    else
        print_info "框架脚本测试失败，请检查 $PROJECT_DIR/start.sh 文件。"
        print_info "您可以手动执行: $PROJECT_DIR/start.sh 查看详细错误。"
    fi
else
    print_info "安装完成，但 '$ALIAS_CMD' 命令尚未生效。"
    echo
    echo -e "${GREEN}使用方法:${RESET}"
    echo "  1. 在当前终端执行: ${CYAN}source ~/.bashrc${RESET}"
    echo "  2. 或重新启动终端"
    echo "  3. 执行 ${CYAN}$ALIAS_CMD${RESET} 命令启动框架"
    echo
fi    