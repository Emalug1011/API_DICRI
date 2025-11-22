import sql from "mssql";
import bcrypt from "bcryptjs";
import { poolPromise } from "../services/db.service.js";

// Crear usuario
export const crearUsuario = async (req, res) => {
    const { nombre_completo, usuario, contrasenia, id_rol } = req.body;

    try {
        const pool = await poolPromise;
        const hash = await bcrypt.hash(contrasenia, 10);

        const result = await pool.request()
            .input("nombre_completo", sql.VarChar, nombre_completo)
            .input("usuario", sql.VarChar, usuario)
            .input("contrasenia_hash", sql.VarChar, hash)
            .input("id_rol", sql.Int, id_rol)
            .execute("SP_CrearUsuario");

        return res.status(201).json({
            message: "Usuario creado correctamente",
            id_usuario: result.recordset[0].id_usuario
        });

    } catch (err) {
        return res.status(400).json({ error: err.message });
    }
};


// Obtener todos los usuarios
export const obtenerUsuarios = async (req, res) => {
    try {
        const pool = await poolPromise;
        const result = await pool.request().execute("SP_ObtenerUsuarios");

        return res.json(result.recordset);
    } catch (err) {
        return res.status(500).json({ error: err.message });
    }
};


// Obtener usuario por id
export const obtenerUsuarioPorId = async (req, res) => {
    const { id } = req.params;

    try {
        const pool = await poolPromise;
        const result = await pool.request()
            .input("id_usuario", sql.Int, id)
            .execute("SP_ObtenerUsuarioPorId");

        if (result.recordset.length === 0) {
            return res.status(404).json({ message: "Usuario no encontrado" });
        }

        return res.json(result.recordset[0]);

    } catch (err) {
        return res.status(500).json({ error: err.message });
    }
};


// Actualizar usuario
export const actualizarUsuario = async (req, res) => {
    const { id } = req.params;
    const { nombre_completo, usuario, id_rol } = req.body;

    try {
        const pool = await poolPromise;

        await pool.request()
            .input("id_usuario", sql.Int, id)
            .input("nombre_completo", sql.VarChar, nombre_completo)
            .input("usuario", sql.VarChar, usuario)
            .input("id_rol", sql.Int, id_rol)
            .execute("SP_ActualizarUsuario");

        return res.json({ message: "Usuario actualizado correctamente" });

    } catch (err) {
        return res.status(500).json({ error: err.message });
    }
};


// Cambiar contraseña
export const cambiarContrasenia = async (req, res) => {
    const { id } = req.params;
    const { nueva_contrasenia } = req.body;

    try {
        const pool = await poolPromise;
        const hash = await bcrypt.hash(nueva_contrasenia, 10);

        await pool.request()
            .input("id_usuario", sql.Int, id)
            .input("contrasenia_hash", sql.VarChar, hash)
            .execute("SP_CambiarContrasenia");

        return res.json({ message: "Contraseña actualizada correctamente" });

    } catch (err) {
        return res.status(500).json({ error: err.message });
    }
};


 
