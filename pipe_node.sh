#!/bin/bash

tput reset
tput civis

show_orange() {
    echo -e "\e[33m$1\e[0m"
}

show_blue() {
    echo -e "\e[34m$1\e[0m"
}

show_green() {
    echo -e "\e[32m$1\e[0m"
    echo
}

show_red() {
    echo -e "\e[31m$1\e[0m"
}

exit_script() {
    show_red "Скрипт остановлен (Script stopped)"
        echo
        exit 0
}

incorrect_option () {
    echo
    show_red "Неверная опция. Пожалуйста, выберите из тех, что есть."
    echo
    show_red "Invalid option. Please choose from the available options."
    echo
}

process_notification() {
    local message="$1"
    show_orange "$message"
    sleep 1 && echo
}

run_commands() {
    local commands="$*"

    if eval "$commands"; then
        sleep 1
        echo
        show_green "Успешно (Success)"
        echo
    else
        sleep 1
        echo
        show_red "Ошибка (Fail)"
        echo
    fi
}

print_logo () {
    echo
    show_orange ".______    __  .______    _______" && sleep 0.2
    show_orange "|   _  \  |  | |   _  \  |   ____|" && sleep 0.2
    show_orange "|  |_)  | |  | |  |_)  | |  |__" && sleep 0.2
    show_orange "|   ___/  |  | |   ___/  |   __|" && sleep 0.2
    show_orange "|  |      |  | |  |      |  |____" && sleep 0.2
    show_orange "| _|      |__| | _|      |_______|" && sleep 0.2
    echo
    sleep 1
}

enter_evm_address () {
    read -p "Введите адрес (EVM Enter EVM address) (0x.....): " EVM_ADDRESS
    show_green "Ваш адрес (Your address): $EVM_ADDRESS"
    sleep 2 && echo
}

stop_node () {
    if screen -r pipe -X quit; then
        sleep 1
        show_green "Успешно (Success)"
        echo
    else
        sleep 1
        show_blue "Сессия не найдена (Session doesn't exist)"
        echo
    fi
}

