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
