-- 0001_esquema_congelado.sql — extraído de docs/V10-ESQUEMA-SQL.md (R03)
-- Generado por script desde el documento fuente. No editar a mano: editar el .md y regenerar.

-- ---------- tipos enumerados ----------

create type tipo_precio        as enum ('FIJO','PORCENTAJE_OBRA','PORCENTAJE_PARTIDA');
create type tipo_insumo        as enum ('MATERIAL','MANO_OBRA','HERRAMIENTA',
                                        'HERRAMIENTA_MENOR','INDIRECTO','SUBCONTRATO');
create type factor_aplicacion  as enum ('POR_CONCEPTO','POR_DIA','PCT_MANO_OBRA','PCT_TOTAL');
create type modo_tarjeta       as enum ('A_CUADRILLA','B_PORCENTAJE');

create type estado_presupuesto as enum ('BORRADOR','ENVIADO','AUTORIZADO','RECHAZADO','CERRADO');
create type estado_requisicion as enum ('SOLICITADA','APROBADA','PAGADA','POR_ENTREGAR',
                                        'PARCIAL_ENTREGADO','ENTREGADA','CANCELADA');
create type estado_concepto_obra as enum ('NO_INICIADO','EN_PROCESO','PARCIAL_ENTREGADO','ENTREGADO');
create type estado_tramo       as enum ('PENDIENTE','SOLICITADO','COBRADO');

create type direccion_dinero   as enum ('POR_COBRAR','POR_PAGAR');
create type origen_compromiso  as enum ('TRAMO_COBRANZA','REQUISICION','NOMINA','DESTAJO','VIATICO');
create type forma_pago         as enum ('EFECTIVO','TRANSFERENCIA','CHEQUE','TARJETA');

create type categoria_gasto_n1 as enum ('MATERIAL','MANO_DE_OBRA','SUBCONTRATO',
                                        'HERRAMIENTA_Y_EQUIPO','INDIRECTO',
                                        'VIATICOS_Y_COMBUSTIBLE','TRAMITES_Y_DERECHOS',
                                        'NOMINA','EXTRAORDINARIO');

create type etapa_bim          as enum ('AP','PE','OB','AS');
create type estado_documento   as enum ('S0','S1','S2','S3','S4','S6','S7',
                                        'A0','A1','A2','A3','A4','A5','A6','A7',
                                        'B0','B1','B2','B3','B4','B5','B6','B7','CR');


create table grupo_empresa (

  id      char(26) primary key,
  nombre  varchar(120) not null,
  activo  boolean not null default true
);

create table empresa (

  id                char(26) primary key,
  grupo_empresa_id  char(26) not null references grupo_empresa(id),
  clave             varchar(8)  not null,
  nombre_comercial  varchar(120) not null,
  nombre_fiscal     varchar(200),
  rfc               varchar(13),
  iva_pct           numeric(7,4) not null default 16,
  vigencia_dias_cotizacion int not null default 15,
  moneda            char(3) not null default 'MXN',  logo              text,
  leyenda_confidencialidad text,
  leyenda_legal     text,
  pie_documento     text,
  activo            boolean not null default true,

  constraint uq_empresa_clave unique (clave),
  constraint ck_empresa_iva check (iva_pct >= 0 and iva_pct <= 100)
);

create table usuario (

  id             char(26) primary key,
  correo         varchar(160) not null,
  nombre         varchar(120) not null,
  hash_password  text not null,
  activo         boolean not null default true,
  constraint uq_usuario_correo unique (correo)
);

create table rol (

  id      char(26) primary key,
  clave   varchar(40) not null,
  nombre  varchar(80) not null,
  constraint uq_rol_clave unique (clave)
);

create table usuario_rol (

  id           char(26) primary key,
  empresa_id   char(26) not null references empresa(id),
  usuario_id   char(26) not null references usuario(id),
  rol_id       char(26) not null references rol(id),
  proyecto_id  char(26) ,  -- FK a proyecto, agregada después: circular
  activo       boolean not null default true,

  constraint uq_usuario_rol unique (empresa_id, usuario_id, rol_id, proyecto_id)
);

create table evento_estado (

  id               char(26) primary key,
  empresa_id       char(26) not null references empresa(id),
  entidad_tipo     varchar(40) not null,
  entidad_id       char(26) not null,
  estado_anterior  varchar(40),
  estado_nuevo     varchar(40) not null,
  motivo           text,
  usuario_id       char(26) not null references usuario(id),
  ocurrido_en      timestamptz not null default now()
);

create table alerta (

  id                    char(26)     primary key,
  empresa_id            char(26)     not null references empresa(id),

  activo                boolean      not null default true,
  desactivado_en        timestamptz,
  desactivado_por       char(26)     references usuario(id),
  motivo_desactivacion  text,

  creado_en             timestamptz  not null default now(),
  creado_por            char(26)     not null references usuario(id),
  actualizado_en        timestamptz  not null default now(),
  actualizado_por       char(26)     not null references usuario(id),

  constraint ck_alerta_desactivacion_completa check (
    activo = true
    or (desactivado_en is not null
        and desactivado_por is not null
        and motivo_desactivacion is not null)
  ),
  tipo          varchar(40) not null,
  severidad     varchar(12) not null,
  rol_id        char(26) not null references rol(id),
  proyecto_id  char(26) ,  -- FK a proyecto, agregada después: circular
  entidad_tipo  varchar(40) not null,
  entidad_id    char(26) not null,
  mensaje       text not null,
  leida_en      timestamptz,
  resuelta_en   timestamptz,
  resuelta_por  char(26) references usuario(id)
);

create table unidad (

  id                    char(26)     primary key,
  empresa_id            char(26)     not null references empresa(id),

  activo                boolean      not null default true,
  desactivado_en        timestamptz,
  desactivado_por       char(26)     references usuario(id),
  motivo_desactivacion  text,

  creado_en             timestamptz  not null default now(),
  creado_por            char(26)     not null references usuario(id),
  actualizado_en        timestamptz  not null default now(),
  actualizado_por       char(26)     not null references usuario(id),

  constraint ck_unidad_desactivacion_completa check (
    activo = true
    or (desactivado_en is not null
        and desactivado_por is not null
        and motivo_desactivacion is not null)
  ),
  clave     varchar(12) not null,
  nombre    varchar(60) not null,
  simbolo   varchar(8)  not null,
  decimales smallint    not null default 2,
  constraint uq_unidad_clave unique (empresa_id, clave)
);

