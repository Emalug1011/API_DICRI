/* ============================================================
    BASE DE DATOS: bd_dicri_evidencias
    Autor: Emanuel Mazariegos
    Objetivo: Registro y auditoría de expedientes e indicios
===============================================================*/

----------------------------------------------------------
-- 1. CREACIÓN DE BASE DE DATOS
----------------------------------------------------------
CREATE DATABASE bd_dicri_evidencias
COLLATE Latin1_General_100_CI_AI_SC_UTF8;
GO

USE bd_dicri_evidencias;
GO


/* ============================================================
    2. TABLAS DE SISTEMA (TS_)
    Usuarios y roles
===============================================================*/

----------------------------------------------------------
-- 2.1 Roles
----------------------------------------------------------
CREATE TABLE TS_Roles (
    id_rol INT IDENTITY(1,1) PRIMARY KEY,
    nombre_rol VARCHAR(50) NOT NULL UNIQUE,
    estado BIT NOT NULL DEFAULT 1,
    fecha_registro DATETIME DEFAULT GETDATE(),
    fecha_modificacion DATETIME NULL
);
GO

----------------------------------------------------------
-- 2.2 Usuarios
----------------------------------------------------------
CREATE TABLE TS_Usuarios (
    id_usuario INT IDENTITY(1,1) PRIMARY KEY,
    nombre_completo VARCHAR(150) NOT NULL,
    usuario VARCHAR(50) NOT NULL UNIQUE,
    contrasenia_hash VARCHAR(255) NULL,
    id_rol INT NOT NULL,
    activo BIT DEFAULT 1,
    fecha_creacion DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (id_rol) REFERENCES TS_Roles(id_rol)
);
GO

----------------------------------------------------------
-- 2.3 Inserts iniciales de roles
----------------------------------------------------------
INSERT INTO TS_Roles (nombre_rol)
VALUES ('Tecnico'), ('Coordinador'), ('Administrador');
GO


/* ============================================================
    3. TABLAS DE CATÁLOGO (TC_)
    Estados de expediente y flujos permitidos
===============================================================*/

----------------------------------------------------------
-- 3.1 Estados de expediente
----------------------------------------------------------
CREATE TABLE TC_EstadoExpediente (
    id_estado INT IDENTITY(1,1) PRIMARY KEY,
    nombre_estado VARCHAR(50) NOT NULL UNIQUE,
    estado BIT NOT NULL DEFAULT 1,
    fecha_registro DATETIME DEFAULT GETDATE(),
    fecha_modificacion DATETIME NULL
);
GO

INSERT INTO TC_EstadoExpediente (nombre_estado)
VALUES ('Registrado'), ('En Revisión'), ('Aprobado'), ('Rechazado');
GO

----------------------------------------------------------
-- 3.2 Flujos permitidos
----------------------------------------------------------
CREATE TABLE TC_FlujosPermitidos (
    id_flujo INT IDENTITY(1,1) PRIMARY KEY,
    estado_actual_id INT NOT NULL,
    estado_siguiente_id INT NOT NULL,
    es_rechazo BIT DEFAULT 0,
    estado BIT NOT NULL DEFAULT 1,
    fecha_registro DATETIME DEFAULT GETDATE(),
    fecha_modificacion DATETIME NULL,
    FOREIGN KEY (estado_actual_id) REFERENCES TC_EstadoExpediente(id_estado),
    FOREIGN KEY (estado_siguiente_id) REFERENCES TC_EstadoExpediente(id_estado)
);
GO

INSERT INTO TC_FlujosPermitidos (estado_actual_id, estado_siguiente_id, es_rechazo)
VALUES 
    (1, 2, 0),  
    (2, 3, 0),  
    (2, 4, 1),  
    (4, 2, 0);
GO


/* ============================================================
    4. TABLAS TRANSACCIONALES (TT_)
    Expedientes e indicios
===============================================================*/

