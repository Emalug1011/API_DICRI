import sql from "mssql";
import { poolPromise } from "../services/db.service.js";
import { writeLog } from "../utils/googleLogger.js";

/* ============================================================
   Crear indicio dentro de un expediente
   ============================================================ */
export const crearIndicio = async (req, res, next) => {
  try {
    const id_expediente = parseInt(req.params.id);
    const { descripcion, color, tamano, peso, ubicacion } = req.body;
    const id_usuario = req.usuario.id_usuario;

    const pool = await poolPromise;

    const result = await pool.request()
      .input("id_expediente", sql.Int, id_expediente)
      .input("descripcion", sql.VarChar, descripcion)
      .input("color", sql.VarChar, color)
      .input("tamano", sql.VarChar, tamano)
      .input("peso", sql.VarChar, peso)
      .input("ubicacion", sql.VarChar, ubicacion)
      .input("id_usuario_tecnico", sql.Int, id_usuario)
      .output("nuevo_id", sql.Int)
      .execute("SP_CrearIndicio");

    // Log exitoso
    writeLog("INFO", "Indicio creado exitosamente", {
      id_indicio: result.output.nuevo_id,
      id_expediente,
      id_usuario
    });

    return res.status(201).json({
      message: "Indicio registrado",
      id_indicio: result.output.nuevo_id
    });

  } catch (error) {
    //console.error("Error crearIndicio:", error);
    return next(error);
  }
};

export const obtenerIndiciosPorExpediente = async (req, res, next) => {
  try {
    const id_expediente = parseInt(req.params.id);

    const pool = await poolPromise;

    const result = await pool.request()
      .input("id_expediente", sql.Int, id_expediente)
      .execute("SP_ObtenerIndiciosPorExpediente");

    writeLog("INFO", "Indicios consultados", {
      id_expediente,
      total: result.recordset.length
    });

    return res.status(200).json({
      message: "Lista de indicios",
      indicios: result.recordset
    });

  } catch (error) {
    return next(error);
  }
};


export const actualizarEstadoIndicio = async (req, res, next) => {
  try {
    const id_indicio = parseInt(req.params.id);
    const { estado } = req.body;  // 1 = activo, 0 = inactivo

    const pool = await poolPromise;

    await pool.request()
      .input("id_indicio", sql.Int, id_indicio)
      .input("estado", sql.Int, estado)
      .execute("SP_ActualizarEstadoIndicio");

    writeLog("INFO", "Estado actualizado de indicio", {
      id_indicio,
      nuevo_estado: estado
    });

    return res.status(200).json({
      message: "Estado del indicio actualizado",
      id_indicio,
      estado
    });

  } catch (error) {
    return next(error);
  }
};


