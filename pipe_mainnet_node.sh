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
show_yellow() {
    if [ -t 1 ]; then
        echo -e "\033[1;33m$1\033[0m"
    else
        echo "$1"
    fi
}
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

    if bash -c "$commands"; then
        sleep 1
        show_green "✅ Success"
    else
        sleep 1
        show_red "❌ Error while executing command"
    fi
    echo
}

menu_header() {
    local service_status=$(systemctl is-active pipe 2>/dev/null || echo "inactive")
    local node_status="🔴 OFFLINE"

    if [ "$service_status" = "active" ]; then
        if pgrep -x pop >/dev/null 2>&1; then
            node_status="🟢 ACTIVE"
        else
            node_status="🔴 NOT RUNNING"
        fi
    fi

    show_gray  "────────────────────────────────────────────"
    show_cyan  "     ⚙️  PIPE NETWORK NODE - MAINNET"
    show_gray  "────────────────────────────────────────────"
    echo
    show_orange "Agent: $(whoami)   🕒 $(date +"%H:%M:%S")   📆 $(date +"%Y-%m-%d")"
    show_green  "Service: ${service_status^^}"
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
        ">> Initializing Pipe Network module..."
        ">> Establishing secure connection..."
        ">> Loading node configuration..."
        ">> Syncing with Pipe Network..."
        ">> Checking system requirements..."
        ">> Terminal integrity: OK"
    )

    echo
    show_cyan "🛰️ INITIALIZING MODULE: \c"
    show_purple "PIPE NETWORK MAINNET"
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
    show_orange ">> ACCESS GRANTED. WELCOME TO PIPE NETWORK MAINNET."
    show_gray "[Pipe Network v1.0.0 / Secure Terminal Session]"
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

# Check if Pipe node is installed
is_pipe_installed() {
    if [[ -d /opt/pipe ]] && [[ -f /opt/pipe/pop ]] && [[ -f /opt/pipe/.env ]]; then
        return 0
    else
        return 1
    fi
}

# Check if node is running
is_node_running() {
    if systemctl is-active --quiet pipe; then
        return 0
    else
        return 1
    fi
}

# Show system requirements
show_requirements() {
    process_notification "📋 System Requirements Check"

    show_orange "System Requirements:"
    show_white "• OS: Ubuntu 24.04+ or Debian 11+"
    show_white "• CPU: 2 vCPU minimum"
    show_white "• RAM: 4 GB minimum"
    show_white "• Storage: 20 GB SSD minimum"
    show_white "• Network: 100Mbps bandwidth"
    show_white "• Ports: TCP 80, 443 (must be open)"
    echo
}

# Update system
update_system() {
    process_notification "🔄 Updating system packages..."

    run_commands "sudo apt update"
    run_commands "sudo apt upgrade -y"

    show_green "✅ System updated successfully"
}

# Install required packages
install_packages() {
    process_notification "📦 Installing required packages..."

    PACKAGES=(
        curl
        git
        jq
        lz4
        build-essential
        unzip
        make
        gcc
        ncdu
        cmake
        clang
        pkg-config
        libssl-dev
        libzmq3-dev
        libczmq-dev
        python3-pip
        protobuf-compiler
        dos2unix
        screen
    )

    for PACKAGE in "${PACKAGES[@]}"; do
        show_gray "Installing $PACKAGE..."
        if run_commands "sudo apt install -y $PACKAGE"; then
            show_green "✓ $PACKAGE installed"
        else
            show_red "✗ Failed to install $PACKAGE"
        fi
    done
}

# Download Pipe binary
download_pipe_binary() {
    process_notification "⬇️ Downloading Pipe Network binary..."

    # Create installation directory
    run_commands "sudo mkdir -p /opt/pipe"

    # Download latest binary
    run_commands "sudo curl -L https://pipe.network/p1-cdn/releases/latest/download/pop -o /opt/pipe/pop"
    run_commands "sudo chmod +x /opt/pipe/pop"

    show_green "✅ Binary downloaded and made executable"
}

