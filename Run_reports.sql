-- =================================================================
	--EJECUCIÓN DE SP DE REPORTES
-- =================================================================


-- Reporte 1

PRINT '--- 4. Re-Ejecutando Carga de Pagos ---';
EXEC dbo.sp_ImportaPagos 
    @RutaArchivo = 'S:\Desktop\TP_BDD_APLICADA_GRUPO_3\consorcios\pagos_consorcios.csv';
GO


USE [TP_BASE_DE_DATOS_2025_GRUPO_3]
GO

PRINT '--- Prueba 1: Reporte 1 (Global, con fechas corregidas) ---';
EXEC dbo.sp_Reporte_6_1_FlujoCajaSemanal
    @FechaInicio = NULL,
    @FechaFin = NULL,
    @ConsorcioNombre = NULL;
GO

-- Reporte 2

PRINT '--REPORTE 2 RECAUDACION ANUAL POR DEPARTAMENTO--'
EXEC dbo.sp_Reporte_2_RecaudacionPorDepto
    @anio = 2025
GO

-- Reporte 3

PRINT '--REPORTE 3  Recaudación por Tipo y Periodo--'
EXEC dbo.sp_Reporte_3_RecaudacionPorTipoDetallado
    @anio = 2025
GO

-- Reporte 4


-- Reporte 5


-- Reporte 6