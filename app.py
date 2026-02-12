import ansible_runner

# Executa o playbook
r = ansible_runner.run(private_data_dir= "/home/lance/ansible", playbook='up-open5gs.yaml')

print(f"Status final: {r.status}")
print(f"Código de saída: {r.rc}")

# Verificar eventos (quais tarefas falharam ou passaram)
for event in r.events:
    print(event.get('event'))
