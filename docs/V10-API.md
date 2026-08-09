# TAAW V10 · API

**R01 · 9-ago-2026 · documento 8 de [[V10-PLAN-DE-TRABAJO-R02]] · último del anteproyecto**

La superficie de servicios: cómo se llama cada operación, quién puede llamarla, qué
dispara y qué le contesta a quien la llamó — incluida la que más lo necesita, la cola
offline de [[V10-PANTALLAS-Y-ROLES]] §5.

Depende de [[V10-ESQUEMA-SQL]] y de [[V10-PANTALLAS-Y-ROLES]]. Con este documento cierra
la etapa de anteproyecto — [[V10-HANDOFF-ClaudeCode]] lo dice en su propio encabezado: el
código empieza cuando estén los seis documentos pendientes y el esquema esté congelado.
Ya están los seis, y el esquema está congelado desde el 8-ago-2026.

---

## Índice

```
1  Qué resuelve este documento y qué no
2  Convención — Server Actions por omisión, Route Handler donde el contrato importa
3  Regla dura · autorización siempre en el servidor
4  Regla dura · toda escritura múltiple en transacción
5  Regla dura · idempotencia en lo que la cola offline puede reintentar
6  Regla dura · los errores son tipos del dominio, con un contrato de respuesta
7  La superficie de sincronización — el endpoint que resuelve la cola de teléfono
8  El catálogo de operaciones, por dominio — lo que tiene regla de negocio,
   no el CRUD que ya implica el esquema
9  Qué quedó fuera
```

---

## 1. Qué resuelve este documento y qué no

**Resuelve:** cómo se organiza la capa `services` de [[V10-ARQUITECTURA]] §2 —Server
Actions contra Route Handlers, y cuándo usar cada uno—, las reglas que aplican a **toda**
operación sin excepción, el diseño completo del endpoint de sincronización que la cola
offline necesita, y el catálogo de las operaciones que tienen una regla de negocio real
detrás — no el `create`/`update`/`delete` genérico que ya implica cada tabla del esquema.

**No resuelve:** el layout de las 34 pantallas —ya está en `V10-PANTALLAS-Y-ROLES`— ni
el código de los repositorios de la capa `data`. Con este documento, un agente empieza a
programar sin adivinar; no escribe el código por él.

---

## 2. Convención — Server Actions por omisión, Route Handler donde el contrato importa

**Regla de dependencia, ya fijada en `V10-ARQUITECTURA` §2 y no se repite aquí:**
`app → services → domain → data`. Una pantalla nunca llama a Prisma directo, y tampoco
llama a un Route Handler propio salvo en los tres casos de abajo — llama a una Server
Action, que vive en `services/` y orquesta hacia `domain` y `data`.

| | Server Action | Route Handler |
|---|---|---|
| Caso de uso | Toda mutación disparada desde una pantalla, con el usuario activo en sesión | Cuando el contrato HTTP importa por sí mismo: reintentos externos, subida de archivo binario, algo que un cliente que no es esta app pueda llamar |
| Dónde vive | `services/<dominio>/acciones.ts` | `app/api/<ruta>/route.ts` |
| Ejemplos en este proyecto | Crear concepto, aprobar requisición, autorizar presupuesto | `POST /api/sincronizar` — sección 7 · exportar un documento a PDF · el webhook futuro de un MCP, si aplica |

**Nombrado:** una Server Action se nombra por el verbo de negocio, no por CRUD genérico —
`aprobarRequisicion`, no `updateRequisicion`. Es la misma disciplina que ya rige los
errores de dominio: el nombre dice qué pasa, no qué tabla se toca.

---

## 3. Regla dura · autorización siempre en el servidor

**Ninguna Server Action ni Route Handler confía en lo que la pantalla dice que el
usuario puede hacer.** La pantalla oculta un botón que el rol no debería ver — eso es
UX, no seguridad. La operación **vuelve a verificar** el permiso contra `usuario_rol`,
con la sesión del servidor, siempre.

```
1. Resolver la sesión → usuario_id, empresa_id activa
2. Resolver el proyecto de la entidad que se va a tocar (si aplica)
3. Cargar usuario_rol para (usuario_id, empresa_id, proyecto_id | null)
4. Verificar que la unión de roles permite ESTA acción sobre ESTA entidad
5. Si no, error de dominio — nunca un 200 con un cuerpo vacío
```

