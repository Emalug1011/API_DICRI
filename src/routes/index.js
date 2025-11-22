import { Router } from "express";
import * as expedientes from "../controllers/expedientes.controller.js";
import * as indicios from "../controllers/indicios.controller.js";

const router = Router();

router.post("/expedientes", expedientes.crearExpediente);
router.post("/expedientes/:id/indicios", indicios.crearIndicio);
router.put("/expedientes/:id/estado", expedientes.cambiarEstado);

export default router;
