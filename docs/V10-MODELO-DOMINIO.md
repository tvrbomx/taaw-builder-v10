# TAAW V10 · MODELO DE DOMINIO

**R02 · 8-ago-2026 · documento 3 de [[V10-PLAN-DE-TRABAJO-R02]]**

> **R02 reemplaza a R01 el mismo día, por cinco correcciones de Stefanno.** El registro
> de qué cambió y por qué está en la sección 17. R01 no llegó a estar vigente.

Entidades, relaciones, máquinas de estado e invariantes de los siete dominios.
Es el documento del que cuelga [[V10-ESQUEMA-SQL]], y por lo tanto **el que decide qué
se puede y qué no se puede hacer durante los próximos años.**

Depende de [[V10-CONCEPTO-ParaQueEsLaApp-R02]], [[V10-ARQUITECTURA]],
[[V10-DISENO]] y [[V10-REQ-CicloDeObra-Cobranza-Bitacora-R01]].

---

## Índice

```
 1  Qué resuelve este documento y qué no
 2  La decisión de identidad · clave de concepto y de partida
 3  Los siete principios del modelo
 4  Mapa de entidades
 5  Dominio 0 · Cimiento
 6  Dominio 1 · Catálogo técnico
 7  Dominio 2 · Proyecto, cliente y documentación
 8  Dominio 3 · Cuantificación y presupuesto
 9  Dominio 4 · Programa y control de obra
10  Dominio 5 · Operación en obra
11  Dominio 6 · Dinero
12  Las máquinas de estado, juntas
13  Dónde vive cada una de las nueve reglas
14  Catálogos controlados
15  Migración de los 877 conceptos
16  Qué quedó fuera
17  Cambios de R01 a R02
```

---

## 1. Qué resuelve este documento y qué no

**Resuelve:** qué cosas existen, cómo se llaman, cómo se relacionan, qué estados
recorren y qué no se les puede hacer nunca.

**No resuelve:** tipos de columna, índices, nombres de tabla en SQL, ni migraciones.
Eso es [[V10-ESQUEMA-SQL]]. Tampoco resuelve pantallas: eso es
[[V10-PANTALLAS-Y-ROLES]].

Cuando este documento dice *derivado*, significa **que no se guarda**: se calcula al
leer. Es la defensa contra el defecto más caro de la V8 — un saldo guardado que dejó de
coincidir con la suma de sus abonos y nadie se enteró.

---

## 2. La decisión de identidad

Es la decisión pendiente número 1 del [[V10-HANDOFF-ClaudeCode]] y bloqueaba el esquema.
**Resuelta por Stefanno el 8-ago-2026**, sobre el análisis de los 877 conceptos reales
del archivo `TAAW_DB_Master.xlsx`.

### 2.1 Lo que se encontró en los datos

No había 40 formatos de identificador: hay **3 formas y 27 prefijos, que dan 40
combinaciones**. Los 877 conceptos se reparten así:

| Forma | Conceptos | Ejemplo |
|---|---:|---|
| `LLL` + 5 dígitos | 571 | `ALB08001` |
| `LLL` + 4 dígitos | 268 | `ALB8072`, `PRE2223` |
| `LLL` + `-` + 4 dígitos | 38 | `EVE-0001` |

La estructura que quiso existir era `prefijo de partida` + `número de partida (2)` +
`correlativo (3)`, y es coherente en las 571 filas sanas. Se degradó por tres causas,
todas de diseño y ninguna de descuido:

**a) El número de partida vive en dos hojas con numeraciones distintas.** `Partidas` da
Albañilerías = 8; `partidas_catalogo` da `order` = 9. Los identificadores siguen a la
primera. El desfase es de +1 y nada obliga a que coincidan.

**b) El generador perdía ceros, y no siempre el mismo.** La secuencia real de
Preliminares es `PRE02021` → `PRE02222` → `PRE2223` → … → `PRE2245`. En Herrería faltan
`HRR10028` a `HRR10032` y en su lugar existen `HRR1030`, `HRR1031`, `HRR1032`. En
partidas de dos dígitos **la descomposición del identificador corto es ambigua**:
`HRR1004` se lee igual como partida 10 + correlativo 04 que como partida 1 +
correlativo 004. No hay regla que las separe, porque nunca la hubo.

**c) La clave nunca fue restricción.** `ARR6011` son **dos conceptos distintos** —
"carga y acarreo en carretilla" y "carga manual a volteo"— con la misma clave. La hoja
lo aceptó sin protestar. Ese es, en una línea, el motivo de existir de la V10.

> **Lo que esto enseña, y vale más que el formato que se elija:** el identificador se
> degradó porque *cargaba información que también vivía en otro lado*. Cada dato
> duplicado dentro de una clave es una oportunidad de que las dos copias dejen de
> coincidir. La clave nueva carga lo mínimo.

### 2.2 Clave de concepto · `ALB-0072`

```
ALB - 0072 [-V1]
 │     │     └── sufijo de variante, opcional
 │     └──────── correlativo dentro de la partida, 4 dígitos, sin reinicio
 └────────────── clave de la partida, 3 caracteres
```

| | |
|---|---|
| **Patrón** | `^[0-9A-Z]{3}-[0-9]{4}(-V[0-9]{1,2})?$` |
| **Longitud** | 8 caracteres, u 11 en una variante |
| **Ámbito de unicidad** | por empresa · `UNIQUE (empresa_id, clave)` |
| **Capacidad** | 9,999 conceptos por partida, contra los 208 del máximo actual |

**Por qué desaparece el número de partida.** El prefijo ya identifica la partida de forma
única en las 877 filas: los dos dígitos eran redundantes, y eran justo el segmento que
traía el conflicto entre las dos numeraciones y el que se rompía al perder el cero.
Quitarlo elimina las causas (a) y (b) de raíz, no las administra.

**Por qué el guion.** No queda ningún número que un `parseInt` pueda interpretar y
truncar. La degradación de la V8 fue, literalmente, aritmética aplicada a algo que no era
un número.

**Por qué tres caracteres alfanuméricos y no tres letras.** Porque la partida
`3D Experiences` ya existe en el catálogo con prefijo `3DS`. Una restricción de sólo
letras rechazaría un dato real el día de la migración.

### 2.3 Clave de partida · el prefijo **es** la clave

Hoy una partida tiene tres identificadores compitiendo: `PART-001`, el prefijo `ALB` y
`order`. Se queda **uno**:

