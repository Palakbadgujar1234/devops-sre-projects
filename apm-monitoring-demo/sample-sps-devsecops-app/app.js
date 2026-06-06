const http = require('http');

const port = process.env.PORT || 8080;

const server = http.createServer((request, response) => {
  if (request.url === '/health') {
    response.writeHead(200, { 'Content-Type': 'application/json' });
    response.end(JSON.stringify({ status: 'ok' }));
    return;
  }

  response.writeHead(200, { 'Content-Type': 'text/plain' });
  response.end('Hello from sample SPS DevSecOps app\n');
});

server.listen(port, () => {
  console.log(`Server is running on port ${port}`);
});

// Made with Bob
