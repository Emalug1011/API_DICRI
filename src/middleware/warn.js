import { writeLog } from "../utils/googleLogger.js";

export const warn = (message, req) => {
    writeLog("WARNING", message, {
        method: req.method,
        endpoint: req.originalUrl,
        usuario: req.usuario?.id_usuario || "No autenticado",
        body: req.body
    });
};
