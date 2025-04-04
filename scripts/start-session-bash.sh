#!/bin/bash

if [ -z "$1" ]; then
    echo "Uso: $0 <instance-id>"
    echo "Exemplo: $0 i-0123456789abcdef0"
    
    # Listar instâncias disponíveis
    echo -e "\nInstâncias disponíveis:"
    aws ec2 describe-instances --filters "Name=tag:Name,Values=bia-dev" "Name=instance-state-name,Values=running" --query "Reservations[].Instances[].[InstanceId,PublicIpAddress,Tags[?Key=='Name'].Value|[0]]" --output table
    
    exit 1
fi

INSTANCE_ID=$1
echo "Verificando se a instância $INSTANCE_ID está disponível..."

# Verificar se a instância existe e está em execução
instance_state=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query "Reservations[].Instances[].State.Name" --output text 2>/dev/null)

if [ $? -ne 0 ]; then
    echo "Instância $INSTANCE_ID não encontrada."
    exit 1
fi

if [ "$instance_state" != "running" ]; then
    echo "Instância $INSTANCE_ID não está em execução (estado atual: $instance_state)."
    echo "Deseja iniciar a instância? (s/n)"
    read resposta
    
    if [ "$resposta" = "s" ]; then
        echo "Iniciando instância..."
        aws ec2 start-instances --instance-ids $INSTANCE_ID
        echo "Aguardando a instância iniciar..."
        aws ec2 wait instance-running --instance-ids $INSTANCE_ID
    else
        exit 1
    fi
fi

echo "Conectando na instância $INSTANCE_ID..."
aws ssm start-session --target $INSTANCE_ID --document-name AWS-StartInteractiveCommand --parameters command="bash -l"