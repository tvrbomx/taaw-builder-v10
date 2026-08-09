# TAAW V10 · ESQUEMA SQL

**R02 · 8-ago-2026 · documento 4 de [[V10-PLAN-DE-TRABAJO-R02]] · APROBADO Y CONGELADO**

> **R02 corrige R01 el mismo día, por dos precisiones de Stefanno al aprobar.** R01 no
> llegó a estar vigente. El registro de qué cambió está en la sección 18.

Tablas, llaves y restricciones. **Este es el esquema, y está congelado desde su
aprobación el 8-ago-2026.** Lo que significa exactamente "congelado" está en la
sección 16.2.

Depende de [[V10-MODELO-DOMINIO]] R02. Cada entidad de aquel documento tiene aquí su
tabla, y cada regla invariante tiene aquí su restricción. Si algo aparece en este
documento y no en aquél, uno de los dos está mal.

PostgreSQL 16. Acceso vía Prisma, migraciones versionadas.

---

## Índice

```
 1  Cómo leer este documento
 2  Convenciones
 3  Tipos enumerados
 4  Dominio 0 · Cimiento
 5  Dominio 1 · Catálogo técnico
 6  Dominio 2 · Proyecto y documentación
 7  Dominio 3 · Presupuesto
 8  Dominio 4 · Programa y control
 9  Dominio 5 · Obra
10  Dominio 6 · Dinero
11  Las nueve reglas, hechas restricción
12  Lo que la base impide y lo que impide la aplicación
13  Vistas derivadas
14  Índices
15  Aislamiento entre empresas
16  Congelamiento y migraciones
17  Qué quedó fuera
18  Cambios de R01 a R02
19  Migraciones posteriores al congelamiento
```

---

## 1. Cómo leer este documento

El DDL de aquí es **la fuente**. El `schema.prisma` se escribe a partir de él, no al
revés: hay restricciones que Prisma no sabe expresar —expresiones regulares, sumas
comprobadas, permisos revocados— y son justo las que impiden repetir la V8.

Donde dice `‹comunes›`, van las columnas de la sección 2.3. Se escriben completas en cada
tabla al generar la migración; aquí se abrevian para que el documento se pueda leer.

---

## 2. Convenciones

### 2.1 Nombres

Dominio en español, palabras técnicas en inglés. Tablas en **singular**: `concepto`, no
`conceptos`. La V8 mezclaba `Clientes`, `proyectos`, `costos_mano_obra` y `INVENTARIO`, y
cada consulta tenía que recordar cuál era cuál.

| Objeto | Patrón |
|---|---|
| Tabla | `concepto`, `renglon_tarjeta` |
| Llave foránea | `concepto_id` |
| Restricción de unicidad | `uq_concepto_clave` |
| Restricción de verificación | `ck_concepto_clave_formato` |
| Índice | `ix_concepto_partida` |
| Vista | `v_saldo_compromiso` |

### 2.2 Tipos

| Para | Tipo | Por qué |
|---|---|---|
| Identificador | `char(26)` · ULID | Ordenable por tiempo, generable sin ida a la base, no revela conteo |
| Dinero unitario | `numeric(14,4)` | **Nunca coma flotante.** Cuatro decimales porque un precio unitario se divide entre rendimientos |
| Dinero total | `numeric(16,4)` | Cabe una obra completa sin desbordar |
| Porcentaje | `numeric(7,4)` | `40` es cuarenta por ciento, no `0.40`. Se escribe como se dice |
| Cantidad | `numeric(14,4)` | Volúmenes y fracciones de consumible |
| Texto corto | `varchar(n)` con `n` explícito | Un límite obliga a pensar qué cabe |
| Texto libre | `text` | Descripciones y notas |
| Fecha con hora | `timestamptz` | Siempre con zona. Nunca `timestamp` a secas |
| Fecha sola | `date` | Fecha de obra, de corte, de pago |
| Sí/no | `boolean not null` | Nunca nulo: un booleano nulo es un tercer estado sin nombre |

**El dinero se guarda sin IVA.** No hay ninguna columna de IVA en ninguna tabla de
precios. El IVA vive en `empresa.iva_pct` y en `documento.iva_pct`, y puede valer `0`
legítimamente. Es la regla invariante 3.

### 2.3 Columnas comunes · `‹comunes›`

Toda tabla de negocio las lleva. Sin excepción.

```sql
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

constraint ck_‹tabla›_desactivacion_completa check (
  activo = true
  or (desactivado_en is not null
      and desactivado_por is not null
      and motivo_desactivacion is not null)
)
```

Esa última restricción es la que impide desactivar sin dejar dicho **quién, cuándo y por
qué**. Un registro inactivo sin motivo es un registro borrado con otro nombre.

---

## 3. Tipos enumerados

Van como `enum` de PostgreSQL, **no** como tabla, cuando agregar un valor obliga
además a cambiar código: un estado nuevo cambia la máquina de estados. Van como **tabla**
cuando no: roles y subcategorías de gasto.

```sql
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
```

**`CANCELADA` en requisición no existía en el requisito de obra.** Se agrega porque una
requisición mal levantada tiene que poder cerrarse sin borrarse — regla 7 — y sin fingir
que se entregó.

---

## 4. Dominio 0 · Cimiento

```sql
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
  moneda            char(3) not null default 'MXN',
  monto_maximo_autorrevision numeric(16,4) not null default 5000,  -- migración 003, §19
  logo              text,
  leyenda_confidencialidad text,
  leyenda_legal     text,
  pie_documento     text,
  activo            boolean not null default true,

  constraint uq_empresa_clave unique (clave),
  constraint ck_empresa_iva check (iva_pct >= 0 and iva_pct <= 100),
  constraint ck_empresa_monto_max_autorrevision check (monto_maximo_autorrevision > 0)
);
```

`iva_pct >= 0` y no `> 0`: **el IVA en cero es una decisión de negocio, no un error.**
Está dicho así en el requisito de obra.

```sql
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
  proyecto_id  char(26) references proyecto(id),
  activo       boolean not null default true,

  constraint uq_usuario_rol unique (empresa_id, usuario_id, rol_id, proyecto_id)
);
```

`proyecto_id` nulo significa **el rol aplica en toda la empresa**. Con valor, sólo en ese
proyecto. Así un mismo usuario es residencia en F-19 y supervisión en C256, que es el
caso real.

```sql
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

revoke update, delete on evento_estado from taaw_app;
```

**Sólo se agrega.** El `revoke` no es adorno: es lo que hace que la bitácora técnica sea
creíble. Un rastro que la aplicación puede editar no es un rastro.

