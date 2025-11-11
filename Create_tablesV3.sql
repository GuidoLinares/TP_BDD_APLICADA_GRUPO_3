CREATE DATABASE [TP_BASE_DE_DATOS_2025_GRUPO_3]
GO

USE [TP_BASE_DE_DATOS_2025_GRUPO_3]
GO

CREATE TABLE dbo.stg_Personas (

	[Nombre] VARCHAR(100) NULL,
	[Apellido] VARCHAR (100) NULL,
	[DNI] VARCHAR(20) NULL,
	[email personal] VARCHAR(255) NULL,
	[telefono de contacto] VARCHAR(50) NULL,
	[CVU/CBU] VARCHAR(50) NULL,
	[Inquilino] VARCHAR (5)NULL
);



CREATE TABLE dbo.inquilino (
    idInquilino INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(45) NOT NULL,
    Apellido VARCHAR(45) NOT NULL,
    DNI VARCHAR(20) NOT NULL UNIQUE,
    email VARCHAR(255),
    telefono INT,
    CBUVCVU INT,
    propietario TINYINT, -- 0 = No, 1 = Sí
    expensa_idExpensa INT,
    expensa_consorcio_idconsorcio INT
);

CREATE TABLE dbo.propietario (
    idPropietario INT IDENTITY(1,1) PRIMARY KEY, 
    DNI VARCHAR(20) NOT NULL UNIQUE,
    Nombre VARCHAR(100),
    Apellido VARCHAR(100),
    Email VARCHAR(255),
    Telefono VARCHAR(50)
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

CREATE TABLE dbo.expensa (
    idExpensa INT IDENTITY(1,1) PRIMARY KEY,
    descripcion NVARCHAR(MAX), -- LONGTEXT
    consorcio_idconsorcio INT NOT NULL,
    detalleExpensa_idDetalleExp INT,
    factura_idFactura INT,
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
        REFERENCES dbo.consorcio(idconsorcio)
);




CREATE TABLE dbo.detalleExpensa (
    idDetalleExp INT IDENTITY(1,1) PRIMARY KEY,
    pago_idPago INT,
    porcentaje_aplicada DECIMAL(5,4),
    saldo_anterior DECIMAL(12,2),
    pagos_recibidos DECIMAL(12,2),
    deudas_remanentes DECIMAL(12,2),
    interes_mora DECIMAL(10,2),
    monto_expensa_ordinaria DECIMAL(12,2),
    monto_expensa_extraordinaria DECIMAL(12,2),
    total_a_pagar DECIMAL(12,2)
);



CREATE TABLE dbo.pago (
    idPago INT IDENTITY(1,1) PRIMARY KEY,
    fecha DATE,
    cuenta_origen VARCHAR(22),
    importe DECIMAL(12,2)
);


CREATE TABLE dbo.factura (
    idFactura INT IDENTITY(1,1) PRIMARY KEY,
    numero_factura VARCHAR(50),
	consorcio_nombre VARCHAR(50),
    mes VARCHAR(50),
    importe DECIMAL(12,2),
	importe_tipo VARCHAR(50),
	es_dolar TINYINT
);

CREATE TABLE dbo.servicio (
    idServicio INT IDENTITY(1,1) PRIMARY KEY,
    factura_idFactura INT,
    nombre_empresa VARCHAR(50),
    CUIT VARCHAR(13),
    CONSTRAINT FK_servicio_factura FOREIGN KEY (factura_idFactura) 
        REFERENCES dbo.factura(idFactura)
);

CREATE TABLE dbo.proveedor (
    idProveedor INT IDENTITY(1,1) PRIMARY KEY,
    factura_idFactura INT,
    tipoGasto VARCHAR(50),
	nombreEmpresa VARCHAR(50),
    cuenta VARCHAR(50),
	consorcio VARCHAR(50),
    CONSTRAINT FK_proveedor_factura FOREIGN KEY (factura_idFactura) 
        REFERENCES dbo.factura(idFactura)
);


CREATE TABLE factura_con_proveedores (
    factura_idFactura INT,
    proveedor_idProveedor INT,
    PRIMARY KEY (factura_idFactura, proveedor_idProveedor),
    FOREIGN KEY (factura_idFactura) REFERENCES factura(idFactura),
    FOREIGN KEY (proveedor_idProveedor) REFERENCES proveedor(idProveedor)
);

CREATE TABLE dbo.unidadAccesoria (
    idunidadAcc INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(45),
    metros_cuadrados DECIMAL(2)
);


CREATE TABLE dbo.unidadFuncional (
    idunidadFuncional INT IDENTITY(1,1) PRIMARY KEY,
    piso INT,
    descripcion_identificacion VARCHAR(45),
    metros_cuadrados DECIMAL(2),
    unidad_accesoria_idunidadAcc INT,
    consorcio_idconsorcio INT,
    CONSTRAINT FK_unidadFuncional_unidadAccesoria FOREIGN KEY (unidad_accesoria_idunidadAcc) 
        REFERENCES dbo.unidadAccesoria(idunidadAcc),
    CONSTRAINT FK_unidadFuncional_consorcio FOREIGN KEY (consorcio_idconsorcio) 
        REFERENCES dbo.consorcio(idconsorcio)
);


ALTER TABLE dbo.inquilino
ADD CONSTRAINT FK_inquilino_expensa FOREIGN KEY (expensa_idExpensa) 
    REFERENCES dbo.expensa(idExpensa);

ALTER TABLE dbo.inquilino
ADD CONSTRAINT FK_inquilino_consorcio FOREIGN KEY (expensa_consorcio_idconsorcio) 
    REFERENCES dbo.consorcio(idconsorcio);


ALTER TABLE dbo.expensa
ADD CONSTRAINT FK_expensa_detalleExpensa FOREIGN KEY (detalleExpensa_idDetalleExp) 
    REFERENCES dbo.detalleExpensa(idDetalleExp);


ALTER TABLE dbo.expensa
ADD CONSTRAINT FK_expensa_factura FOREIGN KEY (factura_idFactura) 
    REFERENCES dbo.factura(idFactura);


ALTER TABLE dbo.detalleExpensa
ADD CONSTRAINT FK_detalleExpensa_pago FOREIGN KEY (pago_idPago) 
    REFERENCES dbo.pago(idPago);


CREATE INDEX IX_inquilino_DNI ON dbo.inquilino(DNI);
CREATE INDEX IX_inquilino_expensa ON dbo.inquilino(expensa_idExpensa);
CREATE INDEX IX_expensa_consorcio ON dbo.expensa(consorcio_idconsorcio);
CREATE INDEX IX_unidadFuncional_consorcio ON dbo.unidadFuncional(consorcio_idconsorcio);
CREATE INDEX IX_servicio_factura ON dbo.servicio(factura_idFactura);
CREATE INDEX IX_proveedor_factura ON dbo.proveedor(factura_idFactura);







