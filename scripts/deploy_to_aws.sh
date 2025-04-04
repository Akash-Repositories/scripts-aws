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
  npx eas-cli build --platform all --profile production --non-interactive
fi

# Deploy to AWS
if [[ "$DEPLOY" == true ]]; then
  echo "Deploying to AWS..."
  aws s3 sync ./build s3://your-bucket-name/ --profile $AWS_PROFILE
  
  # If using CloudFront, invalidate cache
  if [[ -n "$CLOUDFRONT_DISTRIBUTION_ID" ]]; then
    aws cloudfront create-invalidation --distribution-id $CLOUDFRONT_DISTRIBUTION_ID --paths "/*" --profile $AWS_PROFILE
  fi
fi

# Publish to Expo
if [[ "$PUBLISH" == true ]]; then
  echo "Publishing to Expo..."
  npx eas-cli update --auto
fi

echo "Deployment process completed!"