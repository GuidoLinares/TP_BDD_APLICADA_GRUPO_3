USE [TP_BASE_DE_DATOS_2025_GRUPO_3]
GO

-- =====================================================================================
-- Reporte 3: Tabla Cruzada de Recaudación por Tipo y Periodo (CORREGIDO)
-- =====================================================================================
-- Estrategia: Vincular pagos con expensas por consorcio y periodo (mes/año)
-- =====================================================================================

PRINT '--- Creando SP para Reporte 3: Recaudación por Tipo y Periodo ---';
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_Reporte_3_RecaudacionPorTipo]
    @Anio INT,                              -- Año obligatorio
    @ConsorcioNombre VARCHAR(100) = NULL    -- Filtro opcional por consorcio
AS
BEGIN
    SET NOCOUNT ON;
    SET LANGUAGE Spanish;

    -- =====================================================================================
    -- VALIDACIÓN DE PARÁMETROS
    -- =====================================================================================
    IF @Anio IS NULL
    BEGIN
        RAISERROR('El parámetro @Anio es obligatorio', 16, 1);
        RETURN;
    END

    PRINT '========================================';
    PRINT 'REPORTE 3: Recaudación por Tipo y Periodo';
    PRINT 'Año: ' + CAST(@Anio AS VARCHAR(4));
    IF @ConsorcioNombre IS NOT NULL
        PRINT 'Consorcio: ' + @ConsorcioNombre;
    PRINT '========================================';
    PRINT '';

    -- =====================================================================================
    -- ESTRATEGIA CORREGIDA:
    -- =====================================================================================
    -- 1. pago → propietario/inquilino (por CBUVCVU)
    -- 2. propietario/inquilino → unidadFuncional_has_persona → unidadFuncional → consorcio
    -- 3. Mismo consorcio: expensa (por mes/año) → factura (importe_tipo)
    -- 4. Clasificar gastos de expensa como Ordinarios/Extraordinarios
    -- =====================================================================================

    -- Crear tabla de todos los meses
    ;WITH TodosLosMeses AS (
        SELECT 1 AS MesNumero, 'Enero' AS NombreMes
        UNION ALL SELECT 2, 'Febrero'
        UNION ALL SELECT 3, 'Marzo'
        UNION ALL SELECT 4, 'Abril'
        UNION ALL SELECT 5, 'Mayo'
        UNION ALL SELECT 6, 'Junio'
        UNION ALL SELECT 7, 'Julio'
        UNION ALL SELECT 8, 'Agosto'
        UNION ALL SELECT 9, 'Septiembre'
        UNION ALL SELECT 10, 'Octubre'
        UNION ALL SELECT 11, 'Noviembre'
        UNION ALL SELECT 12, 'Diciembre'
    ),

    -- Obtener recaudación por mes y consorcio
    RecaudacionPorConsorcio AS (
        SELECT 
            MONTH(p.fecha) AS MesNumero,
            DATENAME(MONTH, p.fecha) AS NombreMes,
            c.idconsorcio,
            c.nombre AS ConsorcioNombre,
            SUM(p.importe) AS TotalRecaudado
            
        FROM dbo.pago p
        
        -- Vincular con propietario
        LEFT JOIN dbo.propietario prop 
            ON LTRIM(RTRIM(p.cuenta_origen)) = LTRIM(RTRIM(prop.CBUVCVU))
        
        -- Vincular con inquilino
        LEFT JOIN dbo.inquilino inq 
            ON LTRIM(RTRIM(p.cuenta_origen)) = LTRIM(RTRIM(inq.CBUVCVU))
        
        -- Vincular con unidadFuncional_has_persona
        INNER JOIN dbo.unidadFuncional_has_persona rel 
            ON (prop.idPropietario IS NOT NULL AND rel.propietario_idPropietario = prop.idPropietario)
            OR (inq.idInquilino IS NOT NULL AND rel.inquilino_idInquilino = inq.idInquilino)
        
        -- Vincular con unidadFuncional
        INNER JOIN dbo.unidadFuncional uf 
            ON rel.unidadFuncional_idunidadFuncional = uf.idunidadFuncional
        
        -- Vincular con consorcio
        INNER JOIN dbo.consorcio c 
            ON uf.consorcio_idconsorcio = c.idconsorcio
        
        WHERE 
            YEAR(p.fecha) = @Anio
            AND p.importe > 0
            AND (@ConsorcioNombre IS NULL OR c.nombre = @ConsorcioNombre)
        
        GROUP BY MONTH(p.fecha), DATENAME(MONTH, p.fecha), c.idconsorcio, c.nombre
    ),

    -- Obtener gastos por tipo desde expensas del mismo periodo
    GastosPorTipo AS (
        SELECT 
            e.mes AS MesNumero,
            e.consorcio_idconsorcio,
            SUM(ISNULL(e.total_gastos_ordinarios, 0)) AS Gastos_Ordinarios,
            SUM(ISNULL(e.total_gastos_extraordinarios, 0)) AS Gastos_Extraordinarios
        FROM dbo.expensa e
        WHERE e.ano = @Anio
        GROUP BY e.mes, e.consorcio_idconsorcio
    ),

    -- Combinar recaudación con clasificación de gastos
    RecaudacionClasificada AS (
        SELECT 
            r.MesNumero,
            r.NombreMes,
            r.TotalRecaudado,
            
            -- Calcular proporción según gastos del periodo
            CASE 
                WHEN (ISNULL(g.Gastos_Ordinarios, 0) + ISNULL(g.Gastos_Extraordinarios, 0)) > 0 THEN
                    r.TotalRecaudado * (ISNULL(g.Gastos_Ordinarios, 0) / 
                        (ISNULL(g.Gastos_Ordinarios, 0) + ISNULL(g.Gastos_Extraordinarios, 0)))
                ELSE r.TotalRecaudado  -- Si no hay clasificación, todo es ordinario
            END AS Recaudacion_Ordinaria,
            
            CASE 
                WHEN (ISNULL(g.Gastos_Ordinarios, 0) + ISNULL(g.Gastos_Extraordinarios, 0)) > 0 THEN
                    r.TotalRecaudado * (ISNULL(g.Gastos_Extraordinarios, 0) / 
                        (ISNULL(g.Gastos_Ordinarios, 0) + ISNULL(g.Gastos_Extraordinarios, 0)))
                ELSE 0
            END AS Recaudacion_Extraordinaria
            
        FROM RecaudacionPorConsorcio r
        LEFT JOIN GastosPorTipo g 
            ON r.MesNumero = g.MesNumero 
            AND r.idconsorcio = g.consorcio_idconsorcio
    ),

    -- Agregar por mes
    RecaudacionAgregada AS (
        SELECT 
            MesNumero,
            NombreMes,
            SUM(Recaudacion_Ordinaria) AS Total_Ordinario,
            SUM(Recaudacion_Extraordinaria) AS Total_Extraordinario
        FROM RecaudacionClasificada
        GROUP BY MesNumero, NombreMes
    ),

    -- Completar con todos los meses
    RecaudacionCompleta AS (
        SELECT 
            m.MesNumero,
            m.NombreMes,
            ISNULL(r.Total_Ordinario, 0) AS Total_Ordinario,
            ISNULL(r.Total_Extraordinario, 0) AS Total_Extraordinario
        FROM TodosLosMeses m
        LEFT JOIN RecaudacionAgregada r ON m.MesNumero = r.MesNumero
    )

    -- Resultado final
    SELECT 
        MesNumero,
        NombreMes AS Periodo,
        CAST(Total_Ordinario AS DECIMAL(12,2)) AS Ordinario,
        CAST(Total_Extraordinario AS DECIMAL(12,2)) AS Extraordinario,
        CAST((Total_Ordinario + Total_Extraordinario) AS DECIMAL(12,2)) AS Total_Periodo
    FROM RecaudacionCompleta
    ORDER BY MesNumero;

    SET NOCOUNT OFF;
