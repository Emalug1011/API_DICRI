import dotenv from "dotenv";
dotenv.config();
import { Logging } from "@google-cloud/logging";

const logging = new Logging({
    projectId: process.env.GCP_PROJECT_ID,
    keyFilename: process.env.GOOGLE_APPLICATION_CREDENTIALS,
});

const log = logging.log("dicri-api-logs");

// Mapa de severidades permitidas por Google
const SEVERITIES = {
    INFO: "INFO",
    ERROR: "ERROR",
    WARNING: "WARNING",
    CRITICAL: "CRITICAL",
    DEBUG: "DEBUG"
};

export const writeLog = async (severity, message, data = {}) => {
    try {

        // Normalizar severidad
        const sev = SEVERITIES[severity.toUpperCase()] || "ERROR";

        const entry = log.entry(
            { resource: { type: "global" }, severity: sev },
            {

                message,
                ...data,
                timestamp: new Date()
            }
        );

        await log.write(entry);
        

    } catch (err) {
        console.error("Error enviando log a Google:", err.message);
    }
};
