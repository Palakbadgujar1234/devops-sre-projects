const request = require('supertest');
const app = require('../app');

describe('Application Tests', () => {
    
    describe('GET /', () => {
        it('should return 200 OK', async () => {
            const response = await request(app).get('/');
            expect(response.status).toBe(200);
        });

        it('should return JSON', async () => {
            const response = await request(app).get('/');
            expect(response.type).toBe('application/json');
        });

        it('should contain message', async () => {
            const response = await request(app).get('/');
            expect(response.body).toHaveProperty('message');
        });

        it('should contain version', async () => {
            const response = await request(app).get('/');
            expect(response.body).toHaveProperty('version');
        });

        it('should contain timestamp', async () => {
            const response = await request(app).get('/');
            expect(response.body).toHaveProperty('timestamp');
        });
    });

    describe('GET /health', () => {
        it('should return 200 OK', async () => {
            const response = await request(app).get('/health');
            expect(response.status).toBe(200);
        });

        it('should return healthy status', async () => {
            const response = await request(app).get('/health');
            expect(response.body.status).toBe('healthy');
        });

        it('should include uptime', async () => {
            const response = await request(app).get('/health');
            expect(response.body).toHaveProperty('uptime');
            expect(typeof response.body.uptime).toBe('number');
        });

        it('should include timestamp', async () => {
            const response = await request(app).get('/health');
            expect(response.body).toHaveProperty('timestamp');
        });
    });

    describe('GET /ready', () => {
        it('should return 200 OK', async () => {
            const response = await request(app).get('/ready');
            expect(response.status).toBe(200);
        });

        it('should return ready status', async () => {
            const response = await request(app).get('/ready');
            expect(response.body.status).toBe('ready');
        });

        it('should include timestamp', async () => {
            const response = await request(app).get('/ready');
            expect(response.body).toHaveProperty('timestamp');
        });
    });

    describe('GET /api/info', () => {
        it('should return 200 OK', async () => {
            const response = await request(app).get('/api/info');
            expect(response.status).toBe(200);
        });

        it('should return app information', async () => {
            const response = await request(app).get('/api/info');
            expect(response.body).toHaveProperty('app');
            expect(response.body).toHaveProperty('version');
            expect(response.body).toHaveProperty('description');
        });

        it('should list endpoints', async () => {
            const response = await request(app).get('/api/info');
            expect(response.body.endpoints).toBeInstanceOf(Array);
            expect(response.body.endpoints.length).toBeGreaterThan(0);
        });

        it('should have correct endpoint structure', async () => {
            const response = await request(app).get('/api/info');
            const endpoint = response.body.endpoints[0];
            expect(endpoint).toHaveProperty('path');
            expect(endpoint).toHaveProperty('method');
            expect(endpoint).toHaveProperty('description');
        });
    });

    describe('GET /nonexistent', () => {
        it('should return 404', async () => {
            const response = await request(app).get('/nonexistent');
            expect(response.status).toBe(404);
        });

        it('should return error message', async () => {
            const response = await request(app).get('/nonexistent');
            expect(response.body).toHaveProperty('error');
            expect(response.body.error).toBe('Not Found');
        });

        it('should include requested path', async () => {
            const response = await request(app).get('/nonexistent');
            expect(response.body).toHaveProperty('path');
            expect(response.body.path).toBe('/nonexistent');
        });
    });
});

// Made with Bob
