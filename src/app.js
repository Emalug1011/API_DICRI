import express from "express";
import cors from "cors";
import swaggerUi from "swagger-ui-express";
import YAML from "yamljs";
import routes from "./routes/index.js";
import { googleRequestLogger } from "./middleware/googleLogging.middleware.js";
import { errorHandler } from "./middleware/errorHandler.js";

const app = express();

// Middlewares
app.use(cors());
app.use(express.json());
app.use(googleRequestLogger);

// Cargar Swagger (archivo está en la raíz del proyecto)
const swaggerDocument = YAML.load("swagger.yaml");

// URL donde se mostrará Swagger UI
app.use("/api-docs", swaggerUi.serve, swaggerUi.setup(swaggerDocument));

// Ruta de prueba
app.get("/ping", (req, res) => {
    res.json({ message: "pong" });
});

// Registrar rutas del proyecto (todas bajo /api)
app.use("/api/v1", routes);

// Middleware final para manejar errores
app.use(errorHandler);

export default app;
