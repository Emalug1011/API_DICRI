import dotenv from "dotenv";
dotenv.config();   // ← ESTO ES OBLIGATORIO Y DEBE IR AL INICIO

import app from "./app.js";

const PORT = process.env.PORT || 3001;

app.listen(PORT, () => {
  console.log("Servidor corriendo en puerto", PORT);
  console.log("JWT_SECRET =", process.env.JWT_SECRET); // ← DEBUG TEMPORAL
  console.log(` Servidor corriendo en http://localhost:${PORT}`);
  console.log(` Swagger UI: http://localhost:${PORT}/api-docs`);  
});

 