create table categoria_gasto (

  id                    char(26)     primary key,
  empresa_id            char(26)     not null references empresa(id),

  activo                boolean      not null default true,
  desactivado_en        timestamptz,
  desactivado_por       char(26)     references usuario(id),
  motivo_desactivacion  text,

  creado_en             timestamptz  not null default now(),
  creado_por            char(26)     not null references usuario(id),
  actualizado_en        timestamptz  not null default now(),
  actualizado_por       char(26)     not null references usuario(id),

  constraint ck_categoria_gasto_desactivacion_completa check (
    activo = true
    or (desactivado_en is not null
        and desactivado_por is not null
        and motivo_desactivacion is not null)
  ),
  nivel1     categoria_gasto_n1 not null,
  padre_id   char(26) references categoria_gasto(id),
  clave      varchar(40) not null,
  nombre     varchar(80) not null,
  constraint uq_categoria_gasto unique (empresa_id, clave),
  constraint ck_categoria_gasto_un_nivel check (
    padre_id is null or padre_id <> id
  )
);

create table partida (

  id                    char(26)     primary key,
  empresa_id            char(26)     not null references empresa(id),

  activo                boolean      not null default true,
  desactivado_en        timestamptz,
  desactivado_por       char(26)     references usuario(id),
  motivo_desactivacion  text,

  creado_en             timestamptz  not null default now(),
  creado_por            char(26)     not null references usuario(id),
  actualizado_en        timestamptz  not null default now(),
  actualizado_por       char(26)     not null references usuario(id),

  constraint ck_partida_desactivacion_completa check (
    activo = true
    or (desactivado_en is not null
        and desactivado_por is not null
        and motivo_desactivacion is not null)
  ),
  clave   varchar(3) not null,
  nombre  varchar(80) not null,
  orden   int not null,

  constraint uq_partida_clave  unique (empresa_id, clave),
  constraint ck_partida_clave  check (clave ~ '^[0-9A-Z]{3}$')
);

create table proveedor (

  id                    char(26)     primary key,
  empresa_id            char(26)     not null references empresa(id),

  activo                boolean      not null default true,
  desactivado_en        timestamptz,
  desactivado_por       char(26)     references usuario(id),
  motivo_desactivacion  text,

  creado_en             timestamptz  not null default now(),
  creado_por            char(26)     not null references usuario(id),
  actualizado_en        timestamptz  not null default now(),
  actualizado_por       char(26)     not null references usuario(id),

  constraint ck_proveedor_desactivacion_completa check (
    activo = true
    or (desactivado_en is not null
        and desactivado_por is not null
        and motivo_desactivacion is not null)
  ),
  clave           varchar(12) not null,
  empresa_nombre  varchar(160),
  persona         varchar(120),
  especialidad    varchar(80),
  rfc             varchar(13),
  telefono        varchar(30),
  correo          varchar(160),
  ciudad          varchar(80),
  estado          varchar(80),
  forma_pago      forma_pago,
  banco           varchar(60),
  clabe           varchar(18),
  constraint uq_proveedor_clave unique (empresa_id, clave)
);

create table insumo (

  id                    char(26)     primary key,
  empresa_id            char(26)     not null references empresa(id),

  activo                boolean      not null default true,
  desactivado_en        timestamptz,
  desactivado_por       char(26)     references usuario(id),
  motivo_desactivacion  text,

  creado_en             timestamptz  not null default now(),
  creado_por            char(26)     not null references usuario(id),
  actualizado_en        timestamptz  not null default now(),
  actualizado_por       char(26)     not null references usuario(id),

  constraint ck_insumo_desactivacion_completa check (
    activo = true
    or (desactivado_en is not null
        and desactivado_por is not null
        and motivo_desactivacion is not null)
  ),
  clave              varchar(12) not null,
  tipo               tipo_insumo not null,
  descripcion        text not null,
  unidad_id          char(26) not null references unidad(id),
  proveedor_id       char(26) references proveedor(id),
  costo_unitario     numeric(14,4),

  -- mano de obra
  salario_base       numeric(14,4),
  factor_fasar       numeric(7,4),

  -- herramienta
  rendimiento_estandar   numeric(14,4),
  consumo_combustible    numeric(14,4),
  costo_combustible_dia  numeric(14,4),
  requiere_operador      boolean,

  -- indirecto
  factor_aplicacion  factor_aplicacion,

  constraint uq_insumo_clave unique (empresa_id, clave),
  constraint ck_insumo_costo_no_negativo check (costo_unitario is null or costo_unitario >= 0),
  constraint ck_insumo_indirecto_factor check (
    tipo <> 'INDIRECTO' or factor_aplicacion is not null
  ),
  constraint ck_insumo_mano_obra check (
    tipo <> 'MANO_OBRA' or (salario_base is not null and factor_fasar is not null)
  )
);

create table concepto (

  id                    char(26)     primary key,
  empresa_id            char(26)     not null references empresa(id),

  activo                boolean      not null default true,
  desactivado_en        timestamptz,
  desactivado_por       char(26)     references usuario(id),
  motivo_desactivacion  text,

  creado_en             timestamptz  not null default now(),
  creado_por            char(26)     not null references usuario(id),
  actualizado_en        timestamptz  not null default now(),
  actualizado_por       char(26)     not null references usuario(id),

  constraint ck_concepto_desactivacion_completa check (
    activo = true
    or (desactivado_en is not null
        and desactivado_por is not null
        and motivo_desactivacion is not null)
  ),
  clave            varchar(11) not null,
  clave_anterior   varchar(16),
  partida_id       char(26) not null references partida(id),
  padre_id         char(26) references concepto(id),
  descripcion      text not null,
  unidad_id        char(26) not null references unidad(id),
  duracion_dias    numeric(7,2),

  tipo_precio      tipo_precio  not null default 'FIJO',
  valor            numeric(14,4),

  labor_pct           numeric(7,4) not null default 40,
  hta_menor_pct       numeric(7,4) not null default 0,
  indirectos_pct      numeric(7,4) not null default 0,
  financiamiento_pct  numeric(7,4) not null default 0,
  utilidad_pct        numeric(7,4) not null default 0,

  notas            text,

  constraint uq_concepto_clave unique (empresa_id, clave),
  constraint ck_concepto_clave_formato check (
    clave ~ '^[0-9A-Z]{3}-[0-9]{4}(-V[1-9][0-9]?)?$'
    and clave = upper(clave)
  ),
  constraint ck_concepto_labor_pct  check (labor_pct >= 0 and labor_pct <= 50),
  constraint ck_concepto_pcts       check (
    hta_menor_pct >= 0 and indirectos_pct >= 0
    and financiamiento_pct >= 0 and utilidad_pct >= 0
  ),
  constraint ck_concepto_no_es_su_padre check (padre_id is null or padre_id <> id),
  constraint ck_concepto_porcentual_con_valor check (
    tipo_precio = 'FIJO' or (valor is not null and valor > 0 and valor <= 100)
  )
);

