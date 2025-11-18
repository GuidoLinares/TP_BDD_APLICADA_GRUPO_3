USE TP_BDD_FINAL
GO

CREATE OR ALTER FUNCTION dbo.detectarTipoGasto(
    @tipo_gasto VARCHAR(50),
    @empresa VARCHAR(50)
)
RETURNS VARCHAR(50)
AS
BEGIN
    DECLARE @resultado VARCHAR(50);
	DECLARE @texto_limpio VARCHAR(50);

	SET @texto_limpio = @tipo_gasto;
    
    IF CHARINDEX('GASTOS DE', UPPER(@texto_limpio)) > 0
    BEGIN
        SET @texto_limpio = REPLACE(@texto_limpio, 'GASTOS DE', '');
    END;
    
    IF CHARINDEX('GASTOS', UPPER(@texto_limpio)) > 0
    BEGIN
        SET @texto_limpio = REPLACE(@texto_limpio, 'GASTOS', '');
    END;
    
    SET @texto_limpio = LTRIM(RTRIM(REPLACE(@texto_limpio, '  ', ' ')));
    
    IF @texto_limpio = '' OR @texto_limpio IS NULL
        SET @texto_limpio = @tipo_gasto;
    
    IF UPPER(@texto_limpio) = 'SERVICIOS PUBLICOS'
    BEGIN
        IF @empresa LIKE '%AYSA%'
            SET @resultado = 'SERVICIOS PUBLICOS AGUA';
        ELSE IF @empresa LIKE '%EDENOR%'
            SET @resultado = 'SERVICIOS PUBLICOS LUZ';
        ELSE
            SET @resultado = @texto_limpio;
    END
    ELSE
        SET @resultado = @texto_limpio;
    
    RETURN @resultado;
END;