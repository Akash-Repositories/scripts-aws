#!/bin/bash

# Log de inicialização
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
echo "Iniciando script de configuração da instância..."

# Atualizar pacotes
echo "Atualizando pacotes..."
yum update -y

# Instalar Git
echo "Instalando Git..."
yum install git -y

# Instalar Docker
echo "Instalando Docker..."
yum install docker -y

# Configurar permissões Docker
echo "Configurando permissões Docker..."
usermod -a -G docker ec2-user
usermod -a -G docker ssm-user
id ec2-user ssm-user

# Iniciar e habilitar Docker
echo "Iniciando e habilitando Docker..."
systemctl enable docker.service
systemctl start docker.service

# Instalar Docker Compose v2
echo "Instalando Docker Compose v2..."
mkdir -p /usr/local/lib/docker/cli-plugins
curl -SL https://github.com/docker/compose/releases/download/v2.23.3/docker-compose-linux-x86_64 -o /usr/local/lib/docker/cli-plugins/docker-compose
chmod +x /usr/local/lib/docker/cli-plugins/docker-compose

# Verificar instalação do Docker Compose
docker compose version

# Configurar swap
echo "Configurando swap..."
dd if=/dev/zero of=/swapfile bs=128M count=32
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
echo "/swapfile swap swap defaults 0 0" >> /etc/fstab

# Instalar Node.js e npm
echo "Instalando Node.js e npm..."
curl -fsSL https://rpm.nodesource.com/setup_18.x | bash -
yum install -y nodejs

# Instalar Expo CLI
echo "Instalando Expo CLI..."
npm install -g expo-cli

# Instalar AWS CLI v2 (caso não esteja instalado)
if ! command -v aws &> /dev/null; then
    echo "Instalando AWS CLI v2..."
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    ./aws/install
    rm -rf aws awscliv2.zip
fi

# Criar diretório de projeto
echo "Criando diretório de projeto..."
mkdir -p /home/ec2-user/expo-app
chown ec2-user:ec2-user /home/ec2-user/expo-app

echo "Configuração da instância concluída com sucesso!"