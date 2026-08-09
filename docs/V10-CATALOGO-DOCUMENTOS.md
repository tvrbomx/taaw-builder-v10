# TAAW V10 · CATÁLOGO DE DOCUMENTOS

**R01 · 8-ago-2026 · documento 6 de [[V10-PLAN-DE-TRABAJO-R02]]**

Qué PDF emite cada entidad, con qué folio ISO 19650 y en qué estado documental.
Adelantado sobre `V10-PLATAFORMA-Y-MIGRACION`: sólo depende de
[[V10-MODELO-DOMINIO]] y de [[V10-ESQUEMA-SQL]], no de la plataforma.

Depende también de `DRAVYA-NOM-NomenclaturaDocumental-R01`, documento de empresa. Su
fuente vive fuera de este repositorio, en `EMPRESA/NORMATIVA/`; hay una copia de sólo
lectura en [[docs/normativa-dravya/DRAVYA-NOM-NomenclaturaDocumental-R01]], junto con
las otras cinco normas de Dravya que este documento también consultó: el manual de
trabajo colaborativo, la norma BIM, el flujo BIM, el protocolo de revisión de planos y
la estructura de carpetas de proyecto.

---

## Índice

```
1  Qué resuelve este documento y qué no
2  La ficha — los diez campos que declara todo documento
3  Regla dura · cliente nunca ve costo, utilidad, margen ni proveedor
4  Regla dura · marca de agua por estado documental
5  Regla dura · el consecutivo es secuencia en base, no contador de app
6  El catálogo completo — 31 documentos, por dominio
   6.1 Catálogo técnico (3)        6.4 Programa y control de obra (6)
   6.2 Proyecto y documentación (2)     6.5 Obra (9, una bloqueada)
   6.3 Presupuesto (6)             6.6 Dinero (5)
7  Casos especiales
8  Hallazgos y pendientes
9  Qué quedó fuera
```

---

## 1. Qué resuelve este documento y qué no

**Resuelve:** para cada documento que la aplicación puede emitir, quién lo genera, qué
lo dispara, cómo se compone su folio, si es para el cliente o interno, si lleva firma,
si caduca, qué contiene y — con el mismo peso — qué nunca debe aparecer en él.

**No resuelve:** el diseño visual de cada plantilla PDF ni el layout de cada pantalla
que lo genera. Eso es [[V10-PANTALLAS-Y-ROLES]], que depende de este documento y del
modelo de dominio.

Este documento no toca el esquema congelado. Donde un documento necesitó una tabla que
no existe (el contador de folios), la tabla se agrega como **migración aditiva** — nivel
1 de la regla de congelamiento, adelante sin pedir permiso — y donde un documento
necesitó una entidad que tampoco existe (inventario), **se detuvo y se dejó marcado**,
en vez de inventarla aquí para resolver un documento.

---

## 2. La ficha — los diez campos que declara todo documento

Todo documento del catálogo, sin excepción, declara estos diez campos. La tabla central
de la sección 6 los aplica a los 31.

| # | Campo | Qué significa |
|---|---|---|
| 1 | **Entidad emisora** | qué tabla del modelo de dominio produce el documento |
| 2 | **Disparador** | qué evento o transición de estado lo genera — nunca "a petición", siempre un hecho verificable |
| 3 | **Folio** | tipo ISO (2 letras) · función (1 letra) · bloque. Se compone con la fórmula de `documento.folio` del esquema, nunca se escribe a mano |
| 4 | **Numeración** | qué secuencia del contador asigna su `numero` — sección 5 |
| 5 | **Empresa emisora** | de qué fila de `empresa` salen logotipo, datos fiscales, disclaimer y pie de página — sección 3 y hallazgo de la 8 |
| 6 | **Cliente / Interno** | sin ambigüedad — sección 3 |
| 7 | **Contenido** | qué trae |
| 8 | **Excluye** | qué nunca aparece, aunque el dato exista en la base |
| 9 | **Estado documental y marca de agua** | qué estados de `estado_documento` recorre, y cuándo lleva marca de agua — sección 4 |
| 10 | **Firma** | sí o no, de quién, si reserva espacio aunque no se firme en el acto |
| 11 | **Vigencia** | si caduca, a cuántos días, y de qué campo sale la fecha de vencimiento |