create table tarjeta (

  id                    char(26)     primary key,
  empresa_id            char(26)     not null references empresa(id),

  activo                boolean      not null default true,
  desactivado_en        timestamptz,
  desactivado_por       char(26)     references usuario(id),
  motivo_desactivacion  text,

  creado_en             timestamptz  not null default now(),
  creado_por            char(26)     not null references usuario(id),
  actualizado_en        timestamptz  not null default now(),
  actualizado_por       char(26)     not null references usuario(id),

  constraint ck_tarjeta_desactivacion_completa check (
    activo = true
    or (desactivado_en is not null
        and desactivado_por is not null
        and motivo_desactivacion is not null)
  ),
  concepto_id  char(26) not null references concepto(id),
  modo         modo_tarjeta not null,
  notas        text,
  constraint uq_tarjeta_concepto unique (concepto_id)
);

create table renglon_tarjeta (

  id                    char(26)     primary key,
  empresa_id            char(26)     not null references empresa(id),

  activo                boolean      not null default true,
  desactivado_en        timestamptz,
  desactivado_por       char(26)     references usuario(id),
  motivo_desactivacion  text,

  creado_en             timestamptz  not null default now(),
  creado_por            char(26)     not null references usuario(id),
  actualizado_en        timestamptz  not null default now(),
  actualizado_por       char(26)     not null references usuario(id),

  constraint ck_renglon_tarjeta_desactivacion_completa check (
    activo = true
    or (desactivado_en is not null
        and desactivado_por is not null
        and motivo_desactivacion is not null)
  ),
  tarjeta_id      char(26) not null references tarjeta(id) on delete restrict,
  insumo_id       char(26) not null references insumo(id),
  tipo            tipo_insumo not null,
  descripcion     text not null,
  unidad_id       char(26) not null references unidad(id),
  cantidad        numeric(14,4) not null,
  rendimiento     numeric(14,4) not null default 1,
  costo_unitario  numeric(14,4) not null,
  desperdicio_pct numeric(7,4)  not null default 0,
  orden           int not null default 0,
  notas           text,

  constraint ck_renglon_cantidad     check (cantidad >= 0),
  constraint ck_renglon_rendimiento  check (rendimiento > 0),
  constraint ck_renglon_costo        check (costo_unitario >= 0),
  constraint ck_renglon_desperdicio  check (desperdicio_pct >= 0 and desperdicio_pct <= 100),
  constraint ck_renglon_no_hta_menor check (tipo <> 'HERRAMIENTA_MENOR')
);

create table cliente (

  id                    char(26)     primary key,
  empresa_id            char(26)     not null references empresa(id),

  activo                boolean      not null default true,
  desactivado_en        timestamptz,
  desactivado_por       char(26)     references usuario(id),
  motivo_desactivacion  text,

  creado_en             timestamptz  not null default now(),
  creado_por            char(26)     not null references usuario(id),
  actualizado_en        timestamptz  not null default now(),
  actualizado_por       char(26)     not null references usuario(id),

  constraint ck_cliente_desactivacion_completa check (
    activo = true
    or (desactivado_en is not null
        and desactivado_por is not null
        and motivo_desactivacion is not null)
  ),
  clave     varchar(12) not null,
  nombre    varchar(160) not null,
  rfc       varchar(13),
  telefono  varchar(30),
  correo    varchar(160),
  direccion text,
  constraint uq_cliente_clave unique (empresa_id, clave)
);

create table proyecto (

  id                    char(26)     primary key,
  empresa_id            char(26)     not null references empresa(id),

  activo                boolean      not null default true,
  desactivado_en        timestamptz,
  desactivado_por       char(26)     references usuario(id),
  motivo_desactivacion  text,

  creado_en             timestamptz  not null default now(),
  creado_por            char(26)     not null references usuario(id),
  actualizado_en        timestamptz  not null default now(),
  actualizado_por       char(26)     not null references usuario(id),

  constraint ck_proyecto_desactivacion_completa check (
    activo = true
    or (desactivado_en is not null
        and desactivado_por is not null
        and motivo_desactivacion is not null)
  ),
  clave           varchar(4) not null,
  nombre          varchar(160) not null,
  cliente_id      char(26) not null references cliente(id),
  direccion       text,
  etapa_bim       etapa_bim not null default 'AP',
  fecha_inicio_obra date,
  metros_cuadrados  numeric(14,4),
  notas           text,

  constraint uq_proyecto_clave unique (empresa_id, clave),
  constraint ck_proyecto_clave check (clave ~ '^[0-9A-Z]{2,4}$')
);

create table documento (

  id                    char(26)     primary key,
  empresa_id            char(26)     not null references empresa(id),

  activo                boolean      not null default true,
  desactivado_en        timestamptz,
  desactivado_por       char(26)     references usuario(id),
  motivo_desactivacion  text,

  creado_en             timestamptz  not null default now(),
  creado_por            char(26)     not null references usuario(id),
  actualizado_en        timestamptz  not null default now(),
  actualizado_por       char(26)     not null references usuario(id),

  constraint ck_documento_desactivacion_completa check (
    activo = true
    or (desactivado_en is not null
        and desactivado_por is not null
        and motivo_desactivacion is not null)
  ),
  proyecto_id   char(26) references proyecto(id),
  creador       varchar(4)  not null,
  progreso      etapa_bim   not null,
  funcion       char(1)     not null,
  bloque        char(1)     not null,
  bloque_num    char(2)     not null default '01',
  nivel         varchar(3)  not null default 'ZZ',
  tipo          char(2)     not null,
  numero        int         not null,
  revision      int         not null default 0,
  estado        estado_documento not null default 'S0',

  entidad_tipo  varchar(40),
  entidad_id    char(26),
  archivo       text,
  iva_pct       numeric(7,4) not null,

  proyecto_clave varchar(4),   -- corrección 9-ago-2026 · calculada por trigger, nunca a mano
  folio          text,          -- corrección 9-ago-2026 · calculada por trigger, nunca a mano

  constraint uq_documento_folio unique (empresa_id, proyecto_id, tipo, numero, revision),
  constraint ck_documento_revision check (revision >= 0 and revision <= 99),
  constraint ck_documento_numero   check (numero >= 1 and numero <= 999999)
);