----------------------------------------------------------
-- 4.1 Expedientes
----------------------------------------------------------
CREATE TABLE TT_Expediente (
    id_expediente INT IDENTITY(1,1) PRIMARY KEY,
    codigo_expediente VARCHAR(100) NOT NULL UNIQUE,
    descripcion VARCHAR(MAX),
    fecha_registro DATETIME DEFAULT GETDATE(),
    fecha_modificacion DATETIME NULL,
    id_usuario_tecnico INT NOT NULL,
    id_estado INT NOT NULL DEFAULT 1,
    justificacion_rechazo VARCHAR(MAX) NULL,
    FOREIGN KEY (id_usuario_tecnico) REFERENCES TS_Usuarios(id_usuario),
    FOREIGN KEY (id_estado) REFERENCES TC_EstadoExpediente(id_estado)
);
GO

----------------------------------------------------------
-- 4.2 Indicios
----------------------------------------------------------
CREATE TABLE TT_Indicio (
    id_indicio INT IDENTITY(1,1) PRIMARY KEY,
    id_expediente INT NOT NULL,
    descripcion VARCHAR(500) NOT NULL,
    color VARCHAR(100),
    tamano VARCHAR(100),
    peso VARCHAR(100),
    ubicacion VARCHAR(255),
    id_usuario_tecnico INT NOT NULL,
    fecha_registro DATETIME DEFAULT GETDATE(),
    estado INT NOT NULL DEFAULT 1,
    FOREIGN KEY (id_expediente) REFERENCES TT_Expediente(id_expediente),
    FOREIGN KEY (id_usuario_tecnico) REFERENCES TS_Usuarios(id_usuario)
);
GO


/* ============================================================
    5. TABLAS DE METADATOS (MD_)
    Auditoría del expediente
===============================================================*/

----------------------------------------------------------
-- 5.1 Auditoría de expediente
----------------------------------------------------------
CREATE TABLE MD_AuditoriaExpediente (
    id_auditoria INT IDENTITY(1,1) PRIMARY KEY,
    id_expediente INT NOT NULL,
    estado_anterior INT NULL,
    estado_nuevo INT NOT NULL,
    id_usuario INT NOT NULL,
    fecha_cambio DATETIME DEFAULT GETDATE(),
    comentario VARCHAR(MAX),
    FOREIGN KEY (id_expediente) REFERENCES TT_Expediente(id_expediente),
    FOREIGN KEY (id_usuario) REFERENCES TS_Usuarios(id_usuario)
);
GO


/* ============================================================
    6. VISTAS DE REPORTES
===============================================================*/

CREATE VIEW VW_ExpedientesResumen AS
SELECT 
    e.id_expediente,
    e.codigo_expediente,
    e.fecha_registro,
    u.nombre_completo AS tecnico,
    est.nombre_estado AS estado,
    (SELECT COUNT(*) FROM TT_Indicio i WHERE i.id_expediente = e.id_expediente) AS total_indicios
FROM TT_Expediente e
INNER JOIN TS_Usuarios u ON e.id_usuario_tecnico = u.id_usuario
INNER JOIN TC_EstadoExpediente est ON e.id_estado = est.id_estado;
GO


/* ============================================================
    7. PROCEDIMIENTOS ALMACENADOS
===============================================================*/

----------------------------------------------------------
-- 7.1 Autenticación
----------------------------------------------------------
CREATE OR ALTER PROCEDURE SP_LoginUsuario
    @usuario VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        u.id_usuario,
        u.nombre_completo,
        u.usuario,
        u.contrasenia_hash,
        r.nombre_rol,
        u.activo
    FROM TS_Usuarios u
    INNER JOIN TS_Roles r ON u.id_rol = r.id_rol
    WHERE u.usuario = @usuario
      AND u.activo = 1;
END;
GO


----------------------------------------------------------
-- 7.2 Mantenimiento de usuarios
----------------------------------------------------------
CREATE OR ALTER PROCEDURE SP_CrearUsuario
    @nombre_completo VARCHAR(150),
    @usuario VARCHAR(50),
    @contrasenia_hash VARCHAR(255),
    @id_rol INT
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM TS_Usuarios WHERE usuario = @usuario)
        RAISERROR('El usuario ya existe.', 16, 1);

    INSERT INTO TS_Usuarios (nombre_completo, usuario, contrasenia_hash, id_rol, activo)
    VALUES (@nombre_completo, @usuario, @contrasenia_hash, @id_rol, 1);

    SELECT SCOPE_IDENTITY() AS id_usuario;
