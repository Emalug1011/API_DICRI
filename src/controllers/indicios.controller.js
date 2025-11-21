const { poolPromise } = require('../services/db.service');

async function crearIndicio(req, res) {
  const id_expediente = parseInt(req.params.id,10);
  const { descripcion, color, tamano, peso, ubicacion } = req.body;
  const id_usuario_tecnico = 1;
  try {
    const pool = await poolPromise;
    const result = await pool.request()
      .input('id_expediente', id_expediente)
      .input('descripcion', descripcion)
      .input('color', color)
      .input('tamano', tamano)
      .input('peso', peso)
      .input('ubicacion', ubicacion)
      .input('id_usuario_tecnico', id_usuario_tecnico)
      .output('nuevo_id')
      .execute('sp_insert_indicio');
    return res.status(201).json({ id: result.output.nuevo_id });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ message: 'Error al crear indicio' });
  }
}

module.exports = { crearIndicio };