while true; do
    print_logo
    show_green "------ MAIN MENU ------ "
    echo "1. Подготовка (Preparation)"
    echo "2. Установка (Installation)"
    echo "3. Управление (Operational menu)"
    echo "4. Логи (Logs)"
    echo "5. О ноде (Node info)"
    echo "6. Восстановление (Recovery)"
    echo "7. Удаление (Delete)"
    echo "8. Выход (Exit)"
    echo
    read -p "Выберите опцию (Select option): " option

    case $option in
        1)
            # PREPARATION
            process_notification "Начинаем подготовку (Starting preparation)..."
            run_commands "cd $HOME && sudo apt update && sudo apt upgrade -y"
            run_commands "apt install unzip screen nano mc curl git jq lz4 build-essential unzip make gcc ncdu cmake clang pkg-config libssl-dev libzmq3-dev libczmq-dev python3-pip protobuf-compiler dos2unix"
            echo
            show_green "--- ПОГОТОВКА ЗАЕРШЕНА. PREPARATION COMPLETED ---"
            ;;
        2)
            # INSTALLATION
            process_notification "Установка (Installation)..."
            run_commands "cd $HOME && wget https://dl.pipecdn.app/v0.2.5/pop && chmod +x pop"

            process_notification "Создаем каталог (Create folder)..."
            run_commands "mkdir download_cache"
            echo
            show_green "--- УСТАНОВКА ЗАВЕРШЕНА. INSTALLATION COMPLETED ---"
            ;;
        3)
            # OPERATIONAL
            echo
            while true; do
                show_green "------ OPERATIONAL MENU ------ "
                echo "1. Регистрация (Registration)"
                echo "2. Зaпустить (Start)"
                echo "3. Остановить (Stop)"
                echo "4. Статус (Status)"
                echo "5. Поинты (Points)"
                echo "6. Статистика (Stats)"
                echo "7. Обновить токен (Refresh token)"
                echo "8. Выход (Exit)"
                echo
                read -p "Выберите опцию (Select option): " option
                echo
                case $option in
                    1)
                        # Registration
                        process_notification "Регистрируем (Registration)..."
                        read -p "Введите (Enter) referral code: " REF_CODE
                        run_commands "cd $HOME/pipe && ./pop --signup-by-referral-route $REF_CODE"
                        ;;
                    2)
                        # START
                        process_notification "Настройка (Tunning)..."
                        read -p "Введитие (Enter) RAM size: " RAM
                        read -p "Введитие (Enter) DISK size: " DISK
                        read -p "Введитие (Enter) PUBKEY: " PUBKEY

                        process_notification "Запускаем (Starting)..."
                        run_commands "screen -dmS pipe && screen -S pipe -X stuff \"cd \$HOME  && ./pop --ram \$RAM --max-disk \$DISK --pubKey \$PUBKEY$(echo -ne '\r')\""
                        ;;
                    3)
                        # STOP
                        process_notification "Останавливаем (Stopping)..."
                        stop_node
                        ;;
                    4)
                        # STATUS
                        cd $HOME && ./pop --status
                        ;;
                    5)
                        # POINTS
                        cd $HOME && ./pop --points
                        ;;
                    6)
                        # STATS
                        cd $HOME && ./pop --stats
                        ;;
                    7)
                        # REFRESH TOKEN
                        cd $HOME && ./pop --refresh
                        ;;
                    8)
                        break
                        ;;
                    *)
                        incorrect_option
                        ;;
                esac
            done
            ;;
        4)
            # LOGI
            process_notification "Подключаемся (Connecting)..." && sleep 2
            cd $HOME && screen -r pipe
            ;;
        5)
            # NODE INFO
            process_notification "Ищем (Looking)..."
            show_green "------ Сохраните данные. Save data ------"
            cd $HOME && cat node_info.json
            echo
            show_green "-----------------------------------------"
            ;;
        6)
            # RECOVERY
            process_notification "Начинаем восстановление. Starting data recovery"

            process_notification "Ищем JSON фаил (Looking for JSON File)... "
            if [ -f "$HOME/node_info.json" ]; then
            sleep 1
            echo
            show_green "Успешно (Success)"
            echo
            FILE="$HOME/node_info.json"

            read -p "Введите (enter) Node ID: " node_id
            read -p "Введите (enter) Token: " token
            REGISTRATION=true

            jq --arg node_id "$node_id" \
            --argjson registration "$REGISTRATION" \
            --arg token "$token" \
            '.node_id = $node_id |
                .registered = $registration |
                .token = $token' "$FILE" > "$FILE.tmp" && mv "$FILE.tmp" "$FILE"

            echo ""
            show_green "------ ФАИЛ ОБНОВЛЕН. FILE UPDATED ------"
            echo ""
            else
                sleep 1
                echo ""
                show_red "Не найден (Didn't find)"
                echo ""
            fi
            ;;
        7)
            # DELETE
            process_notification "Удаление (Deleting)..."
            echo
            while true; do
                read -p "Удалить ноду? Delete node? (yes/no): " option

                case "$option" in
                    yes|y|Y|Yes|YES)
                        process_notification "Останавливаем (Stopping)..."
                        stop_node

                        process_notification "Чистим (Cleaning)..."
                        run_commands "rm -rvf $HOME/pop && rm -rvf $HOME/download_cache"

                        show_green "--- НОДА УДАЛЕНА. NODE DELETED. ---"
                        break
                        ;;
                    no|n|N|No|NO)
                        process_notification "Отмена (Cancel)"
                        echo ""
                        break
                        ;;
                    *)
                        incorrect_option
                        ;;
                esac
            done
            ;;
        8)
            # EXIT
            exit_script
            ;;
        *)
            incorrect_option
            ;;
    esac
done
