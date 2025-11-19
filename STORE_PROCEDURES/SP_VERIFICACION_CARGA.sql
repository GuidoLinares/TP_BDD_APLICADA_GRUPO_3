USE ENTREGA_FINAL_BDD_GRUPO_3
GO

-- 1. VERIFICAR CONSORCIOS (sp_ImportarConsorcios)
-- ============================================================================
PRINT '========================================';
PRINT '1. VERIFICACIÓN DE CONSORCIOS';
PRINT '========================================';

SELECT 
    COUNT(*) AS TotalConsorcios,
    COUNT(CASE WHEN numeroConsorcio IS NOT NULL THEN 1 END) AS ConNumero,
    COUNT(CASE WHEN nombre IS NOT NULL THEN 1 END) AS ConNombre,
    COUNT(CASE WHEN direccion IS NOT NULL THEN 1 END) AS ConDireccion
FROM dbo.consorcio;

SELECT TOP 5 * FROM dbo.consorcio ORDER BY idconsorcio;


-- 2. VERIFICAR UNIDADES FUNCIONALES (sp_ImportarUnidadesFuncionales)
-- ============================================================================
PRINT '';
PRINT '========================================';
PRINT '2. VERIFICACIÓN DE UNIDADES FUNCIONALES';
PRINT '========================================';

SELECT 
    COUNT(*) AS TotalUnidadesFuncionales,
    COUNT(DISTINCT consorcio_idconsorcio) AS ConsorciosConUF,
    COUNT(CASE WHEN metros_cuadrados IS NOT NULL THEN 1 END) AS ConM2,
    MIN(piso) AS PisoMinimo,
    MAX(piso) AS PisoMaximo
FROM dbo.unidadFuncional;

-- Detalle por consorcio
SELECT 
    c.nombre AS Consorcio,
    COUNT(uf.idunidadFuncional) AS CantidadUF,
    SUM(uf.metros_cuadrados) AS M2Totales
FROM dbo.consorcio c
LEFT JOIN dbo.unidadFuncional uf ON c.idconsorcio = uf.consorcio_idconsorcio
GROUP BY c.nombre
ORDER BY c.nombre;


-- 3. VERIFICAR PERSONAS (sp_ImportaInquilinos)
-- ============================================================================
PRINT '';
PRINT '========================================';
PRINT '3. VERIFICACIÓN DE PERSONAS';
PRINT '========================================';

SELECT 
    COUNT(*) AS TotalPersonas,
    COUNT(CASE WHEN idTipoPersona_FK IS NOT NULL THEN 1 END) AS ConTipoPersona,
    COUNT(CASE WHEN Email IS NOT NULL THEN 1 END) AS ConEmail,
    COUNT(CASE WHEN CBUVCVU IS NOT NULL THEN 1 END) AS ConCBUCVU,
    COUNT(CASE WHEN idUnidadFuncional_FK IS NOT NULL THEN 1 END) AS VinculadasAUF
FROM dbo.persona;

-- Distribución por tipo de persona
SELECT 
    tp.descripcion AS TipoPersona,
    COUNT(p.idPersona) AS Cantidad
FROM dbo.tipoPersona tp
LEFT JOIN dbo.persona p ON tp.idTipoPersona = p.idTipoPersona_FK
GROUP BY tp.descripcion;

-- Verificar personas con UF asignada
SELECT TOP 5
    p.Nombre,
    p.Apellido,
    p.DNI,
    tp.descripcion AS TipoPersona,
    c.nombre AS Consorcio,
    uf.piso,
    uf.descripcion_identificacion AS Depto
FROM dbo.persona p
INNER JOIN dbo.tipoPersona tp ON p.idTipoPersona_FK = tp.idTipoPersona
LEFT JOIN dbo.unidadFuncional uf ON p.idUnidadFuncional_FK = uf.idunidadFuncional
LEFT JOIN dbo.consorcio c ON uf.consorcio_idconsorcio = c.idconsorcio
WHERE p.idUnidadFuncional_FK IS NOT NULL;


-- 4. VERIFICAR RELACIÓN PERSONA-UF (sp_ImportaRelacionUF_Personas)
-- ============================================================================
PRINT '';
PRINT '========================================';
PRINT '4. VERIFICACIÓN RELACIÓN PERSONA-UF';
PRINT '========================================';

SELECT 
    COUNT(DISTINCT p.idPersona) AS PersonasVinculadas,
    COUNT(DISTINCT uf.idunidadFuncional) AS UFConPersonas,
    COUNT(DISTINCT c.idconsorcio) AS ConsorciosConPersonas
