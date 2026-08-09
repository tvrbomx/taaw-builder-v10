-- 0003_sincronizacion_recibida.sql — migración 002 de V10-ESQUEMA-SQL §19

create table sincronizacion_recibida (

  id                 char(26) primary key,
  empresa_id         char(26) not null references empresa(id),
  clave_idempotencia char(26) not null,
  entidad_tipo       varchar(40) not null,
  entidad_id         char(26) not null,
  recibido_en        timestamptz not null default now(),

  constraint uq_sincronizacion_recibida unique (empresa_id, clave_idempotencia)
);
