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

# 系统初始化函数 - 彻底清除所有框架痕迹
system_init() {
    print_info "开始系统彻底初始化..."
    # 创建必要的目录（保留，不删除）
    mkdir -p "$HOME/bin"
    mkdir -p "$HOME/.config"
    # 彻底删除框架安装目录
    if [ -d "$HOME/Fmie--primary" ]; then
        rm -rf "$HOME/Fmie--primary" || handle_error "无法删除框架安装目录"
        print_info "已彻底删除框架安装目录"
    else
        print_info "框架安装目录不存在，跳过删除"
    fi
    # 清理所有相关文件和目录
    RELATED_FILES=(
        "$HOME/Fmie--primary"
        "$HOME/.fmie"
        "$HOME/.config/fmie"
        "$HOME/bin/fmie"
        "$HOME/bin/gg"
        "$HOME/.local/bin/fmie"
        "$HOME/.local/bin/gg"
        "$HOME/.cache/fmie"
        "$HOME/.fmirc"
        "$HOME/.fmie_profile"
    )
    for file in "${RELATED_FILES[@]}"; do
        if [ -e "$file" ]; then
            if [ -d "$file" ]; then
                rm -rf "$file" || handle_error "无法删除目录 $file"
            else
                rm -f "$file" || handle_error "无法删除文件 $file"
            fi
            print_info "已删除 $file"
        else
            print_info "$file 不存在，跳过删除"
        fi
    done
    # 清理环境变量配置 - 彻底清除
    CONFIG_FILES=(
        "$HOME/.bashrc"
        "$HOME/.bash_profile"
        "$HOME/.zshrc"
        "$HOME/.profile"
        "$HOME/.bash_login"
        "$HOME/.config/fish/config.fish"
        "$HOME/.config/fish/functions/fmie.fish"
        "$HOME/.config/fish/functions/gg.fish"
    )
    for file in "${CONFIG_FILES[@]}"; do
        if [ -f "$file" ]; then
            if sed --version 2>/dev/null | grep -q "GNU"; then
                # GNU sed
                sed -i '/# Fmie--primary framework/d' "$file"
                sed -i '/gg() {.*Fmie--primary\/start.sh/d' "$file"
                sed -i '/export PATH.*Fmie--primary/d' "$file"
                sed -i '/alias gg=.*Fmie--primary/d' "$file"
                sed -i '/Fmie--primary/d' "$file"
            else
                # BSD sed (macOS/FreeBSD)
                sed -i '' '/# Fmie--primary framework/d' "$file"
                sed -i '' '/gg() {.*Fmie--primary\/start.sh/d' "$file"
                sed -i '' '/export PATH.*Fmie--primary/d' "$file"
                sed -i '' '/alias gg=.*Fmie--primary/d' "$file"
                sed -i '' '/Fmie--primary/d' "$file"
            fi
            print_info "已彻底清除 $file 中的框架配置"
        fi
    done
    # 清理命令历史记录
    HIST_FILES=(
        "$HOME/.bash_history"
        "$HOME/.zsh_history"
        "$HOME/.fish_history"
    )
    for hist_file in "${HIST_FILES[@]}"; do
        if [ -f "$hist_file" ]; then
            if sed --version 2>/dev/null | grep -q "GNU"; then
                sed -i '/Fmie--primary/d' "$hist_file"
                sed -i '/fmie/d' "$hist_file"
                sed -i '/gg/d' "$hist_file"
            else
                sed -i '' '/Fmie--primary/d' "$hist_file"
                sed -i '' '/fmie/d' "$hist_file"
                sed -i '' '/gg/d' "$hist_file"
            fi
            print_info "已清理 $hist_file 中的框架命令记录"
        fi
    done
    # 清除命令缓存
    print_info "清除命令缓存..."
    hash -r
    print_info "系统彻底初始化完成！Fmie--primary 框架已被完全删除。"
}

# 定义安装目录
PROJECT_DIR="$HOME/Fmie--primary"
ALIAS_CMD="gg"  # 快捷命令名称

# 显示欢迎信息
echo -e "${GREEN}欢迎使用 Fmie--primary 框架安装脚本！${RESET}"
echo -e "${YELLOW}========================================${RESET}"
echo -e "  此脚本将安装 Fmie--primary 框架到您的系统"
echo -e "  安装过程不需要 sudo 权限"
echo -e "${YELLOW}========================================${RESET}"

# 系统初始化并安装框架
system_init()

# 开始安装
print_info "开始安装 Fmie--primary 框架..."

# 创建项目目录
mkdir -p "$PROJECT_DIR" || handle_error "无法创建项目目录: $PROJECT_DIR"

# 下载 start.sh 脚本
print_info "从 GitHub 下载最新框架代码..."
if command -v curl &>/dev/null; then
    curl -Ls https://raw.githubusercontent.com/cfmcmj/Fmie--primary/main/start.sh -o "$PROJECT_DIR/start.sh" || handle_error "下载失败，请检查网络连接"
