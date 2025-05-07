#!/bin/bash

# Exit on error
set -e

# Set variables
CONTAINER_NAME="tuleap"
TULEAP_IMAGE="tuleap:latest"
DATA_DIR="$(pwd)/tuleap_data"
HOSTNAME="tuleap.local"
DEFAULT_DOMAIN="localhost"
ORG_NAME="Tuleap"

# Create data directory if it doesn't exist
mkdir -p "$DATA_DIR"

# Build the Docker image
echo "Building Tuleap Docker image..."
docker build -t "$TULEAP_IMAGE" .

# Check if container already exists
if [ "$(docker ps -aq -f name=^${CONTAINER_NAME}$)" ]; then
    echo "Stopping and removing existing container..."
    docker stop "$CONTAINER_NAME" >/dev/null
    docker rm "$CONTAINER_NAME" >/dev/null
fi

# Run the container
echo "Starting Tuleap container..."
docker run -d \
    --name "$CONTAINER_NAME" \
    --hostname "$HOSTNAME" \
    --privileged \
    -p 8180:80 \
    -p 4443:443 \
    -p 2222:22 \
    -v "$DATA_DIR":/data \
    --network wine-world-network \
    -e "DEFAULT_DOMAIN=$DEFAULT_DOMAIN" \
    -e "ORG_NAME=$ORG_NAME" \
    "$TULEAP_IMAGE"

echo "\nTuleap container is starting..."
echo "It may take a few minutes for all services to be fully operational."
echo "\nYou can access Tuleap at: http://$HOSTNAME"
echo "Default admin credentials will be displayed in the container logs."
echo "\nTo view the logs: docker logs -f $CONTAINER_NAME"
echo "To get the admin password: docker exec $CONTAINER_NAME cat /root/.tuleap_passwd"
