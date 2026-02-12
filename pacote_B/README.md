## Pacote B

<div style="display: flex; align-items: center;">
  <img src="https://open5gs.org/assets/img/open5gs-logo.png" width="280px">
  <img src="https://docs.srsran.com/projects/project/en/latest/_static/logo.png" width="200px">
</div>

---
![Pacote_B](../../docs/figs/Pacote_B.png)

### Instruções Rápidas de Implantação do open5GC do Pacote B

Se logar na Afrodite:

```bash
ssh lancetelecom@172.31.0.51
```

Baixar repositório:
```bash
git clone https://github.com/lance-ufrn/lsu-oai-advanced.git
```
ou 

```bash
git clone git@github.com:lance-ufrn/lsu-oai-advanced.git
```


Entrar na pasta do Pacote B:

```bash
cd /home/lancetelecom/lsu-oai-advanced/pacotes_maestro/pacote_B/
```

Para subir o Core:
```bash
sudo docker compose --env-file docker/open5gs/open5gs.env -f docker/docker-compose-macvlan.yml up -d 5gc
```
Para criar a macvlan se o script reclamar:
```bash
docker network create -d macvlan --subnet=172.31.0.0/24 --gateway=172.31.0.1 -o parent=ens13f0np0 macvlan_net
```
        
Para verificar os logs:
```bash
docker logs -f open5gs_5gc
```

Para parar e deletar a imagem do core:

```bash
sudo docker stop open5gs_5gc
sudo docker rm open5gs_5gc
sudo docker image rm docker-5gc
``` 

Para parar o Core:

```bash
./coreStop.sh
```

Para subir o servidor de vídeo:
```bash
    docker compose --env-file docker/open5gs/open5gs.env -f docker/docker-compose-macvlan.yml up -d video-server
```

Para verificar os logs:
```bash
docker logs -f dash-server
```

Para ver as configurações do Core:

http://172.31.0.154:9999/

login: admin
senha: 1423

Para subir a gNB. Se logar na Haykin:

```bash
ssh lancetelecom@192.168.110.134
```

Entrar na pasta do Pacote B:

```bash
cd  /home/lancetelecom/lsu-oai-advanced/pacotes_maestro/pacote_B/srsRAN/docker 
```
Subir a gNB:

```bash
sudo docker compose -f docker-compose-macvlan_pacoteB.yaml up gnb -d
```

Para criar a macvlan se o script reclamar:
```bash
docker network create -d macvlan --subnet=172.31.0.0/24 --gateway=172.31.0.1 -o parent=ens13f0np0 macvlan_net
```

Para parar a gNB:

```bash
sudo docker stop srsran_gnb
```

# Instruções Detalhadas de Implantação do open5GC em Docker

**Importante:** como usaremos docker, não é necessário instalar o open5GS


### Passo 1: Se logar na máquina e clonar do repositório

Se logar na Afrodite:

```bash
ssh lancetelecom@172.31.0.51
```


Alguns dependencias:

sudo apt install net-tools

```bash
git clone git@github.com:lance-ufrn/lsu-oai-advanced.git
```

### Passo 2: Criar interface mac-vlan

- Este modo de configuração deve ser aplicado quando queremos que o CORE receba conexões de gNBs externas.

- --subnet= Endereço da rede do Host - (aqui: 172.31.0.0/24)
- --gateway= Gateway da rede do Host - (aqui: 172.31.0.1)
- parent= Nome da interface de rede do Host - (aqui: ens13f0np0)
- Se precisar ver as informações de sua interface de rede, digite: ip a

```bash
    sudo docker network create -d macvlan   --subnet=172.31.0.0/24   --gateway=172.31.0.1   -o parent=enp3s0f0   macvlan-dhcp
```

Se a **macvlan** já tiver sido criada, você receberá uma mensagem de warning.

```
Error response from daemon: network with name macvlan_net already exists
```

- Verifique se a interface foi devidamente configurada.

```bash
    sudo docker network ls
```

```
    NETWORK ID     NAME          DRIVER    SCOPE
    b60ecea32324   bridge        bridge    local
    5c6baa9e033b   docker_ran    bridge    local
    bbc77afa2a5f   host          host      local
    32ea57bece00   macvlan_net   macvlan   local
    e9643382360a   none          null      local
```

### Passo 3: Configurar o arquivo open5gs.env

