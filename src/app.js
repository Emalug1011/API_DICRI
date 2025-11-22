import express from "express";
import cors from "cors";
import swaggerUi from "swagger-ui-express";
import YAML from "yamljs";
import routes from "./routes/index.js";

const app = express();

// Middlewares
app.use(cors());
app.use(express.json());

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

export default app;