| Atributo | Papel |
|---|---|
| `clave` | `ALB` · 3 caracteres · única por empresa · **es la identidad** |
| `nombre` | `Albañilerías` · puede corregirse sin consecuencias |
| `orden` | entero · sólo decide en qué lugar se imprime · **se puede mover** |

Desaparecen `PART-###` y el número embebido. El orden pasa de ser una restricción a ser
un dato: hoy hay cuatro partidas con número de escape —`VIA`=88, `EXT`=89, `HNR`=90,
`EVE`=96— precisamente porque la numeración se quedó sin lugar donde crecer.

### 2.4 Variantes · `ALB-0072-V1`

Responde a lo que quedó escrito en `CERRADO_conceptos_padre_hijo.md`: *"que en su
redacción venga la clave y una nomenclatura clave del padre"*, y su alternativa *"sólo
que sean contiguos en sus claves"*. El sufijo cumple las dos a la vez: nombra al padre y
garantiza contigüidad alfabética en cualquier listado ordenado.

| Regla | |
|---|---|
| Un solo nivel | padre → hijos. **Sin nietos.** Un hijo que necesita hijos debía ser padre |
| Tarjeta | la del padre. El hijo **no tiene tarjeta propia** |
| Lo que el hijo sobrescribe | título, nota, y **el rendimiento de renglones concretos** |
| Lo que el hijo nunca sobrescribe | precios de insumo. Vienen del catálogo y cascadean |
| Qué se presupuesta | los hijos. **El padre no se presupuesta**: existe para sostener la tarjeta |

La herencia con sobrescritura de rendimiento es la que resuelve el caso real que la
originó —cortar una losa de 12 cm y una de 25 cm es el mismo trabajo a distinta
velocidad— sin partir la tarjeta en dos.

### 2.5 La clave no es la llave foránea

**Toda entidad tiene dos identificadores y hacen cosas distintas:**

| | `id` | `clave` |
|---|---|---|
| Qué es | ULID interno | identificador de negocio |
| Quién lo ve | nadie | todos |
| A qué apuntan las relaciones | **a esto** | a nada |
| Se puede corregir | no | **sí** |

Sin esta separación, corregir un concepto mal clasificado obliga a renombrar en cascada
su tarjeta, sus renglones de presupuesto, sus actividades de cronograma y sus gastos
ligados. Es exactamente el trabajo que en la V8 nadie quiso hacer, y por eso los 268
identificadores rotos siguen ahí un año después. **Un identificador que no se puede
corregir no se corrige: se hereda.**

---

## 3. Los siete principios del modelo

**1 · Todo pertenece a una empresa.** `empresa_id` obligatorio con llave foránea en toda
tabla de negocio. El repositorio filtra; la pantalla no se entera. Regla invariante 9.

**2 · Nada se borra.** `activo` booleano más `desactivado_en`, `desactivado_por` y
`motivo_desactivacion`. No hay `DELETE` en la capa de datos. Regla 7.

**3 · Los importes se guardan sin IVA y en decimal exacto.** Nunca coma flotante. El IVA
es parámetro de la empresa y del documento, y puede valer 0 legítimamente. Regla 3.

**4 · Una columna significa una sola cosa.** Es la regla 4, y tiene un caso real que la
justifica: `materiales.Tienda_Proveedor` guarda un identificador en 34 filas y texto
libre en 38, y por eso la cascada de precios nunca pudo funcionar. En la V10 esa columna
es una llave foránea obligatoria y no admite otra cosa.

**5 · Los saldos y los totales son derivados.** Saldo de un compromiso, avance de un
concepto, total de un presupuesto: se calculan de sus partes. Lo único que se congela es
lo que se entregó al cliente, y se congela **a propósito y con fecha**.

**6 · Todo cambio de estado deja rastro.** Tabla `evento_estado`, sólo de agregar,
nunca de modificar. De ahí salen la bitácora técnica y las alertas. Regla 8.

**7 · Los errores de negocio son tipos del dominio.** `ClaveDuplicada`,
`GastoSinConcepto`, `AvanceSinCartaEntrega`. No cadenas de texto, no `null`, no un cero
que finge ser un resultado.

---

## 4. Mapa de entidades

```
                          ┌─────────────┐
                          │ grupo       │
                          └──────┬──────┘
                                 │
                          ┌──────┴──────┐
                          │  EMPRESA    │  ← todo cuelga de aquí
                          └──────┬──────┘
        ┌────────────────────────┼────────────────────────┐
        │                        │                        │
  ┌─────┴──────┐          ┌──────┴──────┐          ┌──────┴──────┐
  │ CATÁLOGO   │          │  PROYECTO   │          │  USUARIO    │
  │ partida    │          │  cliente    │          │  rol        │
  │ insumo     │          │  documento  │          │  permiso    │
  │ concepto   │          │  folio      │          └─────────────┘
  │ tarjeta    │          └──────┬──────┘
  └─────┬──────┘                 │
        │          ┌─────────────┼─────────────┬──────────────┐
        │          │             │             │              │
        │   ┌──────┴─────┐ ┌─────┴──────┐ ┌────┴─────┐ ┌──────┴─────┐
        └──▶│PRESUPUESTO │ │ PROGRAMA   │ │  OBRA    │ │  DINERO    │
            │ módulo     │ │ actividad  │ │ evento   │ │ compromiso │
            │ pconcepto  │─▶│ avance     │◀│requisición│▶│ abono      │
            │ generador  │ │ semana     │ │ entrega  │ │ movimiento │
            └────────────┘ └────────────┘ └──────────┘ └────────────┘
                     └──────────── el concepto es el hilo ───────────┘
```

**El concepto es el hilo que atraviesa los siete dominios.** Se cuantifica en el
presupuesto, se reparte en el programa, se ejecuta en obra, se recibe con carta entrega
y se paga contra su compromiso. Ese recorrido es el criterio de valor de la plataforma:
*un dato se captura una vez y sirve en todos lados.*

---

## 5. Dominio 0 · Cimiento

### `grupo`
El corporativo. **No opera.** Sólo agrupa empresas para consolidar.

### `empresa`
Dravya, TAAW, y la de mantenimiento cuando exista. Datos fiscales, logotipo, correos,
**leyendas y pies de página de los documentos**, plantillas, `iva_porcentaje`,
`vigencia_dias_cotizacion`, moneda.

Cada empresa tiene sus propios catálogos: **un concepto de Dravya no existe para TAAW.**

### `usuario` · `rol` · `usuario_rol`
Un usuario puede tener **varios roles a la vez, y distintos por proyecto** — es
obligatorio, porque tres personas cubren ocho funciones. Los roles se definen en tabla,
no en código: agregar uno no debe requerir un despliegue.

