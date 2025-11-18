USE [TP_BDD_FINAL]
GO

CREATE OR ALTER PROCEDURE sp_Reporte_6_dias_entre_pagos
(
    @ConsorcioId INT = NULL,
    @FechaDesde DATE = NULL,
    @FechaHasta DATE = NULL
)
AS
BEGIN
    SET NOCOUNT ON;

    -- ============================================
    -- CTE: Ordena pagos por unidad funcional
    -- ============================================
    WITH PagosOrdenados AS (
        SELECT 
            uf.idUnidadFuncional AS uf_id,
            uf.consorcio_idconsorcio AS consorcio_id,
            p.fecha AS fecha_pago,
            LAG(p.fecha) OVER (
                PARTITION BY uf.idUnidadFuncional
                ORDER BY p.fecha
            ) AS fecha_pago_anterior
        FROM pago p 
		INNER JOIN	dbo.persona per
		ON per.CBUVCVU = p.cuenta_origen AND per.idTipoPersona_FK = 2
		INNER JOIN dbo.unidadFuncional uf
		ON per.idUnidadFuncional_FK = uf.idunidadFuncional
        WHERE
            (@ConsorcioId IS NULL OR uf.consorcio_idconsorcio = @ConsorcioId)
            AND (@FechaDesde IS NULL OR p.fecha >= @FechaDesde)
            AND (@FechaHasta IS NULL OR p.fecha <= @FechaHasta)
    )

    -- ============================================
    -- Resultado final
    -- ============================================
    SELECT
        uf_id AS UnidadFuncional,
        fecha_pago_anterior AS Fecha_Pago_Anterior,
        fecha_pago AS Fecha_Pago_Actual,
        DATEDIFF(DAY, fecha_pago_anterior, fecha_pago) AS Dias_Entre_Pagos
    FROM PagosOrdenados
    WHERE fecha_pago_anterior IS NOT NULL
    ORDER BY uf_id, fecha_pago;
END;
GO