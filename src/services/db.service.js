const sql = require('mssql');
require('dotenv').config();
const config = {
  user: process.env.DB_USER || 'sa',
  password: process.env.DB_PASS || 'Segura2025!',
  server: process.env.DB_HOST || process.env.DB_SERVER || '127.0.0.1',
  database: process.env.DB_NAME || 'bd_dicri_evidencias',
  port: parseInt(process.env.DB_PORT || '1433', 10),
  options: { encrypt: false, trustServerCertificate: true },
  pool: { max: 10, min: 0, idleTimeoutMillis: 30000 }
};
const poolPromise = new sql.ConnectionPool(config).connect().then(p => p).catch(e => { console.error(e); throw e; });
module.exports = { sql, poolPromise };
