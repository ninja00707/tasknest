#!/usr/bin/env node

const http = require('http');
require('./core/env');
const { setupSocket } = require('./core/socket');

process.on('unhandledRejection', (reason, promise) => {
  console.error('Unhandled Rejection at:', promise, 'reason:', reason);
});
process.on('uncaughtException', (err) => {
  console.error('Uncaught Exception:', err);
});

function startServer(app) {
  const port = normalizePort(process.env.PORT || '3000');
  app.set('port', port);

  const server = http.createServer(app);
  const io = setupSocket(server);
  app.set('io', io);

  server.listen(port);
  server.on('error', (error) => onError(error, port));
  server.on('listening', () => {
    onListening(server);
    // Start the event outbox processor after server is listening
    const outboxProcessor = require('./core/outboxProcessor');
    outboxProcessor.start();
  });

  return server;
}

function normalizePort(val) {
  const port = parseInt(val, 10);
  if (isNaN(port)) return val;
  if (port >= 0) return port;
  return false;
}

function onError(error, port) {
  if (error.syscall !== 'listen') throw error;
  const bind = typeof port === 'string' ? 'Pipe ' + port : 'Port ' + port;
  switch (error.code) {
    case 'EACCES':
      console.error(bind + ' requires elevated privileges');
      process.exit(1);
      break;
    case 'EADDRINUSE':
      console.error(bind + ' is already in use');
      process.exit(1);
      break;
    default:
      throw error;
  }
}

function onListening(server) {
  const addr = server.address();
  const bind = typeof addr === 'string' ? 'pipe ' + addr : 'port ' + addr.port;
  console.log(`Worker ${process.pid} listening on ${bind} [${process.env.NODE_ENV || 'development'}]`);
}

module.exports = { startServer, normalizePort, onError };