create table presupuesto (

  id                    char(26)     primary key,
  empresa_id            char(26)     not null references empresa(id),

  activo                boolean      not null default true,
  desactivado_en        timestamptz,
  desactivado_por       char(26)     references usuario(id),
  motivo_desactivacion  text,

  creado_en             timestamptz  not null default now(),
  creado_por            char(26)     not null references usuario(id),
  actualizado_en        timestamptz  not null default now(),
  actualizado_por       char(26)     not null references usuario(id),

  constraint ck_presupuesto_desactivacion_completa check (
    activo = true
    or (desactivado_en is not null
        and desactivado_por is not null
        and motivo_desactivacion is not null)
  ),
  proyecto_id      char(26) not null references proyecto(id),
  clave            varchar(16) not null,
  nombre           varchar(160) not null,
  estado           estado_presupuesto not null default 'BORRADOR',
  metros_cuadrados numeric(14,4),
  vigencia_hasta   date,
  documento_id     char(26) references documento(id),
  enviado_en       timestamptz,
  autorizado_en    timestamptz,  notas            text,

  constraint uq_presupuesto_clave unique (empresa_id, clave),
  constraint ck_presupuesto_enviado check (
    estado in ('BORRADOR') or (enviado_en is not null and documento_id is not null)
  )
);

create table presupuesto_opcion (

  id                    char(26)     primary key,
  empresa_id            char(26)     not null references empresa(id),

  activo                boolean      not null default true,
  desactivado_en        timestamptz,
  desactivado_por       char(26)     references usuario(id),
  motivo_desactivacion  text,

  creado_en             timestamptz  not null default now(),
  creado_por            char(26)     not null references usuario(id),
  actualizado_en        timestamptz  not null default now(),
  actualizado_por       char(26)     not null references usuario(id),

  constraint ck_presupuesto_opcion_desactivacion_completa check (
    activo = true
    or (desactivado_en is not null
        and desactivado_por is not null
        and motivo_desactivacion is not null)
  ),
  presupuesto_id char(26) not null references presupuesto(id),
  clave          varchar(8) not null,
  nombre         varchar(80) not null,
  es_vigente     boolean not null default false,

  mostrar_porcentuales_desglosados boolean not null default true,

  constraint uq_presupuesto_opcion unique (presupuesto_id, clave)
);

create table presupuesto_modulo (

  id                    char(26)     primary key,
  empresa_id            char(26)     not null references empresa(id),

  activo                boolean      not null default true,
  desactivado_en        timestamptz,
  desactivado_por       char(26)     references usuario(id),
  motivo_desactivacion  text,

  creado_en             timestamptz  not null default now(),
  creado_por            char(26)     not null references usuario(id),
  actualizado_en        timestamptz  not null default now(),
  actualizado_por       char(26)     not null references usuario(id),

  constraint ck_presupuesto_modulo_desactivacion_completa check (
    activo = true
    or (desactivado_en is not null
        and desactivado_por is not null
        and motivo_desactivacion is not null)
  ),
  presupuesto_opcion_id char(26) not null references presupuesto_opcion(id),
  clave   varchar(4) not null,
  nombre  varchar(120) not null,
  orden   int not null,
  constraint uq_presupuesto_modulo unique (presupuesto_opcion_id, clave)
);

create table presupuesto_concepto (

  id                    char(26)     primary key,
  empresa_id            char(26)     not null references empresa(id),

  activo                boolean      not null default true,
  desactivado_en        timestamptz,
  desactivado_por       char(26)     references usuario(id),
  motivo_desactivacion  text,

  creado_en             timestamptz  not null default now(),
  creado_por            char(26)     not null references usuario(id),
  actualizado_en        timestamptz  not null default now(),
  actualizado_por       char(26)     not null references usuario(id),

  constraint ck_presupuesto_concepto_desactivacion_completa check (
    activo = true
    or (desactivado_en is not null
        and desactivado_por is not null
        and motivo_desactivacion is not null)
  ),
  presupuesto_modulo_id char(26) not null references presupuesto_modulo(id),
  concepto_id      char(26) not null references concepto(id),
  partida_id       char(26) not null references partida(id),
  descripcion      text not null,
  unidad_id        char(26) not null references unidad(id),

  tipo_precio      tipo_precio not null default 'FIJO',

  -- sólo cuando tipo_precio = 'FIJO'
  cantidad         numeric(14,4),
  precio_catalogo  numeric(14,4),
  precio_costo     numeric(14,4),
  precio_venta     numeric(14,4),

  -- sólo cuando tipo_precio es porcentual
  porcentaje       numeric(7,4),

  orden            int not null default 0,
  notas            text,

  constraint ck_pconcepto_fijo check (
    tipo_precio <> 'FIJO'
    or (cantidad is not null and cantidad > 0
        and precio_catalogo is not null and precio_catalogo >= 0
        and precio_costo    is not null and precio_costo    >= 0
        and precio_venta    is not null and precio_venta    >= 0
        and porcentaje is null)
  ),
  constraint ck_pconcepto_porcentual check (
    tipo_precio = 'FIJO'
    or (porcentaje is not null and porcentaje > 0 and porcentaje <= 100
        and cantidad is null and precio_catalogo is null
        and precio_costo is null and precio_venta is null)
  )
);

create table generador (

  id                    char(26)     primary key,
  empresa_id            char(26)     not null references empresa(id),

  activo                boolean      not null default true,
  desactivado_en        timestamptz,
  desactivado_por       char(26)     references usuario(id),
  motivo_desactivacion  text,

  creado_en             timestamptz  not null default now(),
  creado_por            char(26)     not null references usuario(id),
  actualizado_en        timestamptz  not null default now(),
  actualizado_por       char(26)     not null references usuario(id),

  constraint ck_generador_desactivacion_completa check (
    activo = true
    or (desactivado_en is not null
        and desactivado_por is not null
        and motivo_desactivacion is not null)
  ),
  presupuesto_concepto_id char(26) not null references presupuesto_concepto(id),
  descripcion  text not null,
  eje          varchar(40),
  cantidad     numeric(14,4) not null default 1,
  largo        numeric(14,4),
  ancho        numeric(14,4),
  alto         numeric(14,4),
  factor       numeric(14,4) not null default 1,
  orden        int not null default 0
);

