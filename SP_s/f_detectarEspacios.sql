USE TP_BDD_FINAL
GO

CREATE FUNCTION dbo.detectarEspacios (@texto VARCHAR(50))
RETURNS NVARCHAR(50)
AS
BEGIN
    -- Reemplazar caracteres de espacio no convencionales
    SET @texto = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
               REPLACE(@texto, 
               CHAR(160), ' '),  -- espacio de no separación
               CHAR(9), ' '),    -- tabulación
               CHAR(10), ' '),   -- salto de línea
               CHAR(13), ' '),   -- retorno de carro
               CHAR(0), ''),     -- carácter nulo
               CHAR(11), ' ');   -- tabulación vertical
   
    SET @texto = LTRIM(RTRIM(@texto));
 
    RETURN @texto;
END