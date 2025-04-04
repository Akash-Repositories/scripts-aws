#!/bin/bash

role_name="role-acesso-ssm"
policy_name="AmazonSSMManagedInstanceCore"

echo "Verificando se a role $role_name já existe..."
if aws iam get-role --role-name "$role_name" &> /dev/null; then
    echo "A IAM role $role_name já existe."
    
    # Verificar se o perfil de instância existe
    if ! aws iam get-instance-profile --instance-profile-name "$role_name" &> /dev/null; then
        echo "Criando perfil de instância $role_name..."
        aws iam create-instance-profile --instance-profile-name $role_name
        
        echo "Adicionando role ao perfil de instância..."
        aws iam add-role-to-instance-profile --instance-profile-name $role_name --role-name $role_name
    else
        echo "Perfil de instância $role_name já existe."
    fi
    
    # Verificar se a política está anexada
    if ! aws iam list-attached-role-policies --role-name $role_name --query "AttachedPolicies[?PolicyName=='$policy_name']" --output text | grep -q $policy_name; then
        echo "Anexando política $policy_name à role..."
        aws iam attach-role-policy --role-name $role_name --policy-arn arn:aws:iam::aws:policy/$policy_name
    else
        echo "Política $policy_name já está anexada à role."
    fi
    
    echo "Configuração da role $role_name concluída com sucesso!"
    exit 0
fi

echo "Criando role $role_name..."
# Verificar se o arquivo ec2_principal.json existe
if [ ! -f "ec2_principal.json" ]; then
    echo "Arquivo ec2_principal.json não encontrado no diretório atual."
    echo "Criando arquivo ec2_principal.json..."
    cat > ec2_principal.json << 'EOF'
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Principal": {
      "Service": "ec2.amazonaws.com"
    },
    "Action": "sts:AssumeRole"
  }]
}
EOF
    echo "Arquivo ec2_principal.json criado."
fi

# Criar a role
if aws iam create-role --role-name $role_name --assume-role-policy-document file://ec2_principal.json; then
    echo "Role $role_name criada com sucesso."
else
    echo "Erro ao criar a role $role_name. Verifique suas permissões AWS."
    exit 1
fi

# Criar o perfil de instância
echo "Criando perfil de instância $role_name..."
if aws iam create-instance-profile --instance-profile-name $role_name; then
    echo "Perfil de instância $role_name criado com sucesso."
else
    echo "Erro ao criar o perfil de instância $role_name."
    exit 1
fi

# Adicionar a função IAM ao perfil de instância
echo "Adicionando role ao perfil de instância..."
# Aguardar um momento para garantir que a role foi propagada
sleep 5
if aws iam add-role-to-instance-profile --instance-profile-name $role_name --role-name $role_name; then
    echo "Role adicionada ao perfil de instância com sucesso."
else
    echo "Erro ao adicionar a role ao perfil de instância."
    exit 1
fi

# Anexar a política à role
echo "Anexando política $policy_name à role..."
# Aguardar um momento para garantir que o perfil foi propagado
sleep 5
if aws iam attach-role-policy --role-name $role_name --policy-arn arn:aws:iam::aws:policy/$policy_name; then
    echo "Política anexada com sucesso."
else
    echo "Erro ao anexar a política à role."
    exit 1
fi

echo "Configuração da role $role_name concluída com sucesso!