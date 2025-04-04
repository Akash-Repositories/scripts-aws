#!/bin/bash

echo "Instalando VS Code e Google Chrome..."

# Verificar se o Snap está instalado
if ! command -v snap &> /dev/null; then
    echo "Instalando Snap..."
    sudo apt update
    sudo apt install -y snapd
    sudo snap wait system seed.loaded
fi

# Instalar VS Code
echo "Instalando Visual Studio Code..."
sudo snap install --classic code || { 
    echo "Falha ao instalar VS Code via Snap. Tentando método alternativo..."
    
    # Método alternativo para instalar VS Code
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
    sudo install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/
    sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
    rm -f packages.microsoft.gpg
    
    sudo apt update
    sudo apt install -y code || { echo "Falha ao instalar VS Code"; exit 1; }
}

# Instalar Google Chrome
echo "Instalando Google Chrome..."
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb || { echo "Falha ao baixar Google Chrome"; exit 1; }
sudo apt install -y ./google-chrome-stable_current_amd64.deb || {
    echo "Instalando dependências e tentando novamente..."
    sudo apt install -y gdebi-core
    sudo gdebi -n google-chrome-stable_current_amd64.deb || { echo "Falha ao instalar Google Chrome"; exit 1; }
}
rm google-chrome-stable_current_amd64.deb

# Instalar extensões úteis para VS Code
echo "Instalando extensões úteis para VS Code..."
code --install-extension dbaeumer.vscode-eslint
code --install-extension esbenp.prettier-vscode
code --install-extension ms-azuretools.vscode-docker
code --install-extension ms-vscode.vscode-typescript-next

echo "VS Code e Google Chrome instalados com sucesso!"