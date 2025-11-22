import { writeLog } from "../utils/googleLogger.js";

export const errorHandler = (err, req, res, next) => {
    console.error("Error interno:", err);

    writeLog("ERROR", "Unhandled API Error", {
        method: req.method,
        endpoint: req.originalUrl,
        message: err.message,
        stack: err.stack,
        usuario: req.usuario?.id_usuario || "No autenticado",
        body: req.body
    });

    res.status(500).json({
        message: "Error en el servidor",
        error: err.message
    });
};
