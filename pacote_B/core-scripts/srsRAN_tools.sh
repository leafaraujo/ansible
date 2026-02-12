#!/bin/bash

## Author:   Paulo Eduardo da Silva Junior - paulo.eduardo.093@ufrn.edu.br - Tel: +55 (84) 9 8808-0933
## GitHub:   https://github.com/PauloBigooD
## Linkedin: https://www.linkedin.com/in/paulo-eduardo-5a18b3174/

set -e

## Variável de escolha de opção
COMMAND="$1"
## Work directory path is the current directory
WORK_DIR=$PWD
## Lista de versões disponíveis
VERSION_UHD=("UHD-4.7" "UHD-4.6" "UHD-4.5" "UHD-4.4" "UHD-4.3" "UHD-4.2" "UHD-4.1")
## Definindo o URL do repositório OAI - RAN
REPO_OAI_RAN="https://gitlab.eurecom.fr/oai/openairinterface5g.git"
## Versão da branch OAI - RAN
VERSION_RAN="2024.w42"
## Definindo o URL do repositório OAI - CORE
REPO_OAI_CORE="https://gitlab.eurecom.fr/oai/cn5g/oai-cn5g-fed.git"
## Versão da imagem Docker
DOCKER_IMAGE_OAI="v1.5.0"
## Interface de rede
INTERFACE_PC="enp3s"

