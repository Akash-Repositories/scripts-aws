FROM public.ecr.aws/docker/library/node:18-slim

# Install global dependencies
RUN npm install -g npm@latest expo-cli eas-cli --loglevel=error

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /usr/src/app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm install --loglevel=error

# Copy app source
COPY . .

# Expose Expo dev server ports
EXPOSE 19000
EXPOSE 19001
EXPOSE 19002

# Default command for development
CMD ["npx", "expo", "start", "--dev-client"]