**La regla de "quien edita no aprueba lo que editó"** —`V10-ESQUEMA-SQL` §11, ya escrita
como `CHECK` en `requisicion`— se verifica **dos veces**: una vez aquí, en el servicio,
antes de intentar el `insert`, para dar un error de dominio legible; y otra vez la base,
como último resguardo si algo se coló. Un mensaje de la base nunca es lo que ve el
usuario — regla 6 de la sección siguiente.

---

## 4. Regla dura · toda escritura múltiple en transacción

Ya es regla del proyecto, en `CLAUDE.md` y en cada documento de esquema. Aquí se aplica
al límite de la operación, no de la consulta SQL:

- **Una Server Action que escribe en más de una tabla abre una sola transacción** para
  todo el conjunto. Si el paso 3 de 4 falla, no quedan los primeros dos escritos
- **La cascada de precios** —`V10-MODELO-DOMINIO` §6— corre completa dentro de una
  transacción: renglón → concepto → variantes → presupuestos no enviados. O cambia todo
  o no cambia nada
- **Toda operación destructiva o irreversible** —dar de baja un proveedor, forzar una
  semana de corte, aplicar la simulación de migración— **verifica el estado antes,
  ejecuta, y verifica después**, y ambos estados quedan en la respuesta. Es la misma
  disciplina que ya costó horas de retrabajo en la hoja de F-19, aplicada al código

---

## 5. Regla dura · idempotencia en lo que la cola offline puede reintentar

**La cola de `V10-PANTALLAS-Y-ROLES` §5 reintenta sola.** Si el teléfono manda la misma
alta de evento dos veces —la respuesta se perdió en el camino, no la petición—, el
servidor no puede crear el evento dos veces. Sin esto, la cola local resuelve un
problema y crea otro.

**Mecanismo: clave de idempotencia generada en el cliente, en el momento en que el
elemento entra a la cola —no cuando se envía.**

```sql
-- MIGRACIÓN 002, aditiva, sin tocar nada existente — ver V10-ESQUEMA-SQL §19
create table sincronizacion_recibida (
  id                 char(26) primary key,
  empresa_id         char(26) not null references empresa(id),
  clave_idempotencia char(26) not null,   -- ULID generado en el teléfono
  entidad_tipo       varchar(40) not null,
  entidad_id         char(26) not null,
  recibido_en        timestamptz not null default now(),

  constraint uq_sincronizacion_recibida unique (empresa_id, clave_idempotencia)
);
```

**El flujo completo:**

```
1. El elemento entra a la cola en IndexedDB con un ULID propio, generado ahí mismo
2. Llega señal → POST /api/sincronizar con { clave_idempotencia, tipo, payload }
3. El servidor busca clave_idempotencia en sincronizacion_recibida
     existe   → devuelve el folio/id que ya se creó la primera vez. No crea nada nuevo
     no existe → dentro de la MISMA transacción: crea la entidad real, asigna folio
                 con documento_contador si aplica, inserta la fila de
                 sincronizacion_recibida
4. El teléfono recibe folio real → marca el elemento local como sincronizado
```

**Por qué la clave nace en el cliente y no en el servidor:** si naciera al llegar, dos
intentos de red del mismo elemento —uno que se perdió, uno que reintentó— llegarían con
claves distintas y el problema no se resuelve. Nace una sola vez, en el teléfono, cuando
el usuario tomó la foto o llenó el formulario.

---

## 6. Regla dura · los errores son tipos del dominio, con un contrato de respuesta

**Ya es regla invariante — nunca cadenas de texto.** Aquí se fija el contrato que toda
Server Action y todo Route Handler devuelve:

```ts
type ResultadoOperacion<T> =
  | { ok: true; datos: T }
  | { ok: false; error: ErrorDominio };

type ErrorDominio = {
  tipo: string;        // "ClaveDuplicada" · "GastoSinConcepto" · "AvanceSinCartaEntrega"
  mensaje: string;      // legible, con el dato — "El concepto ALB-0072 ya existe", no "Error"
  campo?: string;       // qué campo del formulario lo causó, si aplica
};
```

