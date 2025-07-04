#!/bin/bash

tput reset
tput civis

# SYSTEM COLOURS
show_orange() { echo -e "\e[33m$1\e[0m"; }
show_blue()   { echo -e "\e[34m$1\e[0m"; }
show_green()  { echo -e "\e[32m$1\e[0m"; }
show_red()    { echo -e "\e[31m$1\e[0m"; }
show_cyan()   { echo -e "\e[36m$1\e[0m"; }
show_purple() { echo -e "\e[35m$1\e[0m"; }
show_gray()   { echo -e "\e[90m$1\e[0m"; }
show_white()  { echo -e "\e[97m$1\e[0m"; }
show_blink()  { echo -e "\e[5m$1\e[0m"; }

# SYSTEM FUNCS
exit_script() {
    echo
    show_red   "🚫 Script terminated by user"
    show_gray  "────────────────────────────────────────────────────────────"
    show_orange "⚠️  All processes stopped. Returning to shell..."
    show_green "Goodbye, Agent. Stay legendary."
    echo
    sleep 1
    exit 0
}

incorrect_option() {
    echo
    show_red   "⛔️  Invalid option selected"
    show_orange "🔄  Please choose a valid option from the menu"
    show_gray  "Tip: Use numbers shown in brackets [1] [2] [3]..."
    echo
    sleep 1
}

process_notification() {
    local message="$1"
    local delay="${2:-1}"

    echo
    show_gray  "────────────────────────────────────────────────────────────"
    show_orange "🔔  $message"
    show_gray  "────────────────────────────────────────────────────────────"
    echo
    sleep "$delay"
}

run_commands() {
    local commands="$*"

    if eval "$commands"; then
        sleep 1
        show_green "✅ Success"
    else
        sleep 1
        show_red "❌ Error while executing command"
    fi
    echo
}

menu_header() {
    local container_status=$(docker inspect -f '{{.State.Status}}' popnode 2>/dev/null || echo "not installed")
    local node_status="🔴 OFFLINE"

    if [ "$container_status" = "running" ]; then
        if docker exec popnode pgrep -x pop >/dev/null 2>&1; then
            node_status="🟢 ACTIVE"
        else
            node_status="🔴 NOT RUNNING"
        fi
    fi

    show_gray  "────────────────────────────────────────────"
    show_cyan  "     ⚙️  POP CACHE NODE - DOCKER CONTROL"
    show_gray  "────────────────────────────────────────────"
    echo
    show_orange "Agent: $(whoami)   🕒 $(date +"%H:%M:%S")   📆 $(date +"%Y-%m-%d")"
    show_green  "Container: ${container_status^^}"
    show_blue   "Node status: $node_status"
    echo
}

menu_item() {
    local num="$1"
    local icon="$2"
    local title="$3"
    local description="$4"

    local formatted_line
    formatted_line=$(printf "  [%-1s] %-2s %-20s - %s" "$num" "$icon" "$title" "$description")
    show_blue "$formatted_line"
}

print_logo() {
    clear
    tput civis

    local logo_lines=(
        " .______    __  .______    _______ "
        " |   _  \  |  | |   _  \  |   ____| "
        " |  |_)  | |  | |  |_)  | |  |__ "
        " |   ___/  |  | |   ___/  |   __| "
        " |  |      |  | |  |      |  |____ "
        " | _|      |__| | _|      |_______| "
    )

    local messages=(
        ">> Initializing POP Cache module..."
        ">> Establishing secure connection..."
        ">> Loading node configuration..."
        ">> Syncing with Pipe Network..."
        ">> Checking system requirements..."
        ">> Terminal integrity: OK"
    )

    echo
    show_cyan "🛰️ INITIALIZING MODULE: \c"
    show_purple "PIPE NETWORK"
    show_gray "────────────────────────────────────────────────────────────"
    echo
    sleep 0.5

    show_gray "Loading: \c"
    for i in {1..30}; do
        echo -ne "\e[32m█\e[0m"
        sleep 0.02
    done
    show_green " [100%]"
    echo
    sleep 0.3

    for msg in "${messages[@]}"; do
        show_gray "$msg"
        sleep 0.15
    done
    echo
    sleep 0.5

    for line in "${logo_lines[@]}"; do
        show_cyan "$line"
        sleep 0.08
    done

    echo
    show_green "⚙️  SYSTEM STATUS: ACTIVE"
    show_orange ">> ACCESS GRANTED. WELCOME TO PIPE NETWORK."
    show_gray "[POP-CACHE v1.0.0 / Secure Terminal Session]"
    echo

    echo -ne "\e[1;37mAwaiting commands"
    for i in {1..3}; do
        echo -ne "."
        sleep 0.4
    done
    echo -e "\e[0m"
    sleep 0.5

    tput cnorm
}

