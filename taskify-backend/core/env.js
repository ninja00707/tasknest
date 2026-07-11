const path = require('path');
const fs = require('fs');

const NODE_ENV = process.env.NODE_ENV || 'development';

const envFiles = [
  `.env.${NODE_ENV}.local`,
  `.env.${NODE_ENV}`,
  '.env.local',
  '.env',
];

for (const file of envFiles) {
  const fullPath = path.resolve(__dirname, '..', file);
  if (fs.existsSync(fullPath)) {
    require('dotenv').config({ path: fullPath });
    break;
  }
}

function isProduction() {
  return NODE_ENV === 'production';
}

function isDevelopment() {
  return NODE_ENV === 'development';
}

module.exports = { NODE_ENV, isProduction, isDevelopment };