```sql
create table alerta (
  ‹comunes›
  tipo          varchar(40) not null,
  severidad     varchar(12) not null,
  rol_id        char(26) not null references rol(id),
  proyecto_id   char(26) references proyecto(id),
  entidad_tipo  varchar(40) not null,
  entidad_id    char(26) not null,
  mensaje       text not null,
  leida_en      timestamptz,
  resuelta_en   timestamptz,
  resuelta_por  char(26) references usuario(id)
);
```

La alerta va **a un rol, no a una persona**. `leida_en` y `resuelta_en` son distintas
porque leer no es resolver.

```sql
create table unidad (
  ‹comunes›
  clave     varchar(12) not null,
  nombre    varchar(60) not null,
  simbolo   varchar(8)  not null,
  decimales smallint    not null default 2,
  constraint uq_unidad_clave unique (empresa_id, clave)
);

create table categoria_gasto (
  ‹comunes›
  nivel1     categoria_gasto_n1 not null,
  padre_id   char(26) references categoria_gasto(id),
  clave      varchar(40) not null,
  nombre     varchar(80) not null,
  constraint uq_categoria_gasto unique (empresa_id, clave),
  constraint ck_categoria_gasto_un_nivel check (
    padre_id is null or padre_id <> id
  )
);
```

El primer nivel es el `enum` fijo. El segundo son filas con `padre_id`, **por empresa**:
Dravya abre "combustible de maquinaria" bajo `VIATICOS_Y_COMBUSTIBLE` sin que TAAW lo
herede y sin un despliegue.

---

## 5. Dominio 1 · Catálogo técnico

```sql
create table partida (
  ‹comunes›
  clave   varchar(3) not null,
  nombre  varchar(80) not null,
  orden   int not null,

  constraint uq_partida_clave  unique (empresa_id, clave),
  constraint ck_partida_clave  check (clave ~ '^[0-9A-Z]{3}$')
);
```

**La clave de tres caracteres es la identidad.** `orden` es un entero movible, no una
restricción: es lo que evita que vuelvan a aparecer partidas con número 88, 89, 90 y 96
porque la numeración se quedó sin lugar.

Alfanumérica y no sólo letras porque la partida `3D Experiences` ya existe con clave
`3DS`. Una restricción de sólo letras rechazaría un dato real el día de la migración.

```sql
create table proveedor (
  ‹comunes›
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
  ‹comunes›
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
```

Un solo catálogo con `tipo`, en vez de las seis hojas paralelas de la V8. Las seis tenían
la misma forma con nombres distintos y tres guardaban su identificador en columnas
diferentes — `costos_mano_obra` lo tenía en la columna C, y cualquier lector que asumiera
la A devolvía la mano de obra sin identificador.

**`proveedor_id` es llave foránea o es nulo. Nunca texto.** En la V8 esa columna traía un
identificador en 34 filas y texto libre en 38, y por eso la cascada de precios no podía
funcionar. Es la regla 4 hecha restricción.

`salario_real` **no se guarda**: es `salario_base × factor_fasar`. Un valor derivado
almacenado es un valor que algún día deja de coincidir.

### `concepto`

```sql
create table concepto (
  ‹comunes›
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

create unique index ux_concepto_clave_anterior
  on concepto (empresa_id, clave_anterior) where clave_anterior is not null;
```

**`ck_concepto_clave_formato` es la regla invariante 1**, y es la restricción más
importante de todo el esquema. Es literalmente lo que Google Sheets no podía hacer: 877
conceptos acumularon 40 combinaciones de formato porque nada rechazaba un dato inválido.

Dos endurecimientos que salieron de probar la expresión, no de suponerla:

| | Por qué |
|---|---|
| `-V[1-9][0-9]?` en vez de `-V[0-9]{1,2}` | La primera versión aceptaba `V0`, `V00` y `V01` además de `V1`. **Cuatro formas de escribir lo mismo son cuatro formatos**, y así empezó exactamente el problema que esta restricción existe para impedir. La forma endurecida admite `V1` a `V99` y nada más |
| `and clave = upper(clave)` | En POSIX, el rango `A-Z` dentro de una clase depende de la collation. Probé con `LC_ALL=C` y con `en_US.UTF-8` y en ninguna se coló una minúscula, **pero no tengo PostgreSQL a mano para probarlo en el motor real**. La comparación con `upper()` no depende de la collation y vuelve la duda irrelevante por un costo despreciable |

`labor_pct <= 50` es la regla de negocio de Stefanno: *la mano de obra nunca pasa del 50%
del costo del concepto.* `0` es válido y no es un descuido — un concepto de puro
suministro no tiene mano de obra.

`ck_concepto_porcentual_con_valor` obliga a que un concepto porcentual traiga su
porcentaje. **Es la restricción que impide que vuelva a existir un precio que dice
"Del monto total de obra".**

`clave_anterior` es única cuando existe, y **buscable**: mientras el Excel de F-19 y la
app convivan, escribir `ALB8072` en el buscador tiene que encontrar el concepto.

**Un solo nivel de herencia** — padre → hijos, sin nietos — se comprueba en trigger, no
en `CHECK`: un `CHECK` no puede consultar otra fila. Ver sección 12.

### Tarjeta de precio unitario

```sql
create table tarjeta (
  ‹comunes›
  concepto_id  char(26) not null references concepto(id),
  modo         modo_tarjeta not null,
  notas        text,
  constraint uq_tarjeta_concepto unique (concepto_id)
);

create table renglon_tarjeta (
  ‹comunes›
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
```

`rendimiento > 0`, no `>= 0`: **es un divisor.** La fórmula canónica dice que un
rendimiento vacío se trata como 1; aquí eso se vuelve imposible de capturar mal, con
`default 1`.

`ck_renglon_no_hta_menor` bloquea el error más fácil del módulo: la herramienta menor
**no es un renglón**, es un porcentaje sobre la mano de obra que vive en
`concepto.hta_menor_pct`.

`on delete restrict` en toda la cadena. No hay `cascade` en ninguna parte del esquema: un
borrado en cascada es exactamente el bug que borraba filas en la V8, escrito a propósito.

**`costo_unitario` es una copia congelada del precio del insumo, y es una decisión.** Un
presupuesto entregado al cliente no puede cambiar solo porque subió un material.
`insumo_id` guarda a quién copió, y es lo que permite la cascada explícita.

---

## 6. Dominio 2 · Proyecto y documentación

