-- Script de creación de base de datos y tablas (UTF8 collation)
CREATE DATABASE bd_dicri_evidencias
COLLATE Latin1_General_100_CI_AI_SC_UTF8;
GO
USE bd_dicri_evidencias;
GO

-- Tables: roles, usuarios, estados, flujos, expedientes, indicios, auditoria
CREATE TABLE TS_Roles (
    id_rol INT IDENTITY(1,1) PRIMARY KEY,
    nombre_rol VARCHAR(50) NOT NULL UNIQUE,
    estado BIT NOT NULL DEFAULT 1,
    fecha_registro DATETIME DEFAULT GETDATE(),
    fecha_modificacion DATETIME NULL
);
GO
CREATE TABLE TS_Usuarios (
    id_usuario INT IDENTITY(1,1) PRIMARY KEY,
    nombre_completo VARCHAR(150) NOT NULL,
    usuario VARCHAR(50) NOT NULL UNIQUE,
    contrasenia_hash VARBINARY(MAX) NULL,
    id_rol INT NOT NULL,
    activo BIT DEFAULT 1,
    fecha_creacion DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (id_rol) REFERENCES TS_Roles(id_rol)
);
GO
INSERT INTO TS_Roles (nombre_rol) VALUES ('Tecnico'), ('Coordinador'), ('Administrador');
GO
CREATE TABLE TC_EstadoExpediente (
    id_estado INT IDENTITY(1,1) PRIMARY KEY,
    nombre_estado VARCHAR(50) NOT NULL UNIQUE,
    estado BIT NOT NULL DEFAULT 1,
    fecha_registro DATETIME DEFAULT GETDATE(),
    fecha_modificacion DATETIME NULL
);
GO
INSERT INTO TC_EstadoExpediente (nombre_estado) VALUES ('Registrado'), ('En Revisión'), ('Aprobado'), ('Rechazado');
GO
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
INSERT INTO TC_FlujosPermitidos (estado_actual_id, estado_siguiente_id, es_rechazo) VALUES (1,2,0),(2,3,0),(2,4,1),(4,2,0);
GO
CREATE TABLE TT_Expediente (
    id_expediente INT IDENTITY(1,1) PRIMARY KEY,
    codigo_expediente VARCHAR(100) NOT NULL UNIQUE,
    descripcion VARCHAR(MAX) NULL,
    fecha_registro DATETIME DEFAULT GETDATE(),
    id_usuario_tecnico INT NOT NULL,
    id_estado INT NOT NULL DEFAULT 1,
    justificacion_rechazo VARCHAR(MAX) NULL,
    FOREIGN KEY (id_usuario_tecnico) REFERENCES TS_Usuarios(id_usuario),
    FOREIGN KEY (id_estado) REFERENCES TC_EstadoExpediente(id_estado)
);
GO
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
    FOREIGN KEY (id_expediente) REFERENCES TT_Expediente(id_expediente),
    FOREIGN KEY (id_usuario_tecnico) REFERENCES TS_Usuarios(id_usuario)
);
GO
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
-- Trigger
CREATE TRIGGER trg_sync_estado_expediente
ON MD_AuditoriaExpediente
AFTER INSERT
AS
BEGIN
    UPDATE TT_Expediente
    SET id_estado = i.estado_nuevo
    FROM inserted i
    WHERE TT_Expediente.id_expediente = i.id_expediente;
END;
GO
