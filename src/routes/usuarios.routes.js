import { Router } from "express";
import {
    crearUsuario,
    obtenerUsuarios,
    obtenerUsuarioPorId,
    actualizarUsuario,
    cambiarContrasenia
    
} from "../controllers/usuarios.controller.js";

import { verificarToken } from "../middleware/auth.middleware.js";

const router = Router();

router.post("/", verificarToken ,  crearUsuario);
router.get("/", verificarToken , obtenerUsuarios);
router.get("/:id", verificarToken ,  obtenerUsuarioPorId);
router.put("/:id", verificarToken , actualizarUsuario);
router.put("/:id/password", verificarToken , cambiarContrasenia);


export default router;