```sql
create table cliente (
  ‹comunes›
  clave     varchar(12) not null,
  nombre    varchar(160) not null,
  rfc       varchar(13),
  telefono  varchar(30),
  correo    varchar(160),
  direccion text,
  constraint uq_cliente_clave unique (empresa_id, clave)
);

create table proyecto (
  ‹comunes›
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
```

`proyecto.clave` con dos a cuatro caracteres porque **es el campo 1 de todos los folios**:
`F19`, `C256`, `EMP`.

```sql
create table documento (
  ‹comunes›
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

  folio text generated always as (
    coalesce(
      (select p.clave from proyecto p where p.id = proyecto_id), 'EMP'
    ) || '-' || creador  || '-' || progreso || '-' || funcion
      || '-' || bloque || bloque_num || '-' || nivel || '-' || tipo
      || '-' || lpad(numero::text, 3, '0')
      || '-' || lpad(revision::text, 2, '0')
      || '-' || estado
  ) stored,

  constraint uq_documento_folio unique (empresa_id, proyecto_id, tipo, numero, revision),
  constraint ck_documento_revision check (revision >= 0 and revision <= 99),
  constraint ck_documento_numero   check (numero >= 1 and numero <= 999999)
);
```

**El folio se compone, no se escribe.** Los once campos de
`DRAVYA-NOM-NomenclaturaDocumental-R01` son columnas, y el folio es una columna generada:
no puede quedar desincronizado de sus partes, porque no es una copia.

`iva_pct` se guarda **en el documento** y no se lee de la empresa al imprimir: un
presupuesto emitido con IVA 0 tiene que seguir diciendo 0 dentro de dos años, aunque la
empresa haya cambiado su parámetro.

---

## 7. Dominio 3 · Presupuesto

```sql
create table presupuesto (
  ‹comunes›
  proyecto_id      char(26) not null references proyecto(id),
  clave            varchar(16) not null,
  nombre           varchar(160) not null,
  estado           estado_presupuesto not null default 'BORRADOR',
  metros_cuadrados numeric(14,4),
  vigencia_hasta   date,
  documento_id     char(26) references documento(id),
  enviado_en       timestamptz,
  autorizado_en    timestamptz,
  firmado_por      varchar(160),   -- migración 001, §19 · nulable: sólo AUTORIZADO la exige
  firmado_en       timestamptz,    -- migración 001, §19
  notas            text,

  constraint uq_presupuesto_clave unique (empresa_id, clave),
  constraint ck_presupuesto_enviado check (
    estado in ('BORRADOR') or (enviado_en is not null and documento_id is not null)
  ),
  constraint ck_presupuesto_autorizado_firmado check (   -- migración 001, §19
    estado <> 'AUTORIZADO' or (firmado_por is not null and firmado_en is not null)
  )
);

create table presupuesto_opcion (
  ‹comunes›
  presupuesto_id char(26) not null references presupuesto(id),
  clave          varchar(8) not null,
  nombre         varchar(80) not null,
  es_vigente     boolean not null default false,

  mostrar_porcentuales_desglosados boolean not null default true,

  constraint uq_presupuesto_opcion unique (presupuesto_id, clave)
);

create table presupuesto_modulo (
  ‹comunes›
  presupuesto_opcion_id char(26) not null references presupuesto_opcion(id),
  clave   varchar(4) not null,
  nombre  varchar(120) not null,
  orden   int not null,
  constraint uq_presupuesto_modulo unique (presupuesto_opcion_id, clave)
);

create table presupuesto_concepto (
  ‹comunes›
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
```

**Tres precios, y cada uno tiene su papel.** `precio_catalogo` es lo que valía al
insertarlo y no cambia nunca; `precio_costo` es el costo directo de la tarjeta;
`precio_venta` es lo que se le cobra al cliente. De los tres sale el margen, **visible al
armar y nunca en la vista del cliente.**

`descripcion` y `unidad_id` se copian del concepto **a propósito**: un presupuesto
entregado tiene que poder reimprimirse igual dentro de dos años aunque el concepto se
haya redactado mejor. La liga viva a `concepto_id` sigue ahí para todo lo demás.

**Aquí las columnas se separan en vez de compartir un `valor` polivalente.** En
`concepto` el campo `valor` funciona porque `tipo_precio` es obligatorio y se lee antes:
es una unión etiquetada, no un campo ambiguo — la diferencia con la columna E de
`materiales` de la V8 es que aquella no tenía discriminador ninguno. Pero en el
presupuesto conviven las dos clases en la misma tabla y se suman en la misma consulta, y
ahí un solo campo sí sería el campo polivalente que prohíbe la regla 4. Las dos
restricciones garantizan que **exactamente uno de los dos juegos esté poblado**.

**`presupuesto_opcion.mostrar_porcentuales_desglosados` responde a que en obra el
honorario a veces va embebido: no se muestra como renglón aparte, aunque siga
cobrándose.** Vive en la opción y no en el presupuesto porque dos opciones comparables
del mismo presupuesto pueden mostrarlo distinto.

**Lo que cambia es sólo la impresión, nunca el cálculo.** El total que ve el cliente es
siempre `subtotal_base + subtotal_derivado`, con la bandera en cualquier posición. En
`true`, el PDF imprime el renglón `PORCENTAJE_OBRA` o `PORCENTAJE_PARTIDA` como línea
propia después del subtotal base. En `false`, esa línea no se imprime y su importe se
suma al total sin desglosarse — el dato interno, la tarjeta, el cálculo y la alerta si
diera cero siguen existiendo igual; sólo el documento cambia.

### 7.1 Subtotal base y subtotal derivado

**El problema:** `HNR-0001` vale 15% del costo total de la obra. Si vive dentro del
presupuesto, el total depende de él y él depende del total. Sin resolverlo, o el número
no converge o alguien lo congela a mano y deja de cuadrar.

**La solución: un presupuesto tiene dos subtotales, y sólo uno de ellos se puede
referenciar.**

```
SUBTOTAL BASE      = Σ (cantidad × precio_venta)   de los conceptos FIJO
                     ← los porcentuales NUNCA entran aquí
        ↓
SUBTOTAL DERIVADO  = Σ importe de los conceptos porcentuales
                       PORCENTAJE_OBRA    → porcentaje × subtotal base del PRESUPUESTO
                       PORCENTAJE_PARTIDA → porcentaje × subtotal base de SU PARTIDA
        ↓
TOTAL              = SUBTOTAL BASE + SUBTOTAL DERIVADO
```