Roles según [[V10-ARQUITECTURA]] §4: administrador de la aplicación, dirección,
coordinación de proyectos, administración de finanzas, residencia, supervisión,
validador de documentos, consulta.

### `evento_estado`
Tabla de sólo agregar. Un renglón por cada transición de cualquier entidad:

| Campo | Qué guarda |
|---|---|
| `entidad_tipo`, `entidad_id` | qué cambió |
| `estado_anterior`, `estado_nuevo` | de dónde a dónde |
| `usuario_id`, `ocurrido_en` | quién y cuándo |
| `motivo` | por qué, cuando la transición lo exige |

**Es la memoria del proyecto.** Nunca se edita ni se borra, ni siquiera al desactivar la
entidad a la que se refiere.

### `alerta`
Regla 8: todo cambio de estado dispara alerta. Destinatario por **rol**, no por persona.
Tiene `leida_en` y `resuelta_en` separados: leer no es resolver.

Alertas que el requisito de obra exige explícitamente:

- Cobro real después de la fecha programada → semáforo rojo
- Avance real que rebasó la semana de corte con el pago aún pendiente →
  **obra financiada por nosotros**
- Requisición en `PARCIAL ENTREGADO` → alerta viva hasta que cierre
- Concepto al 100% sin carta entrega → **no ocurre**: la base lo impide

---

## 6. Dominio 1 · Catálogo técnico

Es el activo más valioso de la empresa y el que hoy está más dañado.

### `partida`

| Atributo | |
|---|---|
| `clave` | `ALB` · 3 caracteres · **es la identidad** |
| `nombre` | `Albañilerías` |
| `orden` | entero, movible |
| `activo` | 21 de las 47 partidas actuales no tienen ni un concepto |

### `insumo`

Un solo catálogo con `tipo`, en vez de las seis hojas separadas de la V8. La razón: las
seis tenían la misma forma con nombres distintos, y tres de ellas guardaban el
identificador en una columna diferente.

| `tipo` | Qué es | Campo de costo |
|---|---|---|
| `material` | varilla, cemento, cable | `costo_unitario` |
| `mano_obra` | cuadrilla | `salario_real` = base × factor |
| `herramienta` | equipo propio o rentado | `costo_unitario` + combustible |
| `herramienta_menor` | **no es renglón**: es porcentaje sobre la mano de obra | — |
| `indirecto` | EPP, andamio, derecho de tiro | `costo_unitario` + `factor_aplicacion` |
| `subcontrato` | destajo por unidad terminada | `precio_unitario_ref` |

Todo insumo tiene `proveedor_id` **obligatorio y como llave foránea**. Un insumo puede
repetirse con proveedores distintos a propósito: es el comparativo de precios, y hay que
conservarlo.

`factor_aplicacion` de un indirecto: `por_concepto` · `por_dia` · `pct_mano_obra` ·
`pct_total`. El motor de cálculo lo respeta; no puede tratarlos igual.

### `concepto`

| Atributo | Nota |
|---|---|
| `clave` | `ALB-0072` · regla invariante 1 |
| `clave_anterior` | el identificador de la V8. **Trazabilidad y búsqueda; nunca se usa para relacionar** |
| `partida_id` | corregible sin renombrar la clave |
| `descripcion` · `unidad_id` | unidad del catálogo controlado, no texto libre |
| `padre_id` | vacío = concepto normal o padre · con valor = variante |
| `tipo_precio` · `valor` | ver abajo |
| `labor_pct` | omisión 40, tope 50, `0` válido para suministro puro |
| `hta_menor_pct` | porcentaje sobre mano de obra |
| `indirectos_pct` · `financiamiento_pct` · `utilidad_pct` | de empresa, se calibran al presupuestar |
| `costo_directo` · `precio_venta` | **derivados de la tarjeta**, sólo cuando `tipo_precio = FIJO` |

**Costo directo y precio de venta separados desde el día uno.** Sale de la decisión 1 del
concepto aprobado: la utilidad tiene que verse desde que se cotiza, no al cerrar la obra.

**`clave_anterior` es buscable desde la aplicación**, no una columna muerta de auditoría.
Mientras el Excel de F-19 y la app convivan, un residente tiene que poder escribir
`ALB8072` en el buscador y encontrar el concepto. Cortar ese puente rompería la decisión
6 del concepto aprobado.

#### Precio fijo y precio porcentual

Un honorario cobrado como porcentaje de la obra **es una regla de negocio válida, no un
dato sucio.** El error estaba en el modelo, que sólo sabía guardar precios unitarios y
obligaba a escribir la regla como texto en el campo del precio.

| `tipo_precio` | `valor` significa | Ejemplo real |
|---|---|---|
| `FIJO` | el precio unitario, por unidad de medida | 877 menos 2 conceptos |
| `PORCENTAJE_OBRA` | el porcentaje sobre el total de la obra | `HNR90001`, honorarios al 15% |
| `PORCENTAJE_PARTIDA` | el porcentaje sobre el total de su partida | por definir cuál lo usa |

Consecuencias, y son las que evitan que esto se convierta en el campo polivalente que
prohíbe la regla 4:

- **`valor` se interpreta siempre según `tipo_precio`.** Nunca es "a veces precio y a
  veces porcentaje" en la misma lectura: el tipo se lee primero, y es obligatorio.
- Un concepto porcentual **no tiene tarjeta de precio unitario**: no hay insumos que
  sumar. La alerta de "concepto sin tarjeta" no le aplica.
- Su importe en el presupuesto es **derivado** del total sobre el que se calcula, y por
  lo tanto se recalcula cuando ese total cambia.

#### La circularidad, resuelta por estructura

`HNR-0001` vale 15% del costo total de la obra. Si vive dentro del presupuesto, el total
depende de él y él depende del total. **Un presupuesto tiene dos subtotales, y sólo uno
de ellos se puede referenciar:**

```
SUBTOTAL BASE      = suma de (cantidad × precio_venta) de los conceptos FIJO
                     ← los porcentuales NUNCA entran
        ↓
SUBTOTAL DERIVADO  = PORCENTAJE_OBRA    sobre el subtotal base del presupuesto
                     PORCENTAJE_PARTIDA sobre el subtotal base de su partida
        ↓
TOTAL              = base + derivado
```

**Sobre qué base se calcula un porcentual, sin ambigüedad porque es dinero: el subtotal
base se calcula a `precio_venta` — el que ve el cliente — nunca a `precio_costo`.** Un
honorario se cobra sobre lo vendido, no sobre el costo directo interno de la empresa.

