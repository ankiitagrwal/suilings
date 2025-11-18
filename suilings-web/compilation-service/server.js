// Move 2024 - Using automatic dependency injection
const express = require('express');
const cors = require('cors');
const rateLimit = require('express-rate-limit');
const { exec } = require('child_process');
const { promisify } = require('util');
const fs = require('fs').promises;
const path = require('path');

const execAsync = promisify(exec);

const app = express();
const PORT = process.env.PORT || 3001;

// Configuration
const RUNNER_CRATE_PATH = process.env.RUNNER_CRATE_PATH || path.join(__dirname, 'runner-crate');
const MAIN_MOVE_PATH = path.join(RUNNER_CRATE_PATH, 'sources', 'main.move');

// Middleware
app.use(express.json({ limit: '1mb' }));

// CORS configuration
const corsOptions = {
  origin: process.env.ALLOWED_ORIGINS 
    ? process.env.ALLOWED_ORIGINS.split(',')
    : ['http://localhost:3000', 'https://suilings.vercel.app'],
  methods: ['GET', 'POST'],
  credentials: true,
};
app.use(cors(corsOptions));

// Rate limiting
const limiter = rateLimit({
  windowMs: 1 * 60 * 1000, // 1 minute
  max: 10, // 10 requests per minute per IP
  message: 'Too many compilation requests, please try again later.',
  standardHeaders: true,
  legacyHeaders: false,
});

// Apply rate limiting to compilation endpoint
app.use('/api/compile', limiter);

// Health check endpoint
app.get('/health', async (req, res) => {
  try {
    // Check if Sui CLI is available
    const { stdout } = await execAsync('sui --version');
    res.json({
      status: 'ok',
      sui_version: stdout.trim(),
      timestamp: new Date().toISOString(),
    });
  } catch (error) {
    res.status(500).json({
      status: 'error',
      message: 'Sui CLI not available',
      error: error.message,
    });
  }
});

// Warmup/ping endpoint - keeps compiler warm
app.get('/api/ping', async (req, res) => {
  const startTime = Date.now();
  try {
    // Quick compilation to keep compiler warm
    const warmupCode = `module suilings::ping {
    public fun pong(): u64 { 42 }
}`;
    await fs.writeFile(MAIN_MOVE_PATH, warmupCode, 'utf-8');
    await execAsync(`sui move build --path ${RUNNER_CRATE_PATH}`, {
      cwd: RUNNER_CRATE_PATH,
      timeout: 10000,
    });
    
    res.json({
      status: 'warm',
      duration: Date.now() - startTime,
      timestamp: new Date().toISOString(),
    });
  } catch (error) {
    res.json({
      status: 'cold',
      duration: Date.now() - startTime,
      timestamp: new Date().toISOString(),
    });
  }
});