**Sobre qué base se calcula un porcentual, dicho sin ambigüedad porque es dinero: el
subtotal base se calcula a `precio_venta` — el que ve el cliente — nunca a
`precio_costo`.** Un honorario se cobra sobre lo vendido, no sobre el costo directo
interno de la empresa. La fórmula de arriba ya lo dice — el subtotal es
`cantidad × precio_venta` — pero se deja escrito aparte para que dentro de seis meses
nadie lo lea al revés y calcule un honorario sobre el costo de la empresa en vez de
sobre lo que se le cobró al cliente.

**Es un cálculo de dos pasos, en un solo sentido, sin recursión posible.** El paso 1 no
puede mirar al paso 2 porque el paso 2 todavía no existe.

Las cuatro reglas, y dónde vive cada una:

| Regla | Dónde |
|---|---|
| Un concepto porcentual **nunca** entra al subtotal base | `v_presupuesto_base` filtra `tipo_precio = 'FIJO'`. No es una convención: es la definición de la vista |
| `PORCENTAJE_OBRA` se calcula sobre el subtotal base del presupuesto | `v_presupuesto_derivado` |
| `PORCENTAJE_PARTIDA` se calcula sobre el subtotal base de su partida | `v_presupuesto_derivado`, agrupando por `partida_id` |
| **Un porcentual no puede referenciar otro porcentual** | Estructural: la base de cálculo **sólo puede ser un subtotal base**, y un subtotal base sólo contiene conceptos `FIJO`. No hay forma de expresar lo contrario |

Esa última es la clave del diseño: **no hace falta un trigger que prohíba la
circularidad, porque no existe la columna con la que se escribiría.** Un porcentual no
apunta a conceptos; apunta a un subtotal, y ese subtotal es porcentual-libre por
definición. Prohibirlo con una restricción sería tapar una puerta que no está en el muro.

Restricciones adicionales que esto exige, todas ya escritas arriba:

```sql
-- un concepto porcentual no tiene tarjeta: no hay insumos que sumar
constraint ck_tarjeta_no_porcentual check (...)   -- en trigger, consulta concepto

-- un porcentual no puede ser variante de un fijo ni al revés
constraint ck_concepto_variante_mismo_tipo check (...)  -- en trigger
```

**Dos casos de borde, resueltos y no escondidos:**

| Caso | Qué pasa |
|---|---|
| Una partida que **sólo** tiene conceptos porcentuales | Su subtotal base es 0, y el derivado da 0. **Es correcto que dé cero**, y la aplicación levanta alerta: un 15% de nada es nada, y el usuario tiene que enterarse |
| Un presupuesto **sin ningún concepto `FIJO`** | Total 0 con alerta. Mismo criterio que la tarjeta sin materiales ni equipo: cero explicado, nunca cero silencioso |

**Consecuencia para el cliente:** en el PDF los porcentuales van **después** del subtotal
base, como renglones que se leen sobre él. Un honorario del 15% impreso entre los
conceptos de albañilería, sumando como si fuera uno más, es justo lo que hace que un
presupuesto no cuadre cuando el cliente lo revisa con calculadora.

```sql
create table generador (
  ‹comunes›
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
```

El generador **documenta de dónde salió la cantidad**. En la V8 esa información vivía en
hojas de Excel sueltas y se perdía al cerrar el archivo.

---

## 8. Dominio 4 · Programa y control

```sql
create table actividad (
  ‹comunes›
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
  ‹comunes›
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

revoke update, delete on linea_base_actividad from taaw_app;
```

La línea base es **una copia inmutable**, no dos columnas dentro de `actividad`. En la V8
el programa vivo pisaba el planeado y la desviación se volvía incalculable.

```sql
create table avance (
  ‹comunes›
  actividad_id      char(26) not null references actividad(id),
  fecha             date not null,
  porcentaje        numeric(7,4) not null,
  evento_id         char(26) references evento(id),
  entrega_id        char(26) references entrega(id),
  carta_entrega_id  char(26) references carta_entrega(id),
  notas             text,

  constraint ck_avance_rango check (porcentaje >= 0 and porcentaje <= 100),
  constraint ck_avance_cien_exige_carta check (
    porcentaje < 100 or carta_entrega_id is not null
  ),
  constraint ck_avance_tiene_origen check (
    evento_id is not null or entrega_id is not null
  )
);
```

**`ck_avance_cien_exige_carta` es la regla invariante 6, y vive en la base.** No es una
advertencia en la interfaz: no hay forma de escribir un 100% sin carta entrega, ni desde
la aplicación ni desde una consulta a mano.

`ck_avance_tiene_origen` impide el avance capturado suelto. Un porcentaje sin quién,
cuándo y contra qué no es información: es una opinión con formato de dato.

```sql
create table semana_flujo (
  ‹comunes›
  proyecto_id  char(26) not null references proyecto(id),
  numero       int not null,
  fecha_inicio date not null,
  fecha_fin    date not null,
  constraint uq_semana_flujo unique (proyecto_id, numero),
  constraint ck_semana_flujo_fechas check (fecha_fin > fecha_inicio)
);

create table tramo_cobranza (
  ‹comunes›
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
  compromiso_id    char(26) references compromiso(id),

  constraint uq_tramo_cobranza unique (proyecto_id, orden),
  constraint ck_tramo_porcentaje check (porcentaje > 0 and porcentaje <= 100),
  constraint ck_tramo_forzado_completo check (
    semana_corte_forzada is null
    or (motivo_forzado is not null and forzado_por is not null and forzado_en is not null)
  )
);
```

**`ck_tramo_forzado_completo` es la corrección 5.** La semana de corte se calcula del
cronograma, y admite excepción manual — porque la realidad siempre difiere del plan —
pero **forzarla sin motivo es imposible.** El valor calculado nunca se pierde: se guardan
los dos, y por eso la aplicación puede decir *"se forzó a la semana 9; el cronograma dice
12"* en vez de mostrar un solo número y mentir.

Que los porcentajes de los tramos sumen exactamente 100 se comprueba en trigger: es una
condición sobre el conjunto de renglones, no sobre uno.

---

## 9. Dominio 5 · Obra

```sql
create table evento (
  ‹comunes›
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
  ‹comunes›
  evento_id   char(26) not null references evento(id),
  archivo     text not null,
  descripcion text,
  tomada_en   timestamptz,
  orden       int not null default 0
);

create table evento_adjunto (
  ‹comunes›
  evento_id   char(26) not null references evento(id),
  archivo     text not null,
  tipo        varchar(40) not null,
  descripcion text
);
```

`ocurrido_en` es distinto de `creado_en`. Lo que pasó en obra el martes puede capturarse
el jueves, y confundir las dos fechas arruina el reporte fotográfico por cortes.