END
GO

-- =====================================================================================
-- SP ALTERNATIVO: Reporte por TIPO DE FACTURA (detallado)
-- =====================================================================================

CREATE OR ALTER PROCEDURE [dbo].[sp_Reporte_3_RecaudacionPorTipoDetallado]
    @Anio INT,                              
    @ConsorcioNombre VARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET LANGUAGE Spanish;

    IF @Anio IS NULL
    BEGIN
        RAISERROR('El parámetro @Anio es obligatorio', 16, 1);
        RETURN;
    END

    PRINT '========================================';
    PRINT 'REPORTE 3 DETALLADO: Por Tipo de Gasto';
    PRINT '========================================';

    -- Obtener tipos de gasto desde facturas vinculadas a expensas del año
    ;WITH TodosLosMeses AS (
        SELECT 1 AS MesNumero, 'Enero' AS NombreMes
        UNION ALL SELECT 2, 'Febrero'
        UNION ALL SELECT 3, 'Marzo'
        UNION ALL SELECT 4, 'Abril'
        UNION ALL SELECT 5, 'Mayo'
        UNION ALL SELECT 6, 'Junio'
        UNION ALL SELECT 7, 'Julio'
        UNION ALL SELECT 8, 'Agosto'
        UNION ALL SELECT 9, 'Septiembre'
        UNION ALL SELECT 10, 'Octubre'
        UNION ALL SELECT 11, 'Noviembre'
        UNION ALL SELECT 12, 'Diciembre'
    ),

    GastosPorTipo AS (
        SELECT 
            e.mes AS MesNumero,
            f.importe_tipo,
            SUM(f.importe) AS TotalGasto
        FROM dbo.expensa e
        INNER JOIN dbo.factura f ON e.idExpensa = f.idExpensa
        INNER JOIN dbo.consorcio c ON e.consorcio_idconsorcio = c.idconsorcio
        WHERE 
            e.ano = @Anio
            AND (@ConsorcioNombre IS NULL OR c.nombre = @ConsorcioNombre)
            AND f.importe_tipo IS NOT NULL
        GROUP BY e.mes, f.importe_tipo
    )

    SELECT 
        m.MesNumero,
        m.NombreMes AS Mes,
        ISNULL([ADMINISTRACION], 0.00) AS Administracion,
        ISNULL([BANCARIOS], 0.00) AS Bancarios,
        ISNULL([GASTOS GENERALES], 0.00) AS Gastos_Generales,
        ISNULL([LIMPIEZA], 0.00) AS Limpieza,
        ISNULL([SEGUROS], 0.00) AS Seguros,
        ISNULL([SERVICIOS PUBLICOS AGUA], 0.00) AS Agua,
        ISNULL([SERVICIOS PUBLICOS LUZ], 0.00) AS Luz,
        (
            ISNULL([ADMINISTRACION], 0) + ISNULL([BANCARIOS], 0) + 
            ISNULL([GASTOS GENERALES], 0) + ISNULL([LIMPIEZA], 0) +
            ISNULL([SEGUROS], 0) + ISNULL([SERVICIOS PUBLICOS AGUA], 0) + 
            ISNULL([SERVICIOS PUBLICOS LUZ], 0)
        ) AS Total_Mes
    FROM TodosLosMeses m
    LEFT JOIN (
        SELECT * FROM GastosPorTipo
        PIVOT (
            SUM(TotalGasto)
            FOR importe_tipo IN (
                [ADMINISTRACION], [BANCARIOS], [GASTOS GENERALES], [LIMPIEZA],
                [SEGUROS], [SERVICIOS PUBLICOS AGUA], [SERVICIOS PUBLICOS LUZ]
            )
        ) AS PivotTable
    ) p ON m.MesNumero = p.MesNumero
    ORDER BY m.MesNumero;

    SET NOCOUNT OFF;
END
GO

PRINT '--- SPs creados exitosamente. ---';
PRINT '';
PRINT '========================================';
PRINT 'EJEMPLOS DE USO:';
PRINT '========================================';
PRINT '';
PRINT '-- 1) Reporte por Ordinario/Extraordinario:';
PRINT 'EXEC sp_Reporte_3_RecaudacionPorTipo @Anio = 2025;';
PRINT '';
PRINT '-- 2) Reporte DETALLADO por tipo de gasto:';
PRINT 'EXEC sp_Reporte_3_RecaudacionPorTipoDetallado @Anio = 2025;';
PRINT '';
PRINT '-- 3) Filtrado por consorcio:';
PRINT 'EXEC sp_Reporte_3_RecaudacionPorTipo @Anio = 2025, @ConsorcioNombre = ''Azcuenaga'';';
PRINT '';
PRINT '========================================';
GO