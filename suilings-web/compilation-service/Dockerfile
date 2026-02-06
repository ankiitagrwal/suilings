# Dockerfile using Ubuntu 24.04 with Node.js and Sui CLI
# Ubuntu 24.04 provides GLIBC 2.39 required by Sui
#
# NETWORK CONFIGURATION - PROVEN WORKING IN PRODUCTION:
# - Sui CLI: testnet v1.61.1 (from suiup install sui)
# - Move Framework: mainnet (Move.toml rev = "mainnet")
# This hybrid setup is stable and tested - DO NOT CHANGE

FROM ubuntu:24.04

# Install Node.js 22 and npm
RUN apt-get update && apt-get install -y \
    curl \
    && curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y nodejs \
    && node --version && npm --version

# Install runtime dependencies
RUN apt-get update && apt-get install -y \
    ca-certificates \
    curl \
    git \
    && rm -rf /var/lib/apt/lists/*

# Install Sui CLI using suiup (installs testnet v1.61.1 by default)
# CLI version doesn't need to match framework - proven working!
RUN curl -sSfL https://raw.githubusercontent.com/MystenLabs/suiup/main/install.sh | sh && \
    export PATH="/root/.local/bin:${PATH}" && \
    echo "y" | suiup install sui && \
    cp /root/.local/bin/sui /usr/local/bin/sui && \
    chmod 755 /usr/local/bin/sui && \
    sui --version

# Create app directory
WORKDIR /app

# Create non-root user
RUN useradd -m -u 1001 appuser

# Setup Sui config for appuser (non-interactive)
RUN mkdir -p /home/appuser/.sui/sui_config && \
    echo "---" > /home/appuser/.sui/sui_config/client.yaml && \
    echo "keystore:" >> /home/appuser/.sui/sui_config/client.yaml && \
    echo "  File: ~/.sui/sui_config/sui.keystore" >> /home/appuser/.sui/sui_config/client.yaml && \
    echo "envs:" >> /home/appuser/.sui/sui_config/client.yaml && \
    echo "  - alias: testnet" >> /home/appuser/.sui/sui_config/client.yaml && \
    echo "    rpc: \"https://sui-testnet-rpc.publicnode.com\"" >> /home/appuser/.sui/sui_config/client.yaml && \
    echo "    ws: ~" >> /home/appuser/.sui/sui_config/client.yaml && \
    echo "active_env: testnet" >> /home/appuser/.sui/sui_config/client.yaml && \
    echo "active_address: ~" >> /home/appuser/.sui/sui_config/client.yaml && \
    touch /home/appuser/.sui/sui_config/sui.keystore && \
    chown -R appuser:appuser /home/appuser/.sui

# Copy package files from compilation-service directory
COPY suilings-web/compilation-service/package*.json ./

# Install dependencies
RUN npm ci --only=production && \
    npm cache clean --force

# Copy application code from compilation-service directory
COPY suilings-web/compilation-service/server.js ./

# Copy runner-crate from compilation-service directory
COPY suilings-web/compilation-service/runner-crate ./runner-crate

# Pre-fetch Sui dependencies during build (as root, before switching user)
# This prevents memory issues during runtime compilation
# Using mainnet framework (Move.toml) with testnet CLI - working config!
RUN cd /app/runner-crate && \
    rm -rf build && \
    sui move build

# Copy Move dependency cache to appuser's home directory
# This prevents re-downloading dependencies at runtime
RUN mkdir -p /home/appuser/.move && \
    cp -r /root/.move/* /home/appuser/.move/ 2>/dev/null || true

# Change ownership to non-root user
RUN chown -R appuser:appuser /app /home/appuser/.move

# Switch to non-root user
USER appuser

# Expose port
EXPOSE 3001

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD node -e "require('http').get('http://localhost:3001/health', (r) => {process.exit(r.statusCode === 200 ? 0 : 1)})"

# Start server
CMD ["npm", "start"]

