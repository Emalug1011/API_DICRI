import sql from "mssql";
import { poolPromise } from "../services/db.service.js";

/* ============================================================
   Crear indicio dentro de un expediente
   ============================================================ */
export const crearIndicio = async (req, res) => {
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

    res.status(201).json({
      message: "Indicio registrado",
      id_indicio: result.output.nuevo_id
    });

  } catch (error) {
    console.error("Error crearIndicio:", error);
    res.status(500).json({ message: "Error al crear indicio", error: error.message });
  }
};
