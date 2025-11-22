CREATE PROCEDURE sp_cambiar_estado_expediente
  @id_expediente INT,
  @id_estado_nuevo INT,
  @id_usuario INT,
  @comentario VARCHAR(MAX) = NULL
AS
BEGIN
  SET NOCOUNT ON;
  DECLARE @estado_actual INT;
  SELECT @estado_actual = id_estado FROM TT_Expediente WHERE id_expediente = @id_expediente;
  IF @estado_actual IS NULL
  BEGIN
    RAISERROR('Expediente no encontrado',16,1);
    RETURN;
  END
  IF NOT EXISTS (SELECT 1 FROM TC_FlujosPermitidos WHERE estado_actual_id = @estado_actual AND estado_siguiente_id = @id_estado_nuevo AND estado = 1)
  BEGIN
    RAISERROR('Transición no permitida',16,1);
    RETURN;
  END
  DECLARE @es_rechazo BIT = (SELECT es_rechazo FROM TC_FlujosPermitidos WHERE estado_actual_id = @estado_actual AND estado_siguiente_id = @id_estado_nuevo);
  IF @es_rechazo = 1 AND ( @comentario IS NULL OR LTRIM(RTRIM(@comentario)) = '' )
  BEGIN
    RAISERROR('Rechazo requiere justificación',16,1);
    RETURN;
  END
  BEGIN TRAN;
  INSERT INTO MD_AuditoriaExpediente (id_expediente, estado_anterior, estado_nuevo, id_usuario, comentario)
  VALUES (@id_expediente, @estado_actual, @id_estado_nuevo, @id_usuario, @comentario);
  UPDATE TT_Expediente
  SET id_estado = @id_estado_nuevo, justificacion_rechazo = CASE WHEN @es_rechazo = 1 THEN @comentario ELSE NULL END
  WHERE id_expediente = @id_expediente;
  COMMIT TRAN;
END
GO
