import ansible_runner
import socket
import os

# 1. Função para detectar o IP dinâmico da VM (Core)
def get_my_ip():
    """Descobre o IP da interface de rede ativa que sai para a internet."""
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    try:
        # Tenta conectar no Google DNS para despertar a interface de rede
        s.connect(('8.8.8.8', 80))
        ip = s.getsockname()[0]
    except Exception:
        ip = '127.0.0.1'
    finally:
        s.close()
    return ip

# 2. Configurações de Acesso ao Controlador
CONTROLLER_IP = '172.31.0.73'  # IP do seu controller-node
SSH_USER = 'lance'
SSH_PASS = 'lance123'
PLAYBOOK_PATH = 'setup_port_security.yaml'
BASE_DIR = "/home/lance/ansible"

# Detecta o IP da VM atual
meu_ip = get_my_ip()
print(f"[*] IP detectado para esta VM (Core): {meu_ip}")
print(f"[*] Iniciando orquestração no controlador: {CONTROLLER_IP}")

# 3. Execução do Ansible Runner
# O parâmetro 'extravars' sobrescreve a variável ip_do_core do Playbook
r = ansible_runner.run(
    private_data_dir=BASE_DIR,
    playbook=PLAYBOOK_PATH,
    inventory={
        'controller_node': {
            'hosts': {
                CONTROLLER_IP: {
                    'ansible_user': SSH_USER,
                    'ansible_password': SSH_PASS,
                    'ansible_become_password': SSH_PASS  # Necessário se o 'source' exigir sudo
                }
            }
        }
    },
    extravars={
        'ip_do_core': meu_ip
    },
    # Desativa a checagem de host (evita erro de 'Fingerprint' no primeiro acesso)
    envvars={
        'ANSIBLE_HOST_KEY_CHECKING': 'False'
    }
)

# 4. Verificação de Resultados
print("-" * 30)
print(f"Status final: {r.status}")
print(f"Código de saída: {r.rc}")
print("-" * 30)

# Loop simplificado para ver o que aconteceu em cada tarefa
for event in r.events:
    event_type = event.get('event')
    if event_type == 'runner_on_ok':
        task_name = event.get('event_data', {}).get('task')
        print(f"[OK] Tarefa concluída: {task_name}")
    elif event_type == 'runner_on_failed':
        task_name = event.get('event_data', {}).get('task')
        error_msg = event.get('event_data', {}).get('res', {}).get('msg')
        print(f"[ERRO] Falha na tarefa: {task_name}")
        print(f"Detalhes: {error_msg}")

if r.status == 'successful':
    print("\n[SUCESSO] O Port Security foi desativado com sucesso!")
else:
    print("\n[ALERTA] Houve um problema na execução do Playbook.")
