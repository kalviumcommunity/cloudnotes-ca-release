'use strict';

const http = require('node:http');

const host = process.env.HOST || '0.0.0.0';
const port = Number(process.env.PORT || 8080);
const mode = process.env.APP_MODE || 'development';

const server = http.createServer((req, res) => {
  res.setHeader('Content-Type', 'application/json');
  if (req.method === 'GET' && req.url.split('?')[0] === '/health') {
    res.writeHead(200);
    res.end(JSON.stringify({ status: 'ok', service: 'cloudnotes', mode }));
    return;
  }
  res.writeHead(404);
  res.end(JSON.stringify({ error: 'not_found' }));
});

server.listen(port, host, () => {
  console.log(`cloudnotes listening on ${host}:${port} (${mode})`);
});
