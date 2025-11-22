import { Router } from "express";
import { crearIndicio } from "../controllers/indicios.controller.js";
import { verificarToken } from "../middleware/auth.middleware.js";

const router = Router();


router.use(verificarToken); 
router.post("/expedientes/:id/indicios", crearIndicio);

export default router;
