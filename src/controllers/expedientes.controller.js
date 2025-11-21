const { poolPromise } = require('../services/db.service');

async function crearExpediente(req, res) {
  const { codigo_expediente, descripcion } = req.body;
  // For demo, using fixed user id 1
  const id_usuario_tecnico = 1;
  try {
    const pool = await poolPromise;
    const result = await pool.request()
      .input('codigo_expediente', codigo_expediente)
      .input('descripcion', descripcion)
      .input('id_usuario_tecnico', id_usuario_tecnico)
      .output('nuevo_id')
      .execute('sp_insert_expediente');
    return res.status(201).json({ id: result.output.nuevo_id });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ message: 'Error al crear expediente', detail: err.message });
  }
}

async function cambiarEstado(req, res) {
  const id_expediente = parseInt(req.params.id,10);
  const { id_estado_nuevo, comentario } = req.body;
  const id_usuario = 1;
  try {
    const pool = await poolPromise;
    await pool.request()
      .input('id_expediente', id_expediente)
      .input('id_estado_nuevo', id_estado_nuevo)
      .input('id_usuario', id_usuario)
      .input('comentario', comentario)
      .execute('sp_cambiar_estado_expediente');
    return res.status(200).json({ message: 'Estado actualizado' });
  } catch (err) {
    console.error(err);
    return res.status(400).json({ message: err.message });
  }
}

module.exports = { crearExpediente, cambiarEstado };
