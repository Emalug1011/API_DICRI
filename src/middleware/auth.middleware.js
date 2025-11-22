import jwt from "jsonwebtoken";

export const verificarToken = (req, res, next) => {
    const token = req.headers["authorization"];

    if (!token) {
        return res.status(401).json({ message: "Acceso denegado. No se envió token." });
    }

    try {
        // Token viene generalmente como: "Bearer eyJhbGciOi..."
        const tokenLimpiado = token.replace("Bearer ", "");

        const decoded = jwt.verify(tokenLimpiado, process.env.JWT_SECRET);

        // Guardar datos del usuario dentro del request
        req.usuario = decoded;

        next(); // continuar al controlador
    } catch (err) {
        return res.status(401).json({ message: "Token inválido o expirado.", error: err.message });
    }
};