```sql
create table cotizacion (
  ‹comunes›
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
```

**`es_implicita` resuelve el caso del maestro albañil de palabra.** Cuando el proveedor no
cotiza, la requisición **es** la cotización y debe traer el desglose completo. Se modela
como una cotización marcada, no como una requisición sin cotización: así la regla "toda
requisición va ligada a una cotización" no tiene excepciones que programar.

```sql
create table requisicion (
  ‹comunes›
  proyecto_id    char(26) not null references proyecto(id),
  clave          varchar(16) not null,
  cotizacion_id  char(26) not null references cotizacion(id),
  proveedor_id   char(26) not null references proveedor(id),
  estado         estado_requisicion not null default 'SOLICITADA',
  forma_pago     forma_pago not null,
  importe        numeric(16,4) not null,
  compromiso_id  char(26) references compromiso(id),

  levantada_por  char(26) not null references usuario(id),
  validada_por   char(26) references usuario(id),
  aprobada_por   char(26) references usuario(id),
  pagada_por     char(26) references usuario(id),

  autorrevision_motivo text,   -- migración 003, §19 · obligatorio si validada_por = levantada_por

  constraint uq_requisicion_clave unique (empresa_id, clave),
  constraint ck_requisicion_importe check (importe >= 0),
  constraint ck_requisicion_validacion_cruzada check (
    validada_por is null
    or validada_por <> levantada_por
    or autorrevision_motivo is not null      -- migración 003: la excepción exige motivo escrito
  ),
  constraint ck_requisicion_aprobacion check (
    aprobada_por is null or (aprobada_por <> levantada_por and aprobada_por <> validada_por)
  )
);

create table requisicion_renglon (
  ‹comunes›
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
```

**`ck_requisicion_validacion_cruzada` y `ck_requisicion_aprobacion` son la regla de que
quien edita no aprueba lo que editó**, escrita en la base. Se comprueba sobre el
**usuario**, no sobre el rol: en una empresa donde tres personas cubren ocho funciones,
la misma persona tiene los dos roles, y comprobar el rol no serviría de nada.

`requisicion_concepto` es la liga obligatoria de la regla 2. Que exista al menos una fila
antes de aprobar se comprueba en trigger, porque es una condición sobre el conjunto.

```sql
create table entrega (
  ‹comunes›
  requisicion_id char(26) not null references requisicion(id),
  fecha          date not null,
  es_parcial     boolean not null default false,
  recibida_por   char(26) not null references usuario(id),
  evento_id      char(26) references evento(id),
  notas          text
);

create table carta_entrega (
  ‹comunes›
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
```

`archivo` y `documento_id` son **obligatorios**: una carta entrega sin documento firmado
es una casilla marcada, y marcar una casilla es exactamente lo que la regla 6 existe para
impedir.

---

## 10. Dominio 6 · Dinero

```sql
create table compromiso (
  ‹comunes›
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
  ‹comunes›
  compromiso_id char(26) not null references compromiso(id) on delete restrict,
  movimiento_id char(26) not null references movimiento(id),
  fecha         date not null,
  monto         numeric(16,4) not null,
  forma_pago    forma_pago not null,
  referencia    varchar(80),
  notas         text,

  constraint ck_abono_monto check (monto > 0)
);
```

**No hay columna `saldo` y no hay columna `pagado`.** El saldo es `monto` menos la suma de
sus abonos, y se calcula al leer. Es la regla invariante 5, y la razón es que un saldo
almacenado es un dato que algún día deja de coincidir con sus partes y nadie se entera.

Que un abono no rebase el saldo se comprueba en trigger: depende de la suma de los otros
abonos del mismo compromiso.

```sql
create table movimiento (
  ‹comunes›
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
```

**Esta tabla es la regla invariante 2 hecha estructura, y es donde está el valor de toda
la plataforma.** Un gasto puede repartirse entre varios conceptos; la suma de la
distribución tiene que igualar el importe del movimiento, y eso se comprueba en un trigger
diferido.

`categoria_gasto_id` vive **aquí y no en el insumo**, a propósito: el tipo de insumo
clasifica *qué es* una cosa, la categoría clasifica *contra qué se carga*. El mismo bulto
de cemento es `MATERIAL` cuando va a un muro y `EXTRAORDINARIO` cuando tapa un bache del
acceso.

De aquí sale, y sólo de aquí:

```
AHORRO   = costo presupuestado en la tarjeta − gasto real ligado al concepto
UTILIDAD = utilidad del presupuesto + ahorro conseguido
```

---

## 11. Las nueve reglas, hechas restricción

Cada regla, y dónde exactamente vive. Una regla que sólo está escrita en un documento no
es una regla.

| # | Regla | Dónde vive |
|---|---|---|
| 1 | Clave única y con formato fijo | `ck_concepto_clave_formato` + `uq_concepto_clave` · igual en `partida` y `proyecto` |
| 2 | Todo gasto ligado a concepto | `movimiento_concepto` + `tg_movimiento_distribucion_completa` + `tg_requisicion_exige_concepto` |
| 3 | Precios sin IVA | **ninguna tabla de precio tiene columna de IVA.** Sólo `empresa.iva_pct` y `documento.iva_pct` |
| 4 | Una columna, una cosa | `insumo.proveedor_id` es llave foránea, no texto · `concepto.tipo_precio` antes de `valor` |
| 5 | Todo pago es abono contra compromiso | `compromiso` + `abono` · **no existe columna `saldo` ni `pagado`** · `tg_abono_no_rebasa_saldo` |
| 6 | Ningún 100% sin carta entrega | `ck_avance_cien_exige_carta` |
| 7 | Nada se borra | `activo` + `ck_*_desactivacion_completa` · `revoke delete` · `on delete restrict` en todas las llaves |
| 8 | Rastro y alerta en cada cambio | `evento_estado` con `revoke update, delete` + `alerta` + triggers de transición |
| 9 | Todo dato pertenece a una empresa | `empresa_id not null` en `‹comunes›` + política de fila · sección 15 |

---

## 12. Lo que la base impide y lo que impide la aplicación

**El criterio:** si romper una regla corrompe datos, la base la impide. Si romperla sólo
produce un flujo raro, la impide la aplicación.

La razón de ser de este reparto es la V8: allí *todo* lo impedía la aplicación, y bastó un
`catch` vacío para que dejara de impedir nada.

### Triggers · lo que un `CHECK` no alcanza

