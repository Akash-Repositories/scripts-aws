#!/bin/bash

# Set environment variables file if it exists
if [ -f .env ]; then
  export $(cat .env | grep -v '#' | awk '/=/ {print $1}')
fi

# Choose development mode
if [ "$1" == "docker" ]; then
  # Start development in Docker
  docker compose up expo-dev
elif [ "$1" == "build" ]; then
  # Build for EAS
  npx eas-cli build --platform all --profile development
elif [ "$1" == "publish" ]; then
  # Publish to Expo/EAS
  npx eas-cli update --auto
elif [ "$1" == "zeego" ]; then
  # Initialize Zeego Cloud configuration
  echo "Configuring Zeego Cloud integration..."
  npx zeego init
else
  # Start Expo development server locally
  npx expo start --dev-client
fi