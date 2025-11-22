CREATE PROCEDURE sp_insert_expediente
  @codigo_expediente VARCHAR(100),
  @descripcion VARCHAR(MAX) = NULL,
  @id_usuario_tecnico INT,
  @nuevo_id INT OUTPUT
AS
BEGIN
  SET NOCOUNT ON;
  INSERT INTO TT_Expediente (codigo_expediente, descripcion, id_usuario_tecnico)
  VALUES (@codigo_expediente, @descripcion, @id_usuario_tecnico);
  SET @nuevo_id = SCOPE_IDENTITY();
  INSERT INTO MD_AuditoriaExpediente (id_expediente, estado_anterior, estado_nuevo, id_usuario, comentario)
  VALUES (@nuevo_id, NULL, (SELECT id_estado FROM TC_EstadoExpediente WHERE nombre_estado='Registrado'), @id_usuario_tecnico, 'Creación de expediente');
END
GO
