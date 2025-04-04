#!/bin/bash

echo "Iniciando configuração do ambiente de desenvolvimento..."

# Atualizar pacotes
echo "Atualizando pacotes..."
sudo apt-get -y update || { echo "Falha ao atualizar pacotes"; exit 1; }

# Instalar Docker
echo "Instalando Docker..."
sudo apt-get install -y ca-certificates curl gnupg lsb-release || { echo "Falha ao instalar dependências do Docker"; exit 1; }
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --batch --yes --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get -y update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io || { echo "Falha ao instalar Docker"; exit 1; }

# Configurar Docker
echo "Configurando Docker..."
sudo systemctl enable docker.service
sudo systemctl enable containerd.service
sudo systemctl start docker.service || { echo "Falha ao iniciar Docker"; exit 1; }

# Instalar Docker Compose
echo "Instalando Docker Compose..."
sudo curl -L "https://github.com/docker/compose/releases/download/v2.24.6/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
docker-compose --version || { echo "Falha ao instalar Docker Compose"; exit 1; }

# Instalar Node.js
echo "Instalando Node.js..."
sudo curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash - || { echo "Falha ao configurar repositório Node.js"; exit 1; }
sudo apt-get install -y nodejs || { echo "Falha ao instalar Node.js"; exit 1; }

# Atualizar NPM
echo "Atualizando NPM..."
sudo npm install -g npm@latest --loglevel=error || { echo "Falha ao atualizar NPM"; exit 1; }

# Instalar Expo CLI
echo "Instalando Expo CLI..."
sudo npm install -g expo-cli || { echo "Falha ao instalar Expo CLI"; exit 1; }

# Instalar AWS CLI
echo "Instalando AWS CLI..."
sudo apt-get install unzip -y || { echo "Falha ao instalar unzip"; exit 1; }
sudo curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
sudo unzip -o awscliv2.zip
sudo ./aws/install || { echo "Falha ao instalar AWS CLI"; exit 1; }
aws --version

# Configurar permissões Docker
echo "Configurando permissões Docker..."
sudo usermod -aG docker ubuntu
echo "Para aplicar as permissões do grupo Docker, execute: newgrp docker"

echo "Configuração do ambiente concluída com sucesso!"
echo "Você pode precisar fazer logout e login novamente para que as permissões do grupo Docker sejam aplicadas."