Dos pasos, un solo sentido, sin recursión posible: el paso 1 no puede mirar al paso 2
porque el paso 2 todavía no existe.

**Un porcentual no puede referenciar otro porcentual, y no hace falta prohibirlo.** Un
porcentual no apunta a conceptos: apunta a un subtotal, y un subtotal base sólo contiene
conceptos `FIJO` por definición. No existe la columna con la que se escribiría la
circularidad. Cerrar esa puerta con una restricción sería tapar un hueco que no está en
el muro.

Lo demás que esto arrastra:

- Un concepto porcentual **no tiene tarjeta**: no hay insumos que sumar
- Una variante hereda el tipo de precio de su padre. No hay padres fijos con hijos
  porcentuales
- Una partida que sólo contiene porcentuales tiene base 0, y su derivado da 0. **Es
  correcto que dé cero**, con alerta: el 15% de nada es nada, y el usuario tiene que
  enterarse
- En el PDF los porcentuales van **después** del subtotal base, leyéndose sobre él. Un
  honorario del 15% impreso entre los conceptos de albañilería, sumando como uno más, es
  lo que hace que un presupuesto no cuadre cuando el cliente saca la calculadora
- **El renglón porcentual se puede mostrar u ocultar, por opción de presupuesto.** En
  obra el honorario a veces va embebido y no se imprime como línea aparte. Lo que cambia
  es sólo la impresión: el total sigue siendo base + derivado siempre; ocultarlo no lo
  quita del cálculo, sólo del documento

### `tarjeta` y `renglon_tarjeta`

Una tarjeta por concepto padre. Un renglón por insumo dentro de ella.

```
importe = (cantidad / (rendimiento || 1)) × costo_unitario × (1 + desperdicio_pct/100)
```

`costo_unitario` del renglón es **una copia congelada** del precio del insumo, y eso es
una decisión, no un descuido: un presupuesto entregado al cliente no puede cambiar solo
porque subió un material. `insumo_id` guarda a quién copió, y es lo que permite la
cascada.

**Los dos modos, y la tarjeta decide sola cuál usa:**

| | Modo A | Modo B |
|---|---|---|
| Cuándo | hay al menos un renglón `mano_obra` | no lo hay |
| Cálculo | suma directa | se despeja con `labor_pct` |
| `labor_pct` | **se ignora** | manda |
| Casos | demolición, acarreo, trazo | aplanado, muro, pintura |

La fórmula completa, con el despeje y sus guardas, está en
`referencia-v8/FORMULA_CANONICA_TPU.md` y **no se reescribe aquí**: se implementa como
función pura, con el ejemplo numérico de ese documento como caso de prueba.

**La interfaz dice siempre en qué modo está.** Si el usuario no lo sabe, no entiende por
qué el número cambió al agregar un renglón.

### La cascada

Es la razón de ser del catálogo: *sube la varilla y cambia sola en todos los conceptos
que la usan.*

```
cambia el precio de un insumo
      ↓
renglones que lo referencian  →  se recalcula su importe
      ↓
conceptos afectados           →  se recalcula costo directo y precio de venta
      ↓
variantes de esos conceptos   →  heredan
      ↓
presupuestos NO enviados      →  se actualizan
presupuestos ya enviados      →  NO se tocan. Se avisa
```

| Regla | Por qué |
|---|---|
| La cascada es **acción explícita**, nunca automática | un presupuesto entregado no cambia solo |
| Antes de escribir, **modo simulación obligatorio** | qué tarjetas, qué conceptos, precio anterior y nuevo |
| Todo en **una transacción** | si falla a la mitad, no se guarda nada |
| Actualiza por registro, **nunca borrar y reescribir** | el patrón "último que guarda gana" ya costó datos |

---

## 7. Dominio 2 · Proyecto, cliente y documentación

### `cliente` · `proyecto` · `colaborador`

`proyecto` lleva `clave` corta de 2 a 4 caracteres —`F19`, `C256`— porque es el campo 1
de todos los folios. Lleva `etapa_bim` vigente: `AP` · `PE` · `OB` · `AS`.

`proyecto_rol` asigna quién es residente, supervisor, coordinador y administrador de
finanzas **en ese proyecto**. Las cuatro firmas del ciclo de requisición salen de ahí.

### `documento` y el folio ISO 19650

El folio se **compone**, no se escribe. Los once campos de
`DRAVYA-NOM-NomenclaturaDocumental-R01` son atributos del documento:

```
proyecto - creador - progreso - función - bloque+núm - nivel - tipo - número - revisión - estado
   F19       DRV        PE         Q        G  01       ZZ      BQ      001       03        S3
```

| Regla | |
|---|---|
| `numero` | consecutivo por `(empresa, proyecto, tipo)`, mínimo 3 dígitos |
| `revision` | empieza en `00`. **No es la revisión del proyecto** |
| `estado` | `S0`…`S7`, `A0`…`A7`, `B0`…`B7`, `CR` |
| `S3 → A5` | **sólo el rol validador de documentos.** Nadie más, ni la dirección |

Todo PDF que emite la aplicación nace con folio. Si un documento no puede componer su
folio, **no se emite** — no se emite con folio en blanco.

---

## 8. Dominio 3 · Cuantificación y presupuesto

### `presupuesto` → `presupuesto_modulo` → `presupuesto_concepto`

| Entidad | Nota |
|---|---|
| `presupuesto` | pertenece a un proyecto. `estado`, `vigencia`, `m2`, `incluye_iva` |
| `presupuesto_opcion` | **opciones comparables del mismo presupuesto**, para que el cliente elija |
| `presupuesto_modulo` | `clave` interna `M1`…`M7`. **Al cliente se le muestra sólo el nombre** |
| `presupuesto_concepto` | concepto + cantidad + precio |
| `generador` | de dónde salió la cantidad: ejes, tramos, largo × ancho × profundidad |

`presupuesto_concepto` guarda **tres precios y cada uno tiene su papel**:

| Campo | Qué es | Cuándo cambia |
|---|---|---|
| `precio_catalogo` | lo que valía en el catálogo al insertarlo | nunca |
| `precio_costo` | costo directo de la tarjeta | con la cascada, si no está enviado |
| `precio_venta` | lo que se le cobra al cliente | se puede ajustar en el armado |

De esos tres sale el margen, **visible al armar y nunca en la vista del cliente**. No es
un permiso: es regla de diseño. Costo, utilidad y proveedores no aparecen en ninguna
vista imprimible para el cliente.