**Prohibido el `catch` silencioso — es la enfermedad con nombre de la V8, 26 veces.**
Todo `catch` de una Server Action o Route Handler hace una de dos cosas: propaga el
error como `ErrorDominio`, o lo registra y **también** lo propaga. Nunca lo absorbe.

---

## 7. La superficie de sincronización — el endpoint que resuelve la cola de teléfono

**`POST /api/sincronizar`.** Es el único Route Handler que existe por una razón de
infraestructura, no de conveniencia: la cola offline vive en un service worker o en un
reintento en segundo plano, fuera del ciclo de vida de una Server Action.

| | |
|---|---|
| Entrada | `{ clave_idempotencia, tipo, empresa_id, proyecto_id, payload, adjuntos[] }` |
| `tipo` admitido | `evento_bitacora` · `requisicion` · `recepcion_trabajo` — las tres pantallas de teléfono con escritura, `V10-PANTALLAS-Y-ROLES` §5 |
| Adjuntos | Se suben al volumen local — `V10-PLATAFORMA-Y-MIGRACION` §4 — antes de confirmar la fila, para que un adjunto huérfano nunca quede referenciado sin archivo |
| Autorización | Igual que cualquier Server Action — sección 3 — resuelta contra la sesión que viajó con la petición, no contra lo que el teléfono afirma |
| Salida éxito | `{ ok: true, folio, id, sincronizado_en }` |
| Salida error de validación | `{ ok: false, error }` — **no reintentable**. La cola lo marca como error explícito, distinto de "pendiente de señal", según `V10-PANTALLAS-Y-ROLES` §5 |
| Salida error de red | El teléfono nunca la ve como respuesta — es la ausencia de respuesta lo que activa el reintento |

**Un elemento con `tipo = requisicion` que crea un proveedor nuevo en línea —regla de
`V10-PANTALLAS-Y-ROLES` §7— no pasa por aquí para el proveedor.** Ya quedó dicho: crear
en línea exige conexión, se resuelve mientras el teléfono tiene señal, antes de que el
elemento entre a la cola. Lo que llega a `/api/sincronizar` ya trae los IDs resueltos,
nunca nombres por resolver.

---

## 8. El catálogo de operaciones, por dominio

**No es CRUD.** Insertar, leer, actualizar y desactivar cada entidad ya lo implica el
esquema y no necesita catálogo — lo que sigue es lo que trae una regla de negocio,
una transición de estado, o una cascada.

### 8.1 Catálogo técnico

| Operación | Dispara | Quién |
|---|---|---|
| `recalcularTarjeta` | Cascada completa: renglón → concepto → variantes → presupuestos no enviados, en una transacción — sección 4 | Coordinación |
| `simularCascada` | Igual que arriba, sin escribir. Es el modo simulación obligatorio antes de confirmar | Coordinación |
| `crearInsumoEnLinea` | Alta de insumo desde el constructor de tarjeta, sin salir del flujo | Coordinación |

### 8.2 Presupuesto

| Operación | Dispara | Quién |
|---|---|---|
| `enviarPresupuesto` | `BORRADOR → ENVIADO`. Congela una versión inmutable con folio — `V10-MODELO-DOMINIO` §8 | Coordinación |
| `autorizarPresupuesto` | `ENVIADO → AUTORIZADO`. Exige `firmado_por`/`firmado_en` — `V10-ESQUEMA-SQL` §19, migración 001 | Dirección |
| `generarComparativo` | Lee `v_presupuesto_base` y `v_presupuesto_derivado` a través de varias opciones — `V10-CATALOGO-DOCUMENTOS` §7.4 | Coordinación, dirección |

### 8.3 Programa y control de obra

| Operación | Dispara | Quién |
|---|---|---|
| `congelarLineaBase` | Copia inmutable a `linea_base`/`linea_base_actividad` — no se edita, se reemplaza con una versión nueva | Coordinación |
| `forzarSemanaCorte` | Escribe `semana_corte_forzada` con `motivo_forzado` obligatorio — `V10-ESQUEMA-SQL` §8 | Coordinación |
| `registrarAvance` | Exige `evento_id` o `entrega_id` de origen — nunca avance suelto | Residencia |

