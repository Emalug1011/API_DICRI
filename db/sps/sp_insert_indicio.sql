CREATE PROCEDURE sp_insert_indicio
  @id_expediente INT,
  @descripcion VARCHAR(500),
  @color VARCHAR(100) = NULL,
  @tamano VARCHAR(100) = NULL,
  @peso VARCHAR(100) = NULL,
  @ubicacion VARCHAR(255) = NULL,
  @id_usuario_tecnico INT,
  @nuevo_id INT OUTPUT
AS
BEGIN
  SET NOCOUNT ON;
  INSERT INTO TT_Indicio (id_expediente, descripcion, color, tamano, peso, ubicacion, id_usuario_tecnico)
  VALUES (@id_expediente, @descripcion, @color, @tamano, @peso, @ubicacion, @id_usuario_tecnico);
  SET @nuevo_id = SCOPE_IDENTITY();
  INSERT INTO MD_AuditoriaExpediente (id_expediente, estado_anterior, estado_nuevo, id_usuario, comentario)
  VALUES (@id_expediente, NULL, (SELECT id_estado FROM TC_EstadoExpediente WHERE nombre_estado='Registrado'), @id_usuario_tecnico, 'Indicio agregado');
END
GO