(Quedaron once, no diez — el campo de numeración se separó del de folio al escribirlo,
porque merece su propia regla. Se avisa aquí en vez de renumerar el índice aprobado.)

---

## 3. Regla dura · cliente nunca ve costo, utilidad, margen ni proveedor

**No es una función de permisos. Es una regla de diseño**, ya escrita en
[[V10-DISENO]] §8: *"El cliente nunca ve lo interno."* No se puede depender de que
alguien se acuerde de ocultar una columna al armar una plantilla nueva.

**Mecanismo, en dos capas:**

1. **La vista de datos que alimenta un documento de cliente nunca incluye las columnas
   prohibidas.** `v_estado_financiero_cliente` no tiene columna de costo ni de utilidad
   — no es que se oculten en la plantilla, es que la consulta no las trae. Un documento
   de cliente no puede filtrar lo que no lee.
2. **Todo documento marcado `Interno` en el campo 6 de su ficha lleva, en el encabezado
   de la primera página, la leyenda:**

   > **DOCUMENTO INTERNO — NO SE ENTREGA AL CLIENTE**

   en el color de estado (`atencion`, de los tokens de [[V10-DISENO]]), visible sin
   necesidad de leer el pie de página.

**Lo que nunca aparece en un documento `Cliente`, en ningún caso:**

- `presupuesto_concepto.precio_costo`
- cualquier `porcentaje` o importe de `PORCENTAJE_OBRA` / `PORCENTAJE_PARTIDA` **si**
  `presupuesto_opcion.mostrar_porcentuales_desglosados = false` — y aun mostrándose,
  nunca su cálculo interno, sólo el importe final
- `proveedor.*` — nombre, contacto, forma de pago, cuenta
- `movimiento.categoria_gasto_id` y cualquier columna de `movimiento_concepto`
- `insumo.costo_unitario`, `tarjeta.*`, `renglon_tarjeta.*`

---

## 4. Regla dura · marca de agua por estado documental

**S0 y S3 salen con marca de agua. A5 en adelante, limpio.** Sin esto, un borrador de
presupuesto llega al cliente indistinguible de uno autorizado — que es exactamente el
tipo de error que una firma de arquitectos no se puede permitir con dinero de por medio.

| `documento.estado` | Marca de agua | Texto |
|---|---|---|
| `S0` | **sí** | `BORRADOR — SUJETO A CAMBIOS` |
| `S1` – `S2` | **sí** | `EN COORDINACIÓN — NO AUTORIZADO` |
| `S3` | **sí** | `EN REVISIÓN — NO AUTORIZADO` |
| `S4`, `S6`, `S7` | **sí** | `PENDIENTE DE AUTORIZACIÓN` |
| `A0` – `A7` | **no** | — limpio, es la versión autorizada |
| `B0` – `B7` | **sí**, distinta | `FIRMA PARCIAL` — el estado lo dice, no es un documento cerrado |
| `CR` | **no** | as-built, es registro final |

La marca de agua se calcula del **prefijo** del estado (`S`, `A`, `B`, `CR`), no de un
booleano capturado aparte — para que no exista la posibilidad de que alguien marque
`A5` y deje la marca de agua encendida por error.

**Esto aplica sólo a documentos `Cliente`.** Un documento `Interno` no necesita marca de
agua de autorización: ya lleva la leyenda de "no se entrega" de la sección 3, que dice
algo más fuerte.

---

## 5. Regla dura · el consecutivo es secuencia en base, no contador de app

