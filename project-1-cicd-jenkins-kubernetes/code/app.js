// Import Express framework
const express = require('express');

// Create Express application
const app = express();

// Define port (use environment variable or default to 3000)
const PORT = process.env.PORT || 3000;

// Health check endpoint (for Kubernetes liveness probe)
app.get('/health', (req, res) => {
    res.status(200).json({
        status: 'healthy',
        timestamp: new Date().toISOString(),
        uptime: process.uptime()
    });
});

// Readiness check endpoint (for Kubernetes readiness probe)
app.get('/ready', (req, res) => {
    res.status(200).json({
        status: 'ready',
        timestamp: new Date().toISOString()
    });
});

// Main application endpoint
app.get('/', (req, res) => {
    res.json({
        message: 'Hello from CI/CD Pipeline!',
        version: process.env.APP_VERSION || '1.0.0',
        environment: process.env.NODE_ENV || 'development',
        timestamp: new Date().toISOString()
    });
});

// API endpoint example
app.get('/api/info', (req, res) => {
    res.json({
        app: 'myapp',
        version: '1.0.0',
        description: 'CI/CD Demo Application',
        endpoints: [
            { path: '/', method: 'GET', description: 'Main endpoint' },
            { path: '/health', method: 'GET', description: 'Health check' },
            { path: '/ready', method: 'GET', description: 'Readiness check' },
            { path: '/api/info', method: 'GET', description: 'API information' }
        ]
    });
});

// Error handling middleware
app.use((err, req, res, next) => {
    console.error('Error:', err);
    res.status(500).json({
        error: 'Internal Server Error',
        message: err.message
    });
});

// 404 handler
app.use((req, res) => {
    res.status(404).json({
        error: 'Not Found',
        path: req.path
    });
});

// Start server
const server = app.listen(PORT, '0.0.0.0', () => {
    console.log(`Server running on port ${PORT}`);
    console.log(`Environment: ${process.env.NODE_ENV || 'development'}`);
    console.log(`Health check: http://localhost:${PORT}/health`);
});

// Graceful shutdown
process.on('SIGTERM', () => {
    console.log('SIGTERM received, shutting down gracefully');
    server.close(() => {
        console.log('Server closed');
        process.exit(0);
    });
});

// Export for testing
module.exports = app;

// Made with Bob
