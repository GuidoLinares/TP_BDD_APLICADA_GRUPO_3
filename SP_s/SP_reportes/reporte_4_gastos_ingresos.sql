USE [TP_BDD_FINAL]
GO

CREATE OR ALTER PROCEDURE [dbo].[reporte_4_gastos_ingresos]
    @IdConsorcio INT = NULL,
    @AnioDesde INT = NULL,
    @AnioHasta INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP 5
        ano,
        mes,
        TotalIngresos = (ingresos_termino + ingresos_adjudicadas + ingresos_adelantadas)
    FROM dbo.expensa
    WHERE 
        (@IdConsorcio IS NULL OR consorcio_idconsorcio = @IdConsorcio)
        AND (@AnioDesde IS NULL OR ano >= @AnioDesde)
        AND (@AnioHasta IS NULL OR ano <= @AnioHasta)
    ORDER BY TotalIngresos DESC;


    SELECT TOP 5
        ano,
        mes,
        TotalGastos = (total_gastos_ordinarios + total_gastos_extraordinarios + egresos_mes)
    FROM dbo.expensa
    WHERE 
        (@IdConsorcio IS NULL OR consorcio_idconsorcio = @IdConsorcio)
        AND (@AnioDesde IS NULL OR ano >= @AnioDesde)
        AND (@AnioHasta IS NULL OR ano <= @AnioHasta)
    ORDER BY TotalGastos DESC;
END;
GO