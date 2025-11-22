import { Router } from "express";
import {
  crearExpediente,
  cambiarEstado,
  obtenerExpediente,
  listarExpedientes
} from "../controllers/expedientes.controller.js";

import { crearIndicio } from "../controllers/indicios.controller.js";
import { verificarToken } from "../middleware/auth.middleware.js";

const router = Router();

// PROTEGER TODAS LAS RUTAS
router.use(verificarToken);

// Expedientes
router.post("/", crearExpediente);
router.get("/", listarExpedientes);
router.get("/:id", obtenerExpediente);
router.put("/:id/estado", cambiarEstado);

// Indicios dentro del expediente
router.post("/:id/indicios", crearIndicio);

export default router;