END;
GO


CREATE OR ALTER PROCEDURE SP_ObtenerUsuarios
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        u.id_usuario,
        u.nombre_completo,
        u.usuario,
        u.id_rol,
        r.nombre_rol,
        u.activo,
        u.fecha_creacion
    FROM TS_Usuarios u
    INNER JOIN TS_Roles r ON u.id_rol = r.id_rol;
END;
GO


CREATE OR ALTER PROCEDURE SP_ObtenerUsuarioPorId
    @id_usuario INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        u.id_usuario,
        u.nombre_completo,
        u.usuario,
        u.id_rol,
        r.nombre_rol,
        u.activo,
        u.fecha_creacion
    FROM TS_Usuarios u
    INNER JOIN TS_Roles r ON u.id_rol = r.id_rol
    WHERE u.id_usuario = @id_usuario;
END;
GO


CREATE OR ALTER PROCEDURE SP_ActualizarUsuario
    @id_usuario INT,
    @nombre_completo VARCHAR(150),
    @usuario VARCHAR(50),
    @id_rol INT
AS
BEGIN
    UPDATE TS_Usuarios
    SET 
        nombre_completo = @nombre_completo,
        usuario = @usuario,
        id_rol = @id_rol
    WHERE id_usuario = @id_usuario;
END;
GO


CREATE OR ALTER PROCEDURE SP_CambiarContrasenia
    @id_usuario INT,
    @contrasenia_hash VARCHAR(255)
AS
BEGIN
    UPDATE TS_Usuarios
    SET contrasenia_hash = @contrasenia_hash
    WHERE id_usuario = @id_usuario;
END;
GO


----------------------------------------------------------
-- 7.3 Crear expediente
----------------------------------------------------------
CREATE OR ALTER PROCEDURE SP_CrearExpediente
    @descripcion VARCHAR(300),
    @id_usuario_tecnico INT,
    @nuevo_id INT OUTPUT,
    @codigo_generado VARCHAR(50) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @anio VARCHAR(4) = YEAR(GETDATE());
    DECLARE @correlativo INT = (SELECT ISNULL(MAX(id_expediente), 0) + 1 FROM TT_Expediente);

    SET @codigo_generado =
        'DICRI-' + @anio + '-' +
        RIGHT('00000000' + CAST(@correlativo AS VARCHAR(10)), 8);

    INSERT INTO TT_Expediente (
        codigo_expediente, descripcion, id_estado, id_usuario_tecnico
    )
    VALUES (@codigo_generado, @descripcion, 1, @id_usuario_tecnico);

    SET @nuevo_id = SCOPE_IDENTITY();
END;
GO


----------------------------------------------------------
-- 7.4 Crear indicio
----------------------------------------------------------
CREATE OR ALTER PROCEDURE SP_CrearIndicio
    @id_expediente INT,
    @descripcion VARCHAR(200),
    @color VARCHAR(50),
    @tamano VARCHAR(50),
    @peso VARCHAR(50),
    @ubicacion VARCHAR(150),
    @id_usuario_tecnico INT,
    @nuevo_id INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @estado_actual INT;

    -- Validar que el expediente exista y obtener su estado
    SELECT @estado_actual = id_estado
    FROM TT_Expediente
    WHERE id_expediente = @id_expediente;

    IF @estado_actual IS NULL
    BEGIN
        RAISERROR('El expediente no existe.', 16, 1);
        RETURN;
    END

    -- Validar si el estado permite agregar indicios
    IF @estado_actual NOT IN (1, 4)
    BEGIN
        RAISERROR('No se pueden agregar indicios en el estado actual del expediente.', 16, 1);
        RETURN;
    END

    -- Insertar el indicio
    INSERT INTO TT_Indicio (
        id_expediente,
        descripcion,
        color,
        tamano,
        peso,
        ubicacion,
        id_usuario_tecnico
    )
    VALUES (
        @id_expediente,
        @descripcion,
        @color,
        @tamano,
        @peso,
        @ubicacion,
        @id_usuario_tecnico
    );

    SET @nuevo_id = SCOPE_IDENTITY();
END;
GO