# Setup Solana wallet
setup_solana_wallet() {
    process_notification "💰 Setting up Solana wallet..."

    while true; do
        read -p "$(show_orange 'Enter Solana wallet address (44 characters): ')" solana_address

        if [[ -n "$solana_address" ]] && [[ ${#solana_address} -eq 44 ]] && [[ "$solana_address" =~ ^[A-Za-z0-9]+$ ]]; then
            export NODE_SOLANA_PUBLIC_KEY="$solana_address"
            show_green "✅ Wallet address set: $solana_address"
            break
        else
            show_red "❌ Invalid address format. Enter valid Solana address (44 characters)"
        fi
    done
}

# Setup node configuration
setup_node_config() {
    process_notification "⚙️ Configuring node settings..."

    read -p "$(show_orange 'Enter node name: ')" node_name
    read -p "$(show_orange 'Enter operator email: ')" node_email
    read -p "$(show_orange 'Enter node location: ')" node_location

    # Create .env file
    sudo tee /opt/pipe/.env > /dev/null <<EOF
# Wallet for earnings
NODE_SOLANA_PUBLIC_KEY=$NODE_SOLANA_PUBLIC_KEY

# Node identity
NODE_NAME=$node_name
NODE_EMAIL="$node_email"
NODE_LOCATION="$node_location"

# Cache configuration
MEMORY_CACHE_SIZE_MB=512
DISK_CACHE_SIZE_GB=100
DISK_CACHE_PATH=./cache

# Network ports
HTTP_PORT=80
HTTPS_PORT=443

# Home network auto port forwarding (disable on VPS/servers)
UPNP_ENABLED=false
EOF

    show_green "✅ Configuration created"
}

# Create systemd service
create_systemd_service() {
    process_notification "🔧 Creating systemd service..."

    sudo tee /etc/systemd/system/pipe.service > /dev/null <<EOF
[Unit]
Description=Pipe Network POP Node
After=network-online.target
Wants=network-online.target

[Service]
WorkingDirectory=/opt/pipe
ExecStart=/bin/bash -c 'source /opt/pipe/.env && /opt/pipe/pop'
Restart=always
RestartSec=5
StandardOutput=journal
StandardError=journal
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

    # Reload systemd and enable service
    run_commands "sudo systemctl daemon-reload"
    run_commands "sudo systemctl enable pipe"

    show_green "✅ Systemd service created and enabled"
}

# Start node
start_node() {
    process_notification "🚀 Starting Pipe Network node..."

    if is_node_running; then
        show_orange "⚠️ Node is already running"
        return 0
    fi

    run_commands "sudo systemctl start pipe"
    sleep 3

    if is_node_running; then
        show_green "✅ Node started successfully"
    else
        show_red "❌ Error starting node"
    fi
}

# Stop node
stop_node() {
    process_notification "🛑 Stopping Pipe Network node..."

    run_commands "sudo systemctl stop pipe"

    if ! is_node_running; then
        show_green "✅ Node stopped successfully"
    else
        show_red "❌ Error stopping node"
    fi
}

# Restart node
restart_node() {
    process_notification "🔄 Restarting Pipe Network node..."

    run_commands "sudo systemctl restart pipe"
    sleep 3

    if is_node_running; then
        show_green "✅ Node restarted successfully"
    else
        show_red "❌ Error restarting node"
    fi
}

# View logs
view_logs() {
    if is_node_running; then
        process_notification "📋 Pipe Network Node Logs (Ctrl+C to exit):"
        show_gray "═══════════════════════════════════════════════════════════════"
        sudo journalctl -u pipe -f
    else
        show_red "❌ Node is not running"
    fi
}

# Show node status
show_node_status() {
    cd /opt/pipe && ./pop status
}

# Show earnings
show_earnings() {
    if is_node_running; then
        process_notification "💰 Node earnings:"
        sudo -u root -H bash -c "cd /opt/pipe && ./pop earnings" 2>/dev/null || show_orange "⚠️ Earnings command not available"
    else
        show_red "❌ Node is not running"
    fi
}

# Health check
health_check() {
    if is_node_running; then
        process_notification "🩺 Node health check:"
        curl -s http://localhost:8081/health 2>/dev/null || show_orange "⚠️ Health endpoint not available"
    else
        show_red "❌ Node is not running"
    fi
}

# Show Solana address
show_solana_address() {
    if [[ -f /opt/pipe/.env ]]; then
        solana_address=$(grep "^NODE_SOLANA_PUBLIC_KEY=" /opt/pipe/.env | head -1 | cut -d'=' -f2)
        show_green "✅ Solana Wallet Address:"
        show_cyan "$solana_address"
    else
        show_red "❌ Wallet address not found"
    fi
}

# Change Solana address
change_solana_address() {
    process_notification "🔄 Changing Solana wallet address"

    if is_node_running; then
        show_orange "⚠️ Stop node before changing address"
        return 1
    fi

    setup_solana_wallet

    # Update .env file
    run_commands "sudo sed -i \"s/NODE_SOLANA_PUBLIC_KEY=.*/NODE_SOLANA_PUBLIC_KEY=$(echo \"$NODE_SOLANA_PUBLIC_KEY\" | sed 's/[[\.*^$()+?{|]/\\&/g')/\" /opt/pipe/.env"

    show_green "✅ Wallet address changed"
}

# Show help commands
show_help_commands() {
    process_notification "📚 Help Commands"
    echo
    show_white "Main systemctl commands:"
    show_cyan "• sudo systemctl status pipe          # Service status"
    show_cyan "• sudo systemctl start pipe           # Start node"
    show_cyan "• sudo systemctl stop pipe            # Stop node"
    show_cyan "• sudo systemctl restart pipe         # Restart node"
    show_cyan "• sudo journalctl -u pipe -f          # Real-time logs"
    echo
    show_white "Pipe Network commands:"
    show_cyan "• cd /opt/pipe && ./pop status        # Node status"
    show_cyan "• cd /opt/pipe && ./pop earnings      # Earnings"
    show_cyan "• curl http://localhost:8081/health   # Health check"
    echo
    show_white "Configuration files:"
    show_cyan "• /opt/pipe/                          # Installation directory"
    show_cyan "• /opt/pipe/.env                      # Configuration"
    show_cyan "• /opt/pipe/cache/                    # Cache directory"
}

# Remove Pipe node
remove_pipe() {
    process_notification "🗑️ Removing Pipe Network Node..."

    read -p "$(show_orange 'Are you sure you want to remove Pipe Network Node? [y/N]: ')" confirm_remove

    if [[ $confirm_remove =~ ^[Yy]$ ]]; then
        # Stop and disable service
        run_commands "sudo systemctl stop pipe"
        run_commands "sudo systemctl disable pipe"

        # Remove service file
        run_commands "sudo rm -f /etc/systemd/system/pipe.service"
        run_commands "sudo systemctl daemon-reload"

        # Remove installation directory
        run_commands "sudo rm -rf /opt/pipe"

        show_green "✅ Pipe Network Node removed successfully"
    else
        show_orange "⚠️ Removal cancelled"
    fi
}

# Main installation function
main_installation() {
    if is_pipe_installed; then
        show_orange "⚠️ Pipe Network Node already installed"
        read -p "$(show_cyan 'Press Enter to continue...')"
        return
    fi

    show_requirements
    read -p "$(show_cyan 'Continue with installation? [y/N]: ')" continue_install

    if [[ ! $continue_install =~ ^[Yy]$ ]]; then
        show_orange "⚠️ Installation cancelled"
        return
    fi

    process_notification "🚀 Installing Pipe Network Node..."

    update_system
    install_packages
    download_pipe_binary
    setup_solana_wallet
    setup_node_config
    create_systemd_service
    start_node

    echo
    show_orange "⚠️ Important:"
    show_white "• Node is syncing with Pipe network"
    show_white "• Make sure ports 80 and 443 are open"
    show_white "• Use management commands for monitoring"
    echo

    read -p "$(show_cyan 'Press Enter to continue...')"
}

# Management menu
show_management_menu() {
    while true; do
        clear
        menu_header
        menu_item 1 "📜" "Logs"           "Показать логи"
        menu_item 2 "🔄" "Restart"        "Перезапустить"
        menu_item 3 "🛑" "Stop"           "Остановить"
        menu_item 4 "🚀" "Start"          "Запустить"
        menu_item 5 "📊" "Status"         "Статус"
        menu_item 6 "💰" "Earnings"       "Показать доходы"
        menu_item 7 "🩺" "Health"         "Проверка состояния"
        menu_item 8 "🔑" "Wallet"         "Показать адрес Solana"
        menu_item 9 "✏️" "Change Wallet"  "Изменить адрес Solana"
        menu_item 10 "📚" "Help"          "Помощь"
        menu_item 0 "↩️" "Back"           "Вернуться в главное меню"
        echo
        read -p "$(show_gray 'Select option ➤ ')" choice
        echo

        case $choice in
            1) view_logs ;;
            2) restart_node ;;
            3) stop_node ;;
            4) start_node ;;
            5) show_node_status ;;
            6) show_earnings ;;
            7) health_check ;;
            8) show_solana_address ;;
            9) change_solana_address ;;
            10) show_help_commands ;;
            0) return ;;
            *) incorrect_option ;;
        esac

        if [ "$choice" != "0" ]; then
            echo
            show_yellow 'Press Enter to continue...'
            read -p ""
        fi
    done
}

# MAIN MENU
print_logo
while true; do
    menu_header
    menu_item 1 "📦" "Install"         "Установить"
    menu_item 2 "⚙️" "Manage"          "Управление"
    menu_item 3 "🗑️" "Remove"          "Удалить"
    menu_item 4 "🚪" "Exit"            "Выйти"
    echo
    read -p "$(show_gray 'Select option ➤ ')" option
    echo

    case $option in
        1) main_installation ;;
        2)
            if is_pipe_installed; then
                show_management_menu
            else
                show_red "❌ Pipe Network Node not installed"
                read -p "$(show_cyan 'Press Enter to continue...')"
            fi
            ;;
        3)
            if is_pipe_installed; then
                remove_pipe
                read -p "$(show_cyan 'Press Enter to continue...')"
            else
                show_red "❌ Pipe Network Node not installed"
                read -p "$(show_cyan 'Press Enter to continue...')"
            fi
            ;;
        4) exit_script ;;
        *) incorrect_option ;;
    esac
done