Un `CHECK` no puede consultar otras filas. Estas seis condiciones lo necesitan, y las seis
van como `constraint trigger ... deferrable initially deferred`, de modo que se comprueban
al cerrar la transacción y no a la mitad de una escritura de varios renglones.

| Trigger | Qué impide |
|---|---|
| `tg_movimiento_distribucion_completa` | que la suma de `movimiento_concepto` no iguale el importe del movimiento, o que no haya ninguna fila |
| `tg_abono_no_rebasa_saldo` | que la suma de abonos supere el monto del compromiso |
| `tg_tramos_suman_cien` | que los tramos de cobranza de un proyecto no sumen exactamente 100% |
| `tg_concepto_un_solo_nivel` | que un concepto con `padre_id` sea a su vez padre de otro — sin nietos |
| `tg_requisicion_exige_concepto` | pasar de `SOLICITADA` a `APROBADA` sin al menos un concepto ligado |
| `tg_transicion_registra_evento` | cualquier cambio de estado que no escriba en `evento_estado` |
| `tg_pconcepto_no_admite_inactivo` | agregar un concepto inactivo a un presupuesto nuevo |
| `tg_tarjeta_no_porcentual` | crear tarjeta para un concepto porcentual: no hay insumos que sumar |
| `tg_variante_mismo_tipo_precio` | que una variante sea porcentual y su padre fijo, o al revés |
| `tg_requisicion_autorrevision_tope` | migración 003, §19 · que una autorrevisión se guarde con `importe` mayor al `monto_maximo_autorrevision` de la empresa |

### Un concepto dado de baja que ya está en un presupuesto emitido

**Sigue visible ahí, y el mecanismo es que el filtro se aplica a la fila equivocada a
propósito.**

```sql
-- CORRECTO: filtra la fila del presupuesto
select ... from presupuesto_concepto pc
 where pc.activo;

-- INCORRECTO: haría desaparecer renglones de un documento ya entregado
select ... from presupuesto_concepto pc
  join concepto c on c.id = pc.concepto_id
 where pc.activo and c.activo;   -- ← el segundo filtro sobra y hace daño
```

Cuatro piezas lo garantizan, y ninguna depende de que alguien se acuerde:

| Pieza | Qué asegura |
|---|---|
| `presupuesto_concepto` copia `descripcion`, `unidad_id` y los tres precios | El renglón se imprime completo aunque el concepto del catálogo cambie o se desactive |
| Desactivar un concepto sólo escribe `activo = false` en `concepto` | **No toca `presupuesto_concepto`.** No hay `cascade` en ningún lado del esquema |
| `on delete restrict` en `presupuesto_concepto.concepto_id` | Aunque alguien intentara un `DELETE`, la base lo rechaza mientras exista el renglón |
| `tg_pconcepto_no_admite_inactivo` | Impide **agregar** un concepto inactivo a un presupuesto nuevo. Lo viejo se conserva; lo nuevo no se contamina |

**La regla en una línea:** un concepto inactivo desaparece del **catálogo**, nunca de un
**documento**. Es la regla 7 llevada a su consecuencia: si desactivar borrara el pasado,
sería un borrado con otro nombre.

Al desactivar, la aplicación avisa en cuántos presupuestos vivos aparece — informa, no
bloquea. Bloquear obligaría a mantener activo un concepto obsoleto para siempre.

### Lo que impide la aplicación

- Las transiciones válidas de cada máquina de estados
- Que quien aprueba tenga el rol para hacerlo — la base sólo comprueba que **no sea la
  misma persona que editó**
- La cascada de precios y su simulación previa obligatoria
- Que el cliente no vea costo, utilidad ni proveedores. Es regla de diseño, y se cumple
  no llevando esas columnas a las vistas imprimibles

### Prohibido, y se vigila en revisión de código

- `catch` vacío. La V8 tenía 26, y de uno salió el bug que borraba filas
- Escritura de varios registros fuera de transacción
- Consulta sin filtro de empresa fuera del repositorio
- `DELETE` en cualquier tabla de negocio

---

## 13. Vistas derivadas

Lo que **no se guarda** porque se calcula. Cada una existe para que nadie tenga la
tentación de almacenar el resultado.

```sql
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
```

### Los dos subtotales del presupuesto

```sql
-- paso 1 · sólo conceptos FIJO. Los porcentuales no existen para esta vista.
-- pc.precio_venta, NO pc.precio_costo: un porcentual se cobra sobre lo que
-- se le vende al cliente, nunca sobre el costo directo interno.
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

-- paso 2 · cada porcentual sobre la base que le corresponde
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

-- total
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
```

`v_presupuesto_derivado` **lee de `v_presupuesto_base`, y `v_presupuesto_base` no sabe
que la otra existe.** La dependencia va en un solo sentido, y por eso el cálculo no puede
entrar en ciclo: PostgreSQL rechazaría la definición si lo intentara.

Las demás, con la misma lógica:

| Vista | Qué entrega |
|---|---|
| `v_avance_concepto` | último avance por actividad, y si tiene carta entrega |
| `v_flujo_semanal` | importe programado por semana y acumulado |
| `v_tramo_vigente` | semana de corte vigente: **la forzada si existe, la calculada si no**, más la señal de si fue forzada |
| `v_posicion_financiera` | cobrado, por cobrar, gastado y **caja del proyecto** |
| `v_desfase_caja` | cobrado acumulado menos gastado acumulado, semana por semana |
| `v_estado_financiero_cliente` | módulo → partida → concepto: contratado, avance, ejecutado, cobrado. **Sin costo, sin utilidad, sin proveedores** |
| `v_estado_financiero_operativo` | por categoría de gasto: gasto real, costo presupuestado, ahorro, utilidad asimilada |
| `v_concepto_precio` | precio vigente de un concepto según `tipo_precio` |

---

## 14. Índices

Sólo los que responden a una consulta real. Un índice de más encarece toda escritura.

```sql
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
```

`ix_renglon_insumo` es el que hace viable la cascada: sin él, "qué conceptos usan la
varilla" recorre la tabla entera.

`ix_concepto_descripcion` es búsqueda de texto en español. Con 877 conceptos y creciendo,
buscar por descripción es la forma en que realmente se usa el catálogo — y `clave_anterior`
tiene su propio índice único para que escribir `ALB8072` siga encontrando el concepto.

---

## 15. Aislamiento entre empresas

`empresa_id` obligatorio es necesario y no es suficiente: **una consulta que olvida el
filtro compila igual.** Es la prueba obligatoria 5 de [[V10-ARQUITECTURA]].

Dos barreras:

**Primera · el repositorio.** Es la única capa que habla con Prisma y aplica el filtro
siempre. La pantalla no se entera.

**Segunda · política de fila en PostgreSQL.**

```sql
alter table concepto enable row level security;

create policy p_concepto_empresa on concepto
  using (empresa_id = current_setting('app.empresa_id', true));
```

La aplicación hace `set local app.empresa_id` al abrir cada transacción. Si un
repositorio olvida el filtro, la base **no devuelve** las filas de la otra empresa: no es
que la consulta esté mal escrita, es que esas filas no existen para esa sesión.

| | |
|---|---|
| **Costo** | cada transacción tiene que fijar la variable. Si se olvida, la consulta devuelve cero filas |
| **Por qué se acepta** | ese modo de fallar es **ruidoso y evidente**. El modo de fallar del olvido sin política es silencioso: se mezclan datos de dos empresas y se descubre en una junta |

---

## 16. Congelamiento y migraciones

**Este documento quedó aprobado el 8-ago-2026. El esquema está congelado desde ese
momento**, con las dos precisiones de la sección 18 ya incorporadas antes de aprobarse.

De ahí en adelante:

1. Todo cambio es una **migración nueva**, nunca una edición de la anterior
2. Las migraciones se versionan en el repositorio y corren solas en el despliegue
3. **Nunca** se edita la base a mano en producción

### 16.1 Orden de creación

`grupo_empresa` → `empresa` → `usuario` → `rol` → catálogos → `partida` → `proveedor` →
`insumo` → `concepto` → `tarjeta` → `cliente` → `proyecto` → `documento` → presupuesto →
programa → obra → dinero.

Hay dos referencias circulares que se resuelven con la llave foránea agregada después:
`usuario_rol.proyecto_id` y `requisicion.compromiso_id`.

### 16.2 Qué significa exactamente "congelado"

**No significa que no se pueda agregar nunca.** Significa que lo que ya existe no se
toca. Son tres niveles, y cada uno se comporta distinto:

| Nivel | Ejemplo | Qué se hace |
|---|---|---|
| **Tabla nueva, o columna nueva en una tabla que no existía todavía** | `nomina` de la rebanada 7, `integracion` de la rebanada 8 | **Migración aditiva. Se hace y se avisa después**, como cualquier trabajo normal |
| **Columna nueva en una tabla que ya existe hoy** | agregar `concepto.marca_registrada` el año próximo | **Se avisa y se aprueba antes de escribir la migración.** No es libre, pero tampoco se detiene todo: es una conversación, no una parada de emergencia |
| **Cambiar o quitar algo que ya existe** | renombrar `precio_venta`, aflojar `ck_concepto_clave_formato`, partir `concepto` en dos tablas | **Se detiene todo y se avisa. No se parcha** |

La distinción que importa es entre **agregar** y **tocar lo que ya está**. Agregar una
tabla nueva no puede romper una consulta que no sabe que esa tabla existe. Tocar una
columna existente sí puede, y por eso ese nivel exige aviso — y quitar o relajar algo
existente exige detenerse del todo, porque ahí es donde la V8 se degradó: cada requisito
nuevo movía el esquema, y mover el esquema rompía lo que ya funcionaba.

**Lo que NO es aditivo, aunque parezca columna nueva:** una columna nueva `not null` sin
`default` en una tabla con filas — rompe la escritura existente el mismo día. Toda
columna aditiva a una tabla existente lleva `default` o admite `null`.

### Orden de creación

`grupo_empresa` → `empresa` → `usuario` → `rol` → catálogos → `partida` → `proveedor` →
`insumo` → `concepto` → `tarjeta` → `cliente` → `proyecto` → `documento` → presupuesto →
programa → obra → dinero.

Hay dos referencias circulares que se resuelven con la llave foránea agregada después:
`usuario_rol.proyecto_id` y `requisicion.compromiso_id`.

---

## 17. Qué quedó fuera

| # | Quedó fuera | Por qué |
|---|---|---|
| 1 | **Nómina, raya semanal, destajos, viáticos e inventario** | Sus tablas son de la rebanada 7. `origen_compromiso` ya reserva sus valores para que entrar no cambie nada de lo congelado |
| 2 | **El cuerpo de los seis triggers** | Están especificados en la sección 12 —qué impide cada uno— pero su código se escribe en la migración, no aquí |
| 3 | **El `schema.prisma`** | Se genera de este documento al construir la rebanada 1 |
| 4 | **Particionado y retención de `evento_estado`** | Crece sin parar por diseño. Cuando estorbe se particiona por año; hoy sería optimizar sin medir |
| 5 | **Datos semilla** | Unidades, roles y categorías de primer nivel se cargan en la migración inicial. Su contenido exacto va en [[V10-PLATAFORMA-Y-MIGRACION]] |
| 6 | **Los 60 grupos de descripción repetida** | Único punto de la migración que sigue abierto. Los revisa Stefanno aparte en `docs/migracion/DESCRIPCIONES-REPETIDAS.md` y no bloquea nada: las seis decisiones de datos que sí bloqueaban ya se resolvieron y están en `docs/migracion/LEEME.md` |

### Lo que este documento decidió y no estaba en el modelo de dominio

1. `char(26)` ULID como identificador, y `numeric` en todo el dinero
2. Estados como `enum` de PostgreSQL; roles y subcategorías como tabla
3. `revoke update, delete` sobre `evento_estado` y `linea_base_actividad`
4. `on delete restrict` en todo el esquema. **No hay un solo `cascade`**
5. `folio` como columna generada, imposible de desincronizar de sus partes
6. La línea base como copia inmutable, no como dos columnas dentro de `actividad`
7. `cotizacion.es_implicita` para el proveedor que no cotiza
8. Política de fila como segunda barrera entre empresas
9. `estado_requisicion.CANCELADA`, que el requisito no contemplaba
10. **Subtotal base y subtotal derivado**, que resuelven la circularidad de los
    porcentuales sin un solo trigger: la puerta no se cierra, no se construye
11. En `presupuesto_concepto`, columnas separadas para precio y porcentaje — en
    `concepto` basta `valor` porque no conviven en la misma suma
12. `-V[1-9][0-9]?` y `clave = upper(clave)`, salidos de probar la expresión regular
13. `presupuesto_opcion.mostrar_porcentuales_desglosados`, para el honorario que en obra
    va embebido y no se imprime como línea aparte
14. El subtotal base se calcula a `precio_venta`, nunca a `precio_costo` — escrito tres
    veces (regla, fórmula y comentario en el SQL) para que no se lea al revés