### Estados del presupuesto

```
BORRADOR ──▶ ENVIADO ──▶ AUTORIZADO ──▶ CERRADO
    │           │
    │           └──▶ RECHAZADO
    └──▶ (se edita libremente)
```

**Al pasar a `ENVIADO` el presupuesto se congela**: se guarda una versión inmutable con
su folio y su fecha. Editar después crea una **revisión nueva**, nunca modifica la
enviada. Es la única forma de responder "¿qué le mandamos en marzo?" sin adivinar.

`AUTORIZADO` exige documento en estado `A5`. De ese presupuesto sale el programa.

### Exportables selectivos

Un mismo presupuesto emite salidas distintas leyendo las tarjetas de sus conceptos:
al cliente · sólo volúmenes · sólo mano de obra · sólo materiales · lista de compras ·
indirectos · viáticos · rentas.

**La lista de compras consolidada es la que exige que los consumibles se registren como
fracción por unidad de concepto** —0.16 piezas de disco por jornada, no una pieza—
porque se suman las fracciones de todo el presupuesto para saber cuánto comprar. Si se
registra la pieza completa, ese exportable no sirve.

---

## 9. Dominio 4 · Programa y control de obra

### `actividad` · `cronograma_plan` · `cronograma_vivo` · `avance`

| Entidad | Qué es |
|---|---|
| `actividad` | un `presupuesto_concepto` colocado en el tiempo |
| `cronograma_plan` | la línea base. Se congela al autorizar |
| `cronograma_vivo` | lo que realmente está pasando |
| `avance` | avance reportado de un concepto, con fecha, origen y evidencia |
| `semana` | unidad de reparto. El flujo semanal se apoya en ella |

**El avance no se captura suelto: nace de un evento de bitácora o de una entrega.** Un
porcentaje sin quién, cuándo y contra qué no es información.

### La regla que reordena la cobranza

Los porcentajes de cobranza **no son fechas: son tramos del cronograma.**

```
CRONOGRAMA  →  FLUJO SEMANAL  →  % ACUMULADO  →  BLOQUE DE COBRANZA  →  CARÁTULA
```

`semana_corte` de cada tramo se **calcula**: la primera semana cuyo acumulado programado
alcanza el porcentaje acumulado de ese pago. Si el cronograma se mueve, los bloques se
mueven solos.

`fecha_programada` = inicio de obra + (semana de corte × 7).

**Y admite excepción manual, porque la realidad siempre difiere del plan.** Forzarla no
sobrescribe el cálculo: lo acompaña.

| Campo | |
|---|---|
| `semana_corte_calculada` | siempre presente, siempre viva. **El cálculo nunca se pierde** |
| `semana_corte_forzada` | vacía normalmente |
| `motivo_forzado` | **obligatorio** si hay valor forzado. Sin motivo, la base rechaza |
| `forzado_por` · `forzado_en` | quién y cuándo |

La semana vigente es la forzada si existe, y la calculada si no. Guardar las dos es lo
que permite que la aplicación diga *"se forzó a la semana 9; el cronograma dice 12"* en
vez de mentir mostrando un solo número. Forzar es una transición: escribe en
`evento_estado` y dispara alerta, como cualquier otra.

**Derivada adicional:** `desfase_de_caja` = cobrado acumulado − gastado acumulado, semana
por semana. Es la curva que avisa antes de quedarse sin dinero.

### El tope del 99%

Regla invariante 6. **Ningún concepto llega a 100% sin carta entrega.** No es una
advertencia en la interfaz: es una restricción de la base. El avance admite hasta 99 sin
carta; el 100 exige `carta_entrega_id` con firma registrada.

Es lo que vuelve real la utilidad estimada: antes de la carta, la ganancia de ese
concepto es un supuesto; después, es un hecho.

---

## 10. Dominio 5 · Operación en obra

La bitácora es la navaja suiza: **la mano que escribe.** El cronograma es la vista de
calendario de lo que esa mano escribió. Quedan como **dos entidades ligadas, no una**,
según la decisión 4 del concepto aprobado.

### `evento`

| Atributo | |
|---|---|
| `tipo` | evento · anomalía · trabajo ejecutado · recepción · nota técnica |
| `criticidad` | ordinaria · atención · crítica |
| `ocurrido_en` | fecha y hora reales, distintas de la de captura |
| `concepto_id` | opcional, pero es lo que conecta el evento con el avance |
| `foto` · `adjunto` | tablas propias. Una foto pertenece a un evento |

Desde un evento se levanta una requisición, se capta un comprobante, se registra un
avance o se emite una entrada de inventario. **Un solo módulo alimenta muchos
documentos:** las fotos ligadas a trabajos generan solas el reporte fotográfico en
cortes semanal, quincenal, mensual, bimestral y general.

### `requisicion` · `requisicion_renglon` · `cotizacion`

**Toda salida de dinero nace en una requisición.**

| Regla | |
|---|---|
| Liga a concepto | **uno o más, obligatorio.** Sin ella no se puede aprobar. Regla 2 |
| Liga a cotización | obligatoria. Si el proveedor no cotiza —el maestro albañil de palabra— **la requisición es la cotización** y trae el desglose completo |
| Forma de pago | efectivo o transferencia, con los datos para ejecutarlo |
| Compromiso | al aprobarse **crea un compromiso de pago**. Ver dominio 6 |

### `entrega` y `carta_entrega`

| Nivel | Qué sella |
|---|---|
| Trabajo o requisición | el estado `ENTREGADA` de esa requisición |
| Obra | el finiquito y el fin de la ejecución |
| Proyecto | el cierre de la etapa de proyecto |

La carta entrega **parcial** existe: deja el trabajo en `PARCIAL ENTREGADO` con alerta
viva hasta que cierre.

### `inventario_herramienta` · `inventario_material`

Entradas y salidas ligadas a evento de bitácora. Un movimiento de inventario sin evento
que lo explique no se registra.

---

## 11. Dominio 6 · Dinero

Está al final a propósito. **Es la consecuencia de controlar bien el proyecto.**

### `compromiso` y `abono` · la regla 5 hecha estructura

*Nadie paga completo de una sola vez, ni el cliente a nosotros ni nosotros al maestro.*

**Un compromiso es una promesa de dinero; los abonos son la realidad.** Una sola
estructura sirve para las dos direcciones:

