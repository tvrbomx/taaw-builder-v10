-- 0004_autorrevision_con_tope.sql — migración 003 de V10-ESQUEMA-SQL §19

alter table empresa add column monto_maximo_autorrevision numeric(16,4) not null default 5000;
alter table empresa add constraint ck_empresa_monto_max_autorrevision
  check (monto_maximo_autorrevision > 0);

alter table requisicion add column autorrevision_motivo text;

alter table requisicion drop constraint ck_requisicion_validacion_cruzada;
alter table requisicion add constraint ck_requisicion_validacion_cruzada check (
  validada_por is null
  or validada_por <> levantada_por
  or autorrevision_motivo is not null
);

create function fn_requisicion_autorrevision_tope() returns trigger as $$
declare
  v_tope numeric(16,4);
begin
  if new.validada_por is not null and new.validada_por = new.levantada_por then
    select monto_maximo_autorrevision into v_tope
      from empresa where id = new.empresa_id;
    if new.importe > v_tope then
      raise exception
        'Autorrevisión no permitida: el importe % excede el tope de % de la empresa',
        new.importe, v_tope;
    end if;
  end if;
  return new;
end;
$$ language plpgsql;

create constraint trigger tg_requisicion_autorrevision_tope
  after insert or update of validada_por, importe on requisicion
  deferrable initially deferred
  for each row execute function fn_requisicion_autorrevision_tope();
