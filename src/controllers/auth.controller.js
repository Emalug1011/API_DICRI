import sql from "mssql";
import bcrypt from "bcryptjs";
import jwt from "jsonwebtoken";
import { poolPromise } from "../services/db.service.js";

export const login = async (req, res) => {
    const { usuario, contrasenia } = req.body;

    try {
        const pool = await poolPromise;

        const result = await pool.request()
            .input("usuario", sql.VarChar, usuario)
            .execute("SP_LoginUsuario");

        // Si no existe el usuario
        if (result.recordset.length === 0) {
            return res.status(401).json({ message: "Usuario no encontrado o inactivo." });
        }

        const user = result.recordset[0];

        
        const hash = user.contrasenia_hash;
        // Comparar la contraseña
        const passwordMatch = await bcrypt.compare(contrasenia, hash);

        if (!passwordMatch) {
            return res.status(401).json({ message: "Contraseña incorrecta." });
        }

        // Generar token JWT
        const token = jwt.sign(
            {
                id_usuario: user.id_usuario,
                rol: user.nombre_rol
            },
            process.env.JWT_SECRET,
            { expiresIn: "8h" }
        );

        return res.json({
            message: "Inicio de sesión exitoso",
            token,
            usuario: {
                id: user.id_usuario,
                nombre: user.nombre_completo,
                rol: user.nombre_rol
            }
        });

    } catch (err) {
        console.error("Error en login:", err);
        return res.status(500).json({
            message: "Error en el servidor",
            error: err.message
        });
    }
};