El campo 9 de la norma ISO 19650 (`numero`) es consecutivo **por tipo de documento**. Un
contador en memoria de la aplicación, o un `SELECT max(numero)+1`, genera folios
repetidos en cuanto dos personas emiten al mismo tiempo — y con tres personas cubriendo
ocho roles, va a pasar.

### 5.1 Tabla nueva · `documento_contador`

**Migración aditiva.** No toca el esquema congelado — es una tabla que no existía,
sobre datos que no existían.

```sql
create table documento_contador (
  id           char(26) primary key,
  empresa_id   char(26) not null references empresa(id),
  proyecto_id  char(26) references proyecto(id),   -- null en documentos EMP
  tipo         char(2)  not null,
  siguiente    int      not null default 1
);

create unique index ux_documento_contador
  on documento_contador (empresa_id, (coalesce(proyecto_id, '')), tipo);
```

`coalesce(proyecto_id, '')` en el índice, no en la tabla: `proyecto_id` no puede ir en
una llave primaria porque las llaves primarias no admiten `null`, y los documentos de
empresa (`EMP`, sin proyecto) necesitan su propio contador igual que los de proyecto. El
índice de expresión resuelve exactamente ese caso sin inventar un proyecto ficticio.

### 5.2 El bloqueo es `SELECT ... FOR UPDATE`, en la misma transacción que crea el documento

```sql
begin;

-- si es el primer documento de este tipo para esta empresa/proyecto, se crea el
-- contador sin pisar uno existente
insert into documento_contador (id, empresa_id, proyecto_id, tipo, siguiente)
values (ulid(), :empresa_id, :proyecto_id, :tipo, 1)
on conflict (empresa_id, (coalesce(proyecto_id, '')), tipo) do nothing;

-- se bloquea la fila del contador. Nadie más puede leer este número hasta que
-- esta transacción termine
select siguiente into v_numero
  from documento_contador
 where empresa_id = :empresa_id
   and coalesce(proyecto_id, '') = coalesce(:proyecto_id, '')
   and tipo = :tipo
   for update;

update documento_contador
   set siguiente = siguiente + 1
 where empresa_id = :empresa_id
   and coalesce(proyecto_id, '') = coalesce(:proyecto_id, '')
   and tipo = :tipo;

insert into documento (..., numero, ...) values (..., v_numero, ...);

commit;
```

**Si la transacción falla, el número no se gasta.** `for update` mantiene el bloqueo
hasta el `commit`; si algo revierte antes, el `update` del contador revierte con él, y
el siguiente que pida un número recibe el mismo — no uno saltado. Es la misma disciplina
de "toda escritura múltiple va en transacción" que ya rige el resto del esquema.

---

## 6. El catálogo completo — 31 documentos

Convenciones de la tabla: **✓** en Folio significa que el tipo ISO tiene ejemplo
confirmado en `DRAVYA-NOM-NomenclaturaDocumental-R01` §12. Sin marca, es una asignación
propuesta en este documento — ver hallazgo 8.5. **C** = Cliente, **I** = Interno.

### 6.1 Catálogo técnico (3)

| # | Documento | Entidad | Disparador | Folio | C/I | Firma | Vigencia |
|---|---|---|---|---|---|---|---|
| 1 | Catálogo de conceptos | `concepto` | a petición, filtrado por partida | `BQ`·Q·G-01 | I | no | no caduca |
| 2 | Catálogo de insumos | `insumo` | a petición, filtrado por tipo | `BQ`·Q·G-01 | I | no | no caduca |
| 3 | Tarjeta de precio unitario | `tarjeta` | a petición, por concepto | `CP`·Q·G-01 ✓ | I | no | no caduca |

Los tres son documentos internos: exponen `costo_unitario` de insumo y `costo_directo`
de concepto sin margen, que es exactamente lo que la regla 3 prohíbe entregar.

