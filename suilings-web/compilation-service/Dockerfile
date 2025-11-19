# Dockerfile using Node.js base image with Sui CLI
# Fast and reliable - Node.js and npm pre-installed

FROM node:22-slim

# Install runtime dependencies
RUN apt-get update && apt-get install -y \
    ca-certificates \
    curl \
    git \
    && rm -rf /var/lib/apt/lists/*

# Install Sui using suiup (set as default automatically)
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
# Using locked dependency versions from Move.lock (testnet)
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

