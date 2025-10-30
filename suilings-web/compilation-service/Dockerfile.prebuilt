# Dockerfile using official suiup installer
# Fast and reliable - installs latest stable Sui

FROM ubuntu:24.04

# Install Node.js 22 and runtime dependencies
RUN apt-get update && apt-get install -y \
    ca-certificates \
    curl \
    git \
    && curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# Install suiup (the Sui installer)
RUN curl -sSfL https://raw.githubusercontent.com/MystenLabs/suiup/main/install.sh | sh

# Add suiup to PATH
ENV PATH="/root/.local/bin:${PATH}"

# Install Sui CLI
RUN suiup install sui

# Find and copy sui binary to global location (accessible by all users)
RUN SUI_PATH=$(find /root/.local/share/suiup/binaries -type f | head -1) && \
    cp $SUI_PATH /usr/local/bin/sui && \
    chmod 755 /usr/local/bin/sui

# Verify Sui installation
RUN sui --version

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
RUN cd /app/runner-crate && sui move build --skip-fetch-latest-git-deps || true

# Change ownership to non-root user
RUN chown -R appuser:appuser /app

# Switch to non-root user
USER appuser

# Expose port
EXPOSE 3001

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD node -e "require('http').get('http://localhost:3001/health', (r) => {process.exit(r.statusCode === 200 ? 0 : 1)})"

# Start server
CMD ["npm", "start"]