### 6.2 Proyecto y documentación (2)

| # | Documento | Entidad | Disparador | Folio | C/I | Firma | Vigencia |
|---|---|---|---|---|---|---|---|
| 4 | Carátula de proyecto | `proyecto` | alta de proyecto o cambio de etapa BIM | `RP`·Q·G-01 | C | no | no caduca |
| 5 | Índice documental | `documento` | a petición, lista todo lo emitido en el proyecto | `SH`·Q·G-01 | I | no | no caduca |

`Carátula de proyecto` es el único documento de este par que sale al cliente: nombre,
dirección, etapa BIM vigente, colaboradores visibles. Sin costos ni proveedores.

### 6.3 Presupuesto (6)

| # | Documento | Entidad | Disparador | Folio | C/I | Firma | Vigencia |
|---|---|---|---|---|---|---|---|
| 6 | Presupuesto al cliente | `presupuesto_opcion` | `presupuesto.estado → ENVIADO` | `BQ`·Q·G-01 ✓ | C | **ver 6.3.1** | `presupuesto.vigencia_hasta` |
| 7 | Presupuesto · sólo volúmenes | `presupuesto_concepto` | igual que 6, exportable | `BQ`·Q·G-01 | C | no | igual que 6 |
| 8 | Presupuesto · exportables selectivos (6 subvariantes, ver §7) | `tarjeta` vía `presupuesto_concepto` | a petición | `SH`·Q·G-01 | I | no | igual que 6 |
| 9 | Presupuesto de un módulo | `presupuesto_modulo` | igual que 6, alcance parcial | `BQ`·Q·M-## ✓ | C | no | igual que 6 |
| 10 | Generadores de volumen | `generador` | a petición, memoria de cálculo | `CA`·Q·G-01 ✓ | I* | no | no caduca |
| 11 | **Comparativo de opciones** — nuevo, ver §7 | `presupuesto` (varias `presupuesto_opcion`) | `presupuesto.estado → ENVIADO` | `BQ`·Q·G-01 | C | no | igual que 6 |

`*` Los generadores son internos por regla general — documentan cómo se sacó una
cantidad, con todo el detalle de ejes y tramos — pero no traen costo ni utilidad, así
que **entregarlos al cliente que los pida no rompe la regla 3.** Quedan marcados
internos por default; el residente decide caso por caso si los adjunta.

#### 6.3.1 Firma del documento 6 — la resolución del "contrato"

**El presupuesto autorizado es el contrato.** No se crea entidad nueva: `presupuesto`
llega a `AUTORIZADO` con documento en estado `A5`, y `A5` significa —según la propia
norma de nomenclatura— *"presupuesto que el cliente firmó."* Los términos ya viven en el
sistema: el esquema de cobranza 60/20/20 en `tramo_cobranza`, la vigencia en
`vigencia_hasta`, y el alcance por concepto en `presupuesto_concepto`.

**Consecuencia para el esquema — nivel 2, avisada y aprobada.** La transición
`presupuesto.estado → AUTORIZADO` exige firma registrada. Se avisó aquí como propuesta,
Stefanno la aprobó el mismo día, y ya está escrita en [[V10-ESQUEMA-SQL]] §19 como
**migración 001**:

```sql
alter table presupuesto add column firmado_por varchar(160);
alter table presupuesto add column firmado_en  timestamptz;
alter table presupuesto add constraint ck_presupuesto_autorizado_firmado check (
  estado <> 'AUTORIZADO' or (firmado_por is not null and firmado_en is not null)
);
```

Es exactamente el camino que la regla de congelamiento nivel 2 describe: se avisa, se
aprueba, y **entonces** se escribe — no antes.

---

*Decisión diferida:* si algún día hace falta un contrato formal con cláusulas,
penalizaciones y garantías —distinto de un presupuesto autorizado—, es una **tabla
nueva** (`contrato`), migración aditiva sin tocar nada de lo congelado. No hace falta
hoy: el requisito de obra nunca lo pidió, y el presupuesto autorizado ya cumple la
función.