create table actividad (

  id                    char(26)     primary key,
  empresa_id            char(26)     not null references empresa(id),

  activo                boolean      not null default true,
  desactivado_en        timestamptz,
  desactivado_por       char(26)     references usuario(id),
  motivo_desactivacion  text,

  creado_en             timestamptz  not null default now(),
  creado_por            char(26)     not null references usuario(id),
  actualizado_en        timestamptz  not null default now(),
  actualizado_por       char(26)     not null references usuario(id),

  constraint ck_actividad_desactivacion_completa check (
    activo = true
    or (desactivado_en is not null
        and desactivado_por is not null
        and motivo_desactivacion is not null)
  ),
  proyecto_id             char(26) not null references proyecto(id),
  presupuesto_concepto_id char(26) not null references presupuesto_concepto(id),
  nombre        varchar(200) not null,
  fecha_inicio  date not null,
  fecha_fin     date not null,
  es_hito       boolean not null default false,
  predecesor_id char(26) references actividad(id),
  dias_holgura  int not null default 0,
  estado        estado_concepto_obra not null default 'NO_INICIADO',

  constraint ck_actividad_fechas check (fecha_fin >= fecha_inicio),
  constraint ck_actividad_no_es_su_predecesor check (predecesor_id is null or predecesor_id <> id)
);

create table linea_base (

  id                    char(26)     primary key,
  empresa_id            char(26)     not null references empresa(id),

  activo                boolean      not null default true,
  desactivado_en        timestamptz,
  desactivado_por       char(26)     references usuario(id),
  motivo_desactivacion  text,

  creado_en             timestamptz  not null default now(),
  creado_por            char(26)     not null references usuario(id),
  actualizado_en        timestamptz  not null default now(),
  actualizado_por       char(26)     not null references usuario(id),

  constraint ck_linea_base_desactivacion_completa check (
    activo = true
    or (desactivado_en is not null
        and desactivado_por is not null
        and motivo_desactivacion is not null)
  ),
  proyecto_id   char(26) not null references proyecto(id),
  version       int not null,
  congelada_en  timestamptz not null default now(),
  motivo        text not null,
  constraint uq_linea_base unique (proyecto_id, version)
);

create table linea_base_actividad (

  id            char(26) primary key,
  linea_base_id char(26) not null references linea_base(id),
  actividad_id  char(26) not null references actividad(id),
  fecha_inicio  date not null,
  fecha_fin     date not null
);

create table avance (

  id                    char(26)     primary key,
  empresa_id            char(26)     not null references empresa(id),

  activo                boolean      not null default true,
  desactivado_en        timestamptz,
  desactivado_por       char(26)     references usuario(id),
  motivo_desactivacion  text,

  creado_en             timestamptz  not null default now(),
  creado_por            char(26)     not null references usuario(id),
  actualizado_en        timestamptz  not null default now(),
  actualizado_por       char(26)     not null references usuario(id),

  constraint ck_avance_desactivacion_completa check (
    activo = true
    or (desactivado_en is not null
        and desactivado_por is not null
        and motivo_desactivacion is not null)
  ),
  actividad_id      char(26) not null references actividad(id),
  fecha             date not null,
  porcentaje        numeric(7,4) not null,
  evento_id  char(26) ,  -- FK a evento, agregada después: circular
  entrega_id  char(26) ,  -- FK a entrega, agregada después: circular
  carta_entrega_id  char(26) ,  -- FK a carta_entrega, agregada después: circular
  notas             text,

  constraint ck_avance_rango check (porcentaje >= 0 and porcentaje <= 100),
  constraint ck_avance_cien_exige_carta check (
    porcentaje < 100 or carta_entrega_id is not null
  ),
  constraint ck_avance_tiene_origen check (
    evento_id is not null or entrega_id is not null
  )
);

create table semana_flujo (

  id                    char(26)     primary key,
  empresa_id            char(26)     not null references empresa(id),

  activo                boolean      not null default true,
  desactivado_en        timestamptz,
  desactivado_por       char(26)     references usuario(id),
  motivo_desactivacion  text,

  creado_en             timestamptz  not null default now(),
  creado_por            char(26)     not null references usuario(id),
  actualizado_en        timestamptz  not null default now(),
  actualizado_por       char(26)     not null references usuario(id),

  constraint ck_semana_flujo_desactivacion_completa check (
    activo = true
    or (desactivado_en is not null
        and desactivado_por is not null
        and motivo_desactivacion is not null)
  ),
  proyecto_id  char(26) not null references proyecto(id),
  numero       int not null,
  fecha_inicio date not null,
  fecha_fin    date not null,
  constraint uq_semana_flujo unique (proyecto_id, numero),
  constraint ck_semana_flujo_fechas check (fecha_fin > fecha_inicio)
);

create table tramo_cobranza (

  id                    char(26)     primary key,
  empresa_id            char(26)     not null references empresa(id),

  activo                boolean      not null default true,
  desactivado_en        timestamptz,
  desactivado_por       char(26)     references usuario(id),
  motivo_desactivacion  text,

  creado_en             timestamptz  not null default now(),
  creado_por            char(26)     not null references usuario(id),
  actualizado_en        timestamptz  not null default now(),
  actualizado_por       char(26)     not null references usuario(id),

  constraint ck_tramo_cobranza_desactivacion_completa check (
    activo = true
    or (desactivado_en is not null
        and desactivado_por is not null
        and motivo_desactivacion is not null)
  ),
  proyecto_id   char(26) not null references proyecto(id),
  orden         int not null,
  nombre        varchar(80) not null,
  porcentaje    numeric(7,4) not null,

  semana_corte_calculada int,
  semana_corte_forzada   int,
  motivo_forzado         text,
  forzado_por            char(26) references usuario(id),
  forzado_en             timestamptz,

  fecha_programada date,
  estado           estado_tramo not null default 'PENDIENTE',
  compromiso_id  char(26) ,  -- FK a compromiso, agregada después: circular

  constraint uq_tramo_cobranza unique (proyecto_id, orden),
  constraint ck_tramo_porcentaje check (porcentaje > 0 and porcentaje <= 100),
  constraint ck_tramo_forzado_completo check (
    semana_corte_forzada is null
    or (motivo_forzado is not null and forzado_por is not null and forzado_en is not null)
  )
);

