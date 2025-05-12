#!/bin/bash
# Fmie--primary 一键安装脚本（无 sudo 版本，FreeBSD 兼容）

# 颜色定义
RED='\033[0;91m'
GREEN='\033[0;92m'
YELLOW='\033[0;33m'
RESET='\033[0m'

# 日志文件
LOG_FILE="$HOME/Fmie--primary/fmie.log"

# 错误处理函数
handle_error() {
    echo -e "${RED}[错误]${RESET} $1" >&2
    echo "[$(date)] ERROR: $1" >> "$LOG_FILE" 2>/dev/null
    exit 1
}

# 信息输出函数
print_info() {
    echo -e "${GREEN}[信息]${RESET} $1"
    echo "[$(date)] INFO: $1" >> "$LOG_FILE" 2>/dev/null
}

# 定义安装目录
PROJECT_DIR="${FMIE_INSTALL_DIR:-$HOME/Fmie--primary}"
ALIAS_CMD="gg"

# 检查家目录权限
[ -w "$HOME" ] || handle_error "家目录 $HOME 不可写，请检查权限"

# 开始安装
print_info "开始安装 Fmie--primary 框架..."

# 创建项目目录
mkdir -p "$PROJECT_DIR" || handle_error "无法创建项目目录: $PROJECT_DIR"

# 选择下载工具
if command -v curl >/dev/null 2>&1; then
    DOWNLOADER="curl -Ls"
elif command -v fetch >/dev/null 2>&1; then
    DOWNLOADER="fetch -o -"
else
    handle_error "需要 curl 或 fetch，请安装任一工具"
fi

# 下载 start.sh 脚本
print_info "从 GitHub 下载最新框架代码..."
$DOWNLOADER https://raw.githubusercontent.com/cfmcmj/Fmie--primary/main/start.sh > "$PROJECT_DIR/start.sh" || handle_error "下载失败，请检查网络连接"

# 验证文件完整性（假设仓库提供校验和）
# 示例校验和，需替换为实际值
EXPECTED_CHECKSUM="replace_with_actual_sha256sum"
if command -v sha256 >/dev/null 2>&1; then
    echo "$EXPECTED_CHECKSUM  $PROJECT_DIR/start.sh" | sha256 -c >/dev/null 2>&1 || handle_error "文件校验和验证失败"
else
    print_info "警告: 缺少 sha256 命令，无法验证文件完整性"
fi

# 处理换行符
print_info "确保脚本使用 Unix 格式换行符..."
if sed -i '' 's/\r$//' "$PROJECT_DIR/start.sh" 2>/dev/null; then
    print_info "成功转换换行符"
elif command -v tr >/dev/null 2>&1 && tr -d '\r' < "$PROJECT_DIR/start.sh" > "$PROJECT_DIR/start.sh.tmp"; then
    mv "$PROJECT_DIR/start.sh.tmp" "$PROJECT_DIR/start.sh" || handle_error "无法修复换行符"
    chmod +x "$PROJECT_DIR/start.sh"
else
    print_info "警告: 无法自动修复换行符，请手动检查 $PROJECT_DIR/start.sh"
fi

# 设置执行权限
chmod +x "$PROJECT_DIR/start.sh" || handle_error "无法设置执行权限"

# 配置 alias
print_info "创建快捷命令 '$ALIAS_CMD'..."
CURRENT_SHELL=$(basename "$SHELL")
case $CURRENT_SHELL in
    bash) ENV_FILE="$HOME/.bashrc"; ALIAS_LINE="alias $ALIAS_CMD \"$PROJECT_DIR/start.sh\"" ;;
    zsh) ENV_FILE="$HOME/.zshrc"; ALIAS_LINE="alias $ALIAS_CMD \"$PROJECT_DIR/start.sh\"" ;;
    tcsh|csh)
        ENV_FILE="$HOME/.tcshrc"
        [ -f "$ENV_FILE" ] || ENV_FILE="$HOME/.cshrc"
        ALIAS_LINE="alias $ALIAS_CMD '$PROJECT_DIR/start.sh'"
        ;;
    *) ENV_FILE="$HOME/.profile"; ALIAS_LINE="alias $ALIAS_CMD \"$PROJECT_DIR/start.sh\"" ;;
esac

if [ -f "$ENV_FILE" ] && ! grep -q "$ALIAS_LINE" "$ENV_FILE"; then
    echo "$ALIAS_LINE" >> "$ENV_FILE" || handle_error "无法写入 $ENV_FILE"
    print_info "已将 '$ALIAS_LINE' 添加到 $ENV_FILE"
elif [ -f "$ENV_FILE" ]; then
    print_info "alias 已在 $ENV_FILE 中配置，跳过"
else
    echo "$ALIAS_LINE" > "$ENV_FILE" || handle_error "无法创建 $ENV_FILE"
    print_info "已创建 $ENV_FILE 并添加 alias"
fi

# 加载环境变量
print_info "尝试加载环境变量..."
if [ "$CURRENT_SHELL" = "tcsh" ] || [ "$CURRENT_SHELL" = "csh" ]; then
    if [ -f "$ENV_FILE" ]; then
        tcsh -c "source $ENV_FILE" 2>/dev/null || print_info "无法自动加载 $ENV_FILE，请手动执行 'source $ENV_FILE'"
    fi
else
    if [ -f "$ENV_FILE" ]; then
        source "$ENV_FILE" 2>/dev/null || print_info "无法加载 $ENV_FILE"
    fi
fi

# 验证安装
print_info "验证安装结果..."
if command -v bash >/dev/null 2>&1 && bash -c "source $ENV_FILE && $ALIAS_CMD --test" >/dev/null 2>&1; then
    print_info "安装成功！'$ALIAS_CMD' 命令已可用。"
else
    print_info "安装完成，但 '$ALIAS_CMD' 可能未生效。"
    echo
    echo -e "${GREEN}使用方法:${RESET}"
    echo "  1. 执行: ${CYAN}source $ENV_FILE${RESET}"
    echo "  2. 或重新打开终端"
    echo "  3. 运行: ${CYAN}$ALIAS_CMD${RESET}"
    echo
fi

# 提示 shell 信息
echo -e "${YELLOW}[提示]${RESET} 当前 shell: $CURRENT_SHELL"
echo "如果 '$ALIAS_CMD' 不可用，请确认 $ENV_FILE 已正确加载"