FROM dbo.persona p
INNER JOIN dbo.unidadFuncional uf ON p.idUnidadFuncional_FK = uf.idunidadFuncional
INNER JOIN dbo.consorcio c ON uf.consorcio_idconsorcio = c.idconsorcio;

-- UF sin personas asignadas
SELECT 
    c.nombre AS Consorcio,
    COUNT(uf.idunidadFuncional) AS UFSinPersonas
FROM dbo.unidadFuncional uf
INNER JOIN dbo.consorcio c ON uf.consorcio_idconsorcio = c.idconsorcio
LEFT JOIN dbo.persona p ON p.idUnidadFuncional_FK = uf.idunidadFuncional
WHERE p.idPersona IS NULL
GROUP BY c.nombre;


-- 5. VERIFICAR PAGOS (sp_ImportaPagos)
-- ============================================================================
PRINT '';
PRINT '========================================';
PRINT '5. VERIFICACIÓN DE PAGOS';
PRINT '========================================';

SELECT 
    COUNT(*) AS TotalPagos,
    COUNT(CASE WHEN fecha IS NOT NULL THEN 1 END) AS ConFecha,
    COUNT(CASE WHEN importe > 0 THEN 1 END) AS ConImporteValido,
    COUNT(CASE WHEN cuenta_origen IS NOT NULL THEN 1 END) AS ConCuentaOrigen,
    MIN(fecha) AS FechaMasAntigua,
    MAX(fecha) AS FechaMasReciente,
    SUM(importe) AS TotalImporte
FROM dbo.pago;

SELECT TOP 5 * FROM dbo.pago ORDER BY fecha DESC;


-- 6. VERIFICAR SERVICIOS (sp_importar_servicios_json)
-- ============================================================================
PRINT '';
PRINT '========================================';
PRINT '6. VERIFICACIÓN DE SERVICIOS Y FACTURAS';
PRINT '========================================';

-- Facturas generadas
SELECT 
    COUNT(*) AS TotalFacturas,
    COUNT(DISTINCT consorcio_nombre) AS ConsorciosConFacturas,
    COUNT(DISTINCT mes) AS MesesConFacturas,
    SUM(importe) AS ImporteTotal,
    COUNT(CASE WHEN es_dolar = 1 THEN 1 END) AS FacturasEnDolares
FROM dbo.factura;

-- Servicios vinculados a facturas
SELECT 
    COUNT(*) AS TotalServicios,
    COUNT(DISTINCT nombre_empresa) AS EmpresasDistintas,
    COUNT(DISTINCT factura_idFactura) AS FacturasConServicio
FROM dbo.servicio;

-- Detalle de servicios por consorcio
SELECT 
    f.consorcio_nombre AS Consorcio,
    f.mes AS Mes,
    COUNT(s.idServicio) AS CantidadServicios,
    SUM(f.importe) AS TotalGastos
FROM dbo.factura f
INNER JOIN dbo.servicio s ON f.idFactura = s.factura_idFactura
GROUP BY f.consorcio_nombre, f.mes
ORDER BY f.consorcio_nombre, f.mes;

-- Expensas generadas
SELECT 
    COUNT(*) AS TotalExpensas,
    COUNT(DISTINCT consorcio_idconsorcio) AS ConsorciosConExpensas,
    COUNT(DISTINCT CONCAT(mes, '-', ano)) AS PeriodosDistintos
FROM dbo.expensa;



PRINT '';
PRINT '========================================';
PRINT '7. VERIFICACIÓN DE PROVEEDORES ';
PRINT '========================================';
select*
from proveedor 




-- 8. RESUMEN GENERAL
-- ============================================================================
PRINT '';
PRINT '========================================';
PRINT '8. RESUMEN GENERAL DEL SISTEMA';
PRINT '========================================';

SELECT 
    'Consorcios' AS Entidad,
    COUNT(*) AS Cantidad
FROM dbo.consorcio
UNION ALL
SELECT 'Unidades Funcionales', COUNT(*) FROM dbo.unidadFuncional
UNION ALL
SELECT 'Personas', COUNT(*) FROM dbo.persona
UNION ALL
SELECT 'Pagos', COUNT(*) FROM dbo.pago
UNION ALL
SELECT 'Facturas', COUNT(*) FROM dbo.factura
UNION ALL
SELECT 'Servicios', COUNT(*) FROM dbo.servicio
UNION ALL
SELECT 'Expensas', COUNT(*) FROM dbo.expensa
ORDER BY Entidad;