// Compilation endpoint
app.post('/api/compile', async (req, res) => {
  const startTime = Date.now();
  
  try {
    const { code, mode } = req.body;

    // Validation
    if (!code || !mode) {
      return res.status(400).json({
        success: false,
        output: '',
        errors: ['Missing required fields: code and mode'],
        duration: Date.now() - startTime,
      });
    }

    if (!['build', 'test'].includes(mode)) {
      return res.status(400).json({
        success: false,
        output: '',
        errors: ['Invalid mode. Must be "build" or "test"'],
        duration: Date.now() - startTime,
      });
    }

    if (code.length > 100000) { // 100KB limit
      return res.status(400).json({
        success: false,
        output: '',
        errors: ['Code size exceeds limit (100KB)'],
        duration: Date.now() - startTime,
      });
    }

    console.log(`[${new Date().toISOString()}] Compilation request - Mode: ${mode}, Code length: ${code.length}`);

    // Write user's code to runner-crate/sources/main.move
    await fs.writeFile(MAIN_MOVE_PATH, code, 'utf-8');

    // Build command
    const command = mode === 'test'
      ? `sui move test --path ${RUNNER_CRATE_PATH}`
      : `sui move build --path ${RUNNER_CRATE_PATH}`;

    try {
      // Execute compilation
      const { stdout, stderr } = await execAsync(command, {
        cwd: RUNNER_CRATE_PATH,
        timeout: 30000, // 30 second timeout
        maxBuffer: 1024 * 1024, // 1MB buffer
      });

      const duration = Date.now() - startTime;

      console.log(`[${new Date().toISOString()}] Compilation successful - Duration: ${duration}ms`);

      // Success response
      return res.json({
        success: true,
        output: stdout || stderr || 'Compilation successful!',
        errors: [],
        duration,
      });

    } catch (error) {
      // Compilation failed (expected for incorrect code)
      const duration = Date.now() - startTime;
      const errorOutput = error.stderr || error.stdout || error.message;

      console.log(`[${new Date().toISOString()}] Compilation failed - Duration: ${duration}ms`);

      return res.json({
        success: false,
        output: '',
        errors: [errorOutput],
        duration,
      });
    }

  } catch (error) {
    // Unexpected server error
    const duration = Date.now() - startTime;
    console.error(`[${new Date().toISOString()}] Server error:`, error);

    return res.status(500).json({
      success: false,
      output: '',
      errors: [`Internal server error: ${error.message}`],
      duration,
    });
  }
});

// Root endpoint
app.get('/', (req, res) => {
  res.json({
    service: 'Suilings Compilation Service',
    version: '1.0.0',
    endpoints: {
      health: 'GET /health',
      compile: 'POST /api/compile',
    },
  });
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({
    error: 'Not Found',
    message: `Cannot ${req.method} ${req.path}`,
  });
});

// Error handler
app.use((err, req, res, next) => {
  console.error('Unhandled error:', err);
  res.status(500).json({
    error: 'Internal Server Error',
    message: err.message,
  });
});

// Startup cleanup - ensure clean state and pre-warm compiler
async function startup() {
  try {
    // Verify runner-crate exists
    await fs.access(RUNNER_CRATE_PATH);
    await fs.access(path.join(RUNNER_CRATE_PATH, 'sources'));
    console.log('✅ Runner crate verified');
    
    // Pre-warm the compiler with a simple test
    console.log('🔥 Pre-warming Sui compiler...');
    const warmupCode = `module suilings::warmup {
    public fun hello(): u64 {
        42
    }
}`;
    
    await fs.writeFile(MAIN_MOVE_PATH, warmupCode, 'utf-8');
    
    try {
      const { stdout } = await execAsync(`sui move build --path ${RUNNER_CRATE_PATH}`, {
        cwd: RUNNER_CRATE_PATH,
        timeout: 60000, // 60 second timeout for warmup
      });
      console.log('✅ Compiler pre-warmed successfully');
    } catch (error) {
      console.warn('⚠️ Compiler pre-warm failed (non-critical):', error.message);
    }
  } catch (error) {
    console.error('❌ Runner crate not found:', RUNNER_CRATE_PATH);
    process.exit(1);
  }
}

// Start server
startup().then(() => {
  const server = app.listen(PORT, '0.0.0.0', () => {
    console.log(`Suilings Compilation Service running on port ${PORT}`);
    console.log(`Runner crate path: ${RUNNER_CRATE_PATH}`);
    console.log(`Environment: ${process.env.NODE_ENV || 'development'}`);
  });

  // Graceful shutdown
  process.on('SIGTERM', () => {
    console.log('SIGTERM signal received: closing HTTP server');
    server.close(() => {
      console.log('HTTP server closed');
      process.exit(0);
    });
  });

  process.on('SIGINT', () => {
    console.log('SIGINT signal received: closing HTTP server');
    server.close(() => {
      console.log('HTTP server closed');
      process.exit(0);
    });
  });
}).catch(error => {
  console.error('Failed to start server:', error);
  process.exit(1);
});
