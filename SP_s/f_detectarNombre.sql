USE TP_BASE_DE_DATOS_2025_GRUPO_3
GO

CREATE OR ALTER FUNCTION dbo.detectarNombre(
    @nombre_empresa VARCHAR(50),
    @cuenta VARCHAR(50)
)
RETURNS VARCHAR(50)
AS
BEGIN
    DECLARE @resultado VARCHAR(50);
    
    IF @nombre_empresa = 'Serv. Limpieza'
    BEGIN
        IF @cuenta LIKE '%Limptech%'
            SET @resultado = 'Limptech';
        ELSE IF @cuenta LIKE '%Limpi AR%'
            SET @resultado = 'Limpi AR';
        ELSE IF @cuenta LIKE '%Clean SA%'
            SET @resultado = 'Clean SA';
        ELSE IF @cuenta LIKE '%Limpieza General SA%'
            SET @resultado = 'Limpieza General SA'
    END
    ELSE
        SET @resultado = @nombre_empresa;
    
    RETURN @resultado;
END;