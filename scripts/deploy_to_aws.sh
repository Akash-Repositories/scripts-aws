#!/bin/bash

# Set variables
AWS_REGION=${AWS_REGION:-"us-east-1"}
AWS_PROFILE=${AWS_PROFILE:-"default"}

# Function to display usage
function display_usage {
  echo "Usage: $0 [options]"
  echo "Options:"
  echo "  --build          Build the application"
  echo "  --deploy         Deploy to AWS"
  echo "  --publish        Publish to Expo"
  echo "  --help           Display this help message"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    --build)
      BUILD=true
      shift
      ;;
    --deploy)
      DEPLOY=true
      shift
      ;;
    --publish)
      PUBLISH=true
      shift
      ;;
    --help)
      display_usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      display_usage
      exit 1
      ;;
  esac
done

# Build the application
if [[ "$BUILD" == true ]]; then
  echo "Building application..."
  amplify build
  npx eas-cli build --platform all --profile production --non-interactive
fi

# Deploy to AWS
if [[ "$DEPLOY" == true ]]; then
  echo "Deploying to AWS using Amplify..."
  amplify push --yes
  
  # Check if environment exists and create if needed
  if ! amplify env get --name prod > /dev/null 2>&1; then
    echo "Creating production environment..."
    amplify env add --name prod --yes
  fi
  
  # Deploy to production environment
  amplify publish --yes
fi

# Publish to Expo
if [[ "$PUBLISH" == true ]]; then
  echo "Publishing to Expo..."
  npx eas-cli update --auto
fi

echo "Deployment process completed!"