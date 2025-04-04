#!/bin/bash

echo "Instalando Session Manager plugin para AWS CloudShell..."

# Verificar se estamos em um ambiente CloudShell
if [ ! -f /etc/amazon/cloudshell/cloudshell.yaml ]; then
    echo "Este script deve ser executado no AWS CloudShell."
    exit 1
fi

# Baixar o plugin do Session Manager
echo "Baixando Session Manager plugin..."
curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/linux_64bit/session-manager-plugin.rpm" -o "session-manager-plugin.rpm"

if [ ! -f "session-manager-plugin.rpm" ]; then
    echo "Falha ao baixar o plugin do Session Manager."
    exit 1
fi

# Instalar o plugin
echo "Instalando o plugin..."
sudo yum install -y session-manager-plugin.rpm

# Verificar a instalação
if session-manager-plugin --version; then
    echo "Session Manager plugin instalado com sucesso!"
    echo "Agora você pode usar o comando 'aws ssm start-session' para se conectar às instâncias."
else
    echo "Falha ao instalar o Session Manager plugin."
    exit 1
fi

# Limpar
rm -f session-manager-plugin.rpm