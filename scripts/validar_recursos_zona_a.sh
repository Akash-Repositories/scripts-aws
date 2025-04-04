#!/bin/bash

echo "Validando recursos AWS na zona us-east-1a..."

# Validar VPC
vpc_id=$(aws ec2 describe-vpcs --filters Name=isDefault,Values=true --query "Vpcs[0].VpcId" --output text 2>/dev/null)
if [ $? -eq 0 ] && [ -n "$vpc_id" ]; then
  echo "[OK] VPC default encontrada: $vpc_id"
else
  echo ">[ERRO] Problema ao encontrar a VPC default. Verifique se ela existe e se você tem permissões."
  exit 1
fi

# Validar Subnet
subnet_id=$(aws ec2 describe-subnets --filters Name=vpc-id,Values=$vpc_id Name=availabilityZone,Values=us-east-1a --query "Subnets[0].SubnetId" --output text 2>/dev/null)
if [ $? -eq 0 ] && [ -n "$subnet_id" ]; then
  echo "[OK] Subnet na zona us-east-1a encontrada: $subnet_id"
else
  echo ">[ERRO] Problema ao encontrar subnet na zona us-east-1a. Verifique se existe uma subnet nesta zona."
  exit 1
fi

# Validar Security Group
security_group_id=$(aws ec2 describe-security-groups --group-names "bia-dev" --query "SecurityGroups[0].GroupId" --output text 2>/dev/null)
if [ $? -eq 0 ] && [ -n "$security_group_id" ]; then
  echo "[OK] Security Group 'bia-dev' encontrado: $security_group_id"
  
  # Validar inbound rule para o security group 'bia-dev'
  inbound_rule=$(aws ec2 describe-security-groups --group-ids $security_group_id --filters "Name=ip-permission.from-port,Values=3001" "Name=ip-permission.cidr,Values=0.0.0.0/0" --output text)

  if [ -n "$inbound_rule" ]; then
    echo " [OK] Regra de entrada para porta 3001 está configurada corretamente"
  else
    echo " >[ERRO] Regra de entrada para a porta 3001 não encontrada ou não está aberta para 0.0.0.0/0"
    echo " Comando para adicionar: aws ec2 authorize-security-group-ingress --group-id $security_group_id --protocol tcp --port 3001 --cidr 0.0.0.0/0"
  fi

  # Validar outbound rule para o security group 'bia-dev'
  outbound_rule=$(aws ec2 describe-security-groups --group-ids $security_group_id --query "SecurityGroups[0].IpPermissionsEgress[?IpProtocol=='-1' && IpRanges[0].CidrIp=='0.0.0.0/0']" --output text)
  
  if [ -n "$outbound_rule" ]; then
    echo " [OK] Regra de saída está configurada corretamente"
  else
    echo " >[ERRO] Regra de saída para o mundo não encontrada"
    echo " Comando para adicionar: aws ec2 authorize-security-group-egress --group-id $security_group_id --protocol all --cidr 0.0.0.0/0"
  fi
else
  echo ">[ERRO] Security group 'bia-dev' não encontrado"
  echo "Comando para criar: aws ec2 create-security-group --group-name bia-dev --description \"Security group para desenvolvimento\" --vpc-id $vpc_id"
  exit 1
fi

# Validar IAM Role
if aws iam get-role --role-name role-acesso-ssm &>/dev/null; then
    echo "[OK] Role 'role-acesso-ssm' existe e está configurada"
else
    echo ">[ERRO] Role 'role-acesso-ssm' não existe"
    echo "Execute o script criar_role_ssm.sh para criar a role"
    exit 1
fi

echo "Validação concluída!"
