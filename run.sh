#!/bin/bash

# 🚨 Exit script on any error
set -e

# Catch error and display a custom message
trap 'echo "❌ ERROR: Something went wrong at line $LINENO. Exiting."' ERR

# Get the current folder name and convert to lowercase
RAW_NAME=${PWD##*/}
PROJECT_NAME=$(echo "$RAW_NAME" | tr '[:upper:]' '[:lower:]')

# Optional: Ask for port (default 8080)
read -p "Enter host port to expose (default 8080): " PORT
PORT=${PORT:-8080}

# Build Docker image
echo "🔧 Building Docker image for $PROJECT_NAME..."
docker build -t $PROJECT_NAME .

# Stop & remove old container if it exists
if [ "$(docker ps -aq -f name=$PROJECT_NAME)" ]; then
    echo "♻️ Removing existing container..."
    docker stop $PROJECT_NAME
    docker rm $PROJECT_NAME
fi

# Run the container on specified port
echo "🚀 Running Docker container..."
docker run -d --name $PROJECT_NAME -p $PORT:80 $PROJECT_NAME

# Open in browser
if command -v xdg-open &> /dev/null; then
    xdg-open "http://localhost:$PORT"
elif command -v open &> /dev/null; then
    open "http://localhost:$PORT"
elif command -v start &> /dev/null; then
    start "http://localhost:$PORT"
fi

echo "✅ Site is live at http://localhost:$PORT"