### 6.4 Programa y control de obra (6)

Los nombres de esta tabla son **los de la oficina**, no los de la norma de
nomenclatura — resolución 4 de Stefanno. Ver hallazgo 8.4.

| # | Documento | Entidad | Disparador | Folio | C/I | Firma | Vigencia |
|---|---|---|---|---|---|---|---|
| 12 | Cronograma de obra | `actividad` / `cronograma_plan` | `linea_base` nueva o cronograma autorizado | `PR`·Q·G-01 ✓ | C | no | no caduca — se sustituye por revisión |
| 13 | Programa valorizado | `actividad` con importe ligado | igual que 12 | `PR`·Q·G-01 | I | no | no caduca |
| 14 | Flujo semanal | `semana_flujo` | a petición o corte semanal | `CP`·Q·G-01 ✓ | I | no | no caduca |
| 15 | Calendario de cobranza | `tramo_cobranza` | cambio de `semana_corte_calculada` o forzado | `CP`·Q·G-01 | C | no | no caduca |
| 16 | Estimación | `avance` | corte de periodo | `RP`·Q·G-01 | C | **sí** — residencia y coordinación | no caduca, es corte |
| 17 | Control de obra semanal | `avance` | corte semanal | `RP`·Q·G-01 ✓ | I | no | no caduca |

`Programa valorizado` es interno porque trae importe por actividad ligado al
`precio_venta` del presupuesto — es información de negocio, aunque no sea costo directo;
`Cronograma de obra` (sin importes) es la versión que sí sale al cliente.

### 6.5 Obra (9 — una bloqueada)

| # | Documento | Entidad | Disparador | Folio | C/I | Firma | Vigencia |
|---|---|---|---|---|---|---|---|
| 18 | Requisición | `requisicion` | `requisicion.estado → SOLICITADA` | `SH`·W·G-01 ✓ | I | **sí** — residente y supervisor, regla de validación cruzada. **Si `autorrevision_motivo` tiene valor, el documento lo imprime visible, con el motivo — nunca se omite** | no caduca |
| 19 | Orden de compra | `requisicion` / `cotizacion` | `requisicion.estado → APROBADA` | `SH`·W·G-01 | I | no | no caduca |
| 20 | Orden de trabajo | `requisicion` / `cotizacion` | igual que 19, para subcontrato/mano de obra | `SH`·W·G-01 | I | no | no caduca |
| 21 | Carta entrega de trabajo | `carta_entrega` (nivel TRABAJO) | `requisicion.estado → ENTREGADA` | `CO`·Q·G-01 | C** | **sí** — quien entrega y quien recibe | no caduca |
| 22 | Carta entrega de obra | `carta_entrega` (nivel OBRA) | finiquito de obra | `CO`·Q·G-01 | C** | **sí** | no caduca |
| 23 | Carta entrega de proyecto | `carta_entrega` (nivel PROYECTO) | cierre de etapa de proyecto | `CO`·Q·G-01 | C** | **sí** | no caduca |
| 24 | Bitácora de obra | `evento` | a petición, corte de periodo | `RP`·W·G-01 ✓ | I | no | no caduca |
| 25 | Reporte fotográfico (ver §7) | `evento_foto` | corte según §7 | `VS`·W·G-01 ✓ | C | no | no caduca |
| 26 | Entrada y salida de inventario | — | — | — | — | — | **⚠ bloqueado, ver 8.1** |

`**` Las cartas entrega son `Cliente` porque sellan un trabajo que el cliente pagó y
tiene derecho a ver recibido — pero llevan la misma exclusión de costo y proveedor que
cualquier otro documento de cliente: la carta dice *qué* se entregó, no *cuánto costó*
entregarlo.

### 6.6 Dinero (5)

