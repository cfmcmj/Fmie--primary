# 安装 sun-panel
installSunPanel() {
  local workdir="${installpath}/serv00-play/sunpanel"
  local exepath="${installpath}/serv00-play/sunpanel/sun-panel"
  if [[ -e $exepath ]]; then
    echo "已安装，请勿重复安装!"
    return
  fi
  mkdir -p $workdir
  cd $workdir

  if ! checkDownload "sun-panel"; then
    return 1
  fi
  if ! checkDownload "panelweb" 1; then
    return 1
  fi

  if [[ ! -e "sun-panel" ]]; then
    echo "下载文件解压失败！"
    return 1
  fi
  # 初始化密码，并且生成相关目录文件
  ./sun-panel -password-reset

  if [[ ! -e "conf/conf.ini" ]]; then
    echo "无配置文件生成!"
    return 1
  fi

  loadPort
  port=""
  randomPort "tcp" "sun-panel"
  if [ -n "$port" ]; then
    sunPanelPort=$port
  else
    echo "未输入端口!"
    return 1
  fi
  cd conf
  sed -i.bak -E "s/^http_port=[0-9]+$/http_port=${sunPanelPort}/" conf.ini
  cd ..

  domain=""
  webIp=""
  if ! makeWWW panel $sunPanelPort; then
    echo "绑定域名失败!"
    return 1
  fi
  # 自定义域名时申请证书的webip可以从2个ip中选择
  if [ $is_self_domain -eq 1 ]; then
    if ! applyLE $domain $webIp; then
      echo "申请证书失败!"
      return 1
    fi
  else # 没有自定义域名时，webip是内置固定的，就是web(x).serv00.com
    if ! applyLE $domain; then
      echo "申请证书失败!"
      return 1
    fi
  fi
  green "安装完毕!"
}

# 启动 sun-panel
startSunPanel() {
  local workdir="${installpath}/serv00-play/sunpanel"
  local exepath="${installpath}/serv00-play/sunpanel/sun-panel"
  if [[ ! -e $exepath ]]; then
    red "未安装，请先安装!"
    return
  fi
  cd $workdir
  if checkProcAlive "sun-panel"; then
    stopProc "sun-panel"
  fi
  read -p "是否需要日志($workdir/running.log)? [y/n] [n]:" input
  input=${input:-n}
  local args=""
  if [[ "$input" == "y" ]]; then
    args=" > running.log 2>&1 "
  else
    args=" > /dev/null 2>&1 "
  fi
  cmd="nohup ./sun-panel $args &"
  eval "$cmd"
  sleep 1
  if checkProcAlive "sun-panel"; then
    green "启动成功"
  else
    red "启动失败"
  fi
}

# 停止 sun-panel
stopSunPanel() {
  stopProc "sun-panel"
  if checkProcAlive "sun-panel"; then
    echo "未能停止，请手动杀进程!"
  fi
}

# 重置 sun-panel 密码
resetSunPanelPwd() {
  local exepath="${installpath}/serv00-play/sunpanel/sun-panel"
  if [[ ! -e $exepath ]]; then
    echo "未安装，请先安装!"
    return
  fi
  read -p "确定初始化密码? [y/n][n]:" input
  input=${input:-n}

  if [[ "$input" == "y" ]]; then
    local workdir="${installpath}/serv00-play/sunpanel"
    cd $workdir
    ./sun-panel -password-reset
  fi
}

# 卸载 sun-panel
uninstallSunPanel() {
  local workdir="${installpath}/serv00-play/sunpanel"
  uninstallProc "$workdir" "sun-panel"
}

# sun-panel 服务管理菜单
sunPanelServ() {
  if ! checkInstalled "serv00-play"; then
    return 1
  fi
  while true; do
    yellow "---------------------"
    echo "1. 安装"
    echo "2. 启动"
    echo "3. 停止"
    echo "4. 初始化密码"
    echo "8. 卸载"
    echo "9. 返回主菜单"
    echo "0. 退出脚本"
    yellow "---------------------"
    read -p "请选择:" input

    case $input in
    1)
      installSunPanel
      ;;
    2)
      startSunPanel
      ;;
    3)
      stopSunPanel
      ;;
    4)
      resetSunPanelPwd
      ;;
    8)
      uninstallSunPanel
      ;;
    9)
      break
      ;;
    0)
      exit 0
      ;;
    *)
      echo "无效选项，请重试"
      ;;
    esac
  done
  showMenu
}