- As informações devem ser ajustadas antes de realizar o build da imagem docker do Open5GS.

```bash
    sudo vim /home/lancetelecom/lsu-oai-advanced/pacotes_maestro/pacote_B/docker/open5gs/open5gs.env
```

### Observação:

- Neste aquivo são sinalizadas algumas variáveis de ambiente do CORE.
- Confira os IPs das variáveis `OPEN5GS_IP` e `UPF_ADVERTISE_IP` que são referentes ao IP do AMF. Este IP deve ser, um IP livre, no mesmo endereço da rede do Host (aqui eu escolhi 172.31.0.154).
- Confira o nome da rede: lanceB

```yaml
    MONGODB_IP=127.0.0.1            # IP do MongoDB a ser usado. 127.0.0.1 é o MongoDB que roda dentro deste contêiner.
    OPEN5GS_IP=172.31.0.154         # IP fixo dentro da rede da máquina, este será o endereço do AMF (aqui:172.31.0.154).
    UE_IP_BASE=10.45.0              # Define a base de IP usada para UEs conectados (aqui: 10.45.0).
    UPF_ADVERTISE_IP=172.31.0.154   # IP fixo dentro da rede da máquina, este será o endereço do UPF (aqui:10.45.0).
    DEBUG=true                      # Ativa ou desativa o modo debug.
    SUBSCRIBER_DB=subscriber_db.csv # Adiciona dados de assinantes para um ou vários usuários ao MongoDB do Open5GS.
    NETWORK_NAME_FULL=lanceB         # Nome da APN.
    NETWORK_NAME_SHORT=lanceB
    TZ=America/Recife               # Esta configuração também será transmitida pelo Open5GS para a UE.,
```

### Conferir o banco de dados dos IMSIs

```bash
sudo vim /home/lancetelecom/lsu-oai-advanced/pacotes_maestro/pacote_B/docker/open5gs/subscriber_db.csv
```

Se certificar que somente o usuário destinado ao Pacote B está ativado no Core:

``` 
ue05,001010000000005,FEC86BA6EB707ED08905757B1BB44B8F,opc,C42449363BBAD02B66D16BC975D77CC1,8000,5,10.45.3.5,lanceB,1,000001
```

### Conferir endereço IP dos containers

- No arquivo `docker/docker-compose-macvlan.yml` confira se no campo `networks` o IP está na mesma faixa de endereços da rede macvlan criada anteriormente.

```yaml
networks:
      macvlan_net:
        ipv4_address: ${OPEN5GS_IP:-172.31.0.154}  # IP válido da rede macvlan
```
- Verificar se o IP roteado via macvlan corresponde a faixa de IP designados aos UEs: **10.45.1.0/24**

```bash
command: /bin/sh -c "apt-get update && apt-get install -y iptables iproute2 && ip route add 10.45.1.0/24 via ${OPEN5GS_IP:-172.31.0.154} dev eth0 && chmod +x /setup-firewall.sh && sleep 5 && /setup-firewall.sh && nginx -g 'daemon off;'"
```

### Observações

- O arquivo localizado em `docker/open5gs/open5gs-5gc.yml` contém as configurações das funções de rede que compõe o Core (AMF, SMF, UPF, PCF, UDM, NSSF, NRF, SCP, HSS...).

É nele que podemos ajustar as configurações de slice como SD, SSD assim como informações de ID e localidade da operadora MCC, MNC, TAC. 

Cheque se o DNN está setado para **lanceB** (em várias partes do arquivo) e se o gateway do SMF está setado para **10.45.0.1**. Cheque também se os dnns dos slices estão setados para **lanceB**

## Passo 4: Iniciar Open5GS

- Execute o comando a seguir para os casos em que o CORE está hospedado em um host diferente do da gNB.

```bash
    sudo docker compose --env-file docker/open5gs/open5gs.env -f docker/docker-compose-macvlan.yml up -d 5gc
```

- Após executar um dos comandos anteriores o `CORE` estará acessivel no mesmo IP, da rede mac-vlan, informado no docker-compose-macvlan.yaml localizado em `docker/docker-compose-macvlan.yml` (aqui: 172.31.0.154). 

## Passo 5: Verificar os logs do CORE:

```bash
docker logs -f open5gs_5gc
```
---

# Video server

## Passo 1: Executando o dash-server para CORE mac-vlan