# NODE FUNCS
docker_installation () {
    process_notification "🚀 Starting Docker installation..."

    if command -v docker >/dev/null; then
        DOCKER_VERSION=$(docker --version | cut -d' ' -f3 | tr -d ',')
        show_green "✅ Docker already installed (version $DOCKER_VERSION)"
    else
        show_orange "ℹ️ Docker not found. Installing..."

        if run_commands "curl -fsSL https://get.docker.com | sudo sh"; then
            show_green "✓ Docker installed successfully"

            if run_commands "sudo usermod -aG docker $USER"; then
                show_green "✓ User added to docker group"

                NEW_VERSION=$(docker --version 2>/dev/null | cut -d' ' -f3 | tr -d ',')
                if [ -n "$NEW_VERSION" ]; then
                    show_green "✅ Docker $NEW_VERSION ready to use"
                    show_orange "⚠️ Please re-login or run: newgrp docker"
                    show_blue "💡 After re-login, restart this script to continue"
                else
                    show_red "❌ Docker installed but not working properly"
                    show_gray "Try manual installation: https://docs.docker.com/engine/install/"
                fi
            else
                show_red "❌ Failed to add user to docker group"
                show_gray "You may need to run docker commands with sudo"
            fi
        else
            show_red "❌ Docker installation failed!"
            show_gray "Check internet connection and try again"
            show_gray "Or install manually: https://docs.docker.com/engine/install/"
            exit 1
        fi

        sleep 2
        if ! docker ps &>/dev/null; then
            show_orange "⚠️ Starting Docker daemon..."
            if run_commands "sudo systemctl enable --now docker"; then
                show_green "✓ Docker daemon started"
            else
                show_red "❌ Failed to start Docker daemon"
                show_gray "Try manually: sudo systemctl start docker"
                exit 1
            fi
        fi

        exit 0
    fi
}

optimize_system() {
    process_notification "⚙️ Optimizing system settings..."

    # Настройка sysctl
    run_commands "sudo bash -c 'cat > /etc/sysctl.d/99-popcache.conf << \"EOL\"
net.ipv4.ip_local_port_range = 1024 65535
net.core.somaxconn = 65535
net.ipv4.tcp_low_latency = 1
net.ipv4.tcp_fastopen = 3
net.ipv4.tcp_slow_start_after_idle = 0
net.ipv4.tcp_window_scaling = 1
net.ipv4.tcp_wmem = 4096 65536 16777216
net.ipv4.tcp_rmem = 4096 87380 16777216
net.core.wmem_max = 16777216
net.core.rmem_max = 16777216
EOL'"

    run_commands "sudo sysctl -p /etc/sysctl.d/99-popcache.conf"
    run_commands "sudo bash -c 'cat > /etc/security/limits.d/popcache.conf << \"EOL\"
*    hard nofile 65535
*    soft nofile 65535
EOL'"

    show_green "✅ System optimization completed"
}

prepare_ports_and_firewall() {
    for PORT in 80 443; do
        if sudo ss -tulpen | awk '{print $5}' | grep -q ":$PORT\$"; then
            show_orange "🔒 Port $PORT is busy. Freeing..."
            sudo fuser -k ${PORT}/tcp; sleep 2
        fi
        show_green "✅ Port $PORT is ready"
    done

    if systemctl list-unit-files --type=service | grep -q '^apache2\.service'; then
        sudo systemctl stop apache2 2>/dev/null
        sudo systemctl disable apache2 2>/dev/null
    fi

    process_notification "🛡️ Configuring firewall..."
    run_commands "sudo iptables -I INPUT -p tcp --dport 443 -j ACCEPT"
    run_commands "sudo iptables -I INPUT -p tcp --dport 80 -j ACCEPT"
    run_commands "sudo mkdir -p /etc/iptables"
    run_commands "sudo sh -c \"iptables-save > /etc/iptables/rules.v4\""
}

