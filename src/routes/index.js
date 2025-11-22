import { Router } from "express";

import authRoutes from "./auth.routes.js";
import usuariosRoutes from "./usuarios.routes.js";
import expedientesRoutes from "./expedientes.routes.js";
import indiciosRoutes from "./indicios.routes.js";

const router = Router();

router.use("/auth", authRoutes);
router.use("/usuarios", usuariosRoutes);
router.use("/expedientes", expedientesRoutes); 
router.use("", indiciosRoutes);   
 

export default router;