----------------------------------------------------------
-- 7.5 Cambiar estado del expediente + validaciones
----------------------------------------------------------
CREATE OR ALTER PROCEDURE SP_CambiarEstadoExpediente
    @id_expediente INT,
    @id_estado_nuevo INT,
    @id_usuario INT,
    @comentario VARCHAR(300) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @estado_actual INT;

    SELECT @estado_actual = id_estado
    FROM TT_Expediente
    WHERE id_expediente = @id_expediente;

    IF @estado_actual IS NULL
        RAISERROR('El expediente no existe.', 16, 1);

    -- Validar flujos permitidos
    IF NOT EXISTS (
        SELECT 1 FROM TC_FlujosPermitidos
        WHERE estado_actual_id = @estado_actual
        AND estado_siguiente_id = @id_estado_nuevo
    )
        RAISERROR('Flujo de estado no permitido.', 16, 1);

    -- Validar que hay indicios activos para pasar a revisión
    IF @id_estado_nuevo = 2 AND NOT EXISTS (
        SELECT 1 FROM TT_Indicio WHERE id_expediente = @id_expediente AND estado = 1
    )
        RAISERROR('Debe existir al menos un indicio activo.', 16, 1);

    -- Validar rechazo requiere comentario
    IF @id_estado_nuevo = 4 AND (ISNULL(@comentario,'') = '')
        RAISERROR('Debe enviar una justificación para el rechazo.', 16, 1);

    -- Actualizar expediente
    UPDATE TT_Expediente
    SET id_estado = @id_estado_nuevo
    WHERE id_expediente = @id_expediente;

    -- Registrar auditoría
    INSERT INTO MD_AuditoriaExpediente (
        id_expediente, estado_anterior, estado_nuevo, id_usuario, comentario
    )
    VALUES (
        @id_expediente, @estado_actual, @id_estado_nuevo, @id_usuario, @comentario
    );
END;
GO


----------------------------------------------------------
-- 7.6 Obtener expediente completo
----------------------------------------------------------
CREATE OR ALTER PROCEDURE SP_ObtenerExpediente
    @id_expediente INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT * FROM TT_Expediente WHERE id_expediente = @id_expediente;
    SELECT * FROM TT_Indicio WHERE id_expediente = @id_expediente;
    SELECT * FROM MD_AuditoriaExpediente WHERE id_expediente = @id_expediente;
END;
GO


----------------------------------------------------------
-- 7.7 Listado general de expedientes
----------------------------------------------------------
CREATE OR ALTER PROCEDURE SP_ListarExpedientes
    @estado INT = NULL,
    @fecha_inicio DATE = NULL,
    @fecha_fin DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        e.id_expediente,
        e.codigo_expediente,
        e.descripcion,
        e.fecha_registro,
        e.id_estado,
        u.nombre_completo AS usuario_creacion,
        e.justificacion_rechazo
    FROM TT_Expediente e
    INNER JOIN TS_Usuarios u ON u.id_usuario = e.id_usuario_tecnico
    WHERE (@estado IS NULL OR e.id_estado = @estado)
      AND (@fecha_inicio IS NULL OR e.fecha_registro >= @fecha_inicio)
      AND (@fecha_fin IS NULL OR e.fecha_registro <= @fecha_fin)
    ORDER BY e.fecha_registro DESC;
END;
GO


