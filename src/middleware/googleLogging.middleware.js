import { writeLog } from "../utils/googleLogger.js";

export const googleRequestLogger = (req, res, next) => {
    const startTime = Date.now();

    res.on("finish", () => {
        const durationMs = Date.now() - startTime;

        writeLog("INFO", "API Request", {
            method: req.method,
            endpoint: req.originalUrl,
            statusCode: res.statusCode,
            duration_ms: durationMs,
            ip: req.headers["x-forwarded-for"] || req.ip,
            usuario: req.usuario?.id_usuario || "No autenticado",
            rol: req.usuario?.rol || "N/A",
            body: req.method !== "GET" ? req.body : undefined
        });
    });

    next();
};
