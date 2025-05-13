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
    
    # 确认操作
    echo -e "${RED}[警告]${RESET} 此操作将彻底删除 Fmie--primary 框架的所有痕迹，包括:"
    echo "  - 框架安装目录"
    echo "  - 环境变量配置"
    echo "  - 所有项目文件"
    echo "  - 所有相关配置"
    echo -e "${RED}[警告]${RESET} 此操作不可恢复，且需要您确认所有删除操作！"
    read -p "确定要继续吗？这将无法恢复！(y/N): " confirm
    if [ "$confirm" != "y" ]; then
        echo -e "${YELLOW}[信息]${RESET} 系统初始化已取消"
        exit 0
    fi
    
    # 创建必要的目录（保留，不删除）
    mkdir -p "$HOME/bin"
    mkdir -p "$HOME/.config"
    
    # 检查并安装必要的依赖（仅检查，不删除）
    print_info "检查系统依赖..."
    MISSING_DEPS=""
    
    # 检查 curl/wget
    if ! command -v curl &>/dev/null && ! command -v wget &>/dev/null; then
        MISSING_DEPS="$MISSING_DEPS curl/wget"
    fi
    
    # 检查 sed
    if ! command -v sed &>/dev/null; then
        MISSING_DEPS="$MISSING_DEPS sed"
    fi
    
    # 检查 grep
    if ! command -v grep &>/dev/null; then
        MISSING_DEPS="$MISSING_DEPS grep"
    fi
    
    # 输出缺少的依赖
    if [ -n "$MISSING_DEPS" ]; then
        echo -e "${YELLOW}[警告]${RESET} 系统缺少以下依赖: $MISSING_DEPS"
        echo -e "${YELLOW}[提示]${RESET} 请联系系统管理员安装这些依赖"
    else
        print_info "系统依赖检查通过"
    fi
    
    # 清理旧的安装文件 - 彻底删除
    print_info "彻底删除框架安装目录..."
    if [ -d "$HOME/Fmie--primary" ]; then
        echo -e "${YELLOW}[确认]${RESET} 即将删除目录: $HOME/Fmie--primary"
        read -p "继续删除？(y/N): " confirm
        if [ "$confirm" = "y" ]; then
            rm -rf "$HOME/Fmie--primary" || handle_error "无法删除框架安装目录"
            print_info "已彻底删除框架安装目录"
        else
            print_info "跳过删除框架安装目录"
        fi
    else
        print_info "框架安装目录不存在，跳过删除"
    fi
    
    # 清理所有相关文件和目录 - 增强版
    print_info "清理所有相关文件和目录..."
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
            echo -e "${YELLOW}[确认]${RESET} 即将删除: $file"
            read -p "继续删除？(y/N): " confirm
            if [ "$confirm" = "y" ]; then
                if [ -d "$file" ]; then
                    rm -rf "$file" || handle_error "无法删除目录 $file"
                else
                    rm -f "$file" || handle_error "无法删除文件 $file"
                fi
                print_info "已删除 $file"
            else
                print_info "跳过删除 $file"
            fi
        else
            print_info "$file 不存在，跳过删除"
        fi
    done
    
    # 清理环境变量配置 - 彻底清除
    print_info "彻底清除环境变量配置..."
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
            echo -e "${YELLOW}[确认]${RESET} 即将清理配置文件: $file"
            read -p "继续清理？(y/N): " confirm
            if [ "$confirm" = "y" ]; then
                # 创建备份
                cp "$file" "$file.bak"
                print_info "已备份 $file 到 $file.bak"
                
                # 彻底清除所有 Fmie--primary 相关配置
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
            else
                print_info "跳过清理 $file"
            fi
        else
            print_info "$file 不存在，跳过清理"
        fi
    done
    
    # 清理命令历史记录
    print_info "清理命令历史记录..."
    HIST_FILES=(
        "$HOME/.bash_history"
        "$HOME/.zsh_history"
        "$HOME/.fish_history"
    )
    
    for hist_file in "${HIST_FILES[@]}"; do
        if [ -f "$hist_file" ]; then
            echo -e "${YELLOW}[确认]${RESET} 即将从历史记录中移除 Fmie--primary 相关命令: $hist_file"
            read -p "继续清理？(y/N): " confirm
            if [ "$confirm" = "y" ]; then
                # 创建备份
                cp "$hist_file" "$hist_file.bak"
                print_info "已备份 $hist_file 到 $hist_file.bak"
                
                # 移除包含 Fmie--primary 的行
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
            else
                print_info "跳过清理 $hist_file"
            fi
        else
            print_info "$hist_file 不存在，跳过清理"
        fi
    done
    
    # 清除命令缓存
    print_info "清除命令缓存..."
    hash -r
    
    print_info "系统彻底初始化完成！Fmie--primary 框架已被完全删除。"
    echo -e "${YELLOW}[提示]${RESET} 建议重新登录或重启终端以确保所有更改生效。"
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
echo

# 提供选项
echo "请选择操作:"
echo "1) 系统初始化 (彻底清除所有框架痕迹)"
echo "2) 安装 Fmie--primary 框架"
echo "3) 系统初始化并安装框架"
echo "0) 退出"

read -p "请选择 [0-3]: " choice

case $choice in
    1)
        system_init
        exit 0
        ;;
    2)
        # 继续安装
        ;;
    3)
        system_init
        ;;
    0)
        echo -e "${YELLOW}[信息]${RESET} 安装已取消"
        exit 0
        ;;
    *)
        echo -e "${RED}[错误]${RESET} 无效选择"
        exit 1
        ;;
esac

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
echo "#!/bin/bash" > "$HOME/bin/$ALIAS_CMD"
echo "$PROJECT_DIR/start.sh" >> "$HOME/bin/$ALIAS_CMD"
chmod +x "$HOME/bin/$ALIAS_CMD" || handle_error "无法设置快捷命令权限"

# 添加到环境变量
ENV_FILE="$HOME/.bashrc"
if [ -f "$ENV_FILE" ]; then
    if ! grep -q "$HOME/bin" "$ENV_FILE"; then
        echo 'export PATH="$HOME/bin:$PATH"' >> "$ENV_FILE"
        print_info "已将 $HOME/bin 添加到环境变量"
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

# 提供启动选项
echo
echo -e "${GREEN}安装已完成！${RESET}"
read -p "是否立即启动 Fmie--primary 框架？(y/N): " start_choice
if [ "$start_choice" = "y" ]; then
    print_info "正在启动 Fmie--primary 框架..."
    # 确保环境变量已更新
    source "$ENV_FILE"
    # 启动框架
    $ALIAS_CMD
else
    echo -e "${YELLOW}[提示]${RESET} 您可以随时通过执行 '$ALIAS_CMD' 命令启动框架。"
fi