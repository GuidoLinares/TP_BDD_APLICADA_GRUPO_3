USE [TP_BASE_DE_DATOS_2025_GRUPO_3]
GO

CREATE TABLE dbo.propietario (
    idPropietario INT IDENTITY(1,1) PRIMARY KEY, 
    DNI VARCHAR(20) NOT NULL UNIQUE,
    Nombre VARCHAR(100),
    Apellido VARCHAR(100),
    Email VARCHAR(255),
    Telefono VARCHAR(50),
    CBUVCVU VARCHAR(50) NULL,
    idUnidadFuncional INT NULL
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
    Importe DECIMAL(12,2),
    idExpensa INT NULL
);
GO

CREATE TABLE dbo.unidadAccesoria (
    idunidadAcc INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(45),
    metros_cuadrados DECIMAL(10,2)
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

PRINT 'Creando tablas dependientes...';

-- =================================================================
-- SECCIÓN 2: TABLAS DEPENDIENTES Y DE RELACIÓN
-- =================================================================

CREATE TABLE dbo.proveedor (
    idProveedor INT IDENTITY(1,1) PRIMARY KEY,
    factura_idFactura INT NULL,
    nombre VARCHAR(100),
    CUIT VARCHAR(13),
    CONSTRAINT FK_proveedor_factura FOREIGN KEY (factura_idFactura) 
        REFERENCES dbo.factura(idFactura)
);
GO

CREATE TABLE dbo.servicio (
    idServicio INT IDENTITY(1,1) PRIMARY KEY,
    factura_idFactura INT NULL,
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
        REFERENCES dbo.detalleExpensa(idDetalleExp)
);
GO

CREATE TABLE dbo.inquilino (
    idInquilino INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(45) NOT NULL,
    Apellido VARCHAR(45) NOT NULL,
    DNI VARCHAR(20) NOT NULL UNIQUE,
    email VARCHAR(255),
    telefono VARCHAR(50),
    CBUVCVU VARCHAR(50) NULL,
    propietario TINYINT,
    expensa_idExpensa INT NULL,
    expensa_consorcio_idconsorcio INT NULL,
    idUnidadFuncional INT NULL,
    CONSTRAINT FK_inquilino_expensa FOREIGN KEY (expensa_idExpensa) 
        REFERENCES dbo.expensa(idExpensa),
    CONSTRAINT FK_inquilino_consorcio FOREIGN KEY (expensa_consorcio_idconsorcio) 
        REFERENCES dbo.consorcio(idconsorcio)
);
GO

PRINT 'Creando tablas de staging...';

-- =================================================================
-- SECCIÓN 3: TABLAS DE STAGING
-- =================================================================

CREATE TABLE dbo.stg_Personas (
    [Nombre] VARCHAR(100) NULL,
    [Apellido] VARCHAR(100) NULL,
    [DNI] VARCHAR(20) NULL,
    [Email] VARCHAR(255) NULL,
    [Telefono] VARCHAR(50) NULL,
    [CVU/CBU] VARCHAR(50) NULL,
    [Inquilino] VARCHAR(5) NULL
);
GO

CREATE TABLE dbo.stg_Proveedores (
    ColumnaVacia VARCHAR(100) NULL,
    Categoria VARCHAR(255) NULL,
    NombreProveedor VARCHAR(255) NULL,
    DescripcionExtra VARCHAR(255) NULL,
    NombreConsorcio VARCHAR(255) NULL
);
GO

CREATE TABLE dbo.stg_Servicios (
    JsonData NVARCHAR(MAX)
);
GO

CREATE TABLE dbo.stg_UnidadFuncional (
    [Nombre del consorcio] VARCHAR(100) NULL,
    [nroUnidadFuncional] VARCHAR(50) NULL,
    [Piso] VARCHAR(50) NULL,
    [departamento] VARCHAR(50) NULL,
    [coeficiente] VARCHAR(50) NULL,
    [m2_unidad_funcional] VARCHAR(50) NULL,
    [bauleras] VARCHAR(10) NULL,
    [cochera] VARCHAR(10) NULL,
    [m2_baulera] VARCHAR(50) NULL,
    [m2_cochera] VARCHAR(50) NULL
);
GO

CREATE TABLE dbo.stg_Consorcios (
    [Consorcio] VARCHAR(100) NULL,
    [Nombre del consorcio] VARCHAR(100) NULL,
    [Domicilio] VARCHAR(100) NULL,
    [Cant unidades funcionales] VARCHAR(50) NULL,
    [m2 totales] VARCHAR(50) NULL
);
GO

CREATE TABLE dbo.stg_Inquilinos_UF (
    [CVU/CBU] VARCHAR(50) NULL,
    [Nombre del consorcio] VARCHAR(255) NULL,
    [nroUnidadFuncional] VARCHAR(50) NULL,
    [piso] VARCHAR(50) NULL,
    [departamento] VARCHAR(50) NULL
);
GO

PRINT 'Creando índices...';

-- =================================================================
-- SECCIÓN 4: ÍNDICES
-- =================================================================

CREATE INDEX IX_inquilino_expensa ON dbo.inquilino(expensa_idExpensa);
CREATE INDEX IX_expensa_consorcio ON dbo.expensa(consorcio_idconsorcio);
CREATE INDEX IX_unidadFuncional_consorcio ON dbo.unidadFuncional(consorcio_idconsorcio);
CREATE INDEX IX_servicio_factura ON dbo.servicio(factura_idFactura);
CREATE INDEX IX_proveedor_factura ON dbo.proveedor(factura_idFactura);
CREATE INDEX IX_Propietario_CBUVCVU ON dbo.propietario(CBUVCVU) WHERE CBUVCVU IS NOT NULL;
CREATE INDEX IX_Inquilino_CBUVCVU ON dbo.inquilino(CBUVCVU) WHERE CBUVCVU IS NOT NULL;
CREATE INDEX IX_Propietario_UF ON dbo.propietario(idUnidadFuncional) WHERE idUnidadFuncional IS NOT NULL;
CREATE INDEX IX_Inquilino_UF ON dbo.inquilino(idUnidadFuncional) WHERE idUnidadFuncional IS NOT NULL;
GO

PRINT '=================================================================';
PRINT 'Base de datos recreada exitosamente!';
PRINT '=================================================================';
PRINT 'Tablas maestras: propietario, consorcio, factura, unidadAccesoria, pago';
PRINT 'Tablas dependientes: proveedor, servicio, unidadFuncional, detalleExpensa, expensa, inquilino';
PRINT 'Tablas staging: stg_Personas, stg_Proveedores, stg_Servicios, stg_UnidadFuncional, stg_Consorcios, stg_Inquilinos_UF';
PRINT 'Índices: 9 índices creados';
PRINT '=================================================================';
GO