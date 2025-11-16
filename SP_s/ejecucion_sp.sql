use TP_BASE_DE_DATOS_2025_GRUPO_3
go

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
PRINT '=====================================================';
PRINT '--- 1. VERIFICACIÓN: sp_ImportarConsorcios ---';
PRINT '=====================================================';
--FUNCIONA

-- 1.1 EJECUCIÓN
EXEC dbo.sp_ImportarConsorcios @RutaArchivo = 'S:\Desktop\TP_BDD_APLICADA_GRUPO_3\consorcios\Consorcios.csv';
GO

-- 1.2. CONSULTAS DE VALIDACIÓN
SELECT 
    'Consorcio' AS Tabla, 
    COUNT(idconsorcio) AS Total_Cargado,
    COUNT(DISTINCT numeroConsorcio) AS Unicidad_Numero
FROM dbo.consorcio;
GO

-- 1.3. VERIFICACIÓN DE INTEGRIDAD
SELECT
    CASE WHEN COUNT(*) = 5 THEN 'OK' ELSE 'ERROR: Faltan/Sobran Consorcios' END AS Estado_Conteo,
    CASE WHEN COUNT(idconsorcio) = COUNT(DISTINCT numeroConsorcio) THEN 'OK' ELSE 'ERROR: Duplicados en numeroConsorcio' END AS Estado_Unicidad
FROM dbo.consorcio;



SELECT *
FROM consorcio

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


PRINT '=====================================================';
PRINT '--- 2. VERIFICACIÓN: sp_ImportaInquilinos ---';
PRINT '=====================================================';
-- FUNCIONA

-- 2.1 EJECUCIÓN
EXEC dbo.sp_ImportaInquilinos @RutaArchivo = 'S:\Desktop\TP_BDD_APLICADA_GRUPO_3\consorcios\Inquilino-propietarios-datos.csv';
GO

-- 2.2. CONSULTAS DE VALIDACIÓN
SELECT 
    'Propietarios' AS Tabla, COUNT(*) AS Total, COUNT(DISTINCT DNI) AS DNI_Unicos 
FROM dbo.propietario
UNION ALL
SELECT 
    'Inquilinos' AS Tabla, COUNT(*) AS Total, COUNT(DISTINCT DNI) AS DNI_Unicos 
FROM dbo.inquilino;
GO

-- 2.3. VERIFICACIÓN DE INTEGRIDAD (DNI y Solapamiento)
DECLARE @TotalDNI INT = 177;
DECLARE @DNI_Unicos_Personas INT = (SELECT COUNT(DISTINCT DNI) FROM dbo.propietario) + (SELECT COUNT(DISTINCT DNI) FROM dbo.inquilino);

SELECT 
    CASE WHEN @DNI_Unicos_Personas <= @TotalDNI THEN 'OK' ELSE 'ERROR: Solapamiento o Sobrecarga' END AS Estado_Integridad,
    @DNI_Unicos_Personas AS DNI_Totales_Cargados;


----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

PRINT '=====================================================';
PRINT '--- 3. VERIFICACIÓN: sp_ImportaPagos ---';
PRINT '=====================================================';
-- FUNCIONA

-- 3.1 EJECUCIÓN
EXEC dbo.sp_ImportaPagos @RutaArchivo = 'S:\Desktop\TP_BDD_APLICADA_GRUPO_3\consorcios\pagos_consorcios.csv';
GO

-- 3.2. CONSULTAS DE VALIDACIÓN
SELECT 
    'Pagos' AS Tabla, 
    COUNT(idPago) AS Total_Cargado,
    MIN(idPago) AS Min_ID,
    MAX(idPago) AS Max_ID
FROM dbo.pago;
GO

-- 3.3. VERIFICACIÓN DE INTEGRIDAD
SELECT *
FROM dbo.pago;


----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
PRINT '=====================================================';
PRINT '--- 4. VERIFICACIÓN: sp_ImportarUnidadesFuncionales ---';
PRINT '=====================================================';
-- FUNCIONA 


-- 4.1 EJECUCIÓN (Depende de Consorcios)
EXEC dbo.sp_ImportarUnidadesFuncionales @RutaArchivo = 'S:\Desktop\TP_BDD_APLICADA_GRUPO_3\consorcios\UF por consorcio.txt';
GO

-- 4.2. CONSULTAS DE VALIDACIÓN

-- CONTEO Y UNICIDAD
SELECT 
    'Unidades Funcionales' AS Tabla, 
    COUNT(idunidadFuncional) AS Total_Cargado,
    COUNT(DISTINCT consorcio_idconsorcio) AS Consorcios_Asignados
FROM dbo.unidadFuncional;
GO

-- VERIFICACIÓN DE INTEGRIDAD REFERENCIAL (Debe devolver 0)
-- Busca UF que tengan un idconsorcio que no existe en la tabla consorcio.
SELECT 
    *
FROM dbo.unidadFuncional UF
inner join consorcio c on c.idconsorcio = consorcio_idconsorcio
GO

-- VERIFICACIÓN DE LÓGICA DE NEGOCIO (PB -> Piso 0)
-- Verifica si la lógica de mapeo 'PB' a piso = 0 funcionó correctamente.
SELECT 
    'UFs en Planta Baja (Piso 0)' AS Estado, 
    COUNT(*) AS UFs_Piso_Cero
FROM dbo.unidadFuncional
WHERE piso = 0;


----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

PRINT '=====================================================';
PRINT '--- 5. VERIFICACIÓN: sp_importar_servicios_json ---';
PRINT '=====================================================';
--FUNCIONA


-- 5.1 EJECUCIÓN (Depende de Consorcios)
EXEC dbo.sp_ImportarFacturas
    @RutaArchivo = 'S:\Desktop\TP_BDD_APLICADA_GRUPO_3\consorcios\Servicios.Servicios.json'
GO

-- 5.2. CONSULTAS DE VALIDACIÓN

-- CONTEO DE ENTIDADES CREADAS
SELECT 
    'Expensas Creadas' AS Entidad, COUNT(*) AS Total
FROM dbo.expensa
UNION ALL
SELECT 
    'Facturas (Gastos)' AS Entidad, COUNT(*) AS Total
FROM dbo.factura


-- 5.3. VERIFICACIÓN DE LA CARGA DE MONTO (Muestra un ejemplo de un monto procesado)
-- Muestra algunos montos para confirmar que la lógica avanzada de conversión de moneda funcionó.
SELECT
    F.consorcio_nombre,
    F.mes,
    F.importe_tipo AS Tipo_Gasto,
    F.importe AS Monto_Procesado
FROM dbo.factura F
WHERE F.importe IS NOT NULL
ORDER BY F.importe DESC;