15. Los tres niveles de "congelado" — tabla nueva, columna nueva en tabla existente,
    tocar lo que ya está — cada uno con su propio requisito, en la sección 16.2

---

## 18. Cambios de R01 a R02

Dos precisiones de Stefanno al aprobar, el mismo 8-ago-2026. R01 no llegó a estar
vigente.

| # | R01 dejaba implícito | R02 dice | Por qué cambió |
|---|---|---|---|
| 1 | Que el subtotal base de un porcentual es a precio de venta | **Escrito explícitamente**, tres veces: junto a la fórmula en §7.1, en el comentario del SQL de `v_presupuesto_base` en §13, y en [[V10-MODELO-DOMINIO]] | Es dinero, y un honorario calculado sobre el costo directo interno en vez de sobre lo vendido es un error que sólo se nota cuando ya se facturó mal. Dejarlo implícito era apostar a que nadie lo leyera al revés dentro de seis meses |
| 2 | Si el renglón porcentual siempre se imprime | `presupuesto_opcion.mostrar_porcentuales_desglosados`, boolean, por opción | En obra el honorario a veces va embebido y no se muestra como renglón aparte. El cálculo no cambia — sigue siendo base + derivado — sólo cambia si se desglosa en el documento |
| 3 | Qué significa "esquema congelado" | Tres niveles explícitos en §16.2: tabla o columna nueva en tabla nueva (aditivo, adelante) · columna nueva en tabla existente (se avisa y se aprueba) · tocar lo existente (se detiene) | La primera redacción sonaba a que nada se podía agregar nunca, y eso habría obligado a romper la regla en la primera rebanada que necesitara una tabla de preferencias de usuario |

---

## 19. Migraciones posteriores al congelamiento

El esquema quedó congelado el 8-ago-2026 (§16). Lo que sigue después **no reabre el
congelamiento**: sigue exactamente la regla de tres niveles de §16.2. Cada entrada de
esta sección es una migración aditiva o de nivel 2, avisada y aprobada antes de
escribirse en el DDL de las secciones 4 a 10 — que ya la incorporan, para que ese DDL
siga siendo la fuente de verdad del estado actual, y esta sección quede como el
registro de cómo se llegó ahí.

### Migración 001 · firma en `presupuesto.AUTORIZADO` · 8-ago-2026

**Nivel 2 — columna nueva en tabla existente.** Avisada como propuesta en
[[V10-CATALOGO-DOCUMENTOS]] §6.3.1, **aprobada por Stefanno el mismo día.**

```sql
alter table presupuesto add column firmado_por varchar(160);
alter table presupuesto add column firmado_en  timestamptz;
alter table presupuesto add constraint ck_presupuesto_autorizado_firmado check (
  estado <> 'AUTORIZADO' or (firmado_por is not null and firmado_en is not null)
);
```

**Por qué:** el presupuesto autorizado es el contrato — decisión de
[[V10-CATALOGO-DOCUMENTOS]] §6.3.1, sin crear una entidad `contrato` aparte. **Y un
contrato sin firma registrada no es un contrato.** Las columnas son nulables porque
`BORRADOR` y `ENVIADO` no las necesitan; la restricción sólo exige que estén llenas
cuando el estado ya es `AUTORIZADO` — el mismo patrón que `ck_presupuesto_enviado` ya
usaba para `ENVIADO`, aplicado un estado más adelante.

Ya aplicada en la tabla `presupuesto` de la sección 7.

### Migración 002 · `sincronizacion_recibida` · 9-ago-2026

**Nivel 1 — tabla nueva, aditiva. No requiere aprobación previa.** Diseñada en
[[V10-API]] §5, para la idempotencia de la cola offline de
[[V10-PANTALLAS-Y-ROLES]] §5.

```sql
create table sincronizacion_recibida (
  id                 char(26) primary key,
  empresa_id         char(26) not null references empresa(id),
  clave_idempotencia char(26) not null,
  entidad_tipo       varchar(40) not null,
  entidad_id         char(26) not null,
  recibido_en        timestamptz not null default now(),

  constraint uq_sincronizacion_recibida unique (empresa_id, clave_idempotencia)
);
```

**Por qué:** un elemento de la cola offline puede reintentarse por señal intermitente, y
el servidor no puede crear dos veces el mismo evento o la misma requisición sólo porque
la respuesta del primer intento se perdió en el camino. La clave de idempotencia nace en
el teléfono, una sola vez, cuando el elemento entra a la cola — no cuando se envía.

### Migración 003 · autorrevisión de requisición, con tope · 9-ago-2026

**Nivel 2 — columna nueva en dos tablas existentes, más un `CHECK` modificado y un
trigger nuevo. Avisada como hallazgo en [[V10-HANDOFF-ClaudeCode]] §5, decisión 9,
aprobada por Stefanno el mismo día con condición: no es una excepción libre, tiene
tope.**

```sql
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
```

**El tope no puede ir en un `CHECK`** — depende de `empresa.monto_maximo_autorrevision`,
una tabla distinta, y un `CHECK` sólo ve columnas de su propia fila. Va en trigger,
como los otros seis de la sección 12:

```sql
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
```

**Por qué el tope, y por qué en trigger y no en aplicación:** comprar un bulto de cemento
parado en la obra no puede esperar a que alguien más firme — por eso la autorrevisión
existe. Autorizarse solo una compra de cincuenta mil pesos sí es un problema, y ningún
despacho pequeño debería permitírselo aunque sean tres personas — por eso tiene tope.
Ponerlo en trigger, no sólo en la validación de la Server Action, significa que **ni un
error de la aplicación ni una consulta directa a la base** pueden colar una autorrevisión
por encima del tope. Es la misma razón por la que `ck_avance_cien_exige_carta` vive en la
base y no sólo en la interfaz.

**Valor inicial: $5,000, configurable por empresa.** Ninguna migración de datos que
tocar: es una columna nueva con `default`, y las requisiciones que ya existan —ninguna
todavía, el código no ha empezado— no se ven afectadas.

**La marca visible, en pantalla y en documento, no es de este documento.** Vive en
[[V10-PANTALLAS-Y-ROLES]] pantalla 20 y en [[V10-CATALOGO-DOCUMENTOS]] — ver ambos,
actualizados el mismo día.

---

*Documento 4 de 8 · APROBADO Y CONGELADO el 8-ago-2026, con las migraciones 001, 002 y
003 posteriores. El anteproyecto y el proyecto ejecutivo —los ocho documentos— cerraron
el 9-ago-2026 con [[V10-API]].*
