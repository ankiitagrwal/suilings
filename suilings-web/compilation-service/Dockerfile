# Stage 1: Build Sui CLI
FROM rust:1.75-slim as sui-builder

# Install dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    build-essential \
    libssl-dev \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

# Clone and build Sui
WORKDIR /build
RUN git clone https://github.com/MystenLabs/sui.git
WORKDIR /build/sui
RUN cargo build --release --bin sui

# Stage 2: Runtime
FROM node:18-slim

# Install runtime dependencies
RUN apt-get update && apt-get install -y \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Copy Sui binary from builder
COPY --from=sui-builder /build/sui/target/release/sui /usr/local/bin/sui

# Verify Sui installation
RUN sui --version

# Create app directory
WORKDIR /app

# Create non-root user
RUN useradd -m -u 1001 appuser

# Copy package files
COPY suilings-web/compilation-service/package*.json ./

# Install dependencies
RUN npm ci --only=production && \
    npm cache clean --force

# Copy application code
COPY suilings-web/compilation-service/server.js ./

# Copy runner-crate (at same level as suilings-web)
COPY runner-crate ./runner-crate

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

