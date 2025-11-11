USE TP_BASE_DE_DATOS_2025_GRUPO_3
GO

CREATE OR ALTER FUNCTION dbo.conversorMoneda(@importe VARCHAR(50))
RETURNS DECIMAL (12,2)
AS
BEGIN
	DECLARE @importe_limpio VARCHAR(50)
	DECLARE @resultado DECIMAL(12,2)

	IF @importe IS NULL OR LTRIM(RTRIM(@importe)) = '' OR @importe = '0,00'
        RETURN 0.00

	IF dbo.detectorMoneda(@importe) = 1
	BEGIN
		SET @importe_limpio = REPLACE(@importe,',','')
	END
	ELSE
	BEGIN
		SET @importe_limpio = REPLACE(REPLACE(@importe,'.',''),',','.')
	END

	IF ISNUMERIC(@importe_limpio) = 1
        SET @resultado = CAST(@importe_limpio AS DECIMAL(12,2))
    ELSE
        SET @resultado = 0.00

	RETURN @resultado
END