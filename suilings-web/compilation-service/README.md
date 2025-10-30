# Suilings Compilation Service

Backend service for compiling Sui Move code. This service runs the Sui CLI to compile and test Move code submitted from the frontend.

## Architecture

- **Express.js** - REST API server
- **Sui CLI** - Move language compiler
- **Docker** - Containerized deployment
- **Railway/Fly.io** - Hosting platform

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

## Railway Deployment

### Option A: Using Railway CLI

```bash
# Install Railway CLI
npm install -g @railway/cli

# Login
railway login

# Link project
railway link

# Deploy
cd compilation-service
railway up
```

### Option B: Using GitHub Integration

1. **Connect Repository**
   - Go to Railway dashboard
   - Create new project
   - Connect GitHub repo

2. **Configure Service**
   - Root Directory: `` (empty - use repository root)
   - Dockerfile Path: `suilings-web/compilation-service/Dockerfile`
   - Watch Paths: `suilings-web/compilation-service/**`, `runner-crate/**`

3. **Environment Variables** (Optional)
   ```
   PORT=3001
   NODE_ENV=production
   ALLOWED_ORIGINS=https://suilings.vercel.app,https://your-domain.com
   ```

4. **Deploy**
   - Railway auto-deploys on push to main branch
   - Get deployment URL: `https://your-service.up.railway.app`

### Railway Configuration File

The `railway.toml` file is located at the repository root (`suilings/railway.toml`), not in this directory.

Content (already created at repository root):

```toml
[build]
builder = "DOCKERFILE"
dockerfilePath = "suilings-web/compilation-service/Dockerfile"
watchPatterns = ["suilings-web/compilation-service/**", "runner-crate/**"]

[deploy]
startCommand = "npm start"
healthcheckPath = "/health"
healthcheckTimeout = 30
restartPolicyType = "ON_FAILURE"
restartPolicyMaxRetries = 5
```

This configuration tells Railway to:
- Build from repository root
- Use the Dockerfile in compilation-service
- Watch for changes in both backend code and runner-crate

## Fly.io Deployment

### Setup

```bash
# Install flyctl
curl -L https://fly.io/install.sh | sh

# Login
fly auth login

# Initialize (from compilation-service directory)
cd compilation-service
fly launch
```

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

**Railway:**
```bash
railway logs
```

**Docker:**
```bash
docker logs <container-id>
```

### Metrics

Check health endpoint regularly:
```bash
curl https://your-backend.railway.app/health
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

- **Railway Hobby:** $5/month
- **Fly.io Free Tier:** 3 VMs (256MB each) - FREE
- **Railway Pro:** $20/month (if needed)

## Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `PORT` | Server port | 3001 |
| `NODE_ENV` | Environment | development |
| `ALLOWED_ORIGINS` | CORS origins | localhost:3000 |

## Support

For issues or questions, open an issue on GitHub.

