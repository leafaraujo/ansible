#!/bin/bash

set -e

WORK_DIR=$PWD
LOG_DIR="$WORK_DIR/logs"
mkdir -p "$LOG_DIR"

TMUX_CONF_FILE="$HOME/.tmux.conf"
[[ ! -f "$TMUX_CONF_FILE" ]] && echo "set -g mouse on" > "$TMUX_CONF_FILE"

log_exec() {
    local log_name="$1"
    shift
    bash -c "$@" 2>&1 | tee "$LOG_DIR/${log_name}_$(date +%Y%m%d_%H%M%S).log"
}

function open_terminal() {
    TMUX_CONF_FILE="$HOME/.tmux.conf"
    [[ ! -f "$TMUX_CONF_FILE" ]] && echo "set -g mouse on" > "$TMUX_CONF_FILE"

    if [[ -n "$SSH_CONNECTION" ]]; then
        tmux new-session -d -s session_$2 "$1; echo -e '\n\nPressione qualquer tecla para sair...'; read -n 1 -s; exit"
        tmux attach-session -t session_$2
    else
        if [[ -n "$DISPLAY" && $XDG_SESSION_TYPE == "x11" ]]; then
            if command -v gnome-terminal &> /dev/null; then
                gnome-terminal -- bash -c "$1; echo -e '\n\nPressione qualquer tecla para sair...'; read -n 1 -s; exit" & disown
            else
                x-terminal-emulator -e bash -c "$1; echo -e '\n\nPressione qualquer tecla para sair...'; read -n 1 -s; exit" & disown
            fi
        else
            tmux new-session -d -s session_$2 "$1; echo -e '\n\nPressione qualquer tecla para sair...'; read -n 1 -s; exit"
            tmux attach-session -t session_$2
        fi
    fi
}

run_oai() {
    local option="$1"
    open_terminal "./core-scripts/srsRAN_tools.sh $option" "$(echo $option | tr -d -- -)"
}

menu() {
    while true; do
        echo -e "\n===================== 🛠 \e[1;36m srsRAN_Open5GS_tools Pacote_B \e[0m🛠 ====================="
        echo "1) Instalar componentes Git, Docker e UHD"
        echo "2) Modo performance 🚀"
        echo "3) Iniciar Core 5G macvlan - pacote_B:DNN lanceB"
        echo "4) Logs Core 5G - Open5GS"
        echo "5) Parar Core 5G - Open5GS"
        echo "========================================================"
        echo "6) Iniciar Video Server"
        echo "7) Encerrar Video Server"
        echo "========================================================"
        echo "8) Iniciar gNB b210 srsRAN (Docker 🐳)"
        echo "9) Logs gNB b210 srsRAN (Docker 🐳)"
        echo "10) Encerrar gNB b210 srsRAN (Docker 🐳)"
        echo "========================================================"
        echo -e "11) \e[1;31mSair\e[0m"

        read -p "Escolha uma opção: " opt
        case $opt in
            1) run_oai --install ;;
            2) run_oai --performance ;;
            3) run_oai --start_5g_core ;;
            4) run_oai --logs_5g_core ;;
            5) run_oai --stop_5g_core ;;
            6) run_oai --start_video ;;
            7) run_oai --stop_video ;;
            8) run_oai --start_gNB_srsRAN_docker ;;
            9) run_oai --logs_gNB_srsRAN_docker ;;
            10) run_oai --stop_gNB_srsRAN_docker ;;
            11) echo "Saindo..."; break ;;
            *) echo "Opção inválida!" ;;
        esac
    done
}

menu

