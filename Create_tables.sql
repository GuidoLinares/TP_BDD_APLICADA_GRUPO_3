CREATE DATABASE TP_BASE_DE_DATOS_2025
GO

USE TP_BASE_DE_DATOS_2025
GO

-- =================================================================
-- SECCIÓN 1: TABLAS MAESTRAS
-- (Tablas principales que no dependen de otras)
-- =================================================================

CREATE TABLE dbo.propietario (
    idPropietario INT IDENTITY(1,1) PRIMARY KEY, 
    DNI VARCHAR(20) NOT NULL UNIQUE,
    Nombre VARCHAR(100),
    Apellido VARCHAR(100),
    Email VARCHAR(255),
    Telefono VARCHAR(50) -- Cambiado a VARCHAR para ser flexible
);
GO

CREATE TABLE dbo.consorcio (
    idconsorcio INT IDENTITY(1,1) PRIMARY KEY,
    numeroConsorcio INT NOT NULL,
    nombre VARCHAR(45),
    direccion VARCHAR(45),
    cantidad_unidades INT,
    metros_cuadrados_totales INT
);
GO

CREATE TABLE dbo.factura (
    idFactura INT IDENTITY(1,1) PRIMARY KEY,
    numero_factura VARCHAR(50),
    fecha DATE,
    Importe DECIMAL(12,2)
);
GO

CREATE TABLE dbo.unidadAccesoria (
    idunidadAcc INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(45),
    metros_cuadrados DECIMAL(10,2) -- Ajustado
);
GO


CREATE TABLE dbo.pago (
    idPago INT NOT NULL PRIMARY KEY, 
    fecha DATE,
    importe DECIMAL(12,2),
    cuenta_origen VARCHAR(22),
    asociado TINYINT
);
GO

-- =================================================================
-- SECCIÓN 2: TABLAS DEPENDIENTES Y DE RELACIÓN
-- (Se crean después de las maestras)
-- =================================================================

CREATE TABLE dbo.proveedor (
    idProveedor INT IDENTITY(1,1) PRIMARY KEY,
    factura_idFactura INT NULL, -- Un proveedor puede existir sin factura
    nombre VARCHAR(100),
    CUIT VARCHAR(13),
    CONSTRAINT FK_proveedor_factura FOREIGN KEY (factura_idFactura) 
        REFERENCES dbo.factura(idFactura)
);
GO

CREATE TABLE dbo.servicio (
    idServicio INT IDENTITY(1,1) PRIMARY KEY,
    factura_idFactura INT NULL, -- Un servicio puede existir sin factura
    nombre_empresa VARCHAR(100),
    CUIT VARCHAR(13),
    CONSTRAINT FK_servicio_factura FOREIGN KEY (factura_idFactura) 
        REFERENCES dbo.factura(idFactura)
);
GO

CREATE TABLE dbo.unidadFuncional (
    idunidadFuncional INT IDENTITY(1,1) PRIMARY KEY,
    piso INT,
    descripcion_identificacion VARCHAR(45),
    metros_cuadrados DECIMAL(10,2), 
    unidad_accesoria_idunidadAcc INT NULL,
    consorcio_idconsorcio INT NOT NULL,
    CONSTRAINT FK_unidadFuncional_unidadAccesoria FOREIGN KEY (unidad_accesoria_idunidadAcc) 
        REFERENCES dbo.unidadAccesoria(idunidadAcc),
    CONSTRAINT FK_unidadFuncional_consorcio FOREIGN KEY (consorcio_idconsorcio) 
        REFERENCES dbo.consorcio(idconsorcio)
);
GO

CREATE TABLE dbo.detalleExpensa (
    idDetalleExp INT IDENTITY(1,1) PRIMARY KEY,
    pago_idPago INT NULL,
    porcentaje_aplicada DECIMAL(5,4),
    saldo_anterior DECIMAL(12,2),
    pagos_recibidos DECIMAL(12,2),
    deudas_remanentes DECIMAL(12,2),
    interes_mora DECIMAL(10,2),
    monto_expensa_ordinaria DECIMAL(12,2),
    monto_expensa_extraordinaria DECIMAL(12,2),
    total_a_pagar DECIMAL(12,2),
    CONSTRAINT FK_detalleExpensa_pago FOREIGN KEY (pago_idPago) 
        REFERENCES dbo.pago(idPago)
);
GO

