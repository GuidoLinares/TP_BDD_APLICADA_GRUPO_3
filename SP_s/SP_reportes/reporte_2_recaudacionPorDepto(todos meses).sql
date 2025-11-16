USE [TP_BASE_DE_DATOS_2025_GRUPO_3]
GO

-- =====================================================================================
-- Reporte 2: Tabla Cruzada de Recaudación por Mes y Departamento (CORREGIDO)
-- =====================================================================================
-- Objetivo: Mostrar recaudación mensual agrupada por departamento en formato PIVOT
-- Filas: Meses del año | Columnas: Departamentos (A, B, C, D, E, etc.)
-- =====================================================================================

PRINT '--- Creando SP para Reporte 2: Tabla Cruzada de Recaudación ---';
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_Reporte_2_RecaudacionPorDepto]
    @Anio INT,                              -- Año obligatorio
    @ConsorcioNombre VARCHAR(100) = NULL,   -- Filtro opcional por consorcio
    @Piso INT = NULL                        -- Filtro opcional por piso
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Configurar idioma español para nombres de meses
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
    PRINT 'REPORTE 2: Recaudación por Mes y Departamento';
    PRINT 'Año: ' + CAST(@Anio AS VARCHAR(4));
    IF @ConsorcioNombre IS NOT NULL
        PRINT 'Consorcio: ' + @ConsorcioNombre;
    IF @Piso IS NOT NULL
        PRINT 'Piso: ' + CAST(@Piso AS VARCHAR(10));
    PRINT '========================================';
    PRINT '';

    -- =====================================================================================
    -- ESTRATEGIA DE VINCULACIÓN:
    -- =====================================================================================
    -- pago (cuenta_origen) → propietario/inquilino (CBUVCVU)
    -- propietario/inquilino (id) → unidadFuncional_has_persona (FK)
    -- unidadFuncional_has_persona → unidadFuncional → consorcio
    -- =====================================================================================

    -- Crear tabla de TODOS los meses (1-12) para mostrar incluso los sin datos
    ;WITH TodosLosMeses AS (
        SELECT 1 AS MesNumero, 'enero' AS NombreMes
        UNION ALL SELECT 2, 'febrero'
        UNION ALL SELECT 3, 'marzo'
        UNION ALL SELECT 4, 'abril'
        UNION ALL SELECT 5, 'mayo'
        UNION ALL SELECT 6, 'junio'
        UNION ALL SELECT 7, 'julio'
        UNION ALL SELECT 8, 'agosto'
        UNION ALL SELECT 9, 'septiembre'
        UNION ALL SELECT 10, 'octubre'
        UNION ALL SELECT 11, 'noviembre'
        UNION ALL SELECT 12, 'diciembre'
    ),
    
    PagosConDepartamento AS (
        SELECT 
            MONTH(p.fecha) AS MesNumero,
            DATENAME(MONTH, p.fecha) AS NombreMes,
            p.importe,
            uf.descripcion_identificacion AS Departamento,
            uf.piso,
            c.nombre AS ConsorcioNombre
            
        FROM dbo.pago p
        
        -- Vincular pago con propietario por CBU/CVU
        LEFT JOIN dbo.propietario prop 
            ON LTRIM(RTRIM(p.cuenta_origen)) = LTRIM(RTRIM(prop.CBUVCVU))
        
        -- Vincular pago con inquilino por CBU/CVU
        LEFT JOIN dbo.inquilino inq 
            ON LTRIM(RTRIM(p.cuenta_origen)) = LTRIM(RTRIM(inq.CBUVCVU))
        
        -- Vincular con la tabla de relación N:M
        INNER JOIN dbo.unidadFuncional_has_persona rel 
            ON (prop.idPropietario IS NOT NULL AND rel.propietario_idPropietario = prop.idPropietario)
            OR (inq.idInquilino IS NOT NULL AND rel.inquilino_idInquilino = inq.idInquilino)
        
        -- Vincular con unidad funcional
        INNER JOIN dbo.unidadFuncional uf 
            ON rel.unidadFuncional_idunidadFuncional = uf.idunidadFuncional
        
        -- Vincular con consorcio
        INNER JOIN dbo.consorcio c 
            ON uf.consorcio_idconsorcio = c.idconsorcio
        
        WHERE
            -- Filtro obligatorio por año
            YEAR(p.fecha) = @Anio
            
            -- Filtros opcionales
            AND (@ConsorcioNombre IS NULL OR c.nombre = @ConsorcioNombre)
            AND (@Piso IS NULL OR uf.piso = @Piso)
            
            -- Asegurar que hay vinculación válida
            AND uf.descripcion_identificacion IS NOT NULL
            AND p.importe > 0  -- Solo pagos con importe positivo
    ),

    -- Agregar recaudación por mes y departamento
    RecaudacionAgregada AS (
        SELECT 
            MesNumero,
            NombreMes,
            Departamento,
            SUM(importe) AS TotalRecaudado
        FROM PagosConDepartamento
        GROUP BY MesNumero, NombreMes, Departamento
    ),
    
    -- Combinar TODOS los meses con los datos (LEFT JOIN para incluir meses sin datos)
    RecaudacionCompleta AS (
        SELECT 
            m.MesNumero,
            m.NombreMes,
            ISNULL(r.Departamento, 'A') AS Departamento,  -- Default 'A' para meses sin datos
            ISNULL(r.TotalRecaudado, 0) AS TotalRecaudado
        FROM TodosLosMeses m
        LEFT JOIN RecaudacionAgregada r ON m.MesNumero = r.MesNumero
    )

    -- =====================================================================================
    -- PIVOT: Convertir departamentos en columnas
    -- =====================================================================================
    -- =====================================================================================
    -- OPCIÓN 1: Solo departamentos existentes (A-E) - MÁS LIMPIO - CON TODOS LOS MESES
    -- =====================================================================================
    SELECT 
        MesNumero,
        NombreMes AS Mes,
        ISNULL([A], 0.00) AS Depto_A,
        ISNULL([B], 0.00) AS Depto_B,
        ISNULL([C], 0.00) AS Depto_C,
        ISNULL([D], 0.00) AS Depto_D,
        ISNULL([E], 0.00) AS Depto_E,
        -- Total por mes
        (ISNULL([A], 0) + ISNULL([B], 0) + ISNULL([C], 0) + ISNULL([D], 0) + ISNULL([E], 0)) AS Total_Mes
    FROM RecaudacionCompleta
    PIVOT (
        SUM(TotalRecaudado)
        FOR Departamento IN ([A], [B], [C], [D], [E])
    ) AS PivotTable
    ORDER BY MesNumero;
    
    -- =====================================================================================
    -- OPCIÓN 2: Si necesitas todos los departamentos A-J (incluso los que no existen)
    -- =====================================================================================
    /*
    SELECT 
        MesNumero,
        NombreMes AS Mes,
        ISNULL([A], 0.00) AS Depto_A,
        ISNULL([B], 0.00) AS Depto_B,
        ISNULL([C], 0.00) AS Depto_C,
        ISNULL([D], 0.00) AS Depto_D,
        ISNULL([E], 0.00) AS Depto_E,
        ISNULL([F], 0.00) AS Depto_F,
        ISNULL([G], 0.00) AS Depto_G,
        ISNULL([H], 0.00) AS Depto_H,
        ISNULL([I], 0.00) AS Depto_I,
        ISNULL([J], 0.00) AS Depto_J,
        -- Total por mes
        (
            ISNULL([A], 0) + ISNULL([B], 0) + ISNULL([C], 0) + ISNULL([D], 0) + 
            ISNULL([E], 0) + ISNULL([F], 0) + ISNULL([G], 0) + ISNULL([H], 0) +
            ISNULL([I], 0) + ISNULL([J], 0)
        ) AS Total_Mes
    FROM RecaudacionAgregada
    PIVOT (
        SUM(TotalRecaudado)
        FOR Departamento IN ([A], [B], [C], [D], [E], [F], [G], [H], [I], [J])
    ) AS PivotTable
    ORDER BY MesNumero;
    */

    SET NOCOUNT OFF;
END
GO

PRINT '--- SP [sp_Reporte_2_RecaudacionPorDepto] creado exitosamente. ---';
PRINT '';
PRINT '========================================';
PRINT 'EJEMPLOS DE USO:';
PRINT '========================================';
PRINT '';
PRINT '-- 1) Recaudación de todo el año 2025:';
PRINT 'EXEC sp_Reporte_2_RecaudacionPorDepto @Anio = 2025;';
PRINT '';
PRINT '-- 2) Filtrado por consorcio específico:';
PRINT 'EXEC sp_Reporte_2_RecaudacionPorDepto @Anio = 2025, @ConsorcioNombre = ''Azcuenaga'';';
PRINT '';
PRINT '-- 3) Filtrado por piso específico:';
PRINT 'EXEC sp_Reporte_2_RecaudacionPorDepto @Anio = 2025, @Piso = 1;';
PRINT '';
PRINT '-- 4) Filtrado por consorcio y piso:';
PRINT 'EXEC sp_Reporte_2_RecaudacionPorDepto @Anio = 2025, @ConsorcioNombre = ''Alzaga'', @Piso = 2;';
PRINT '';
PRINT '========================================';
GO