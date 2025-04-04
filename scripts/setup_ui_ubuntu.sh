#!/bin/bash

echo "Configurando ambiente gráfico e Chrome Remote Desktop..."

# Atualizar pacotes
echo "Atualizando pacotes..."
sudo apt update -y && sudo apt upgrade -y || { echo "Falha ao atualizar pacotes"; exit 1; }

# Instalar ambiente gráfico XFCE
echo "Instalando ambiente gráfico XFCE..."
sudo DEBIAN_FRONTEND=noninteractive apt install -y xfce4 xfce4-goodies || { echo "Falha ao instalar XFCE"; exit 1; }

# Instalar Chrome Remote Desktop
echo "Instalando Chrome Remote Desktop..."
wget https://dl.google.com/linux/direct/chrome-remote-desktop_current_amd64.deb || { echo "Falha ao baixar Chrome Remote Desktop"; exit 1; }
sudo apt install -y ./chrome-remote-desktop_current_amd64.deb || { echo "Falha ao instalar Chrome Remote Desktop"; exit 1; }
rm chrome-remote-desktop_current_amd64.deb

# Configurar permissões
echo "Configurando permissões..."
sudo chmod 777 /home/ubuntu/.config/

# Configurar serviço Chrome Remote Desktop
echo "Para completar a configuração do Chrome Remote Desktop:"
echo "1. Visite: https://remotedesktop.google.com/headless"
echo "2. Clique em 'Começar'"
echo "3. Clique em 'Autorizar'"
echo "4. Copie o comando Debian Linux e execute-o nesta máquina"
echo "5. Defina um PIN para acesso"
echo "6. Acesse sua máquina em: https://remotedesktop.google.com/access"

echo "Configuração do ambiente gráfico concluída!"