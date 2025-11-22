import sql from "mssql";
import dotenv from "dotenv";

dotenv.config();

const config = {
  user: process.env.DB_USER || "sa",
  password: process.env.DB_PASS || "Segura2025!",
  server: process.env.DB_HOST || process.env.DB_SERVER || "127.0.0.1",
  database: process.env.DB_NAME || "bd_dicri_evidencias",
  port: parseInt(process.env.DB_PORT || "1433", 10),
  options: {
    encrypt: false,
    trustServerCertificate: true,
  },
  pool: {
    max: 10,
    min: 0,
    idleTimeoutMillis: 30000,
  },
};

// Crear pool de conexión
export const poolPromise = new sql.ConnectionPool(config)
  .connect()
  .then((pool) => {
    console.log("✅ Conectado a SQL Server");
    return pool;
  })
  .catch((err) => {
    console.error("❌ Error al conectar a SQL Server:", err);
    throw err;
  });

// Exportar sql por si quieres ejecutar consultas directas
export { sql };