configure_node() {

    process_notification "⌨️ Data request..."
    read -p "$(show_orange 'Invite code: ')" INVITE_CODE
    read -p "$(show_orange 'POP name: ')" POP_NAME
    read -p "$(show_orange 'Node name: ')" NODE_NAME
    read -p "$(show_orange 'Email: ')" USER_EMAIL
    read -p "$(show_orange 'Twitter: ')" TWITTER
    read -p "$(show_orange 'Discord: ')" DISCORD
    read -p "$(show_orange 'Telegram: ')" TELEGRAM
    read -p "$(show_orange 'Solana wallet: ')" SOLANA_WALLET
    read -p "$(show_orange 'RAM (GB): ')" RAM_GB
    read -p "$(show_orange 'Cache disk (GB): ')" DISK_GB

    MB=$(( RAM_GB * 1024 ))
    response=$(curl -s http://ip-api.com/json)
    city=$(echo "$response" | jq -r '.city')
    country=$(echo "$response" | jq -r '.country')
    POP_LOCATION="$city, $country"

    mkdir -p /opt/popcache
    cat > /opt/popcache/config.json << EOL
{
  "pop_name": "${POP_NAME}",
  "pop_location": "${POP_LOCATION}",
  "invite_code": "${INVITE_CODE}",
  "server": {
    "host": "0.0.0.0",
    "port": 443,
    "http_port": 80,
    "workers": 0
  },
  "cache_config": {
    "memory_cache_size_mb": ${MB},
    "disk_cache_path": "./cache",
    "disk_cache_size_gb": ${DISK_GB},
    "default_ttl_seconds": 86400,
    "respect_origin_headers": true,
    "max_cacheable_size_mb": 1024
  },
  "api_endpoints": {
    "base_url": "https://dataplane.pipenetwork.com"
  },
  "identity_config": {
    "node_name": "${NODE_NAME}",
    "name": "${USER_NAME}",
    "email": "${USER_EMAIL}",
    "twitter": "${TWITTER}",
    "discord": "${DISCORD}",
    "telegram": "${TELEGRAM}",
    "solana_pubkey": "${SOLANA_WALLET}"
  }
}
EOL
    echo
    show_green "✅ Configuration saved to config.json"
}

install_node() {
    process_notification "📦 Starting installation process..."

    optimize_system

    prepare_ports_and_firewall

    docker_installation

    configure_node

    process_notification "⬇️ Downloading binary for $(uname -m)..."
    ARCH=$(uname -m)
    case $ARCH in
        x86_64) POP_URL="https://download.pipe.network/static/pop-v0.3.0-linux-x64.tar.gz" ;;
        aarch64|arm64) POP_URL="https://download.pipe.network/static/pop-v0.3.0-linux-arm64.tar.gz" ;;
        *) show_red "❌ Unsupported architecture: $ARCH"; exit 1 ;;
    esac

    run_commands "curl --progress-bar -L -o pop.tar.gz \"$POP_URL\""
    tar -xzf pop.tar.gz && rm pop.tar.gz
    mv pop /opt/popcache/ && chmod +x /opt/popcache/pop

    cat > /opt/popcache/Dockerfile << EOL
