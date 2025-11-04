USE [TP_BASE_DE_DATOS_2025_GRUPO_3]
GO

SET NOCOUNT ON;
PRINT '--- INICIO DE CARGA SECUENCIAL DE DATOS ---';
PRINT 'Fecha y Hora: ' + CONVERT(VARCHAR, GETDATE(), 121);
PRINT '------------------------------------------------';

-- =================================================================
-- 1. DEFINIR VARIABLES DE RUTA
-- !! IMPORTANTE: Modifica estas rutas a tu entorno local !!
-- =================================================================
DECLARE @RutaConsorcios   NVARCHAR(1000) = 'S:\Desktop\TP_BDD_APLICADA_GRUPO_3\consorcios\Consorcios.csv';
DECLARE @RutaPersonas     NVARCHAR(1000) = 'S:\Desktop\TP_BDD_APLICADA_GRUPO_3\consorcios\Inquilino-propietarios-datos.csv';
DECLARE @RutaPagos        NVARCHAR(1000) = 'S:\Desktop\TP_BDD_APLICADA_GRUPO_3\consorcios\pagos_consorcios.csv';
DECLARE @RutaUF           NVARCHAR(1000) = 'S:\Desktop\TP_BDD_APLICADA_GRUPO_3\consorcios\UF por consorcio.txt';
DECLARE @RutaServicios    NVARCHAR(1000) = 'S:\Desktop\TP_BDD_APLICADA_GRUPO_3\consorcios\Servicios.Servicios.json';
DECLARE @RutaRelaciones   NVARCHAR(1000) = 'S:\Desktop\TP_BDD_APLICADA_GRUPO_3\consorcios\Inquilino-propietarios-UF.csv';
DECLARE @AnoServicios     INT            = 2024; -- El año para la importación del JSON

-- =================================================================
-- 2. EJECUCIÓN GRUPO 1: Maestros Base (Sin dependencias)
-- =================================================================

PRINT 'Ejecutando: 1. sp_ImportarConsorcios...';
EXEC dbo.sp_ImportarConsorcios @RutaArchivo = @RutaConsorcios;
PRINT '------------------------------------------------';

PRINT 'Ejecutando: 2. sp_ImportaInquilinos (Carga Propietarios e Inquilinos)...';
EXEC dbo.sp_ImportaInquilinos @RutaArchivo = @RutaPersonas;
PRINT '------------------------------------------------';

PRINT 'Ejecutando: 3. sp_ImportaPagos...';
EXEC dbo.sp_ImportaPagos @RutaArchivo = @RutaPagos;
PRINT '------------------------------------------------';

-- =================================================================
-- 3. EJECUCIÓN GRUPO 2: Maestros Dependientes
-- =================================================================

PRINT 'Ejecutando: 4. sp_ImportarUnidadesFuncionales (Depende de Consorcios)...';
EXEC dbo.sp_ImportarUnidadesFuncionales @RutaArchivo = @RutaUF;
PRINT '------------------------------------------------';

PRINT 'Ejecutando: 5. sp_importar_servicios_json (Depende de Consorcios)...';
EXEC dbo.sp_importar_servicios_json 
    @RutaArchivo = @RutaServicios, 
    @AnoImportacion = @AnoServicios;
PRINT '------------------------------------------------';

-- =================================================================
-- 4. EJECUCIÓN GRUPO 3: Tablas de Relación
-- =================================================================

PRINT 'Ejecutando: 6. sp_ImportarRelacion_UF_Persona (Depende de Consorcios, Personas y UF)...';
EXEC dbo.sp_ImportarRelacion_UF_Persona @RutaArchivo = @RutaRelaciones;
PRINT '------------------------------------------------';

PRINT '--- FIN DE CARGA SECUENCIAL ---';
SET NOCOUNT OFF;