| # | Documento | Entidad | Disparador | Folio | C/I | Firma | Vigencia |
|---|---|---|---|---|---|---|---|
| 27 | Recibo de ingreso | `movimiento` | `movimiento` creado, `tipo = POR_COBRAR` | `RP`·Q·G-01 | C | no | no caduca |
| 28 | Recibo de egreso | `movimiento` | `movimiento` creado, `tipo = POR_PAGAR` | `RP`·Q·G-01 | I | no | no caduca |
| 29 | Estado de cuenta de cliente | `compromiso` (`POR_COBRAR`) | a petición o corte | `RP`·Q·G-01 ✓ | C | no | no caduca, es corte a la fecha |
| 30 | Estado de cuenta de proveedor | `compromiso` (`POR_PAGAR`) | a petición | `RP`·Q·G-01 | I | no | no caduca |
| 31 | Reporte de utilidad y ahorros | `v_estado_financiero_operativo` | a petición | `RP`·Q·G-01 | I | no | no caduca |

**Recibo de egreso es interno** porque su detalle incluye `movimiento_concepto` con
`categoria_gasto_id` y puede traer el nombre del proveedor pagado — dato que la regla 3
prohíbe. Recibo de ingreso sí es de cliente: es la constancia de lo que él pagó, sin
información de cómo se gastó.

---

## 7. Casos especiales

### 7.1 Exportables selectivos del presupuesto — documento 8

Un solo motor, seis salidas, todas leyendo `tarjeta` a través de `presupuesto_concepto`:

| Variante | Qué trae | A quién sirve |
|---|---|---|
| Sólo materiales | renglones `MATERIAL` de las tarjetas de los conceptos presupuestados | comparar contra cotización de proveedor |
| Sólo mano de obra | renglones `MANO_OBRA` | control de destajos y cuadrillas |
| Sólo equipo y renta | renglones `HERRAMIENTA` | negociar renta con el proveedor de maquinaria |
| Sólo indirectos | renglones `INDIRECTO` | EPP, andamiaje, trámites de obra |
| Sólo viáticos | conceptos de la categoría `VIATICOS_Y_COMBUSTIBLE` | logística de campo |
| **Lista de compras consolidada** | suma de las fracciones de consumible de **todo** el presupuesto — es la razón por la que un consumible se registra como fracción de pieza y no como pieza completa, según `V10-MODELO-DOMINIO` §8 | compra en bloque, no por concepto |

Las seis son internas: exponen `costo_unitario` de insumo, que es exactamente lo que la
regla 3 prohíbe en un documento de cliente.

### 7.2 Reporte fotográfico por cortes — documento 25

Un solo documento, cinco anchos de corte sobre `evento_foto.tomada_en`:

```
semanal · quincenal · mensual · bimestral · general (todo el proyecto)
```

Cada corte es una emisión distinta con su propio `numero` de la misma secuencia
`VS·W·G-01` — no cinco tipos de documento, un tipo con cinco alcances de fecha.

### 7.3 Los tres niveles de carta entrega — documentos 21, 22 y 23

Ya especificados en `V10-MODELO-DOMINIO` §10: **trabajo** sella el estado `ENTREGADA` de
una requisición, **obra** sella el finiquito y fin de ejecución, **proyecto** sella el
cierre de la etapa. Comparten tipo `CO` y función `Q`; se distinguen por `nivel` en la
tabla `carta_entrega`, no por un tipo de documento distinto.

### 7.4 Comparativo de opciones — documento 11, nuevo

**Una sola página.** Módulos en las filas, opciones del mismo `presupuesto` en las
columnas, totales al pie, precio por m² de cada una.