create table evento (

  id                    char(26)     primary key,
  empresa_id            char(26)     not null references empresa(id),

  activo                boolean      not null default true,
  desactivado_en        timestamptz,
  desactivado_por       char(26)     references usuario(id),
  motivo_desactivacion  text,

  creado_en             timestamptz  not null default now(),
  creado_por            char(26)     not null references usuario(id),
  actualizado_en        timestamptz  not null default now(),
  actualizado_por       char(26)     not null references usuario(id),

  constraint ck_evento_desactivacion_completa check (
    activo = true
    or (desactivado_en is not null
        and desactivado_por is not null
        and motivo_desactivacion is not null)
  ),
  proyecto_id  char(26) not null references proyecto(id),
  tipo         varchar(40) not null,
  criticidad   varchar(12) not null default 'ORDINARIA',
  ocurrido_en  timestamptz not null,
  descripcion  text not null,
  ubicacion    varchar(120),
  clima        varchar(40),
  concepto_id  char(26) references concepto(id),
  notas_tecnicas text
);

create table evento_foto (

  id                    char(26)     primary key,
  empresa_id            char(26)     not null references empresa(id),

  activo                boolean      not null default true,
  desactivado_en        timestamptz,
  desactivado_por       char(26)     references usuario(id),
  motivo_desactivacion  text,

  creado_en             timestamptz  not null default now(),
  creado_por            char(26)     not null references usuario(id),
  actualizado_en        timestamptz  not null default now(),
  actualizado_por       char(26)     not null references usuario(id),

  constraint ck_evento_foto_desactivacion_completa check (
    activo = true
    or (desactivado_en is not null
        and desactivado_por is not null
        and motivo_desactivacion is not null)
  ),
  evento_id   char(26) not null references evento(id),
  archivo     text not null,
  descripcion text,
  tomada_en   timestamptz,
  orden       int not null default 0
);

create table evento_adjunto (

  id                    char(26)     primary key,
  empresa_id            char(26)     not null references empresa(id),

  activo                boolean      not null default true,
  desactivado_en        timestamptz,
  desactivado_por       char(26)     references usuario(id),
  motivo_desactivacion  text,

  creado_en             timestamptz  not null default now(),
  creado_por            char(26)     not null references usuario(id),
  actualizado_en        timestamptz  not null default now(),
  actualizado_por       char(26)     not null references usuario(id),

  constraint ck_evento_adjunto_desactivacion_completa check (
    activo = true
    or (desactivado_en is not null
        and desactivado_por is not null
        and motivo_desactivacion is not null)
  ),
  evento_id   char(26) not null references evento(id),
  archivo     text not null,
  tipo        varchar(40) not null,
  descripcion text
);

create table cotizacion (

  id                    char(26)     primary key,
  empresa_id            char(26)     not null references empresa(id),

  activo                boolean      not null default true,
  desactivado_en        timestamptz,
  desactivado_por       char(26)     references usuario(id),
  motivo_desactivacion  text,

  creado_en             timestamptz  not null default now(),
  creado_por            char(26)     not null references usuario(id),
  actualizado_en        timestamptz  not null default now(),
  actualizado_por       char(26)     not null references usuario(id),

  constraint ck_cotizacion_desactivacion_completa check (
    activo = true
    or (desactivado_en is not null
        and desactivado_por is not null
        and motivo_desactivacion is not null)
  ),
  proyecto_id   char(26) not null references proyecto(id),
  proveedor_id  char(26) not null references proveedor(id),
  clave         varchar(16) not null,
  fecha         date not null,
  vigencia_hasta date,
  importe       numeric(16,4) not null,
  archivo       text,
  es_implicita  boolean not null default false,
  notas         text,
  constraint uq_cotizacion_clave unique (empresa_id, clave),
  constraint ck_cotizacion_importe check (importe >= 0)
);

create table requisicion (

  id                    char(26)     primary key,
  empresa_id            char(26)     not null references empresa(id),

  activo                boolean      not null default true,
  desactivado_en        timestamptz,
  desactivado_por       char(26)     references usuario(id),
  motivo_desactivacion  text,

  creado_en             timestamptz  not null default now(),
  creado_por            char(26)     not null references usuario(id),
  actualizado_en        timestamptz  not null default now(),
  actualizado_por       char(26)     not null references usuario(id),

  constraint ck_requisicion_desactivacion_completa check (
    activo = true
    or (desactivado_en is not null
        and desactivado_por is not null
        and motivo_desactivacion is not null)
  ),
  proyecto_id    char(26) not null references proyecto(id),
  clave          varchar(16) not null,
  cotizacion_id  char(26) not null references cotizacion(id),
  proveedor_id   char(26) not null references proveedor(id),
  estado         estado_requisicion not null default 'SOLICITADA',
  forma_pago     forma_pago not null,
  importe        numeric(16,4) not null,
  compromiso_id  char(26) ,  -- FK a compromiso, agregada después: circular

  levantada_por  char(26) not null references usuario(id),
  validada_por   char(26) references usuario(id),
  aprobada_por   char(26) references usuario(id),
  pagada_por     char(26) references usuario(id),

  constraint uq_requisicion_clave unique (empresa_id, clave),
  constraint ck_requisicion_importe check (importe >= 0),
  constraint ck_requisicion_validacion_cruzada check (
    validada_por is null
    or validada_por <> levantada_por
  ),
  constraint ck_requisicion_aprobacion check (
    aprobada_por is null or (aprobada_por <> levantada_por and aprobada_por <> validada_por)
  )
);

create table requisicion_renglon (

  id                    char(26)     primary key,
  empresa_id            char(26)     not null references empresa(id),

  activo                boolean      not null default true,
  desactivado_en        timestamptz,
  desactivado_por       char(26)     references usuario(id),
  motivo_desactivacion  text,

  creado_en             timestamptz  not null default now(),
  creado_por            char(26)     not null references usuario(id),
  actualizado_en        timestamptz  not null default now(),
  actualizado_por       char(26)     not null references usuario(id),

  constraint ck_requisicion_renglon_desactivacion_completa check (
    activo = true
    or (desactivado_en is not null
        and desactivado_por is not null
        and motivo_desactivacion is not null)
  ),
  requisicion_id char(26) not null references requisicion(id),
  descripcion    text not null,
  unidad_id      char(26) not null references unidad(id),
  cantidad       numeric(14,4) not null,
  precio_unitario numeric(14,4) not null,
  insumo_id      char(26) references insumo(id),
  constraint ck_requisicion_renglon check (cantidad > 0 and precio_unitario >= 0)
);

create table requisicion_concepto (

  id             char(26) primary key,
  empresa_id     char(26) not null references empresa(id),
  requisicion_id char(26) not null references requisicion(id),
  concepto_id    char(26) not null references concepto(id),
  constraint uq_requisicion_concepto unique (requisicion_id, concepto_id)
);