FROM ubuntu:24.04
RUN apt update && apt install -y ca-certificates curl libssl-dev && rm -rf /var/lib/apt/lists/*
WORKDIR /opt/popcache
COPY pop .
COPY config.json .
RUN chmod +x ./pop
CMD ["./pop", "--config", "config.json"]
EOL

    process_notification "🐳 Building and starting container..."
    cd /opt/popcache
    docker stop popnode 2>/dev/null && docker rm popnode 2>/dev/null
    docker build -t popnode .
    docker run -d --name popnode -p 80:80 -p 443:443 --restart unless-stopped popnode
    cd ~
    echo
    show_green "🎉 POP Cache Node successfully installed and running in Docker"
}

# LOGS AND METRICS
view_logs() {
    docker logs -f popnode
}

node_health_check() {
    process_notification "🩺 Running health checks..."

    # Проверяем, запущен ли контейнер
    if [ "$(docker inspect -f '{{.State.Status}}' popnode 2>/dev/null)" != "running" ]; then
        show_red "❌ Container is not running"
        return 1
    fi

    # Проверка /health
    show_cyan "🔍 Health status:"
    docker exec popnode curl -s http://localhost/health || show_red "Health endpoint unavailable"

    # Проверка /state
    show_cyan "\n📊 Node state:"
    docker exec popnode curl -s http://localhost/state | jq . || show_red "Failed to get state"

    # Проверка /metrics
    show_cyan "\n📈 Metrics:"
    docker exec popnode curl -s http://localhost/metrics | head -n 10
    show_gray "Showing first 10 metrics lines... Use 'view_metrics' for full output"
}

view_metrics() {
    if [ "$(docker inspect -f '{{.State.Status}}' popnode)" != "running" ]; then
        show_red "Container is not running"
        return 1
    fi

    process_notification "📊 Showing live metrics (Ctrl+C to stop)..."
    watch -n 2 "docker exec popnode curl -s http://localhost/metrics | head -n 20"
}

view_state() {
    docker exec popnode curl -s http://localhost/state | jq .
}

# OPERATIONAL FUNCS
start_node() {
    docker start popnode
}

stop_node() {
    docker stop popnode
}

restart_node() {
    docker restart popnode
}

delete_node() {
    process_notification "🗑 Deleting POP Node..."
    docker stop popnode 2>/dev/null
    docker rm popnode 2>/dev/null
    docker rmi popnode:latest 2>/dev/null

    rm -f /etc/sysctl.d/99-popcache.conf
    sysctl --system
    rm -f /etc/security/limits.d/popcache.conf

    rm -rf /opt/popcache
    show_green "✅ Node and Docker container deleted"
}

# MAIN MENU
print_logo
while true; do
    menu_header
    menu_item 1 "📦" "Install"         "Установка контейнера"
    menu_item 2 "🔁" "Operations"      "Запуск/Стоп/Рестарт"
    menu_item 3 "📜" "Logs"           "Просмотр логов"
    menu_item 4 "📊" "Monitoring"       "Мониторинг"
    menu_item 5 "🗑" "Uninstall"       "Удалить ноду"
    menu_item 6 "🚪" "Exit"           "Выход"
    echo; read -p "$(show_gray 'Select option ➤ ') " option; echo

    case $option in
        1) install_node ;;
        2)
            clear; menu_header
            menu_item 1 "🚀" "Start"     "Запустить контейнер"
            menu_item 2 "🛑" "Stop"      "Остановить контейнер"
            menu_item 3 "🔄" "Restart"   "Перезапустить"
            menu_item 4 "🖥️" "Console"   "Connect to container"
            menu_item 5 "↩️" "Back"      "Назад"
            echo; read -p "$(show_gray 'Select operation ➤ ') " op_option; echo
            case $op_option in
                1) start_node ;;
                2) stop_node ;;
                3) restart_node ;;
                4) docker exec -it popnode /bin/bash ;;
                4) continue ;;
                *) incorrect_option ;;
            esac ;;
        3) view_logs ;;
        4)
            clear
            menu_header
            menu_item 1 "🩺" "Health"    "Здоровье"
            menu_item 2 "📈" "Metrics"   "Метрики"
            menu_item 3 "📋" "State"     "Состояние"
            menu_item 4 "↩️" "Back"      "В главное меню"
            read -p "$(show_gray 'Select operation ➤ ') " op_option
            case $op_option in
                1) node_health_check ;;
                2) view_metrics ;;
                3) view_state ;;
                4) continue ;;
                *) incorrect_option ;;
            esac ;;
        5) delete_node ;;
        6) exit_script ;;
        *) incorrect_option ;;
    esac
done
