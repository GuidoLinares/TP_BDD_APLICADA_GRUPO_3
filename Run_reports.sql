/*
================================================================================
 SCRIPT DE EJECUCIÓN: CARGAS Y REPORTES
 Base de Datos: [TP_BDD_FINAL]
================================================================================
*/
USE [TP_BDD_FINAL]
GO

-- ==============================================================================
-- CONFIGURAR RUTAS DE ARCHIVOS
-- ==============================================================================
DECLARE @RutaConsorcios   NVARCHAR(1000) = 'S:\Desktop\TP_BDD_APLICADA_GRUPO_3\consorcios\Consorcios.csv';
DECLARE @RutaPersonas     NVARCHAR(1000) = 'S:\Desktop\TP_BDD_APLICADA_GRUPO_3\consorcios\Inquilino-propietarios-datos.csv';
DECLARE @RutaUFs          NVARCHAR(1000) = 'S:\Desktop\TP_BDD_APLICADA_GRUPO_3\consorcios\UF por consorcio.txt';
DECLARE @RutaRelaciones   NVARCHAR(1000) = 'S:\Desktop\TP_BDD_APLICADA_GRUPO_3\consorcios\Inquilino-propietarios-UF.csv';
DECLARE @RutaPagos        NVARCHAR(1000) = 'S:\Desktop\TP_BDD_APLICADA_GRUPO_3\consorcios\pagos_consorcios.csv';
DECLARE @RutaServicios    NVARCHAR(1000) = 'S:\Desktop\TP_BDD_APLICADA_GRUPO_3\consorcios\Servicios.Servicios.json';

-- ==============================================================================
-- 0. POBLACIÓN DE TABLA tipoPersona
-- ==============================================================================
IF NOT EXISTS (SELECT 1 FROM dbo.tipoPersona WHERE descripcion = 'PROPIETARIO')
    INSERT INTO dbo.tipoPersona (descripcion) VALUES ('PROPIETARIO');

IF NOT EXISTS (SELECT 1 FROM dbo.tipoPersona WHERE descripcion = 'INQUILINO')
    INSERT INTO dbo.tipoPersona (descripcion) VALUES ('INQUILINO');
GO

-- ==============================================================================
-- 1. PROCESO DE CARGAS (ETL)
-- ==============================================================================
PRINT '--- INICIANDO CARGAS ETL ---';

BEGIN TRY
    EXEC sp_ImportarConsorcios @RutaArchivo = @RutaConsorcios;
    EXEC sp_ImportaInquilinos @RutaArchivo = @RutaPersonas;
    EXEC sp_ImportarUnidadesFuncionales @RutaArchivo = @RutaUFs;
    EXEC sp_ImportaRelacionUF_Personas @RutaArchivo = @RutaRelaciones;
    EXEC sp_ImportaPagos @RutaArchivo = @RutaPagos;
    EXEC sp_importar_servicios_json @RutaArchivo = @RutaServicios, @AnoImportacion = 2025;

    PRINT '--- CARGAS COMPLETADAS EXITOSAMENTE ---';
END TRY
BEGIN CATCH
    PRINT '*** ERROR EN CARGA: ' + ERROR_MESSAGE();
END CATCH
GO

-- ==============================================================================
-- 2. EJECUCIÓN DE REPORTES
-- ==============================================================================
PRINT '';
PRINT '--- INICIANDO REPORTES ---';
GO

-- REPORTE 1: sp_Reporte_6_1_FlujoCajaSemanal
PRINT 'REPORTE 1: Flujo de Caja Semanal';
EXEC sp_Reporte_6_1_FlujoCajaSemanal;

EXEC sp_Reporte_6_1_FlujoCajaSemanal
    @FechaInicio = '2025-01-01',
    @FechaFin = '2025-03-31',
    @ConsorcioNombre = 'Azcuenaga';
GO

-- REPORTE 2: sp_Reporte_2_RecaudacionPorDepto
PRINT 'REPORTE 2: Recaudación por Departamento';
EXEC sp_Reporte_2_RecaudacionPorDepto @Anio = 2025;

EXEC sp_Reporte_2_RecaudacionPorDepto
    @Anio = 2025,
    @ConsorcioNombre = 'Alzaga',
    @Piso = 2;
GO

-- REPORTE 3: sp_Reporte_3_RecaudacionPorTipoDetallado
PRINT 'REPORTE 3: Recaudación Detallada por Tipo de Gasto';
EXEC sp_Reporte_3_RecaudacionPorTipoDetallado @Anio = 2025;
GO

-- REPORTE 4: [Pendiente]
PRINT 'REPORTE 4: [Pendiente de implementación]';
-- EXEC sp_Reporte_4 @Parametro = valor;
GO

-- REPORTE 5: [Pendiente]
PRINT 'REPORTE 5: [Pendiente de implementación]';
-- EXEC sp_Reporte_5 @Parametro = valor;
GO

-- REPORTE 6: [Pendiente]
PRINT 'REPORTE 6: [Pendiente de implementación]';
-- EXEC sp_Reporte_6 @Parametro = valor;
GO

PRINT '--- REPORTES FINALIZADOS ---';
GO