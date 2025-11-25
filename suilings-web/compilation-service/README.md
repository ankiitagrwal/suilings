# Suilings Compilation Service

Backend service for compiling Sui Move code. This service runs the Sui CLI to compile and test Move code submitted from the frontend.

## Architecture

- **Express.js** - REST API server
- **Sui CLI** - Move language compiler
- **Docker** - Containerized deployment
- **AWS EC2** - Hosting platform

## Local Development

### Prerequisites
- Node.js 18+
- Sui CLI installed locally
- Access to parent `runner-crate` directory

### Setup

```bash
# Install dependencies
npm install

# Run in development mode
npm run dev

# Test the server
curl http://localhost:3001/health
```

### Test Compilation

```bash
curl -X POST http://localhost:3001/api/compile \
  -H "Content-Type: application/json" \
  -d '{
    "code": "module suilings::test { public fun main() {} }",
    "mode": "build"
  }'
```

## Docker Deployment

### Build Image

**Important:** Build from the `suilings` root directory (parent of suilings-web)

```bash
# Navigate to suilings root directory
cd suilings

# Build the Docker image
docker build -t suilings-backend -f suilings-web/compilation-service/Dockerfile .
```

The Dockerfile uses `suilings` (repository root) as the build context, allowing access to both `suilings-web/compilation-service/` and `runner-crate/`.

### Run Container

```bash
docker run -p 3001:3001 suilings-backend
```

### Test

```bash
curl http://localhost:3001/health
```

## AWS EC2 Deployment

### Quick Deploy

From the repository root:

```bash
./deploy.sh
```

This will:
1. Build Docker image for EC2 (AMD64)
2. Push to Docker Hub
3. Deploy to EC2 instance
4. Verify health

### Manual Deployment

```bash
# Build for EC2
docker build --platform linux/amd64 \
  -f suilings-web/compilation-service/Dockerfile \
  -t ankiitagrwal/suilings:latest .

# Push to Docker Hub
docker push ankiitagrwal/suilings:latest

# SSH to EC2 and pull
ssh -i MyEC2KeyPair.pem ubuntu@3.213.0.115 << 'EOF'
  docker pull ankiitagrwal/suilings:latest
  docker stop suilings-backend || true
  docker rm suilings-backend || true
  docker run -d --name suilings-backend -p 3006:3001 ankiitagrwal/suilings:latest
EOF

# Verify
curl http://3.213.0.115:3006/health
```

### EC2 Configuration

- **Instance:** AWS EC2 (Ubuntu)
- **IP:** 3.213.0.115
- **Port:** 3006 (external) → 3001 (container)
- **URL:** http://3.213.0.115:3006

## API Endpoints

### `GET /health`

Health check endpoint.

**Response:**
```json
{
  "status": "ok",
  "sui_version": "sui 1.x.x",
  "timestamp": "2025-01-01T00:00:00.000Z"
}
```

### `POST /api/compile`

Compile Sui Move code.

**Request:**
```json
{
  "code": "module suilings::test { public fun main() {} }",
  "mode": "build" // or "test"
}
```

**Response (Success):**
```json
{
  "success": true,
  "output": "Compilation output...",
  "errors": [],
  "duration": 1234
}
```

**Response (Failure):**
```json
{
  "success": false,
  "output": "",
  "errors": ["Error message..."],
  "duration": 567
}
```

## Security

- **Rate Limiting:** 10 requests per minute per IP
- **CORS:** Restricted to allowed origins
- **Code Size Limit:** 100KB max
- **Timeout:** 30 seconds max
- **Non-root User:** Runs as `appuser` in Docker

## Monitoring

### Logs

**Local Docker:**
```bash
docker logs suilings-backend
```

**EC2 Docker:**
```bash
ssh -i MyEC2KeyPair.pem ubuntu@3.213.0.115 "docker logs suilings-backend"
```

### Health Check

```bash
curl http://3.213.0.115:3006/health
```

## Troubleshooting

### Sui CLI Not Found

Check if Sui is installed in container:
```bash
docker exec -it <container> sui --version
```

### Permission Errors

Ensure files are owned by `appuser`:
```bash
docker exec -it <container> ls -la /app
```

### Build Failures

Check Docker build logs:
```bash
docker build -t suilings-backend -f compilation-service/Dockerfile . --progress=plain
```

## Cost Estimates

- **AWS EC2:** ~$10-20/month (t3.medium or similar)
- **Data Transfer:** Minimal for compilation service

## Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `PORT` | Server port | 3001 |
| `NODE_ENV` | Environment | development |
| `ALLOWED_ORIGINS` | CORS origins | localhost:3000 |

## Support

For issues or questions, open an issue on GitHub.

