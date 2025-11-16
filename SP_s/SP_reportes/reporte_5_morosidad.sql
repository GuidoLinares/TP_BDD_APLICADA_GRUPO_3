USE TP_BBDDA
GO

CREATE OR ALTER PROCEDURE [dbo].[reporte_5_morosidad]
AS
BEGIN
	SET NOCOUNT ON;

	SELECT TOP 3
	 p.idPersona,
     p.Nombre,
     p.Apellido,
     p.DNI,
     p.Email,
     p.Telefono,
	  SUM(ISNULL(de.deudas_remanentes,0) + ISNULL(de.interes_mora,0)) AS MorosidadTotal
    FROM persona p
    INNER JOIN tipoPersona tp
        ON p.idTipoPersona_FK = tp.idTipoPersona
    INNER JOIN unidadFuncional uf
        ON p.idUnidadFuncional_FK = uf.idunidadFuncional
    INNER JOIN consorcio c
        ON uf.consorcio_idconsorcio = c.idconsorcio
    INNER JOIN expensa e
        ON e.consorcio_idconsorcio = c.idconsorcio
    INNER JOIN detalleExpensa de
        ON de.idDetalleExp = e.detalleExpensa_idDetalleExp
    WHERE tp.descripcion = 'Propietario'
	GROUP BY 
		p.idPersona,
		 p.Nombre,
        p.Apellido,
        p.DNI,
        p.Email,
        p.Telefono
    ORDER BY MorosidadTotal DESC;
END;
GO