| Campo | |
|---|---|
| `direccion` | `por_cobrar` (cliente → nosotros) · `por_pagar` (nosotros → proveedor) |
| `origen_tipo` | `tramo_cobranza` · `requisicion` · `nomina` · `destajo` · `viatico` |
| `monto` | el total comprometido, sin IVA |
| `saldo` | **derivado**: monto − suma de abonos. **Nunca se guarda** |
| `estado` | derivado del saldo: `abierto` · `parcial` · `liquidado` |

**No hay campo "pagado sí/no" en ninguna parte del modelo.** Un abono nunca puede
rebasar el saldo de su compromiso, y esa es una de las cinco pruebas obligatorias de
[[V10-ARQUITECTURA]] §9.

### `movimiento` · `movimiento_concepto`

El dinero que efectivamente entró o salió, con su recibo.

**Regla 2, hecha estructura:** `movimiento_concepto` es una relación de muchos a muchos
con importe distribuido. Un gasto puede repartirse entre varios conceptos, y **la suma
de la distribución debe igualar el importe del movimiento.** Sin esa liga el movimiento
no se aprueba.

Ahí está el punto de más valor de toda la plataforma:

```
AHORRO   = costo presupuestado en la tarjeta − gasto real ligado al concepto
UTILIDAD = utilidad del presupuesto + ahorro conseguido
```

*La utilidad real no es sólo el porcentaje del presupuesto: es ese porcentaje más lo que
se negocie con proveedores.* **Ese ahorro sólo existe si cada gasto está ligado a un
concepto.** Sin la liga es invisible y se diluye — que es exactamente lo que pasa hoy.

### Los dos estados financieros gemelos

Misma información, dos lecturas. Uno se entrega, el otro no sale de la empresa.

| | Cliente | Operativo |
|---|---|---|
| Pregunta | en qué se ha gastado tu dinero | cuánto nos costó y dónde ganamos |
| Jerarquía | módulo → partida → concepto | categoría de gasto |
| Columnas | contratado, % avance, ejecutado, cobrado, por ejecutar | gasto real, costo presupuestado, ahorro, utilidad asimilada |
| Nunca muestra | costo directo, utilidad, proveedores | — |

### Posición financiera del proyecto

Cuatro derivados que hoy no existen en ningún lado: **cobrado a la fecha**, **por
cobrar**, **gastado a la fecha** y **caja del proyecto** = cobrado − gastado.

El último es el que dice si la obra se autofinancia o si la estás pagando tú.

---

## 12. Las máquinas de estado, juntas

### Requisición · seis pasos

```
SOLICITADA          residente + supervisor la levantan y se validan entre sí
     ↓
APROBADA            coordinación de proyectos · crea el compromiso de pago
     ↓
PAGADA              administración de finanzas · admite ABONOS PARCIALES
     ↓                 no avanza hasta que el saldo llega a cero
POR ENTREGAR
     ↓
PARCIAL ENTREGADO   ← alerta viva hasta el cierre
     ↓
ENTREGADA           ← exige CARTA ENTREGA firmada · actualiza el avance del concepto
```

**Sin liga a concepto no se puede pasar de `SOLICITADA` a `APROBADA`.** Cada transición
escribe en `evento_estado` y dispara alerta. Sin excepción.

### Presupuesto

```
BORRADOR → ENVIADO → AUTORIZADO → CERRADO
              └────→ RECHAZADO
```
`ENVIADO` congela una versión inmutable. `AUTORIZADO` exige documento en `A5`.

### Documento · ISO 19650

```
S0 → S3 → A5 → CR
```
`S3 → A5` sólo el validador de documentos.

### Tramo de cobranza

```
PENDIENTE → SOLICITADO → COBRADO
```
`COBRADO` cuando el saldo del compromiso llega a cero, **no cuando alguien lo marca**.

### Concepto en obra

```
NO INICIADO → EN PROCESO → PARCIAL ENTREGADO → ENTREGADO (100%)
```
El paso a `ENTREGADO` exige carta entrega. Es la regla 6.

### Quién edita y quién aprueba · **resuelto 8-ago-2026**

| Objeto | Lo edita | Lo aprueba | Se avisa a |
|---|---|---|---|
| Presupuesto | coordinación de proyectos | **dirección** | — |
| Programa | residencia | **coordinación de proyectos** | — |
| Cambio de precio de un insumo | coordinación de proyectos | — | **dirección** |
| Requisición · `SOLICITADA` | residencia + supervisión, se validan entre sí | — | — |
| Requisición · `→ APROBADA` | — | coordinación de proyectos | — |
| Requisición · `→ PAGADA` | — | administración de finanzas | — |
| Documento · `S3 → A5` | — | validador de documentos | — |

**Quien edita no aprueba lo que editó**, ni siquiera si tiene los dos roles. Es la única
separación que hace que una aprobación signifique algo, y se verifica sobre el usuario,
no sobre el rol.

El cambio de precio de insumo es el único caso de **aviso sin aprobación**: detener una
cascada de precios a esperar firma paralizaría el catálogo, pero dirección tiene que
enterarse de que el costo de la empresa se movió. Es una alerta, no una compuerta.

---

## 13. Dónde vive cada una de las nueve reglas

Una regla que sólo está escrita en un documento no es una regla. Cada una tiene aquí el
mecanismo que la hace cumplirse.

| # | Regla | Mecanismo |
|---|---|---|
| 1 | Clave única y con formato fijo | `CHECK` con expresión regular + `UNIQUE (empresa_id, clave)` |
| 2 | Todo gasto ligado a concepto | `movimiento_concepto` obligatoria + transición bloqueada sin liga |
| 3 | Precios sin IVA | decimal exacto; el IVA es parámetro de empresa y documento |
| 4 | Una columna, una cosa | sin campos polivalentes; `proveedor_id` es llave foránea, no texto |
| 5 | Todo pago es abono contra compromiso | `compromiso` + `abono`; saldo derivado; **no existe "pagado sí/no"** |
| 6 | Ningún 100% sin carta entrega | `CHECK`: avance = 100 exige `carta_entrega_id` |
| 7 | Nada se borra | `activo` + `desactivado_en/por/motivo`; sin `DELETE` en la capa de datos |
| 8 | Rastro y alerta en cada cambio | `evento_estado` de sólo agregar + `alerta` por rol |
| 9 | Todo pertenece a una empresa | `empresa_id` obligatorio; el repositorio filtra siempre |

**Si una función futura exige romper una, no se hace la función: se replantea.**

---

## 14. Catálogos controlados

Lo que en la V8 era texto libre y por eso se degradó. Todos con `activo`, ninguno
editable desde la pantalla que los usa.

