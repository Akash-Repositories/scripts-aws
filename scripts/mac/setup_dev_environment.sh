#!/bin/bash

echo "Setting up development environment for macOS..."

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    echo "Updating Homebrew..."
    brew update
fi

# Install Docker Desktop if not installed
if ! command -v docker &> /dev/null; then
    echo "Installing Docker Desktop..."
    brew install --cask docker
    echo "Please open Docker Desktop manually to complete setup"
else
    echo "Docker is already installed"
fi

# Install Node.js
echo "Installing Node.js..."
brew install node

# Install AWS CLI
echo "Installing AWS CLI..."
brew install awscli

# Install Expo CLI
echo "Installing Expo CLI..."
npm install -g expo-cli

# Install VS Code if not installed
if ! command -v code &> /dev/null; then
    echo "Installing Visual Studio Code..."
    brew install --cask visual-studio-code
else
    echo "VS Code is already installed"
fi

echo "Development environment setup complete!"
echo "Make sure to configure your AWS credentials with: aws configure"