CREATE TABLE dbo.expensa (
    idExpensa INT IDENTITY(1,1) PRIMARY KEY,
    descripcion NVARCHAR(MAX), 
    consorcio_idconsorcio INT NOT NULL,
    detalleExpensa_idDetalleExp INT NULL,
    factura_idFactura INT NULL,
    mes INT,
    ano INT,
    fecha_emision DATE,
    fecha_vto_1 DATE,
    fecha_vto_2 DATE,
    total_gastos_ordinarios DECIMAL(14,2),
    total_gastos_extraordinarios DECIMAL(14,2),
    saldo_anterior_banco DECIMAL(14,2),
    ingresos_termino DECIMAL(14,2),
    ingresos_adjudicadas DECIMAL(14,2),
    ingresos_adelantadas DECIMAL(14,2),
    egresos_mes DECIMAL(14,2),
    saldo_Cierre_banco DECIMAL(14,2),
    CONSTRAINT FK_expensa_consorcio FOREIGN KEY (consorcio_idconsorcio) 
        REFERENCES dbo.consorcio(idconsorcio),
    CONSTRAINT FK_expensa_detalleExpensa FOREIGN KEY (detalleExpensa_idDetalleExp) 
        REFERENCES dbo.detalleExpensa(idDetalleExp),
    CONSTRAINT FK_expensa_factura FOREIGN KEY (factura_idFactura) 
        REFERENCES dbo.factura(idFactura)
);
GO

CREATE TABLE dbo.inquilino (
    idInquilino INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(45) NOT NULL,
    Apellido VARCHAR(45) NOT NULL,
    DNI VARCHAR(20) NOT NULL UNIQUE,
    email VARCHAR(255),
    telefono VARCHAR(50),
    CBUVCVU VARCHAR(22), 
    propietario TINYINT, -- 0 = No, 1 = Sí
    expensa_idExpensa INT NULL,
    expensa_consorcio_idconsorcio INT NULL,
    CONSTRAINT FK_inquilino_expensa FOREIGN KEY (expensa_idExpensa) 
        REFERENCES dbo.expensa(idExpensa),
    CONSTRAINT FK_inquilino_consorcio FOREIGN KEY (expensa_consorcio_idconsorcio) 
        REFERENCES dbo.consorcio(idconsorcio)
);
GO

-- =================================================================
-- SECCIÓN 3: TABLAS DE ESCENARIO (STAGING) PARA LA ENTREGA 5
-- (Estas son las "pistas de aterrizaje" para los archivos CSV/JSON)
-- =================================================================

CREATE TABLE dbo.stg_Personas (
    [Nombre] VARCHAR(100) NULL,
    [ apellido] VARCHAR(100) NULL,
    [DNI] VARCHAR(20) NULL,
    [ email personal] VARCHAR(255) NULL,
    [ telＧono de contacto] VARCHAR(50) NULL, -- Corregido
    [CVU/CBU] VARCHAR(50) NULL,
    [Inquilino] VARCHAR(5) NULL
);
GO

-- Staging table para Proveedores.csv
CREATE TABLE dbo.stg_Proveedores (
    ColumnaVacia VARCHAR(100) NULL,
    Categoria VARCHAR(255) NULL,
    NombreProveedor VARCHAR(255) NULL,
    DescripcionExtra VARCHAR(255) NULL,
    NombreConsorcio VARCHAR(255) NULL
);
GO

-- Staging table para Servicios.Servicios.json
CREATE TABLE dbo.stg_Servicios (
    JsonData NVARCHAR(MAX)
);
GO


-- =================================================================
-- SECCIÓN 4: ÍNDICES (Para optimizar el rendimiento)
-- =================================================================

CREATE INDEX IX_inquilino_expensa ON dbo.inquilino(expensa_idExpensa);
CREATE INDEX IX_expensa_consorcio ON dbo.expensa(consorcio_idconsorcio);
CREATE INDEX IX_unidadFuncional_consorcio ON dbo.unidadFuncional(consorcio_idconsorcio);
CREATE INDEX IX_servicio_factura ON dbo.servicio(factura_idFactura);
CREATE INDEX IX_proveedor_factura ON dbo.proveedor(factura_idFactura);
GO