DOCKER_CMD="docker compose"
[[ $# -eq 2 ]] && DOCKER_CMD="docker compose"

# Função para exibir ajuda
function show_help(){
    echo -e "Comandos comuns: 
            ------------------------------------------------------------------------------------
            ||   \e[0;34mOpções\e[0m        ||               🛠 \e[1;36m oai_tools \e[0m🛠                                ||
            |==================================================================================|
            || --install       || Instalar componentes Git, Docker e libuhd atualizados.      ||
            || --performance   || Instalar componentes Git e libuhd \e[1;33m4.4; 4.5; 4.6 ou 4.7\e[0m.     ||
            || --install_UHD   || Instalar modo performance para processador \e[1;31mAMD\e[0m ou \e[1;36mIntel\e[0m 🚀. ||
            || --install_5g_core    || Instalar dependências para Core e RAN 5G.                   ||
            || --install_4g    || Instalar dependências para EPC e RAN 4G.                    ||
            || --flexric       || Instalar dependências para FlexRIC                          ||
            || --start_5g      || Iniciar Core 5G.                                            ||
            || --start_4g      || Iniciar EPC 4G.                                             ||
            || --logs_5g       || Exibir logs Core 5G - AMF.                                  ||
            || --logs_4g       || Exibir logs EPC 4G - MME.                                   ||
            || --stop_5g       || Parar Core 5G.                                              ||
            || --stop_4g       || Parar EPC 4G.                                               ||
            |==================================================================================|
            |                             gNB's n310 in Docker 🐳                              |
            |==================================================================================|
            || --gNB_n106      || Iniciar gNB usrp 1 n310 5G - 106 prbs 📡                    ||
            || --gNB_n106_2    || Iniciar gNB usrp 2 n310 5G - 106 prbs 📡                    ||
            || --gNB_n162      || Iniciar gNB usrp 1 n310 5G - 162 prbs 📡                    ||
            || --gNB_n162_2    || Iniciar gNB usrp 2 n310 5G - 162 prbs 📡                    ||
            || --gNB_n273      || Iniciar gNB usrp 1 n310 5G - 273 prbs 📡                    ||
            || --gNB_n273_2    || Iniciar gNB usrp 2 n310 5G - 273 prbs 📡                    ||
            |==================================================================================|
            |                             gNB's n310 Bare Metal 🪖                              |
            |==================================================================================|
            || --CU_Pacote_E   || Iniciar gNB usrp 1 n310 5G - 106 prbs 📡                    ||
            || --gNB_n106_2_bm || Iniciar gNB usrp 2 n310 5G - 106 prbs 📡                    ||
            || --gNB_n162_bm   || Iniciar gNB usrp 1 n310 5G - 162 prbs 📡                    ||
            || --gNB_n162_2_bm || Iniciar gNB usrp 2 n310 5G - 162 prbs 📡                    ||
            || --gNB_n273_bm   || Iniciar gNB usrp 1 n310 5G - 273 prbs 📡                    ||
            || --gNB_n273_2_bm || Iniciar gNB usrp 2 n310 5G - 273 prbs 📡                    ||
            |==================================================================================|
            |                             gNB's b210 in Docker 🐳                              |
            |==================================================================================|
            || --gNB_b106      || Iniciar gNB usrp 1 b210 5G - 106 prbs 📡                    ||
            |==================================================================================|
            |                             gNB's b210 Bare Metal 🪖                              |
            |==================================================================================|
            || --gNB_b106_bm   || Iniciar gNB usrp 1 b210 5G - 106 prbs 📡                    ||
            |==================================================================================|
            |                             eNB's n310 in Docker 🐳                              |
            |==================================================================================|
            || --eNB_n100      || Iniciar eNB usrp 1 n310 4G - 100 prbs 📡                    ||
            || --eNB_n100_2    || Iniciar eNB usrp 2 n310 4G - 100 prbs 📡                    ||
            |==================================================================================|
            |                             eNB's n310 Bare Metal 🪖                              |
            |==================================================================================|
            || --eNB_n100_bm   || Iniciar gNB usrp 1 n310 5G - 100 prbs 📡                    ||
            || --eNB_n100_2_bm || Iniciar gNB usrp 2 n310 5G - 100 prbs 📡                    ||
            |==================================================================================|
    "
    }

# Função para verificar se um pacote está instalado
function is_installed(){
    dpkg -l | grep -q "$1"
    }
# Função para instalar pacotes se não estiverem instalados
function install_package() {
    for package in "$@"; do
        if ! is_installed "$package"; then
            echo "Instalando $package..."
            sudo apt-get install -y "$package"
        else
            echo "$package já está instalado."
        fi
    done
    }
# Função para gerenciar performance mode
function performance_mode(){
    install_package "linux-image-lowlatency" "linux-headers-lowlatency"
    if grep -m 1 'vendor_id' /proc/cpuinfo | grep -q 'GenuineIntel'; then
        echo "Intel CPU detectado. Configurando..."
        sudo sed -i '/^GRUB_CMDLINE_LINUX=/d' /etc/default/grub
        echo 'GRUB_CMDLINE_LINUX="quiet intel_pstate=disable processor.max_cstate=1 intel_idle.max_cstate=0"' | sudo tee -a /etc/default/grub
        echo 'blacklist intel_powerclamp' | sudo tee -a /etc/modprobe.d/blacklist.conf
        echo 'GOVERNOR="performance"' | sudo tee /etc/default/cpufrequtils
        sudo update-grub
        install_package "i7z"
        install_package "cpufrequtils"
        sudo systemctl restart cpufrequtils
    elif grep -m 1 'vendor_id' /proc/cpuinfo | grep -q 'AuthenticAMD'; then
        echo "AMD CPU detectado. Configurando..."
        sudo sed -i '/^GRUB_CMDLINE_LINUX=/d' /etc/default/grub
        echo 'GRUB_CMDLINE_LINUX="quiet amd_pstate=disable processor.max_cstate=1 idle=nomwait processor.max_cstate=0"' | sudo tee -a /etc/default/grub
        echo 'GOVERNOR="performance"' | sudo tee /etc/default/cpufrequtils
        sudo update-grub
        install_package "cpufrequtils"
        sudo systemctl restart cpufrequtils
    else
        echo "CPU não identificada."
    fi
    }
# Função para verificar dispositivos USRP
function check_usrp_device(){
    echo "Realizando a verificação da USRP"
    uhd_find_devices 2>&1 | {
    skip=1  # Variável para controlar a primeira linha
    output=""

    while read -r line; do
        if [ $skip -eq 1 ]; then
            skip=0  # Ignora a primeira linha
            continue
        fi
        if echo "$line" | grep -q "No UHD Devices Found"; then
            echo "Verifique se a USRP encontra-se conectada a uma porta USB 3.0"
        fi
    done
    }
    uhd_find_devices
    echo "--------------------------------------------------"
    }
# Função que verifica acionamento da dashboard OAI
function dashboard_check(){
    # Condição que verifica o uso da Dashboard
    if [ "$2" = "-d" ];then
        dash="$2"
        echo -e "Dashboard \e[92mON\e[0m"
    elif [[ "$2" == -* ]];then
        dash=" "
        echo -e "Parâmetro inválido, este deve ser igual a \e[33m-d\e[0m"
    else
        dash=" "
        echo -e "Dashboard \e[31mOFF\e[0m"
    fi
    }
# Função que instala o modo performance
function init_performance(){
    ## Performance mode
	sudo /etc/init.d/cpufrequtils restart
    ## Configuration of the packer forwarding
	sudo sysctl net.ipv4.conf.all.forwarding=1
	sudo iptables -P FORWARD ACCEPT
    }

# Função para compilar e instalar UHD
function install_libuhd() {
    # Verifica se a UHD já está instalada
    if command -v uhd_find_devices &> /dev/null; then
        echo "A biblioteca UHD já está instalada."
        read -p "Deseja reinstalá-la? (s/n): " resposta
        case "$resposta" in
            [Ss]* )
                echo "Reinstalando a biblioteca UHD..."
                ;;
            [Nn]* )
                echo "Nenhuma ação será realizada."
                return 0
                ;;
            * )
                echo "Resposta inválida. Nenhuma ação será realizada."
                return 1
                ;;
        esac
    fi
    echo "Removendo instalações anteriores..."
    sudo rm -rf /usr/local/lib/cmake/uhd
    sudo rm -rf /usr/local/share/doc/uhd
    sudo rm -rf /usr/share/uhd
    sudo rm -rf /usr/share/doc/uhd
    sudo rm -rf /usr/lib/cmake/uhd
    sudo rm -rf ./uhd
    sudo rm -rf /usr/local/lib/uhd
    sudo rm -rf /usr/local/include/uhd
    sudo rm -rf /usr/local/share/uhd

    echo "Escolha a versão da UHD para instalar:"
    for i in "${!VERSION_UHD[@]}"; do
        echo "$((i+1)). ${VERSION_UHD[i]}"
    done
    read -p "Digite o número correspondente à versão desejada: " escolha
    if [[ "$escolha" -ge 1 && "$escolha" -le "${#VERSION_UHD[@]}" ]]; then
        VERSAO_SELECIONADA="${VERSION_UHD[$((escolha-1))]}"
    else
        echo "Escolha inválida. Tente novamente."
        escolher_versao
    fi
    echo "Instalando dependências..."
    sudo apt-get update
    install_package "autoconf " "automake" "ccache" "build-essential" "cmake" "doxygen" "ethtool" "g++" "inetutils-tools" "libboost-all-dev" "libncurses5" "libncurses5-dev" "libusb-1.0-0" "libusb-1.0-0-dev" "libusb-dev" "python3-dev" "python3-mako" "python3-numpy" "python3-requests" "python3-scipy" "python3-setuptools" "python3-ruamel.yaml"
    echo "Instalando UHD versão: $VERSAO_SELECIONADA"
    git clone --branch "$VERSAO_SELECIONADA" https://github.com/EttusResearch/uhd.git
    cd uhd/host || exit
    mkdir build
    cd build || exit
    cmake ../
    make -j"$(nproc)"
    sudo make install
    sudo ldconfig
    # Verificação da instalação
    echo "Verificando a instalação..."
    uhd_find_devices
    uhd_usrp_probe
    }

# Função que instala o Docker
function install_docker(){
    if is_installed docker; then
        echo "Docker já instalado."
    else
        echo "Instalando Docker..."
        # Instalar dependências comuns
        install_package "apt-transport-https" "ca-certificates" "curl" "gnupg" "lsb-release" "python3-pip"
        # Criar o diretório para armazenar a chave GPG, caso não exista
        sudo mkdir -p /etc/apt/keyrings
        # Adicionar chave GPG do Docker
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo tee /etc/apt/keyrings/docker.asc
        sudo gpg --no-default-keyring --keyring /etc/apt/keyrings/docker.gpg --import /etc/apt/keyrings/docker.asc
        sudo chmod a+r /etc/apt/keyrings/docker.gpg
        # Detectar a distribuição do sistema
        DISTRO=$(lsb_release -si)
        CODENAME=$(lsb_release -cs)
        if [[ "$DISTRO" == "Ubuntu" ]]; then
            echo "Distribuição Ubuntu detectada."
            echo "deb [arch=$(dpkg --print-architecture)] https://download.docker.com/linux/ubuntu $CODENAME stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
        elif [[ "$DISTRO" == "Debian" ]]; then
            echo "Distribuição Debian detectada."
            echo "deb [arch=$(dpkg --print-architecture)] https://download.docker.com/linux/debian $CODENAME stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
        elif [[ "$DISTRO" == "CentOS" || "$DISTRO" == "RHEL" || "$DISTRO" == "Fedora" ]]; then
            echo "Distribuição baseada em RedHat detectada."
            # Para distribuições como CentOS/RHEL/Fedora, usamos repositórios diferentes
            curl -fsSL https://download.docker.com/linux/centos/docker-ce.repo | sudo tee /etc/yum.repos.d/docker-ce.repo > /dev/null
        else
            echo "Distribuição não suportada para instalação automatizada."
            exit 1
        fi
        # Atualizar repositórios e instalar Docker
        sudo apt-get update
        install_package "docker-ce" "docker-ce-cli" "containerd.io" "docker-buildx-plugin" "docker-compose-plugin"
        # Instalar Docker Compose via pip3 (opcional, se não instalado com o plugin)
        sudo pip3 install docker-compose
    fi
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo apt-get clean
    }


function start_5g_macvlan(){
    sudo sysctl net.ipv4.conf.all.forwarding=1
    sudo iptables -P FORWARD ACCEPT
    sudo sysctl -w net.core.wmem_max=33554432
    sudo sysctl -w net.core.rmem_max=33554432
    sudo sysctl -w net.core.wmem_default=33554432
    sudo sysctl -w net.core.rmem_default=33554432
    cd $WORK_DIR/ || exit
    sudo docker compose --env-file docker/open5gs/open5gs.env -f docker/docker-compose-macvlan.yml down 5gc
    sudo docker compose --env-file docker/open5gs/open5gs.env -f docker/docker-compose-macvlan.yml up -d 5gc
    docker ps -a
    }

# Função que pausa o 5G OAI
function stop_5g(){
    echo "Encerrando Open5GS"
    cd $WORK_DIR/
    sudo docker compose --env-file docker/open5gs/open5gs.env -f docker/docker-compose-macvlan.yml down 5gc
    }

# Função que gera o log do AMF 5G OAI
function logs_5g() {
    ## Verifica se o contêiner 5G Core está em execução
    if sudo docker inspect -f '{{.State.Running}}' open5gs_5gc | grep true > /dev/null; then
        ## Exibe os logs do 5G Core
        echo "Exibindo logs do 5G Core..."
        sudo docker logs -f open5gs_5gc
    else
        ## Exibe mensagem se o 5G Core não estiver em execução
        echo "O 5G Core não está em execução. Por favor, selecione a opção 6 do menu para iniciar o Core 5G."
    fi
    }

function start_gNB_srsRAN_docker(){
    sudo docker rm -f srsran_gnb
    cd $WORK_DIR/srsRAN/docker
    sudo docker compose -f docker-compose-macvlan_pacoteB.yaml up gnb -d
    }

function logs_gNB_srsRAN_docker(){
    sudo docker logs -f srsran_gnb
    }

function stop_gNB_srsRAN_docker(){
    echo "Encerrando gNB srsRAN"
    cd $WORK_DIR/srsRAN/docker
    sudo docker compose -f docker-compose-macvlan_pacoteB.yaml down gnb
    }

function start_video(){
    cd $WORK_DIR
    docker compose --env-file docker/open5gs/open5gs.env -f docker/docker-compose-macvlan.yml up -d video-server
    }

function stop_video(){
    echo "Encerrando Servidor de vídeo"
    cd $WORK_DIR
    docker compose --env-file docker/open5gs/open5gs.env -f docker/docker-compose-macvlan.yml down video-server
    }

# Case principal
case "${COMMAND}" in
    "--help")
        show_help
        ;;
    "--install")
        install_package "git"
        install_docker
        install_libuhd
        ;;
    "--performance")
        performance_mode
        ;;
    "--start_5g_core")
        start_5g_macvlan
        ;;
    "--stop_5g_core")
        stop_5g
        ;;
    "--logs_5g_core")
        logs_5g
        ;;
    "--start_video")
        start_video
        ;;
    "--stop_video")
        stop_video
        ;;
    "--start_gNB_srsRAN_docker")
        start_gNB_srsRAN_docker
        ;;
    "--logs_gNB_srsRAN_docker")
        logs_gNB_srsRAN_docker
        ;;
    "--stop_gNB_srsRAN_docker")
        stop_gNB_srsRAN_docker
        ;;
        *)
echo " COMMAND not Found."
show_help
exit 127;
;;
esac

