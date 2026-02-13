import ansible_runner
import os

# --- CONFIGURAÇÕES DO AMBIENTE ---
GNB_IP = '172.31.0.56'  # <--- Altere para o IP da sua gNB
GNB_USER = 'lance'   # <--- Altere para o seu usuário (ex: 'lance')
GNB_PASS = 'lance123'     # <--- Altere para a senha do sudo
PLAYBOOK_PATH = 'up_srsran.yaml' # Nome do arquivo .yaml que você me enviou
BASE_DIR = os.getcwd()    # Assume que o script roda na mesma pasta do playbook

print(f"[*] Iniciando deploy da srsRAN no host: {GNB_IP}")

# --- EXECUÇÃO DO ANSIBLE RUNNER ---
r = ansible_runner.run(
    private_data_dir=BASE_DIR,
    playbook=PLAYBOOK_PATH,
    inventory={
        'all': {
            'hosts': {
                'gnb': {
                    'ansible_host': GNB_IP,
                    'ansible_user': GNB_USER,
                    'ansible_password': GNB_PASS,
                    'ansible_become_password': GNB_PASS
                }
            }
        }
    },
    # Variáveis extras caso você queira dinamizar caminhos no Playbook
    extravars={
        'ansible_user': GNB_USER
    },
    envvars={
        'ANSIBLE_HOST_KEY_CHECKING': 'False'
    }
)

# --- TRATAMENTO DE RESULTADOS ---
print("-" * 40)
print(f"Status da Execução: {r.status.upper()}")
print("-" * 40)

# Resumo simplificado das tarefas
for event in r.events:
    event_type = event.get('event')
    if event_type == 'runner_on_ok':
        task = event.get('event_data', {}).get('task')
        print(f"✅ [SUCESSO] {task}")
    elif event_type == 'runner_on_failed':
        task = event.get('event_data', {}).get('task')
        msg = event.get('event_data', {}).get('res', {}).get('msg', 'Erro desconhecido')
        print(f"❌ [FALHA]   {task}")
        print(f"    Motivo: {msg}")

if r.status == 'successful':
    print("\n🚀 srsRAN está UP! Você pode verificar a sessão com: 'tmux attach -t srsRAN_session'")
else:
    print("\n⚠️ Ocorreram erros durante o deploy. Verifique os logs acima.")
