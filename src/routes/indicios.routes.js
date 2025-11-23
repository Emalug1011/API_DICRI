import { Router } from "express";
import { obtenerIndiciosPorExpediente, crearIndicio , actualizarEstadoIndicio } from "../controllers/indicios.controller.js";
import { verificarToken } from "../middleware/auth.middleware.js";

const router = Router();


router.use(verificarToken); 
// Obtener indicios activos del expediente
router.get("/expedientes/:id/indicios", obtenerIndiciosPorExpediente);

// Crear indicio
router.post("/expedientes/:id/indicios", crearIndicio);

// Cambiar estado del indicio
router.put("/indicios/:id/estado", actualizarEstadoIndicio);

export default router;
