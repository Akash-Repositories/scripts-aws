#!/bin/bash

nome="bia-dev"
echo "Procurando instância com tag Name=$nome..."

instance_id=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=$nome" "Name=instance-state-name,Values=stopped" --query 'Reservations[].Instances[].InstanceId' --output text)

if [ -z "$instance_id" ]; then
    echo ">[ERRO] Nenhuma instância parada com o nome $nome foi encontrada."
    exit 1
fi

echo "Iniciando instância $instance_id..."
aws ec2 start-instances --instance-ids $instance_id

if [ $? -eq 0 ]; then
    echo "Instância iniciada com sucesso. Aguardando a instância ficar disponível..."
    aws ec2 wait instance-running --instance-ids $instance_id
    
    # Obter o IP público da instância
    public_ip=$(aws ec2 describe-instances --instance-ids $instance_id --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)
    echo "Instância está em execução. IP público: $public_ip"
    
    echo "Para se conectar à instância via Session Manager, execute:"
    echo "./start-session-bash.sh $instance_id"
else
    echo ">[ERRO] Falha ao iniciar a instância."
    exit 1
fi
