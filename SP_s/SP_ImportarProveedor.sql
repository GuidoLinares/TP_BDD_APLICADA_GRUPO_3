USE [TP_BDD_FINAL]
GO
/****** Object:  StoredProcedure [dbo].[sp_ImportaProveedores]  ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE dbo.sp_ImportaProveedores
	@RutaArchivo NVARCHAR(1000)
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		BEGIN TRANSACTION;
	
-- =================================================================
	--EXTRACCION (CARGAMOS EL ARCHIVO)
-- =================================================================

	IF OBJECT_ID('tempdb..#proveedorALimpiar') IS NOT NULL
   		DROP TABLE #proveedorALimpiar;

	CREATE TABLE #proveedorALimpiar 
	(
		tipoGasto VARCHAR(50),
		nombreEmpresa VARCHAR(50),
		cuenta VARCHAR(50),
		consorcio VARCHAR(50)
	);
	
	DECLARE @Sql NVARCHAR(MAX);
	SET @Sql = N'
		BULK INSERT #proveedorALimpiar
		FROM ''' + @RutaArchivo + N'''
		WITH(
			FORMAT = ''CSV'',
			FIRSTROW = 2,
			FIELDTERMINATOR = '','', -- aplicable para celdas
			ROWTERMINATOR = ''0x0a'',
			CODEPAGE = ''65001''
		);';

	EXEC sp_executesql @Sql;

-- =================================================================
	--TRANSFORMACION y CARGA (Corregidas con MERGE)
-- =================================================================

    -- Creamos una tabla temporal limpia
    IF OBJECT_ID('tempdb..#proveedorLimpio') IS NOT NULL
        DROP TABLE #proveedorLimpio;

	CREATE TABLE #proveedorLimpio 
	(
		tipoGasto VARCHAR(50),
		nombreEmpresa VARCHAR(50),
		cuenta VARCHAR(50),
		consorcio VARCHAR(50)
	);

	INSERT INTO #proveedorLimpio
    SELECT
        dbo.detectarTipoGasto(dbo.detectarEspacios(tipoGasto),dbo.detectarEspacios(nombreEmpresa)),
        dbo.detectarNombre(dbo.detectarEspacios(nombreEmpresa),dbo.detectarEspacios(cuenta)),
        dbo.detectarEspacios(cuenta),
        dbo.detectarEspacios(consorcio)
    FROM #proveedorALimpiar

    -- CARGA con MERGE
    MERGE INTO dbo.proveedor AS T -- Target (Objetivo)
    USING #proveedorLimpio AS S -- Source (Fuente)
     ON (T.tipoGasto = S.tipoGasto AND T.consorcio = S.consorcio) -- La clave para detectar duplicados

    -- Si el proveedor YA EXISTE, actualizamos (ej. si el nombre cambió)
    WHEN MATCHED THEN
        UPDATE SET
            T.tipoGasto = S.tipoGasto,
            T.nombreEmpresa = S.nombreEmpresa,
            T.cuenta = S.cuenta,
			T.consorcio = S.consorcio

    -- Si NO EXISTE, lo insertamos
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (tipoGasto, nombreEmpresa, cuenta, consorcio)
        VALUES (S.tipoGasto, S.nombreEmpresa, S.cuenta, S.consorcio);

	DROP TABLE #proveedorALimpiar;
    DROP TABLE #proveedorLimpio;

	COMMIT TRANSACTION;
		
	PRINT 'Importación completada exitosamente.';
		
	END TRY
	BEGIN CATCH
		IF OBJECT_ID('tempdb..#proveedorALimpiar') IS NOT NULL
			DROP TABLE #proveedorALimpiar;
        IF OBJECT_ID('tempdb..#proveedorLimpio') IS NOT NULL
			DROP TABLE #proveedorLimpio;

		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION;
		
		DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
		DECLARE @ErrorMessageCompleto NVARCHAR(4000) = 'Error: ' + @ErrorMessage + ' (Línea: ' + CAST(ERROR_LINE() AS VARCHAR(10)) + ')';
		
		RAISERROR(@ErrorMessageCompleto, 16, 1); 
	END CATCH

    SET NOCOUNT OFF;
END	
