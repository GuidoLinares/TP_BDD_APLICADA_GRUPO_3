-- Primero, cambiar a otra base de datos
USE master;
GO

-- Luego forzar el drop terminando conexiones activas
ALTER DATABASE [TP_BASE_DE_DATOS_2025_GRUPO_3] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
ALTER DATABASE TP_BASE_DE_DATOS_2025_GRUPO_3 SET MULTI_USER;
GO

--Verificar el estado de la base de datos
SELECT name, state_desc, user_access_desc 
FROM sys.databases 
WHERE name = 'TP_BASE_DE_DATOS_2025_GRUPO_3';

-- Finalmente eliminar
DROP DATABASE [TP_BASE_DE_DATOS_2025_GRUPO_3];
GO

-- Para crear de nuevo 
CREATE DATABASE [TP_BASE_DE_DATOS_2025_GRUPO_3];
GO

-- Probar procedimientos
USE [TP_BASE_DE_DATOS_2025_GRUPO_3]
GO

-- Check Servicios
EXEC dbo.sp_ImportarFacturas
    @RutaArchivo = 'C:\TPBDA\consorcios\Servicios.Servicios.json';
GO
-- Si falla carga
DELETE FROM dbo.factura;
-- Check Tabla
SELECT * 
FROM dbo.factura;
GO

-- Check Proovedor
EXEC dbo.sp_ImportaProveedores
    @RutaArchivo = 'C:\TPBDA\consorcios\Proveedores.csv';
GO
-- Si falla carga
DELETE FROM dbo.proveedor;
-- Check Tabla
SELECT * 
FROM dbo.proveedor;
GO

-- Check Union Servicio con Proovedor
-- NO USAR YA AGREGADO EN CREATE TABLES V3
CREATE TABLE factura_con_proveedores (
    factura_idFactura INT,
    proveedor_idProveedor INT,
    PRIMARY KEY (factura_idFactura, proveedor_idProveedor),
    FOREIGN KEY (factura_idFactura) REFERENCES factura(idFactura),
    FOREIGN KEY (proveedor_idProveedor) REFERENCES proveedor(idProveedor)
);
-- NO USAR YA AGREGADO EN CREATE TABLES V3


-- Poblamos la tabla union
INSERT INTO factura_con_proveedores (factura_idFactura, proveedor_idProveedor)
SELECT DISTINCT 
    f.idFactura, 
    p.idProveedor
FROM dbo.factura f
INNER JOIN dbo.proveedor p 
	ON f.importe_tipo = p.tipoGasto 
    AND f.consorcio_nombre = p.consorcio;
-- Check Tabla
SELECT * 
FROM dbo.factura_con_proveedores;
GO


-- CHECK PAGOS
EXEC dbo.sp_ImportarPagos
	@RutaArchivo = 'C:\TPBDA\consorcios\pagos_consorcios.csv'
-- CHECK tabla
SELECT * 
FROM dbo.pago


-- PROBAMOS API
EXEC sp_configure 'show advanced options', 1;	--Este es para poder editar los permisos avanzados.
RECONFIGURE;
GO
EXEC sp_configure 'Ole Automation Procedures', 1;	-- Aqui habilitamos esta opcion avanzada
RECONFIGURE;
GO



-- INFORME 3