### `unidad`

**Los 877 conceptos usan 33 unidades distintas para unas doce reales:** `m2` y `m²`;
`Pza`, `pza`, `PZA` y `Pieza`; `lote` y `Lote`; `m3` y `m³`; `Dia`, `día` y `Semana`.
Ninguna suma de volúmenes es confiable mientras eso siga así.

Cada unidad tiene `clave` canónica, `nombre`, `simbolo` y `decimales`. La migración mapea
las 33 formas a su unidad canónica.

### `tipo_insumo`
`material` · `mano_obra` · `herramienta` · `herramienta_menor` · `indirecto` ·
`subcontrato`.

### `factor_aplicacion`
`por_concepto` · `por_dia` · `pct_mano_obra` · `pct_total`.

### `categoria_gasto` · **resuelta 8-ago-2026**

Dos niveles. **El primero es fijo y lo define la empresa desarrolladora; el segundo queda
abierto por empresa, en tabla, no en código.**

| Nivel 1 · fijo |
|---|
| `MATERIAL` |
| `MANO_DE_OBRA` |
| `SUBCONTRATO` |
| `HERRAMIENTA_Y_EQUIPO` |
| `INDIRECTO` |
| `VIATICOS_Y_COMBUSTIBLE` |
| `TRAMITES_Y_DERECHOS` |
| `NOMINA` |
| `EXTRAORDINARIO` |

El nivel 2 es `categoria_gasto` con `padre_id` y `empresa_id`: Dravya puede abrir
"combustible de maquinaria" bajo `VIATICOS_Y_COMBUSTIBLE` sin que TAAW lo herede, y sin
un despliegue.

> **Categoría de gasto y tipo de insumo son cosas distintas, y confundirlas es lo que
> vuelve inútil el estado financiero operativo.**
>
> El **tipo de insumo** clasifica **qué es** una cosa: un bulto de cemento es material.
> La **categoría de gasto** clasifica **contra qué se carga**: ese mismo bulto de cemento,
> comprado para rellenar un bache del acceso, se carga contra `EXTRAORDINARIO`.
>
> Por eso son dos catálogos y no uno, y por eso `movimiento_concepto` lleva su propia
> `categoria_gasto_id` en vez de heredarla del insumo.

### `etapa_bim` · `estado_documento` · `tipo_documento` · `funcion_iso`
Los del documento `DRAVYA-NOM-NomenclaturaDocumental-R01`, tal cual.

---

## 15. Migración de los 877 conceptos

**Los 877 se migran completos y se depuran sobre la marcha.** No se detiene el
desarrollo esperando una limpieza previa — decisión 5 del concepto aprobado.

### La regla de migración

**Renumerar limpio: `0001..N` por partida, en el orden actual, conservando la clave vieja
en `clave_anterior`.**

**Condición para ejecutarla — el puente con el Excel no se corta.** El presupuesto de
F-19 vive hoy en hoja de cálculo con las claves viejas, y quedó decidido que la app y el
Excel conviven. La renumeración no se ejecuta si no se cumplen las tres:

| | Requisito | Estado |
|---|---|---|
| a | `concepto.clave_anterior` se conserva y es **buscable desde la app** | modelado en §6 |
| b | Se genera `docs/migracion/EQUIVALENCIA-CLAVES.csv` con las 877 filas: clave anterior, clave nueva, descripción y partida | **generado y verificado** |
| c | Ese archivo sirve para actualizar el Excel de un jalón | instructivo en `docs/migracion/LEEME.md` |

Las claves nuevas se asignaron **por orden de aparición**, así que dar de baja un
concepto deja un hueco y no recorre a los demás. El archivo de equivalencia no cambia
cuando se resuelvan las decisiones pendientes.

La razón está en los datos. Intentar preservar el correlativo viejo obliga a resolver
**42 casos a mano**: 4 colisiones y 38 identificadores cuya descomposición no es
decidible. Y obligaría a inventar una regla de lectura para un generador que nunca la
tuvo — es decir, a adivinar. Renumerar limpio elimina las dos cosas de un golpe y no
pierde nada: la clave vieja queda guardada y buscable.

### Las cuatro colisiones, y qué se hace con cada una

**Resueltas por Stefanno el 8-ago-2026.**

| Clave normalizada | Origen | Resolución |
|---|---|---|
| `ARR-0011` | `ARR6011` **dos veces** | **Se separan.** Carretilla y volteo son trabajos distintos |
| `CIM-0001` | `CIM-0001` + `CIM04001` | **Se separan.** Cimentación y plantilla no son lo mismo |
| `EXV-0001` | `EXV0001` + `EXV03001` | `EXV0001` (`"xxxxxxx"`) **se da de baja: es captura basura.** `EXV03001` conserva la clave |
| `HRR-0004` | `HRR10004` + `HRR1004` | **Se separan.** Peldaños de escalera marinero y pérgola metálica no tienen nada que ver |

### Las demás correcciones, con su decisión

Las decisiones de abajo las resolvió Stefanno el 8-ago-2026, con los datos a la vista.

| Hallazgo | Qué se hace |
|---|---|
| Prefijo `TCL` en conceptos, `TLC` en el catálogo | **Gana `TCL`**, el de los conceptos. *Toldos, Cortinas y Lonas* da T-C-L, y **el prefijo debe ser mnemónico del nombre**. Se corrigen las dos filas del catálogo, no los tres conceptos |
| Partida `Sistemas`, inexistente en el catálogo | Se mapea a `Sistemas y Redes` (`SYS`) |
| `HNR90001`, precio de texto `"Del monto total de obra"` | `PORCENTAJE_OBRA`, **valor 15**. Está escrito en su propia descripción |
| `EXT89001`, precio de texto, "Vicios ocultos" | `PORCENTAJE_OBRA`, **valor 5**. Es una retención del 5% sobre el monto de obra |
| `TRA1009`, unidad `%`, precio `6248.15` | **Es `FIJO` con la unidad mal puesta.** La unidad cambia a `lote` y **conserva el precio**: un cargo indirecto por compra de material que vale $6,248.15 es un monto, no un porcentaje |
| `TRA1009` y `TRA-1009` | **Dos conceptos distintos.** Los dos se conservan, con claves nuevas separadas |
| `ALB8206` con precio `0.0` y descripción `"barda"` | Se migra inactivo con alerta. Es un concepto sin terminar, no un concepto gratis |
| 60 grupos de descripción repetida, 140 conceptos | **Resuelto por regla, 8-ago-2026 — cerrado.** Mismo precio → sobrevive la clave mayor, las demás se dan de baja (38 grupos, 51 conceptos). Precio distinto → se conservan todas, no se fusiona nada (22 grupos). Detalle en `docs/migracion/DESCRIPCIONES-REPETIDAS.md` |
| 33 formas de unidad | Se mapean al catálogo canónico. **Lo que no mapee se detiene y se pregunta** |
| Números de partida `88`, `89`, `90`, `96` | Desaparecen. El orden es un campo movible |