----------------------------------------------------------
-- 7.8 Obtener expedientes según rol del usuario
----------------------------------------------------------
CREATE OR ALTER PROCEDURE SP_ObtenerExpedientesPorUsuario
    @id_usuario INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @id_rol INT =
        (SELECT id_rol FROM TS_Usuarios WHERE id_usuario = @id_usuario);

    IF @id_rol IS NULL
        RAISERROR('Usuario no existe.', 16, 1);

    -- Técnico → sus expedientes en estado Registrado o Rechazado
    IF @id_rol = 1
    BEGIN
        SELECT 
            e.id_expediente,
            e.codigo_expediente,
            e.descripcion,
            e.id_estado,
            es.nombre_estado,
            e.fecha_registro
        FROM TT_Expediente e
        INNER JOIN TC_EstadoExpediente es ON es.id_estado = e.id_estado
        WHERE e.id_usuario_tecnico = @id_usuario
          AND e.id_estado IN (1,4)
        ORDER BY e.fecha_registro DESC;
        RETURN;
    END

    -- Coordinador → expedientes en Revisión
    IF @id_rol = 2
    BEGIN
        SELECT 
            e.id_expediente,
            e.codigo_expediente,
            e.descripcion,
            e.id_estado,
            es.nombre_estado,
            e.fecha_registro
        FROM TT_Expediente e
        INNER JOIN TC_EstadoExpediente es ON es.id_estado = e.id_estado
        WHERE e.id_estado = 2
        ORDER BY e.fecha_registro DESC;
        RETURN;
    END

    -- Administrador → todos
    IF @id_rol = 3
    BEGIN
        SELECT 
            e.id_expediente,
            e.codigo_expediente,
            e.descripcion,
            e.id_estado,
            es.nombre_estado,
            e.fecha_registro
        FROM TT_Expediente e
        INNER JOIN TC_EstadoExpediente es ON es.id_estado = e.id_estado
        ORDER BY e.fecha_registro DESC;
        RETURN;
    END
END;
GO


----------------------------------------------------------
-- 7.9 Indicios por expediente
----------------------------------------------------------
CREATE OR ALTER PROCEDURE SP_ObtenerIndiciosPorExpediente
    @id_expediente INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM TT_Expediente WHERE id_expediente = @id_expediente)
        RAISERROR('El expediente no existe.', 16, 1);

    SELECT 
        id_indicio,
        id_expediente,
        descripcion,
        color,
        tamano,
        peso,
        ubicacion,
        id_usuario_tecnico,
        fecha_registro,
        estado
    FROM TT_Indicio
    WHERE id_expediente = @id_expediente
      AND estado = 1
    ORDER BY fecha_registro DESC;
END;
GO


----------------------------------------------------------
-- 7.10 Cambiar estado de indicio
----------------------------------------------------------
CREATE OR ALTER PROCEDURE SP_ActualizarEstadoIndicio
    @id_indicio INT,
    @estado INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM TT_Indicio WHERE id_indicio = @id_indicio)
        RAISERROR('El indicio no existe.', 16, 1);

    UPDATE TT_Indicio
    SET estado = @estado
    WHERE id_indicio = @id_indicio;
END;
GO


----------------------------------------------------------
-- 7.11 Auditoría detallada del expediente
----------------------------------------------------------
CREATE OR ALTER PROCEDURE SP_ObtenerAuditoriaExpediente
(
    @id_expediente INT
)
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM TT_Expediente WHERE id_expediente = @id_expediente)
        RAISERROR('El expediente no existe.', 16, 1);

    SELECT 
        ae.id_auditoria,
        ae.id_expediente,
        ae.estado_anterior,
        estA.nombre_estado AS nombre_estado_anterior,
        ae.estado_nuevo,
        estN.nombre_estado AS nombre_estado_nuevo,
        ae.id_usuario,
        u.nombre_completo AS usuario_responsable,
        ae.comentario,
        FORMAT(ae.fecha_cambio, 'dd.MM.yyyy') AS fecha_cambio
    FROM MD_AuditoriaExpediente ae
    INNER JOIN TC_EstadoExpediente estA ON ae.estado_anterior = estA.id_estado
    INNER JOIN TC_EstadoExpediente estN ON ae.estado_nuevo = estN.id_estado
    INNER JOIN TS_Usuarios u ON ae.id_usuario = u.id_usuario
    WHERE ae.id_expediente = @id_expediente
    ORDER BY ae.fecha_cambio DESC;
END;
GO


----------------------------------------------------------
-- 7.12 Resumen de expedientes por estado
----------------------------------------------------------
CREATE OR ALTER PROCEDURE SP_ResumenExpedientesPorEstado
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        est.id_estado,
        est.nombre_estado,
        COUNT(e.id_expediente) AS total_expedientes
    FROM TC_EstadoExpediente est
    LEFT JOIN TT_Expediente e ON e.id_estado = est.id_estado
    WHERE est.estado = 1
    GROUP BY est.id_estado, est.nombre_estado
    ORDER BY est.id_estado ASC;
END;
GO
