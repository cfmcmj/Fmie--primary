# Fmie--primary 框架

Fmie--primary 是一个自动化部署框架，支持在 FreeBSD 等无 root 权限环境中运行。主要功能包括系统信息查看、项目管理和环境配置。

## 功能
- 系统信息查看（主机名、操作系统、内存、磁盘）
- sun-panel 部署（占位实现，待完善）
- 环境变量配置
- 基本工具集（文件管理、日志查看）
- 框架更新检查

## 安装

在 FreeBSD 14.1 无 root 权限环境下运行以下命令：

```bash
bash <(fetch -o - https://raw.githubusercontent.com/cfmcmj/Fmie--primary/main/install_nosudo.sh)