create table entrega (

  id                    char(26)     primary key,
  empresa_id            char(26)     not null references empresa(id),

  activo                boolean      not null default true,
  desactivado_en        timestamptz,
  desactivado_por       char(26)     references usuario(id),
  motivo_desactivacion  text,

  creado_en             timestamptz  not null default now(),
  creado_por            char(26)     not null references usuario(id),
  actualizado_en        timestamptz  not null default now(),
  actualizado_por       char(26)     not null references usuario(id),

  constraint ck_entrega_desactivacion_completa check (
    activo = true
    or (desactivado_en is not null
        and desactivado_por is not null
        and motivo_desactivacion is not null)
  ),
  requisicion_id char(26) not null references requisicion(id),
  fecha          date not null,
  es_parcial     boolean not null default false,
  recibida_por   char(26) not null references usuario(id),
  evento_id      char(26) references evento(id),
  notas          text
);

create table carta_entrega (

  id                    char(26)     primary key,
  empresa_id            char(26)     not null references empresa(id),

  activo                boolean      not null default true,
  desactivado_en        timestamptz,
  desactivado_por       char(26)     references usuario(id),
  motivo_desactivacion  text,

  creado_en             timestamptz  not null default now(),
  creado_por            char(26)     not null references usuario(id),
  actualizado_en        timestamptz  not null default now(),
  actualizado_por       char(26)     not null references usuario(id),

  constraint ck_carta_entrega_desactivacion_completa check (
    activo = true
    or (desactivado_en is not null
        and desactivado_por is not null
        and motivo_desactivacion is not null)
  ),
  nivel          varchar(12) not null,
  requisicion_id char(26) references requisicion(id),
  proyecto_id    char(26) references proyecto(id),
  entrega_id     char(26) references entrega(id),
  documento_id   char(26) not null references documento(id),
  fecha_firma    date not null,
  firmada_por    varchar(160) not null,
  archivo        text not null,

  constraint ck_carta_nivel check (nivel in ('TRABAJO','OBRA','PROYECTO')),
  constraint ck_carta_tiene_objeto check (
    (nivel = 'TRABAJO'  and requisicion_id is not null)
    or (nivel in ('OBRA','PROYECTO') and proyecto_id is not null)
  )
);

create table compromiso (

  id                    char(26)     primary key,
  empresa_id            char(26)     not null references empresa(id),

  activo                boolean      not null default true,
  desactivado_en        timestamptz,
  desactivado_por       char(26)     references usuario(id),
  motivo_desactivacion  text,

  creado_en             timestamptz  not null default now(),
  creado_por            char(26)     not null references usuario(id),
  actualizado_en        timestamptz  not null default now(),
  actualizado_por       char(26)     not null references usuario(id),

  constraint ck_compromiso_desactivacion_completa check (
    activo = true
    or (desactivado_en is not null
        and desactivado_por is not null
        and motivo_desactivacion is not null)
  ),
  proyecto_id   char(26) not null references proyecto(id),
  direccion     direccion_dinero not null,
  origen_tipo   origen_compromiso not null,
  origen_id     char(26) not null,
  contraparte_cliente_id  char(26) references cliente(id),
  contraparte_proveedor_id char(26) references proveedor(id),
  monto         numeric(16,4) not null,
  fecha_compromiso date not null,
  notas         text,

  constraint ck_compromiso_monto check (monto > 0),
  constraint ck_compromiso_contraparte check (
    (direccion = 'POR_COBRAR' and contraparte_cliente_id is not null
                              and contraparte_proveedor_id is null)
    or (direccion = 'POR_PAGAR' and contraparte_proveedor_id is not null
                                and contraparte_cliente_id is null)
  )
);

create table abono (

  id                    char(26)     primary key,
  empresa_id            char(26)     not null references empresa(id),

  activo                boolean      not null default true,
  desactivado_en        timestamptz,
  desactivado_por       char(26)     references usuario(id),
  motivo_desactivacion  text,

  creado_en             timestamptz  not null default now(),
  creado_por            char(26)     not null references usuario(id),
  actualizado_en        timestamptz  not null default now(),
  actualizado_por       char(26)     not null references usuario(id),

  constraint ck_abono_desactivacion_completa check (
    activo = true
    or (desactivado_en is not null
        and desactivado_por is not null
        and motivo_desactivacion is not null)
  ),
  compromiso_id char(26) not null references compromiso(id) on delete restrict,
  movimiento_id  char(26) not null ,  -- FK a movimiento, agregada después: circular
  fecha         date not null,
  monto         numeric(16,4) not null,
  forma_pago    forma_pago not null,
  referencia    varchar(80),
  notas         text,

  constraint ck_abono_monto check (monto > 0)
);

create table movimiento (

  id                    char(26)     primary key,
  empresa_id            char(26)     not null references empresa(id),

  activo                boolean      not null default true,
  desactivado_en        timestamptz,
  desactivado_por       char(26)     references usuario(id),
  motivo_desactivacion  text,

  creado_en             timestamptz  not null default now(),
  creado_por            char(26)     not null references usuario(id),
  actualizado_en        timestamptz  not null default now(),
  actualizado_por       char(26)     not null references usuario(id),

  constraint ck_movimiento_desactivacion_completa check (
    activo = true
    or (desactivado_en is not null
        and desactivado_por is not null
        and motivo_desactivacion is not null)
  ),
  proyecto_id   char(26) not null references proyecto(id),
  clave         varchar(16) not null,
  tipo          direccion_dinero not null,
  fecha         date not null,
  importe       numeric(16,4) not null,
  forma_pago    forma_pago not null,
  cliente_id    char(26) references cliente(id),
  proveedor_id  char(26) references proveedor(id),
  documento_id  char(26) references documento(id),
  comprobante   text,
  evento_id     char(26) references evento(id),
  notas         text,

  constraint uq_movimiento_clave unique (empresa_id, clave),
  constraint ck_movimiento_importe check (importe > 0)
);

create table movimiento_concepto (

  id                char(26) primary key,
  empresa_id        char(26) not null references empresa(id),
  movimiento_id     char(26) not null references movimiento(id) on delete restrict,
  concepto_id       char(26) not null references concepto(id),
  presupuesto_concepto_id char(26) references presupuesto_concepto(id),
  categoria_gasto_id char(26) not null references categoria_gasto(id),
  importe           numeric(16,4) not null,

  constraint uq_movimiento_concepto unique (movimiento_id, concepto_id),
  constraint ck_movimiento_concepto_importe check (importe > 0)
);

