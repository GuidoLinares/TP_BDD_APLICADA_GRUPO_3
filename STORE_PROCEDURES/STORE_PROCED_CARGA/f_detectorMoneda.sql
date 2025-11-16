USE TP_BDD_FINAL
GO

CREATE OR ALTER FUNCTION dbo.detectorMoneda(@importe VARCHAR(50))
RETURNS TINYINT
AS
BEGIN
    DECLARE @es_dolar TINYINT = 0;

    IF @importe IS NULL OR LTRIM(RTRIM(@importe)) = '' OR @importe = '0,00'
        RETURN 0;

    IF @importe LIKE '%,%' AND @importe LIKE '%.%'
        AND CHARINDEX(',', @importe) < CHARINDEX('.', @importe)
    BEGIN
        SET @es_dolar = 1;
    END
    
    RETURN @es_dolar;
END
GO