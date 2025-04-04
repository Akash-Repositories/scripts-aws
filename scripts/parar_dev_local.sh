#!/bin/bash

nome="bia-dev"
echo "Procurando instância com tag Name=$nome..."

instance_id=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=$nome" "Name=instance-state-name,Values=running" --query 'Reservations[].Instances[].InstanceId' --output text)

if [ -z "$instance_id" ]; then
    echo ">[ERRO] Nenhuma instância em execução com o nome $nome foi encontrada."
    exit 1
fi

echo "Parando instância $instance_id..."
aws ec2 stop-instances --instance-ids $instance_id

if [ $? -eq 0 ]; then
    echo "Comando para parar a instância enviado com sucesso."
    echo "Aguardando a instância parar..."
    aws ec2 wait instance-stopped --instance-ids $instance_id
    echo "Instância parada com sucesso."
else
    echo ">[ERRO] Falha ao parar a instância."
    exit 1
fi
