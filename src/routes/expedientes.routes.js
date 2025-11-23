import { Router } from "express";
import {
  crearExpediente,
  cambiarEstado,
  obtenerExpediente,
  listarExpedientes,
  obtenerExpedientesPorUsuario,
  obtenerAuditoriaExpediente,
  resumenEstados 
} from "../controllers/expedientes.controller.js";

import { crearIndicio } from "../controllers/indicios.controller.js";
import { verificarToken } from "../middleware/auth.middleware.js";

const router = Router();

// ------------------------------------------------------
//  PROTEGER TODAS LAS RUTAS
// ------------------------------------------------------
router.use(verificarToken);

// ------------------------------------------------------
//  BANDEJA DEL USUARIO
// ------------------------------------------------------
router.get("/mis-expedientes", obtenerExpedientesPorUsuario);

// ------------------------------------------------------
//  EXPEDIENTES
// ------------------------------------------------------
router.get("/resumen", resumenEstados);
router.post("/", crearExpediente);
router.get("/filter", listarExpedientes);
router.get("/:id", obtenerExpediente);


// Cambio de estado
router.put("/:id/estado", cambiarEstado);

// ------------------------------------------------------
//  AUDITORÍA DE EXPEDIENTE
// ------------------------------------------------------
router.get("/:id/auditoria", obtenerAuditoriaExpediente);

// ------------------------------------------------------
//  INDICIOS DEL EXPEDIENTE
// ------------------------------------------------------
router.post("/:id/indicios", crearIndicio);

export default router;
