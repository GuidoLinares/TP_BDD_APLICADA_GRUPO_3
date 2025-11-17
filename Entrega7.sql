USE [TP_BDD_FINAL]
GO

create login admingeneral
with password = 'Admin01',
CHECK_EXPIRATION = OFF;

create user Administrativo_General for login admingeneral;


create login adminbancario
with password = 'Admin02',
CHECK_EXPIRATION = OFF;

create user Administrativo_Bancario for login adminbancario;

create login adminoperativo
with password = 'Admin03',
CHECK_EXPIRATION = OFF;

create user Administrativo_Operativo for login adminoperativo;

create login sistemas
with password = 'Admin00',
CHECK_EXPIRATION = OFF;

create user Sistemas for login sistemas;


alter server role Administrativo_General add member admingeneral
alter server role Administrativo_Bancario add member adminbancario
alter server role Administrativo_Operativo add member adminoperativo

alter server role Sistemas add member sistemas


grant execute on [dbo].[sp_Reporte_6_1_FlujoCajaSemanal] to Administrativo_General
grant execute on [dbo].[sp_Reporte_6_1_FlujoCajaSemanal] to Administrativo_Bancario
grant execute on [dbo].[sp_Reporte_6_1_FlujoCajaSemanal] to Administrativo_Operativo
grant execute on [dbo].[sp_Reporte_6_1_FlujoCajaSemanal] to Sistemas

grant execute on [dbo].[sp_Reporte_2_RecaudacionPorDepto] to Administrativo_General
grant execute on [dbo].[sp_Reporte_2_RecaudacionPorDepto] to Administrativo_Bancario
grant execute on [dbo].[sp_Reporte_2_RecaudacionPorDepto] to Administrativo_Operativo
grant execute on [dbo].[sp_Reporte_2_RecaudacionPorDepto]to Sistemas

grant execute on [dbo].[sp_Reporte_3_RecaudacionPorTipoDetallado] to Administrativo_General
grant execute on [dbo].[sp_Reporte_3_RecaudacionPorTipoDetallado] to Administrativo_Bancario
grant execute on [dbo].[sp_Reporte_3_RecaudacionPorTipoDetallado] to Administrativo_Operativo
grant execute on [dbo].[sp_Reporte_3_RecaudacionPorTipoDetallado] to Sistemas

grant execute on [dbo].[reporte_4_gastos_ingresos] to Administrativo_General
grant execute on [dbo].[reporte_4_gastos_ingresos] to Administrativo_Bancario
grant execute on [dbo].[reporte_4_gastos_ingresos] to Administrativo_Operativo
grant execute on [dbo].[reporte_4_gastos_ingresos] to Sistemas

grant execute on [dbo].[reporte_5_morosidad] to Administrativo_General
grant execute on [dbo].[reporte_5_morosidad] to Administrativo_Bancario
grant execute on [dbo].[reporte_5_morosidad] to Administrativo_Operativo
grant execute on [dbo].[reporte_5_morosidad] to Sistemas

--acá pongo los dos SP relacionados a unidades funcionales por las dudas

grant execute on [dbo].[sp_ImportarUnidadesFuncionales] to Administrativo_General
deny execute on [dbo].[sp_ImportarUnidadesFuncionales] to Administrativo_Bancario
grant execute on [dbo].[sp_ImportarUnidadesFuncionales] to Administrativo_Operativo
deny execute on [dbo].[sp_ImportarUnidadesFuncionales] to Sistemas

grant execute on [dbo].[sp_ImportaRelacionUF_Personas] to Administrativo_General
deny execute on [dbo].[sp_ImportaRelacionUF_Personas] to Administrativo_Bancario
grant execute on [dbo].[sp_ImportaRelacionUF_Personas] to Administrativo_Operativo
deny execute on [dbo].[sp_ImportaRelacionUF_Personas] to Sistemas

-- tengo entendido que este es el que se vincula a la información bancaria, puede que me equivoque

deny execute on [dbo].[sp_ImportaPagos] to Administrativo_General
grant execute on [dbo].[sp_ImportaPagos] to Administrativo_Bancario
deny execute on [dbo].[sp_ImportaPagos] to Administrativo_Operativo
deny execute on [dbo].[sp_ImportaPagos] to Sistemas

