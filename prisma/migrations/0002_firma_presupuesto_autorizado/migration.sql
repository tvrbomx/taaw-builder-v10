-- 0002_firma_presupuesto_autorizado.sql — migración 001 de V10-ESQUEMA-SQL §19

alter table presupuesto add column firmado_por varchar(160);
alter table presupuesto add column firmado_en  timestamptz;
alter table presupuesto add constraint ck_presupuesto_autorizado_firmado check (
  estado <> 'AUTORIZADO' or (firmado_por is not null and firmado_en is not null)
);