-- ---------- llaves foráneas diferidas (referencias circulares, detectadas contra Postgres real) ----------

alter table usuario_rol add constraint fk_usuario_rol_proyecto_id foreign key (proyecto_id) references proyecto(id);

alter table alerta add constraint fk_alerta_proyecto_id foreign key (proyecto_id) references proyecto(id);

alter table avance add constraint fk_avance_evento_id foreign key (evento_id) references evento(id);

alter table avance add constraint fk_avance_entrega_id foreign key (entrega_id) references entrega(id);

alter table avance add constraint fk_avance_carta_entrega_id foreign key (carta_entrega_id) references carta_entrega(id);

alter table tramo_cobranza add constraint fk_tramo_cobranza_compromiso_id foreign key (compromiso_id) references compromiso(id);

alter table requisicion add constraint fk_requisicion_compromiso_id foreign key (compromiso_id) references compromiso(id);

alter table abono add constraint fk_abono_movimiento_id foreign key (movimiento_id) references movimiento(id);


-- ---------- índices ----------

create index ix_concepto_partida        on concepto (empresa_id, partida_id) where activo;
create index ix_concepto_padre          on concepto (padre_id) where padre_id is not null;
create index ix_concepto_descripcion    on concepto using gin (to_tsvector('spanish', descripcion));
create index ix_renglon_insumo          on renglon_tarjeta (insumo_id) where activo;
create index ix_pconcepto_concepto      on presupuesto_concepto (concepto_id);
create index ix_movconcepto_concepto    on movimiento_concepto (concepto_id);
create index ix_abono_compromiso        on abono (compromiso_id) where activo;
create index ix_evento_proyecto_fecha   on evento (proyecto_id, ocurrido_en desc) where activo;
create index ix_evento_estado_entidad   on evento_estado (entidad_tipo, entidad_id, ocurrido_en desc);
create index ix_alerta_pendiente        on alerta (empresa_id, rol_id) where resuelta_en is null;


-- ---------- vistas derivadas ----------

create view v_saldo_compromiso as
select c.id            as compromiso_id,
       c.empresa_id,
       c.proyecto_id,
       c.direccion,
       c.monto,
       coalesce(sum(a.monto), 0)             as abonado,
       c.monto - coalesce(sum(a.monto), 0)   as saldo,
       case
         when coalesce(sum(a.monto), 0) = 0     then 'ABIERTO'
         when coalesce(sum(a.monto), 0) < c.monto then 'PARCIAL'
         else 'LIQUIDADO'
       end as estado
  from compromiso c
  left join abono a on a.compromiso_id = c.id and a.activo
 where c.activo
 group by c.id;

create view v_presupuesto_base as
select m.presupuesto_opcion_id,
       pc.empresa_id,
       pc.partida_id,
       sum(pc.cantidad * pc.precio_venta) as base
  from presupuesto_concepto pc
  join presupuesto_modulo m on m.id = pc.presupuesto_modulo_id
 where pc.activo
   and pc.tipo_precio = 'FIJO'
 group by m.presupuesto_opcion_id, pc.empresa_id, pc.partida_id;

create view v_presupuesto_derivado as
select pc.id as presupuesto_concepto_id,
       m.presupuesto_opcion_id,
       pc.empresa_id,
       pc.porcentaje,
       pc.tipo_precio,
       case pc.tipo_precio
         when 'PORCENTAJE_OBRA' then
           pc.porcentaje / 100 * (
             select coalesce(sum(b.base), 0) from v_presupuesto_base b
              where b.presupuesto_opcion_id = m.presupuesto_opcion_id)
         when 'PORCENTAJE_PARTIDA' then
           pc.porcentaje / 100 * (
             select coalesce(sum(b.base), 0) from v_presupuesto_base b
              where b.presupuesto_opcion_id = m.presupuesto_opcion_id
                and b.partida_id = pc.partida_id)
       end as importe
  from presupuesto_concepto pc
  join presupuesto_modulo m on m.id = pc.presupuesto_modulo_id
 where pc.activo
   and pc.tipo_precio <> 'FIJO';

create view v_presupuesto_total as
select o.id as presupuesto_opcion_id,
       coalesce((select sum(b.base)    from v_presupuesto_base b
                  where b.presupuesto_opcion_id = o.id), 0) as subtotal_base,
       coalesce((select sum(d.importe) from v_presupuesto_derivado d
                  where d.presupuesto_opcion_id = o.id), 0) as subtotal_derivado,
       coalesce((select sum(b.base)    from v_presupuesto_base b
                  where b.presupuesto_opcion_id = o.id), 0)
     + coalesce((select sum(d.importe) from v_presupuesto_derivado d
                  where d.presupuesto_opcion_id = o.id), 0) as total
  from presupuesto_opcion o
 where o.activo;


-- ---------- corrección: folio y proyecto_clave calculados por trigger ----------

create function fn_documento_folio() returns trigger as $$
begin
  if new.proyecto_id is not null then
    select clave into new.proyecto_clave from proyecto where id = new.proyecto_id;
  else
    new.proyecto_clave := 'EMP';
  end if;

  new.folio :=
    coalesce(new.proyecto_clave, 'EMP')
      || '-' || new.creador  || '-' || new.progreso::text || '-' || new.funcion
      || '-' || new.bloque || new.bloque_num || '-' || new.nivel || '-' || new.tipo
      || '-' || lpad(new.numero::text, 3, '0')
      || '-' || lpad(new.revision::text, 2, '0')
      || '-' || new.estado::text;

  return new;
end;
$$ language plpgsql;

create trigger tg_documento_folio
  before insert or update of proyecto_id, creador, progreso, funcion, bloque,
    bloque_num, nivel, tipo, numero, revision, estado on documento
  for each row execute function fn_documento_folio();


-- ---------- política de fila por empresa, en las 38 tablas con empresa_id ----------

do $$
declare
  t text;
begin
  for t in
    select c.table_name from information_schema.columns c
    join information_schema.tables tb
      on tb.table_schema = c.table_schema and tb.table_name = c.table_name
     where c.table_schema = 'public'
       and c.column_name = 'empresa_id'
       and tb.table_type = 'BASE TABLE'   -- nunca una vista: RLS no aplica a vistas
  loop
    execute format('alter table %I enable row level security', t);
    execute format(
      'create policy p_%s_empresa on %I using (empresa_id = current_setting(''app.empresa_id'', true))',
      t, t
    );
  end loop;
end $$;