import ansible_runner
import os

base_dir = os.path.dirname(os.path.abspath(__file__))

# 1. Definições de acesso
TARGET_IP = '192.168.160.80'
USER = 'lance'
PASS = 'lance123'

# 2. Execução usando a lógica que deu certo no app2.py
r = ansible_runner.run(
    private_data_dir=base_dir,
    playbook='up-video-app.yaml',
    inventory={
        'video_app': {  # Nome do grupo que está no seu playbook
            'hosts': {
                TARGET_IP: {
                    'ansible_user': USER,
                    'ansible_password': PASS,
                    'ansible_become_password': PASS
                }
            }
        }
    },
    envvars={
        'ANSIBLE_HOST_KEY_CHECKING': 'False'
    }
)

print("-" * 30)
print(f"Status final: {r.status}")
print(f"Código de saída: {r.rc}")

# Opcional: imprimir erros se houver
if r.status != 'successful':
    for event in r.events:
        if event.get('event') == 'runner_on_unreachable':
            print(f"[ERRO] Host inacessível: {event.get('event_data', {}).get('res')}")
