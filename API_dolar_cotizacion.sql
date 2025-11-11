DECLARE @url NVARCHAR(64) = 'https://dolarapi.com/v1/dolares'
DECLARE @Object INT
DECLARE @json TABLE(DATA NVARCHAR(MAX))
DECLARE @respuesta NVARCHAR(MAX)
EXEC sp_OACreate 'MSXML2.XMLHTTP', @Object OUT
EXEC sp_OAMethod @Object, 'OPEN', NULL, 'GET', @url, 'FALSE'
EXEC sp_OAMethod @Object, 'SEND'
EXEC sp_OAMethod @Object, 'RESPONSETEXT', @respuesta OUTPUT , @json OUTPUT

INSERT INTO @json 
	EXEC sp_OAGetProperty @Object, 'RESPONSETEXT'
-- chequear resultado llamada
SELECT * FROM @json
-- Proseguimos
DECLARE @datos NVARCHAR(MAX) = (SELECT DATA FROM @json)
SELECT * FROM OPENJSON(@datos)
WITH
(
	[moneda] nvarchar(40) '$.moneda',
	[casa] nvarchar(40) '$.casa',
	[nombre] nvarchar(40) '$.nombre',
	[compra] nvarchar(40) '$.compra',
	[venta] nvarchar(40) '$.venta',
	[fecha_actualización] nvarchar(40) '$.fechaActualizacion'
);

