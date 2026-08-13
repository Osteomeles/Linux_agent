# Linux_agent
# Linux服务器安装代理（clash）
## Step1 下载mihomo（clash.meta）二进制：
```  
cd ~
wget https://github.com/MetaCubeX/mihomo/releases/download/v1.19.4/mihomo-linux-amd64-v1.19.4.gz
gunzip mihomo-linux-amd64-v1.19.4.gz
mv mihomo-linux-amd64-v1.19.4 mihomo
chmod +x mihomo
```
## Step2 配置订阅链接
首先需要去任何代理商处订阅代理，并在其主页复制订阅链接
```
mkdir -p clash/conf clash/logs
curl -L -k '你的订阅链接' -o ~/clash/conf/config.yaml
```
## Step3 启动代理
```
nohup ~/mihomo -d ~/clash/conf > ~/clash/logs/mihomo.log 2>&1 &
```
## Step4 在终端使用代理
```
export http_proxy=http://127.0.0.1:7890
export https_proxy=http://127.0.0.1:7890
export HTTP_PROXY=http://127.0.0.1:7890
export HTTPS_PROXY=http://127.0.0.1:7890
```
## Step5 验证代理是否生效
```
curl -x http://127.0.0.1:7890 https://www.google.com -o /dev/null -w '%{http_code}'
# 返回 200 即成功
```
## Step6 创建管理脚本~/proxy.sh
`vi ~/proxy.sh`
```
proxy_on() {
    export http_proxy=http://127.0.0.1:7890
    export https_proxy=http://127.0.0.1:7890
    export HTTP_PROXY=http://127.0.0.1:7890
    export HTTPS_PROXY=http://127.0.0.1:7890
    export NO_PROXY=127.0.0.1,localhost
    echo '[OK] Proxy ON'
}

proxy_off() {
    unset http_proxy https_proxy HTTP_PROXY HTTPS_PROXY NO_PROXY
    echo '[OK] Proxy OFF'
}

clash_start() {
    if pgrep -x mihomo > /dev/null; then
        echo 'Clash already running'
    else
        nohup ~/mihomo -d ~/clash/conf > ~/clash/logs/mihomo.log 2>&1 &
        sleep 2
        pgrep -x mihomo > /dev/null && echo 'Clash started' && proxy_on || echo 'Start failed'
    fi
}

clash_stop() {
    pkill mihomo 2>/dev/null && echo 'Clash stopped' || echo 'Clash not running'
    proxy_off
}

clash_status() {
    if pgrep -x mihomo > /dev/null; then
        echo 'Clash: RUNNING'
        curl -s --connect-timeout 3 -x http://127.0.0.1:7890 https://www.google.com -o /dev/null && echo 'Proxy: WORKING' || echo 'Proxy: NOT WORKING'
    else
        echo 'Clash: STOPPED'
    fi
}
```
## Step7 后续如何使用
```
source ~/proxy.sh    # 加载函数（每次新终端只需一次）
clash_start          # 启动代理
clash_status         # 查看状态
clash_stop           # 停止代理
```
## Step8 订阅链接失效后怎么办
重新拉取配置并重启clash即可
```
curl -L -k '新订阅链接' -o ~/clash/conf/config.yaml
clash_stop
clash_start
```
## Step9 服务器重启后
需要重新执行`source ~/proxy.sh && clash_start`即可
