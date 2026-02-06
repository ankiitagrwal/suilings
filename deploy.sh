#!/bin/bash
# Complete deployment script: Build Docker + Deploy to EC2
# Run this when you update backend code

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
EC2_HOST="3.213.0.115"
EC2_USER="ubuntu"
SSH_KEY="/Users/ankit.agrawal/projects/block-c/sui/suilings/MyEC2KeyPair.pem"
IMAGE_NAME="ankiitagrwal/suilings"
IMAGE_TAG="latest"
CONTAINER_NAME="suilings-backend"

echo -e "${BLUE}╔═══════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║         Build Docker + Deploy to EC2                       ║${NC}"
echo -e "${BLUE}╔═══════════════════════════════════════════════════════════╗${NC}"
echo ""

# Step 0: Verify Move.toml is correct
echo -e "${YELLOW}[0/4] Verifying Move.toml configuration...${NC}"
if grep -q "Sui.*=.*{.*git" runner-crate/Move.toml 2>/dev/null; then
    echo -e "${RED}❌ Error: Move.toml has explicit Sui dependency!${NC}"
    echo -e "${RED}   This will cause compilation errors in production.${NC}"
    echo ""
    echo "Run this to fix:"
    echo "  ./fix-production-sui.sh"
    exit 1
fi
echo -e "${GREEN}✅ Move.toml is correct${NC}"
echo ""

# Step 1: Build Docker for EC2 (AMD64)
echo -e "${YELLOW}[1/4] Building Docker image for EC2 (AMD64)...${NC}"
echo "This takes 5-10 minutes..."
echo "Building with updated Move.toml (no explicit Sui dependency)"
echo ""

docker build \
    --platform linux/amd64 \
    -f suilings-web/compilation-service/Dockerfile \
    -t ${IMAGE_NAME}:${IMAGE_TAG} \
    . || {
    echo -e "${RED}❌ Build failed${NC}"
    exit 1
}

echo -e "${GREEN}✅ Build complete${NC}"
echo ""

# Step 2: Push to Docker Hub
echo -e "${YELLOW}[2/4] Pushing to Docker Hub...${NC}"
docker push ${IMAGE_NAME}:${IMAGE_TAG} || {
    echo -e "${RED}❌ Push failed. Run 'docker login' first${NC}"
    exit 1
}
echo -e "${GREEN}✅ Pushed${NC}"
echo ""

# Step 3: Deploy to EC2
echo -e "${YELLOW}[3/4] Deploying to EC2...${NC}"
if [ -n "$SSH_KEY" ]; then
    SSH_CMD="ssh -i $SSH_KEY ${EC2_USER}@${EC2_HOST}"
else
    SSH_CMD="ssh ${EC2_USER}@${EC2_HOST}"
fi

$SSH_CMD << ENDSSH
    echo "Pulling latest image..."
    docker pull ${IMAGE_NAME}:${IMAGE_TAG}
    
    echo "Stopping old container..."
    docker stop ${CONTAINER_NAME} 2>/dev/null || true
    docker rm ${CONTAINER_NAME} 2>/dev/null || true
    
    echo "Clearing old Sui framework cache..."
    rm -rf ~/.move/https___github_com_MystenLabs_sui_mainnet 2>/dev/null || true
    
    echo "Starting new container..."
    docker run -d \
        --name ${CONTAINER_NAME} \
        -p 3006:3001 \
        --restart unless-stopped \
        ${IMAGE_NAME}:${IMAGE_TAG}
    
    sleep 10
    echo "Checking container logs..."
    docker logs ${CONTAINER_NAME} 2>&1 | tail -20
    
    echo ""
    echo "Checking health..."
    curl -s http://localhost:3006/health | head -20
ENDSSH

echo ""
echo -e "${YELLOW}[4/4] Verifying deployment...${NC}"
sleep 5
echo "Testing health endpoint..."
curl -s http://${EC2_HOST}:3006/health || {
    echo -e "${RED}❌ Health check failed${NC}"
    if [ -n "$SSH_KEY" ]; then
        echo "Check logs: ssh -i $SSH_KEY ${EC2_USER}@${EC2_HOST} 'docker logs ${CONTAINER_NAME}'"
    else
        echo "Check logs: ssh ${EC2_USER}@${EC2_HOST} 'docker logs ${CONTAINER_NAME}'"
    fi
    exit 1
}

echo ""
echo -e "${GREEN}╔═══════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║            Deployment Complete! ✅                         ║${NC}"
echo -e "${GREEN}╔═══════════════════════════════════════════════════════════╗${NC}"
echo ""
echo "Service: http://${EC2_HOST}:3006"
echo "Health: http://${EC2_HOST}:3006/health"
echo ""

