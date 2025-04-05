#!/bin/bash

# Set variables
if [ -z "$AWS_REGION" ]; then
    echo "Please set AWS_REGION environment variable"
    echo "Example: export AWS_REGION=us-east-1"
    exit 1
fi

# Check if Amplify CLI is installed
if ! command -v amplify &> /dev/null; then
    echo "Installing AWS Amplify CLI..."
    npm install -g @aws-amplify/cli
fi

# Initialize Amplify if not already initialized
if [ ! -d "amplify" ]; then
    echo "Initializing Amplify project..."
    amplify init --yes
fi

# Build the application with Amplify
echo "Building application with Amplify..."
amplify build

# Build Docker image if container deployment is needed
if [ "$CONTAINER_DEPLOY" = "true" ]; then
    if [ -z "$AWS_ACCOUNT_ID" ]; then
        echo "Please set AWS_ACCOUNT_ID for container deployment"
        exit 1
    fi

    ECR_REGISTRY="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
    IMAGE_NAME="akash-app"
    IMAGE_TAG="latest"

    echo "Building and pushing Docker image..."
    aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_REGISTRY}
    docker build -t ${IMAGE_NAME}:${IMAGE_TAG} .
    docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${ECR_REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}
    docker push ${ECR_REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}
fi

# Deploy with Amplify
echo "Deploying with Amplify..."
amplify push --yes

echo "Build and deployment completed successfully!"