#!/bin/bash

echo "Iniciando lançamento de instância EC2 na zona us-east-1a..."

# Obter VPC ID
vpc_id=$(aws ec2 describe-vpcs --filters Name=isDefault,Values=true --query "Vpcs[0].VpcId" --output text)
if [ -z "$vpc_id" ]; then
    echo ">[ERRO] Não foi possível encontrar a VPC default."
    exit 1
fi
echo "VPC ID: $vpc_id"

# Obter Subnet ID
subnet_id=$(aws ec2 describe-subnets --filters Name=vpc-id,Values=$vpc_id Name=availabilityZone,Values=us-east-1a --query "Subnets[0].SubnetId" --output text)
if [ -z "$subnet_id" ]; then
    echo ">[ERRO] Não foi possível encontrar uma subnet na zona us-east-1a."
    exit 1
fi
echo "Subnet ID: $subnet_id"

# Obter Security Group ID
security_group_id=$(aws ec2 describe-security-groups --group-names "bia-dev" --query "SecurityGroups[0].GroupId" --output text 2>/dev/null)
if [ -z "$security_group_id" ]; then
    echo ">[ERRO] Security group bia-dev não foi encontrado na VPC $vpc_id"
    echo "Execute o script para criar o security group primeiro."
    exit 1
fi
echo "Security Group ID: $security_group_id"

# Verificar se o arquivo user_data_ec2_zona_a.sh existe
if [ ! -f "user_data_ec2_zona_a.sh" ]; then
    echo ">[ERRO] Arquivo user_data_ec2_zona_a.sh não encontrado."
    exit 1
fi

# Verificar se a role existe
if ! aws iam get-instance-profile --instance-profile-name role-acesso-ssm &>/dev/null; then
    echo ">[ERRO] Perfil de instância role-acesso-ssm não encontrado."
    echo "Execute o script criar_role_ssm.sh primeiro."
    exit 1
fi

echo "Lançando instância EC2..."
instance_id=$(aws ec2 run-instances --image-id ami-02f3f602d23f1659d --count 1 --instance-type t3.micro \
--security-group-ids $security_group_id --subnet-id $subnet_id --associate-public-ip-address \
--block-device-mappings '[{"DeviceName":"/dev/xvda","Ebs":{"VolumeSize":15,"VolumeType":"gp2"}}]' \
--tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=bia-dev}]' \
--iam-instance-profile Name=role-acesso-ssm --user-data file://user_data_ec2_zona_a.sh \
--query 'Instances[0].InstanceId' --output text)

if [ -z "$instance_id" ]; then
    echo ">[ERRO] Falha ao lançar a instância EC2."
    exit 1
fi

echo "Instância EC2 lançada com sucesso! ID: $instance_id"
echo "Aguardando a instância iniciar..."

aws ec2 wait instance-running --instance-ids $instance_id
echo "Instância está em execução. Aguarde alguns minutos para que o user data script seja executado."

# Obter o IP público da instância
public_ip=$(aws ec2 describe-instances --instance-ids $instance_id --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)
echo "IP público da instância: $public_ip"

echo "Para se conectar à instância via Session Manager, execute:"
echo "./start-session-bash.sh $instance_id"
