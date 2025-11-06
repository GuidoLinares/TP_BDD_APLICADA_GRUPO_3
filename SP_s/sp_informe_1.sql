-- Ejemplo 1: Mostrar todas las expensas cargadas (sin filtros)
EXEC dbo.sp_Reporte_6_1_Resumen_Saldos @ConsorcioNombre = NULL, @Anio = NULL, @Mes = NULL;

-- Ejemplo 2: Filtrar por el año 2024 para el consorcio 'Azcuenaga'
EXEC dbo.sp_Reporte_6_1_Resumen_Saldos @ConsorcioNombre = 'Azcuenaga', @Anio = 2024, @Mes = NULL;