elif command -v wget &>/dev/null; then
    wget -q -O "$PROJECT_DIR/start.sh" https://raw.githubusercontent.com/cfmcmj/Fmie--primary/main/start.sh || handle_error "下载失败，请检查网络连接"
else
    handle_error "未找到 curl 或 wget 命令，无法下载框架代码"
fi

# 处理 Windows 换行符问题（增强版）
print_info "确保脚本使用 Unix 格式换行符..."
if command -v dos2unix &>/dev/null; then
    dos2unix "$PROJECT_DIR/start.sh" || print_info "警告: dos2unix 执行失败，尝试替代方法"
else
    # 尝试使用 sed
    SED_SUCCESS=0
    if sed -i 's/\r$//' "$PROJECT_DIR/start.sh" 2>/dev/null; then
        SED_SUCCESS=1
    elif sed -i '' 's/\r$//' "$PROJECT_DIR/start.sh" 2>/dev/null; then
        SED_SUCCESS=1
    elif sed -i "" 's/\r$//' "$PROJECT_DIR/start.sh" 2>/dev/null; then
        SED_SUCCESS=1
    fi
    if [ $SED_SUCCESS -eq 0 ]; then
        print_info "警告: sed 命令失败，尝试使用 tr"
        if tr -d '\r' < "$PROJECT_DIR/start.sh" > "$PROJECT_DIR/start.sh.tmp"; then
            mv "$PROJECT_DIR/start.sh.tmp" "$PROJECT_DIR/start.sh" || handle_error "无法修复换行符问题"
        else
            handle_error "无法修复换行符问题，请检查文件权限"
        fi
    fi
fi

# 设置执行权限
chmod +x "$PROJECT_DIR/start.sh" || handle_error "无法设置执行权限"

# 创建快捷命令（使用函数替代 alias）
print_info "创建快捷命令 '$ALIAS_CMD'..."
FUNCTION_LINE="$ALIAS_CMD() { $PROJECT_DIR/start.sh \"\$@\"; }"
# 配置环境变量（增强版）
print_info "配置环境变量..."
ENV_FILES=("$HOME/.bashrc" "$HOME/.bash_profile" "$HOME/.zshrc")
ENV_FILE=""
# 查找当前用户使用的 shell 对应的配置文件
for file in "${ENV_FILES[@]}"; do
    if [ -f "$file" ]; then
        # 移除旧的 alias 定义（改进版 sed 命令）
        if grep -q "alias $ALIAS_CMD=" "$file"; then
            if sed --version 2>/dev/null | grep -q "GNU"; then
                # GNU sed
                sed -i '/alias '"$ALIAS_CMD"'=/d' "$file"
            else
                # BSD sed (macOS/FreeBSD)
                sed -i '' '/alias '"$ALIAS_CMD"'=/d' "$file"
            fi
            print_info "已从 $file 中移除旧的 alias 定义"
        fi
        # 添加函数定义
        if ! grep -q "$FUNCTION_LINE" "$file"; then
            echo -e "\n# Fmie--primary framework" >> "$file"
            echo "$FUNCTION_LINE" >> "$file"
            print_info "已将函数定义添加到 $file"
        else
            print_info "函数已在 $file 中配置，跳过此步骤"
        fi
        ENV_FILE="$file"
        break
    fi
done
# 如果未找到任何文件，则默认使用 .bashrc
if [ -z "$ENV_FILE" ]; then
    echo -e "\n# Fmie--primary framework" >> "$HOME/.bashrc"
    echo "$FUNCTION_LINE" >> "$HOME/.bashrc"
    ENV_FILE="$HOME/.bashrc"
fi
# 立即生效环境变量（改进版验证）
print_info "尝试立即加载环境变量..."
if [ -n "$ENV_FILE" ] && [ -f "$ENV_FILE" ]; then
    # 检查 .bashrc 第一行是否有语法错误
    if head -n1 "$ENV_FILE" | grep -q "alias gg="; then
        if sed --version 2>/dev/null | grep -q "GNU"; then
            sed -i '1d' "$ENV_FILE"
        else
            # BSD sed 需要临时文件
            sed '1d' "$ENV_FILE" > "$ENV_FILE.tmp" && mv "$ENV_FILE.tmp" "$ENV_FILE"
        fi
        print_info "已修复 .bashrc 文件"
    fi
    # 在子 shell 中加载并验证
    if bash -c "source $ENV_FILE && type $ALIAS_CMD &>/dev/null"; then
        print_info "环境变量已成功加载！"
    else
        print_info "警告: 环境变量未能立即生效。这可能不影响后续使用。"
    fi
fi
# 验证安装结果（改进版验证）
print_info "验证安装结果..."
# 使用子 shell 验证，避免影响当前环境
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
    echo "  1. 在当前终端执行: ${CYAN}source $ENV_FILE${RESET}"
    echo "  2. 或重新启动终端"
    echo "  3. 执行 ${CYAN}$ALIAS_CMD${RESET} 命令启动框架"
    echo
fi