### 8.4 Obra

| Operación | Dispara | Quién |
|---|---|---|
| `levantarRequisicion` | `→ SOLICITADA`. Exige `requisicion_concepto` con al menos una fila — sin liga no se aprueba | Residente + supervisor, validación cruzada |
| `aprobarRequisicion` | `SOLICITADA → APROBADA`. Crea el `compromiso` | Coordinación |
| `pagarRequisicion` | Admite abonos parciales, no avanza hasta saldo cero | Administración de finanzas |
| `entregarTrabajo` | `→ ENTREGADA`, exige `carta_entrega` firmada. Actualiza el avance del concepto ligado | Quien recibe |
| `autorrevisarRequisicion` | Exige `autorrevision_motivo`. El servidor intenta el `insert`/`update`; si `importe` supera `empresa.monto_maximo_autorrevision`, `tg_requisicion_autorrevision_tope` lo rechaza y la Server Action devuelve `ErrorDominio` tipo `AutorrevisionExcedeTope` — migración 003, `V10-ESQUEMA-SQL` §19 | Residente-supervisor, mismo usuario |

### 8.5 Dinero

| Operación | Dispara | Quién |
|---|---|---|
| `registrarAbono` | Nunca rebasa el saldo del compromiso — `trigger` `tg_abono_no_rebasa_saldo` | Administración de finanzas |
| `aplicarAnticipo` | **Diseñada, no implementada** — `anticipo_proveedor`/`anticipo_aplicacion`, `V10-HANDOFF` §5, decisión 7. Entra con la rebanada 7 | Administración de finanzas |

### 8.6 Documentos

| Operación | Dispara | Quién |
|---|---|---|
| `emitirDocumento` | Compone el folio, asigna número vía `documento_contador` — sección 5, y aplica marca de agua según estado — `V10-CATALOGO-DOCUMENTOS` §4 | Según el documento |
| `autorizarDocumento` | `S3 → A5`. Único movimiento que puede hacer el validador de documentos | Validador de documentos |

---

## 9. Qué quedó fuera

| # | Quedó fuera | Por qué |
|---|---|---|
| 1 | El código real de cada Server Action | Es la rebanada correspondiente, no el anteproyecto |
| 2 | `sincronizacion_recibida`, escrita aquí como diseño | Aditiva — se agrega a `V10-ESQUEMA-SQL` como migración 002 cuando se construya la rebanada 5 |
| 3 | `aplicarAnticipo`, completa | Depende de la decisión 7 de `V10-HANDOFF` §5 — aditiva, diseñada, entra con la rebanada 7. `autorrevisarRequisicion` ya no está aquí: se resolvió con tope el 9-ago-2026, migración 003 |
| 4 | Límite de tasa o protección contra abuso de la API | Tres personas, uso interno. Se revisa si algún día deja de serlo |
| 5 | Versionado de la API (`/v1/`, `/v2/`) | No hay consumidor externo todavía. Se decide cuando exista uno |
| 6 | El contrato exacto del webhook de MCP mencionado en la rebanada 8 | Depende de qué integración se elija, todavía no decidida |

---

## Cierre del anteproyecto

Con este documento terminan los ocho de la etapa 2. El esquema está congelado desde el
8-ago-2026, el modelo de dominio, el catálogo de documentos, la plataforma y la
migración, las pantallas y roles, y ahora la superficie de servicios — todos escritos,
verificados contra datos reales de F-19 donde fue posible, y con lo que falta marcado
explícitamente en vez de inventado.

**Quedan dos pendientes de aprobación de Stefanno antes de que la rebanada 1 arranque sin
sorpresas** — [[V10-HANDOFF-ClaudeCode]] §6, pendientes 3, 5, 8 y 9. Ninguno bloquea
empezar a programar la rebanada 1: son ajuste visual, logotipo, y dos piezas de esquema
que entran cuando les toque su rebanada.

*Documento 8 de 8. Etapa 2 de 4, anteproyecto, cerrada. La rebanada 1 —arquitectura y
sistema de diseño— puede empezar.*