### Las 21 partidas sin conceptos · resuelto 8-ago-2026

El criterio es el giro: **Dravya hace arquitectura y construcción, no eventos.**

| Se quedan **activas** | Se dan de **baja** |
|---|---|
| `SYS` Sistemas y Redes | `AVV` Audio y Video y `AVS` Audio/Video/Sonido — **las dos**, duplicadas entre sí |
| `CTV` Circuito Cerrado de TV | `RIG` Iluminación Rigging |
| `DOM` Domótica | `SDO` · `MTT` · `AVZ` · `ARD` · `VDP` · `CTG` · `ESC` · `MBR` · `RRS` · `PDC` · `CSR` · `DCK` · `3DS` |
| `VIA` Viáticos | |
| `MOB` Mobiliario — gana sobre `MBR` Renta Mobiliario | |

Dar de baja una partida es marcarla inactiva. Si algún día vuelve el giro de eventos, se
reactiva con todo lo que tenga colgando.

### Cómo se ejecuta

1. **Simulación primero, siempre.** Produce el mapa completo `clave_v8 → clave_v10` y la
   lista de todo lo que no mapeó. Nada se escribe hasta que ese informe se lee.
2. **Una transacción.** Si algo falla, no se migra nada.
3. **Verificación posterior obligatoria**, contra el original: 877 conceptos entran, 877
   registros salen (uno de ellos inactivo), 877 valores de `clave_v8` distintos,
   cero claves duplicadas.
4. El informe de migración **se guarda como documento del proyecto**, con folio.

> Esta es exactamente la clase de operación que en la hoja de cálculo de F-19 destruyó
> datos en silencio. Aquí se verifica el estado antes, se ejecuta, y se vuelve a
> verificar. Se reportan los dos estados.

---

## 16. Qué quedó fuera

Se dice explícitamente, porque un hueco marcado vale más que un dato inventado.

| # | Quedó fuera | Por qué |
|---|---|---|
| 1 | **Nómina, raya semanal, destajos y viáticos** | Se nombran como orígenes de compromiso; su modelo detallado corresponde a la rebanada 7 |
| 2 | **Módulo de cálculo eléctrico** | Salió a satélite. Ver [[SAT-ELECTRICO-CONCEPTO]] |
| 3 | **Tipos SQL, índices y llaves** | Es [[V10-ESQUEMA-SQL]], el documento siguiente |
| 4 | **Vista de línea de tiempo** | Pendiente de diseño en [[V10-REQ-CicloDeObra-Cobranza-Bitacora-R01]] §8 |
| 5 | **Integraciones y respaldo** | Rebanada 8 |
| 6 | **El segundo nivel del catálogo de categorías de gasto** | Queda abierto por empresa a propósito. Se llena operando, no antes |
| 7 | **Siete decisiones de datos de la migración** | Colisiones, descripciones repetidas, `TCL`/`TLC`, partidas huérfanas y tres precios contradictorios. Listadas en `docs/migracion/LEEME.md`. **No bloquean el esquema: bloquean la ejecución de la migración** |

### Lo que este documento decidió y antes no estaba decidido

1. Clave de concepto `ALB-0072`, con variante `-V1`
2. La clave de la partida **es** su prefijo; el orden es un campo movible
3. `id` interno separado de la `clave` de negocio, y las relaciones apuntan al `id`
4. Un solo catálogo `insumo` con `tipo`, en vez de seis hojas paralelas
5. Migración por renumeración limpia, conservando `clave_v8`
6. `compromiso` + `abono` como estructura única para las dos direcciones del dinero
7. Los saldos, avances, semanas de corte y totales son **derivados**
8. El presupuesto se congela al enviarse; editar crea revisión

---

## 17. Cambios de R01 a R02

Cinco correcciones de Stefanno el mismo 8-ago-2026, más dos decisiones que estaban
marcadas como huecos y quedaron cerradas. Se registran con su razón, no sólo con su
resultado.

| # | R01 decía | R02 dice | Por qué cambió |
|---|---|---|---|
| 1 | Los precios de texto de `EXT89001` y `HNR90001` se anulan y pasan a nota | `tipo_precio` con `FIJO`, `PORCENTAJE_OBRA` y `PORCENTAJE_PARTIDA`, y `valor` que se interpreta según el tipo | **Era un error del modelo, no un dato sucio.** Un honorario cobrado como porcentaje de la obra es una regla de negocio legítima; el modelo no sabía representarla y por eso alguien la escribió como texto |
| 2 | `clave_v8` como columna de trazabilidad | `clave_anterior`, **buscable desde la aplicación**, más el archivo de equivalencia como condición para ejecutar la renumeración | El presupuesto de F-19 vive en el Excel con las claves viejas. Renumerar sin puente rompería la decisión de que app y Excel conviven |
| 3 | La semana de corte es derivada y punto | Se calcula **y** admite excepción manual con motivo obligatorio, autor y fecha, conservando siempre el valor calculado | La realidad difiere del plan y el sistema tiene que aguantarlo **sin mentir**. Guardar las dos permite decir "se forzó a la 9; el cronograma dice 12" |
| 4 | Categorías de gasto: hueco marcado | Nueve categorías fijas de primer nivel, segundo nivel abierto por empresa en tabla | Resuelto por Stefanno. El segundo nivel se llena operando |
| 5 | Autorizaciones: hueco marcado | Tabla de quién edita, quién aprueba y a quién se avisa, con la regla de que quien edita no aprueba | Resuelto por Stefanno |
| 6 | "58 descripciones repetidas" | **60 grupos, 140 conceptos** | El primer conteo no normalizaba acentos ni espacios dobles. El dato corregido salió al agrupar para el archivo de revisión |
| 7 | Las 4 colisiones se resolvían en la tabla de migración | Se listan una por una con sus dos descripciones para que Stefanno decida | Separar o dar de baja un concepto es destructivo y no lo decide un script |

---

*Documento 3 de 8. El siguiente es [[V10-ESQUEMA-SQL]], y con él se congela el esquema.*
