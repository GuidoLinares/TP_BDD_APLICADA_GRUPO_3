USE TP_BASE_DE_DATOS_2025_GRUPO_3
GO

-- =============================================
-- Author:	Grupo,3
-- Create date: 04/11/2025
-- Description:	Este store sirve para importar los datos de los importes de servicios, este SP se ejecutará cada mes para cargar las novedades.
-- =============================================
ALTER PROCEDURE dbo.sp_ImportarFacturas
	@RutaArchivo NVARCHAR(1000)

AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		BEGIN TRANSACTION;

	-- =================================================================
	--EXTRACCION (CARGAMOS EL ARCHIVO)
	-- =================================================================

	IF OBJECT_ID('tempdb..#facturasALimpiar') IS NOT NULL
   	DROP TABLE #facturasALimpiar;

	CREATE TABLE #facturasALimpiar (
		numero_factura VARCHAR(50),
		consorcio_nombre VARCHAR(50),
		mes VARCHAR(50),
		importe_bancarios VARCHAR(50),
		importe_limpieza VARCHAR(50),
		importe_administracion VARCHAR(50),
		importe_seguros VARCHAR(50),
		importe_gastos_generales VARCHAR(50),
		importe_servicios_publicos_agua VARCHAR(50),
		importe_servicios_publicos_luz VARCHAR(50),
	);

	DECLARE @Sql NVARCHAR(MAX);
		SET @Sql = N'
			INSERT INTO #facturasALimpiar
			SELECT 
				numero_factura,
				consorcio_nombre,
				mes,
				importe_bancarios,
				importe_limpieza,
				importe_administracion,
				importe_seguros,
				importe_gastos_generales,
				importe_servicios_publicos_agua,
				importe_servicios_publicos_luz
			FROM OPENROWSET (BULK ''' + @RutaArchivo + N''', SINGLE_CLOB) as j
			CROSS APPLY OPENJSON(BulkColumn)
			WITH (
					numero_factura VARCHAR(50) ''$."_id"."$oid"'',
					consorcio_nombre VARCHAR(50) ''$."Nombre del consorcio"'',
					mes VARCHAR(50) ''$.Mes'',
					importe_bancarios VARCHAR(50) ''$.BANCARIOS'',
					importe_limpieza VARCHAR(50) ''$.LIMPIEZA'',
					importe_administracion VARCHAR(50) ''$.ADMINISTRACION'',
					importe_seguros VARCHAR(50) ''$.SEGUROS'',
					importe_gastos_generales VARCHAR(50) ''$."GASTOS GENERALES"'',
					importe_servicios_publicos_agua VARCHAR(50) ''$."SERVICIOS PUBLICOS-Agua"'',
					importe_servicios_publicos_luz VARCHAR(50) ''$."SERVICIOS PUBLICOS-Luz"''
			);';
	EXEC sp_executesql @Sql;

	-- Verificar que se cargaron datos
	IF NOT EXISTS (SELECT 1 FROM #facturasALimpiar)
	BEGIN
		RAISERROR('No se pudieron cargar datos del archivo JSON', 16, 1);
	END

	-- =================================================================
	--TRANSFORMACION y CARGA (Limpiamos los datos provenientes del archivo y los cargamos en tabla maestra)--
	-- =================================================================

	IF OBJECT_ID('tempdb..#facturasNormalizadas') IS NOT NULL
		DROP TABLE #facturasNormalizadas;

	CREATE TABLE #facturasNormalizadas (
		numero_factura VARCHAR(50),
		consorcio_nombre VARCHAR(50),
		mes DATE,
		importe DECIMAL(12,2),
		importe_tipo VARCHAR(50),
		es_dolar TINYINT
	);

	INSERT INTO #facturasNormalizadas (numero_factura, consorcio_nombre, mes, importe, importe_tipo, es_dolar)

	-- Bancarios
	SELECT 
		numero_factura,
		consorcio_nombre,
		mes,
		dbo.conversorMoneda(importe_bancarios) as importe,
		'BANCARIOS' as importe_tipo,
		dbo.detectorMoneda(importe_bancarios) as es_dolar
	FROM #facturasALimpiar

	UNION ALL

	-- Limpieza
	SELECT 
		numero_factura,
		consorcio_nombre,
		mes,
		dbo.conversorMoneda(importe_limpieza) as importe,
		'LIMPIEZA' as importe_tipo,
		dbo.detectorMoneda(importe_limpieza) as es_dolar
	FROM #facturasALimpiar

	UNION ALL

	-- Administración
	SELECT 
		numero_factura,
		consorcio_nombre,
		mes,
		dbo.conversorMoneda(importe_administracion) as importe,
		'ADMINISTRACION' as importe_tipo,
		dbo.detectorMoneda(importe_administracion) as es_dolar
	FROM #facturasALimpiar

	UNION ALL

	-- Seguros
	SELECT 
		numero_factura,
		consorcio_nombre,
		mes,
		dbo.conversorMoneda(importe_seguros) as importe,
		'SEGUROS' as importe_tipo,
		dbo.detectorMoneda(importe_seguros) as es_dolar
	FROM #facturasALimpiar

	UNION ALL

	-- Gastos Generales
	SELECT 
		numero_factura,
		consorcio_nombre,
		mes,
		dbo.conversorMoneda(importe_gastos_generales) as importe,
		'GASTOS GENERALES' as importe_tipo,
		dbo.detectorMoneda(importe_gastos_generales) as es_dolar
	FROM #facturasALimpiar

	UNION ALL

	-- Servicios Públicos - Agua
	SELECT 
		numero_factura,
		consorcio_nombre,
		mes,
		dbo.conversorMoneda(importe_servicios_publicos_agua) as importe,
		'SERVICIOS PUBLICOS AGUA' as importe_tipo,
		dbo.detectorMoneda(importe_servicios_publicos_agua) as es_dolar
	FROM #facturasALimpiar

	UNION ALL

	-- Servicios Públicos - Luz
	SELECT 
		numero_factura,
		consorcio_nombre,
		mes,
		dbo.conversorMoneda(importe_servicios_publicos_luz) as importe,
		'SERVICIOS PUBLICOS LUZ' as importe_tipo,
		dbo.detectorMoneda(importe_servicios_publicos_luz) as es_dolar
	FROM #facturasALimpiar
	 
	 -- Verificación de datos normalizados
	SELECT 
		COUNT(*) as total_filas,
		SUM(CASE WHEN importe IS NOT NULL THEN 1 ELSE 0 END) as importes_validos
	FROM #facturasNormalizadas;

	-- Presentar errores en los servicios

	IF EXISTS (
		SELECT 1 
		FROM #facturasNormalizadas 
		WHERE importe IS NULL
	)
	BEGIN
		SELECT 'Datos con problemas:' as Mensaje, * 
		FROM #facturasNormalizadas 
		WHERE importe IS NULL
	END

	-- Inserción en tabla de facturas
	INSERT INTO dbo.factura (
		numero_factura,
		consorcio_nombre,
		mes,
		importe,
		importe_tipo,
		es_dolar
	)
	SELECT 
		numero_factura,
		consorcio_nombre,
		mes,
		importe,
		importe_tipo,
		es_dolar
	FROM #facturasNormalizadas;

	-- Limpiar tablas temporales
	DROP TABLE #facturasALimpiar;
	DROP TABLE #facturasNormalizadas;

	COMMIT TRANSACTION;
		
	PRINT 'Importación completada exitosamente.';
		
	END TRY
	BEGIN CATCH

		IF OBJECT_ID('tempdb..#facturasALimpiar') IS NOT NULL
			DROP TABLE #facturasALimpiar;

		IF OBJECT_ID('tempdb..#facturasNormalizadas') IS NOT NULL
			DROP TABLE #facturasALimpiar;

		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION;
		
		DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
		DECLARE @ErrorMessageCompleto NVARCHAR(4000) = 'Error: ' + @ErrorMessage + ' (Línea: ' + CAST(ERROR_LINE() AS VARCHAR(10)) + ')';
		
		RAISERROR(@ErrorMessageCompleto, 16, 1); 
	END CATCH

    SET NOCOUNT OFF;
END	
GO