### Atenção
- Lembre-se de verificar se os IPs dos containers estão na mesma faixa de IP da interface mac-vlan criada anteriormente (aqui: 172.31.0.155).

```bash
    docker compose --env-file docker/open5gs/open5gs.env -f docker/docker-compose-macvlan.yml up -d video-server
 ```

## Passo 3: Executando o dash-server para CORE local

```bash
    docker compose --env-file docker/open5gs/open5gs.env -f docker/docker-compose.yml up -d video-server
 ```

---

# srsRAN - Docker

## Passo 1: Se logar na máquina e alternar para o diretório do repositório

Se conecte na máquina que hospedará a gNB. Nesse caso, a Haykin:

```bash
ssh lancetelecom@192.168.110.134
```
- Mudar para pasta da srsRAN do Pacote B:

```bash
    cd /home/lancetelecom/lsu-oai-advanced/pacotes_maestro/pacote_B/srsRAN/docker
```

## Passo 2: Provisionando a gNB em Docker (gNB em Host difente do CORE)

- Crie uma macvlan chamada **macvlan_net**:

- --subnet= Endereço da rede do Host - (aqui: 172.31.0.0/24)
- --gateway= Gatewai da rede do Host - (aqui: 172.31.0.1)
- parent= Nome da interface de rede do Host - (aqui: enp3s0f0)

```bash
    sudo docker network create -d macvlan --subnet=172.31.0.0/24 --gateway=172.31.0.1 -o parent=enp3s0f0 macvlan_net
```

- Verifique se a interface foi devidamente configurada.

```bash
    sudo ocker network ls

    NETWORK ID     NAME          DRIVER    SCOPE
    b60ecea32324   bridge        bridge    local
    5c6baa9e033b   docker_ran    bridge    local
    bbc77afa2a5f   host          host      local
    32ea57bece00   macvlan_net   macvlan   local
    e9643382360a   none          null      local
```

- Aqui temos o arquivo `docker-compose-macvlan_pacoteB.yaml` para os casos em que o CORE está em outro Host.


- É importante verificar que o arquivo docker esteja apontando para o arquivo de configuração da gNB **/home/lancetelecom/lsu-oai-advanced/pacotes_maestro/pacote_B/conf_gnb**.

```yaml
configs:
  gnb_config.yml:
    file: ${GNB_CONFIG_PATH:-../../conf_gnb/gnb.pacoteB.conf}  # Path to your desired config file
```
- No arquivo de configuração da gNB (`docker-compose-macvlan_pacoteB.yaml`) existe um campo para informar as configurações de nome e IP. Verifique se as informações estão corretas:

```bash
vim /home/lancetelecom/lsu-oai-advanced/pacotes_maestro/pacote_B/conf_gnb/gnb.pacoteB.conf
```

```yaml
ran_node_name: gNB-srsRAN-B
cu_cp:
  amf:
    addr: 172.31.0.154      # IP do AMF que está no dockcompose do Core (macvlan)
    port: 38412
    bind_addr:  172.31.0.156 # IP da macvaln do container da gNB (dentro do docker compose da gNB macvlan)
```

Para provisionar a gNB:

```bash
cd /home/lancetelecom/lsu-oai-advanced/pacotes_maestro/pacote_B/
```
Subir a gNB:

```bash
sudo docker compose -f docker-compose-macvlan_pacoteB.yaml up gnb -d
```


- Também existe a possibilidade de provisionar os serviços de monitoramento da gNB, basta executar o seguinte comando:

```bash
    sudo docker compose -f docker-compose-macvlan_pacoteB.yaml up -d gnb grafana influxdb metrics-server
```

- Para que a gNB exporte corretamente as KPIs é necessário descomentar no arquivo de configuração da gNB as configurações do expositor de métricas. Os arquivos de configuração da gNB ()

```bash
vim /home/lancetelecom/lsu-oai-advanced/pacotes_maestro/pacote_B/conf_gnb/gnb.pacoteB.conf
```


```yaml
    metrics:
      sched_report_period: 1000
      enable_json_metrics: true       # Enable reporting metrics in JSON format
      addr: 172.19.1.4                # Metrics-server IP
      port: 55555                     # Metrics-server Port
```

- Para acessar a dashboard de monitoramento basta abrir o navegador e inserir o IP do Host na porta 3300.

```
    hhttp://192.168.110.134:3300/
```

---
