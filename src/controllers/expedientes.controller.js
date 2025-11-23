import sql from "mssql";
import { poolPromise } from "../services/db.service.js";
import { writeLog } from "../utils/googleLogger.js";
import { warn } from "../middleware/warn.js";

/* ============================================================
   1. Crear expediente
   ============================================================ */
export const crearExpediente = async (req, res, next) => {
  try {
    const { codigo_expediente, descripcion } = req.body;
    const id_usuario = req.usuario.id_usuario; // del token

    const pool = await poolPromise;

    const result = await pool.request()
      .input("descripcion", sql.VarChar, descripcion)
      .input("id_usuario_tecnico", sql.Int, id_usuario)
      .output("nuevo_id", sql.Int)
      .output("codigo_generado", sql.VarChar)
      .execute("SP_CrearExpediente");

    writeLog("INFO", "Expediente creado exitosamente", {
      id_expediente: result.output.nuevo_id,
      usuario: id_usuario
    });

    res.status(201).json({
      message: "Expediente creado",
      codigo: result.output.codigo_generado,
      id_expediente: result.output.nuevo_id
    });

  } catch (error) {
    next(error);
    // console.error("Error crearExpediente:", error);
    // res.status(500).json({ message: "Error al crear expediente", error: error.message });
  }
};

/* ============================================================
   2. Cambiar estado del expediente (Revisión, Aprobación, Rechazo)
   ============================================================ */
export const cambiarEstado = async (req, res, next) => {
  try {
    const id_expediente = parseInt(req.params.id);
    const { id_estado_nuevo, comentario } = req.body;
    const id_usuario = req.usuario.id_usuario;

    const pool = await poolPromise;

    await pool.request()
      .input("id_expediente", sql.Int, id_expediente)
      .input("id_estado_nuevo", sql.Int, id_estado_nuevo)
      .input("id_usuario", sql.Int, id_usuario)
      .input("comentario", sql.VarChar, comentario || null)
      .execute("SP_CambiarEstadoExpediente");

    res.status(200).json({ message: "Estado actualizado con éxito" });

  } catch (error) {
    next(error);
    console.error("Error cambiarEstado:", error);

  }
};

/* ============================================================
   3. Obtener expediente completo (expediente + indicios + historial)
   ============================================================ */
export const obtenerExpediente = async (req, res, next) => {
  try {
    const id_expediente = parseInt(req.params.id);
    const pool = await poolPromise;

    const result = await pool.request()
      .input("id_expediente", sql.Int, id_expediente)
      .execute("SP_ObtenerExpediente");

    res.status(200).json({
      expediente: result.recordsets[0][0],
      indicios: result.recordsets[1],
      historial: result.recordsets[2]
    });

  } catch (error) {
    next(error);
    console.error("Error obtenerExpediente:", error);

  }
};

/* ============================================================
   4. Listar expedientes (filtros por estado y fechas)
   ============================================================ */
export const listarExpedientes = async (req, res, next) => {
  try {
    const { estado, fecha_inicio, fecha_fin } = req.query;

    const pool = await poolPromise;

    const result = await pool.request()
      .input("estado", sql.Int, estado || null)
      .input("fecha_inicio", sql.Date, fecha_inicio || null)
      .input("fecha_fin", sql.Date, fecha_fin || null)
      .execute("SP_ListarExpedientes");

    res.status(200).json(result.recordset);

  } catch (error) {
    next(error);
    console.error("Error listarExpedientes:", error);
    res.status(500).json({ message: "Error al consultar expedientes", error: error.message });
  }
};

/* ============================================================
   5. Bandeja por usuario
   ============================================================ */
export const obtenerExpedientesPorUsuario = async (req, res, next) => {
  try {
    const id_usuario = req.usuario.id_usuario;
    console.log(11);

    const pool = await poolPromise;

    const result = await pool.request()
      .input("id_usuario", sql.Int, id_usuario)
      .execute("SP_ObtenerExpedientesPorUsuario");

    return res.status(200).json({
      message: "Expedientes cargados correctamente",
      expedientes: result.recordset
    });

  } catch (error) {

    console.error("Error obtenerExpedientesPorUsuario:", error);
    next(error);
  }
};


// ============================
// Obtener Auditoría del Expediente
// ============================
export const obtenerAuditoriaExpediente = async (req, res, next) => {
  try {
    const id_expediente = parseInt(req.params.id);

    const pool = await poolPromise;

    const result = await pool.request()
      .input("id_expediente", sql.Int, id_expediente)
      .execute("SP_ObtenerAuditoriaExpediente");

    return res.status(200).json({
      message: "Auditoría del expediente",
      auditoria: result.recordset
    });

  } catch (error) {
    return next(error);
  }
};


/* ============================================================
   6. Resumen de expedientes por estado
   ============================================================ */
export const resumenEstados = async (req, res, next) => {
  try {
    const pool = await poolPromise;

    const result = await pool.request()
      .execute("SP_ResumenExpedientesPorEstado");
    
    writeLog("INFO", "Resumen de expedientes por estado consultado.", {
      total_estados: result.recordset.length
    });

    return res.status(200).json({
      message: "Resumen de expedientes por estado",
      resumen: result.recordset
    });

  } catch (error) {
    console.error("Error resumenEstados:", error);
    return next(error);
  }
};