```
                    OPCIÓN A         OPCIÓN B         OPCIÓN C
Cocina              $ xxx,xxx        $ xxx,xxx        $ xxx,xxx
Baños               $ xxx,xxx        $ xxx,xxx        $ xxx,xxx
Acabados            $ xxx,xxx        $ xxx,xxx        $ xxx,xxx
                    ─────────        ─────────        ─────────
TOTAL               $ x,xxx,xxx      $ x,xxx,xxx      $ x,xxx,xxx
$ / m²              $ x,xxx          $ x,xxx          $ x,xxx
```

**Regla de negocio, no restricción de base:** las opciones que se comparan tienen que
compartir nombres de módulo, o la fila "Cocina" de una opción sumaría contra la fila
"Cocina y desayunador" de otra y la comparación mentiría. Se valida **al generar el
documento**, en la capa de servicios — igual que la validación de transiciones de
estado, no en una restricción SQL, porque `presupuesto_modulo.nombre` no tiene por qué
ser idéntico entre opciones en el caso general, sólo cuando se van a comparar.

Fuente: `v_presupuesto_total` y `v_presupuesto_base`, agrupadas por `presupuesto_id` en
vez de por `presupuesto_opcion_id` — es la primera vista de la sección 13 del esquema
que se lee **a través de** varias opciones a la vez, no de una sola.

---

## 8. Hallazgos y pendientes

### 8.1 Inventario — documento 26, bloqueado

`inventario_herramienta` e `inventario_material` están descritas en
`V10-MODELO-DOMINIO` §10 pero **no existen en el esquema congelado** — están
explícitamente en `V10-ESQUEMA-SQL` §17 como parte de la rebanada 7. El documento queda
en este catálogo con su número de fila reservado y sin folio, contenido ni disparador
asignado. Se completa cuando la rebanada 7 cree las tablas — no antes, y no aquí.

### 8.2 Contrato — resuelto y aprobado

Ver 6.3.1. El presupuesto autorizado es el contrato. Las dos columnas nuevas en
`presupuesto` (`firmado_por`, `firmado_en`) que exigen la firma en `AUTORIZADO` fueron
**aprobadas por Stefanno el 8-ago-2026** y ya están en [[V10-ESQUEMA-SQL]] §19, migración
001 — nivel 2 de la regla de congelamiento, avisada y aprobada antes de escribirse, como
corresponde.

Queda diferida, no pendiente de nada hoy: si algún día hace falta un contrato formal con
cláusulas, penalizaciones y garantías, es tabla nueva (`contrato`), migración aditiva.

### 8.3 `documento_contador` — resuelto

Tabla nueva, sección 5. Aditiva, no requiere aprobación previa por ser tabla nueva sobre
datos que no existían — se avisa aquí, no se pide permiso.

### 8.4 Tres nombres a actualizar en la norma de empresa — pendiente, fuera de este repositorio

`DRAVYA-NOM-NomenclaturaDocumental-R01.md` §12 usa nombres distintos a los que se operan
todos los días. Gana el nombre de la oficina — resolución 4 de Stefanno:

| Norma dice hoy | Debe decir |
|---|---|
| Cronograma de obra | *(ya coincide — se queda)* |
| Flujograma | **Flujo semanal** |
| Control de obra semanal | *(ya coincide — se queda)* |

Sólo `Flujograma` cambia realmente — al revisar contra el nombre operativo real,
"Cronograma de obra" y "Control de obra semanal" ya coinciden con lo que pediste. Este
catálogo usa los nombres de oficina en toda la sección 6.

**No se edita la norma desde aquí.** Es documento de empresa,
`EMPRESA/NORMATIVA/DRAVYA-NOM-NomenclaturaDocumental-R01.md`, fuera de este repositorio.
Queda anotado como pendiente para que Stefanno lo actualice donde corresponde.

### 8.5 Tipos ISO sin ejemplo en la norma — aprobados por Stefanno, 8-ago-2026

La norma trae ejemplo de folio para 11 documentos. Este catálogo necesitó tipo para 31.
Lo que se asignó sin ejemplo previo, con el criterio usado, **queda aprobado tal como se
propuso**:

| Documento | Tipo asignado | Por qué |
|---|---|---|
| Catálogo de conceptos, Catálogo de insumos, Presupuesto sólo volúmenes | `BQ` | Coincide con la definición literal del tipo: "Catálogo de conceptos / presupuesto" |
| Presupuesto exportables selectivos, Índice documental, Requisición, Orden de compra, Orden de trabajo | `SH` | Son listas/tablas estructuradas, no narrativa ni plano |
| Carátula de proyecto, Estimación, Recibo de ingreso, Recibo de egreso, Estado de cuenta de proveedor, Reporte de utilidad y ahorros | `RP` | Reporte genérico — es el cajón por omisión cuando nada más calza mejor |
| Calendario de cobranza | `CP` | Sigue a `Flujo semanal`, que ya usa `CP` en la norma, y es de la misma familia financiera |
| **Carta entrega (los tres niveles)** | `CO` | Único tipo que no es de la familia "producida por TAAW" marcada en negritas de la norma §5. Se usó porque `CO` significa literalmente *correspondencia* — una carta firmada es correspondencia por definición, y ningún tipo de la familia TAAW lo describe mejor |
| Comparativo de opciones | `BQ` | Misma familia que el presupuesto del que se deriva |

**Sobre `VS` y la contradicción aparente — resuelto por Stefanno, no era contradicción de
la §12.** `VS` **sí** es un tipo producido por Dravya: el reporte fotográfico es suyo y
ya tiene folio de ejemplo en la propia §12. **La que está incompleta es la tabla de
tipos del §8**, que no lo marcó en negritas junto a `BQ`, `CP`, `PR`, `RP`, `SH` y `CA`.
No es que la norma se contradiga: es que a su tabla de tipos le falta una marca.

Esto **no se corrige aquí** — la norma vive fuera de este repositorio y es de sólo
lectura. Se anota junto con el pendiente del punto 8.4, para quien la actualice:

> **Pendiente de la norma:** en `DRAVYA-NOM-NomenclaturaDocumental-R01` §8, marcar `VS`
> en negritas junto a los demás tipos que produce Dravya/TAAW. El folio de ejemplo del
> §12 (`Reporte fotográfico` → `VS`) ya estaba correcto.

---

## 9. Qué quedó fuera

| # | Quedó fuera | Por qué |
|---|---|---|
| 1 | El diseño visual de cada plantilla PDF | Es [[V10-PANTALLAS-Y-ROLES]] |
| 2 | Contenido y folio del documento 26 (inventario) | Bloqueado hasta la rebanada 7 — hallazgo 8.1 |
| 3 | Quién firma exactamente cada carta entrega, más allá de "quien entrega y quien recibe" | Depende de roles por proyecto, y es tema de [[V10-PANTALLAS-Y-ROLES]] |
| 4 | La actualización de `DRAVYA-NOM-NomenclaturaDocumental-R01` §12 (`Flujograma` → `Flujo semanal`) y §8 (marcar `VS` en negritas) | Documento de empresa fuera de este repositorio — hallazgos 8.4 y 8.5 |
| 5 | Plantillas de documento por empresa (logotipo, disclaimers) | Su estructura ya vive en `empresa` desde el esquema; su edición es de la rebanada 8 |

~~Las columnas `firmado_por`/`firmado_en`~~ y ~~la confirmación de los tipos ISO~~ ya no
están fuera: las aprobó Stefanno el 8-ago-2026 — ver 8.2, 8.5 y
[[V10-ESQUEMA-SQL]] §19.

---

*Documento 6 de 8. El siguiente, según el mapa, es [[V10-PLATAFORMA-Y-MIGRACION]] o
[[V10-PANTALLAS-Y-ROLES]] — ambos ya pueden empezar: el primero no dependía de este
documento, y el segundo lo tenía como única dependencia pendiente.*
