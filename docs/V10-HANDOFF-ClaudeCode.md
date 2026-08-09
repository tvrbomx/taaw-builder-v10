# TAAW BUILDER V10 · TRASPASO A CLAUDE CODE

**R01 · 7-ago-2026**

Este documento existe para que una sesión nueva de Claude Code, sin haber estado en
ninguna conversación previa, sepa **todo lo necesario** para continuar.

**El contexto no vive en un chat. Vive en esta carpeta.**

---

## 1. Orden de lectura obligatorio

```
1. V10-CONCEPTO-ParaQueEsLaApp-R02      qué es y para qué. APROBADO
2. V10-PLAN-DE-TRABAJO-R02              orden de construcción y rebanadas
3. V10-ARQUITECTURA                     stack, estructura, roles, despliegue
4. V10-DISENO                           dirección visual y filosofía de interfaz
5. V10-REQ-CicloDeObra-Cobranza-Bitacora-R01   el requisito funcional más detallado
6. SAT-ELECTRICO-CONCEPTO               app satélite, no se desarrolla todavía
```

Después, del repositorio de la V8, **sólo para entender qué existe y qué no repetir**:

```
.agents/context/ESQUEMA_BASE_DE_DATOS.md      las 59 pestañas y sus anomalías
.agents/context/FORMULA_CANONICA_TPU.md       la fórmula de precio unitario
.agents/context/ESPEC_MODULO_TPU.md
.agents/context/FLUJO_COTIZACION_REQUISICION_PAGO.md
src/app/(app)/                                 las 60 pantallas, como referencia
```

**Y `docs/normativa-dravya/`**, copia de sólo lectura de seis documentos de empresa
—desde el 8-ago-2026 vive en este repositorio, no hace falta que Stefanno la cite—:

```
docs/normativa-dravya/DRAVYA-NOM-NomenclaturaDocumental-R01.md   folio ISO 19650 completo
docs/normativa-dravya/MANUAL_TRABAJO_COLABORATIVO_DRAVYA.md      autoridad vigente del flujo BIM
docs/normativa-dravya/NORMA_BIM_DRAVYA.md                        superada por el manual, se lee por contexto
docs/normativa-dravya/FLUJO_BIM_DRAVYA.md                        superada por el manual
docs/normativa-dravya/PROTOCOLO_REVISION_DE_PLANOS.md            superado por el manual
docs/normativa-dravya/DONDE_VA_TODO.md                           OJO: no es estructura de carpetas — es
                                                                   bitácora de desarrollo V8/V9 de jul-2026.
                                                                   El LEEME.md de esa carpeta lo describe mal
```

**Son de sólo lectura.** Si algo debe cambiar ahí, se anota como pendiente y se corrige
en `TAAW V8 ANTIGRAVITY/EMPRESA/NORMATIVA/`, que es la fuente real, fuera de este
repositorio.

**Y `docs/referencia-f19/`** — el presupuesto real de F-19, instantánea del 8-ago-2026,
**también de sólo lectura**. Su propio `LEEME.md` dice que la fuente sigue viva en
`Desktop/Felipe/04_PRESUPUESTO/VERSIONES PARA TERMINAR/`. Es **el juego de datos de
prueba** que exige la definición de terminado del proyecto — no las 82 filas de
cronograma que trae `TAAW_DB_Master.xlsx` para `PRY-0001`, que son todo lo que la V8
tiene de F-19 y no incluyen presupuesto ni finanzas. Detalle completo en
[[V10-PLATAFORMA-Y-MIGRACION]] §7.

---
en `TAAW V8 ANTIGRAVITY/EMPRESA/NORMATIVA/`, que es la fuente real, fuera de este
repositorio.

---

## 2. Estado en una página

| | |
|---|---|
| **Producto** | TAAW Builder v10 · plataforma de control de proyecto |
| **Quién la hace** | TAAW ThArqum Architecture Workshop |
| **Quién la usa** | Dravya — arquitectura y construcción |
| **Repositorio** | `TAAW Builder v10` · creado, `github.com/tvrbomx/taaw-builder-v10` · commit `770e7a2` en `main`, local por delante de `origin` — el push sigue pendiente de que Stefanno lo corra (sin credenciales de GitHub en el entorno de ejecución) |
| **Etapa** | **4 de 4 · Ejecución.** Etapas 2 (anteproyecto) y 3 (proyecto ejecutivo) cerradas el 9-ago-2026 — cuatro etapas, no dos, resuelto contra `V10-CONCEPTO-ParaQueEsLaApp-R02` §6. **Rebanada 1 completa y pulida, 9-ago-2026** |
| **Escrito** | Concepto · Plan · Arquitectura · Diseño · Requisito de ciclo de obra · **Modelo de dominio R02** · **Esquema SQL R02** · **Catálogo de documentos** · **Plataforma y migración** · **Pantallas y roles** · **API** |
| **Falta** | Nada de las etapas 1 a 3. Rebanada 1 terminada — sigue la rebanada 2, catálogo técnico, sin arrancar todavía |
| **Esquema** | **APROBADO Y CONGELADO el 8-ago-2026,** con las tres migraciones de diseño (001 firma en `presupuesto.AUTORIZADO`, 002 `sincronizacion_recibida`, 003 autorrevisión con tope) y las cuatro correcciones de ejecución de §19.2, todas aplicadas y verificadas contra Postgres real. Ver `V10-ESQUEMA-SQL` §16.2 y §19 |
| **Catálogo de documentos** | **31 documentos**, escrito el 8-ago-2026. Uno bloqueado (inventario, hallazgo 8.1). Las columnas de firma y los tipos ISO propuestos, aprobados el mismo día |
| **Plataforma y migración** | Escrito el 8-ago-2026. Frontera de almacenamiento fijada (CDE en la nube, nunca entra a TAAW Builder). **El juego de datos de prueba real es `docs/referencia-f19/`**, no las 82 filas huérfanas de la V8 |
| **Pantallas y roles** | **34 pantallas**, escrito el 8-ago-2026. Cola local con reintento para las tres pantallas de obra en teléfono. Las 3 pantallas de junta y la autorrevisión con tope, aprobadas el 9-ago-2026 |
| **API** | Escrito el 9-ago-2026. Server Actions por omisión, un solo Route Handler —`/api/sincronizar`— para la cola offline, con idempotencia por clave generada en el teléfono |
| **Código** | **Rebanada 1 completa, 9-ago-2026:** login, aislamiento por empresa (RLS verificado con dos roles reales), tema claro/oscuro, tipografía (Fraunces/Inter/JetBrains Mono), patrones Tabla y Formulario completos, Ficha y LineaDeTiempo en bosquejo. `npm run dev` en el puerto 4010 — ver README |

**Nada del código de la V8 se reutiliza tal cual.** Se rescatan ideas, plantillas PDF y
la fórmula de precio unitario. Todo lo demás se rehace.

---

## 3. Las nueve reglas que no se rompen

Están en el plan de trabajo, y son la razón de existir de este proyecto.
Si una función futura exige romper una, **no se hace la función: se replantea.**

1. Clave de concepto única y con formato fijo. La base rechaza lo que no cumple
2. Todo gasto ligado a uno o más conceptos
3. Los precios se guardan sin IVA. El IVA es parámetro
4. Una columna significa una sola cosa
5. Todo pago es un abono contra un compromiso
6. Ningún concepto llega a 100% de avance sin carta entrega
7. Nada se borra. Sólo se marca inactivo
8. Todo cambio de estado deja rastro y dispara alerta
9. Todo dato pertenece a una empresa

---

## 4. Errores ya cometidos · no repetir

Esto es lo más valioso del traspaso. Cada punto costó tiempo o dinero real.

**En las versiones anteriores de la app:**

- Se construyó antes de saber qué se construía. Cada requisito nuevo movía el esquema,
  y mover el esquema rompía lo que ya servía
- **877 conceptos con 40 formatos de identificador.** Nadie lo decidió: se acumuló por
  no tener restricción de clave
- **26 capturas de error silenciosas** en cronograma, pagos, destajos, bitácora y programa
  vivo. De una de ellas salió un bug que borraba filas de la base
- Se metieron temas cuando la app ya existía y se rompió, porque los colores estaban
  escritos dentro de cada pantalla
- 28 de 59 pestañas creadas y vacías: estructura antes que contenido
- Pantallas hablando directo con la fuente de datos, sin capa intermedia

**Al preparar los documentos de esta etapa:**

- Se encuadró la aplicación alrededor del dinero. **Está mal.** Es control de proyecto;
  el dinero es una de las cosas que controla
- Se mezcló el hub informativo de Dravya con los requisitos de la app. Son productos
  distintos con públicos distintos
- Se propuso construir sin haber leído el código y el esquema reales. Leer primero

**Trabajando la hoja de cálculo del proyecto F-19:**

- Se leyeron como vacías celdas que contenían **fórmulas**, y se sobrescribieron con
  números. Nunca asumir el tipo de un dato: verificarlo
- Combinar celdas sobre filas equivocadas **destruyó datos en silencio**. Toda operación
  destructiva se verifica contra el original antes y después

---

## 5. Decisiones tomadas, con su razón

| Decisión | Razón |
|---|---|
| PostgreSQL, no Sheets | Sheets no puede rechazar un dato inválido. Es la causa raíz de todo |
| Next.js 15 + TypeScript | Se conserva: el equipo lo conoce y Dokploy lo despliega sin configuración |
| Prisma | Migraciones versionadas y tipos generados del esquema |
| Servidor propio, mini PC con Dokploy | Costo cero, sin suspensión por inactividad, respaldo local |
| Multiempresa desde el día uno | Meterlo después obliga a tocar todas las tablas |
| Un usuario, varios roles | Tres personas cubren ocho funciones |
| El eléctrico sale a satélite | Cálculos con normativa y ritmo propios. Cargárselos a la V10 la vuelve pesada |
| El esquema se congela al cerrar el anteproyecto | Es el mecanismo que impide repetir la degradación |
| La app y el Excel conviven | Hasta que la rebanada de presupuesto esté en producción |
| Los 877 conceptos se migran completos | Se depuran sobre la marcha, conservando la clave vieja en columna de trazabilidad |
| **Clave de concepto `ALB-0072`** · 8-ago-2026 | El prefijo de partida ya la identifica: el segmento de 2 dígitos era redundante y era el que se rompía. Variantes con sufijo `-V1` |
| **La clave de la partida es su prefijo** · 8-ago-2026 | Había tres identificadores compitiendo (`PART-001`, prefijo, `order`). El orden pasa a ser un campo movible |
| **`id` interno separado de la `clave`** · 8-ago-2026 | Permite corregir un concepto mal clasificado sin renombrar en cascada. En la V8 nadie lo hizo, y por eso los 268 IDs rotos siguen ahí |
| **Migración por renumeración limpia** · 8-ago-2026 | Preservar el correlativo obligaba a resolver 42 casos a mano y a inventar una regla para un generador que nunca la tuvo |
| **`tipo_precio` FIJO / PORCENTAJE_OBRA / PORCENTAJE_PARTIDA** · 8-ago-2026 | Un honorario cobrado como porcentaje de la obra es regla de negocio válida. El modelo no sabía representarla y por eso alguien la escribió como texto en el campo del precio |
| **`clave_anterior` buscable + CSV de equivalencia** · 8-ago-2026 | El presupuesto de F-19 vive en el Excel con las claves viejas. Renumerar sin puente rompería la convivencia app/Excel |
| **La semana de corte se puede forzar** · 8-ago-2026 | Con motivo obligatorio, autor y fecha, conservando siempre el valor calculado. La realidad difiere del plan y el sistema tiene que aguantarlo sin mentir |
| **Categorías de gasto: 9 fijas + segundo nivel por empresa** · 8-ago-2026 | La categoría clasifica contra qué se carga; el tipo de insumo clasifica qué es. Son cosas distintas |
| **Quien edita no aprueba lo que editó** · 8-ago-2026 | Se comprueba sobre el usuario, no sobre el rol: tres personas cubren ocho funciones y una misma persona tiene los dos roles |
| **Subtotal base y subtotal derivado** · 8-ago-2026 | Resuelve la circularidad de `HNR-0001` (15% de la obra) sin trigger: un porcentual apunta a un subtotal, y el subtotal base sólo contiene conceptos `FIJO` por definición. La puerta de la circularidad no se cierra, no se construye |
| **El subtotal se calcula a `precio_venta`, no a `precio_costo`** · 8-ago-2026 | Un honorario se cobra sobre lo vendido al cliente, no sobre el costo directo interno de la empresa. Escrito tres veces en el esquema para que no se lea al revés |
| **Renglón porcentual visible u ocultable por opción de presupuesto** · 8-ago-2026 | En obra el honorario a veces va embebido y no se imprime aparte. El cálculo no cambia; sólo cambia el documento |
| **TCL gana sobre TLC** · 8-ago-2026 | *Toldos, Cortinas y Lonas* da T-C-L: el prefijo debe ser mnemónico del nombre. Se corrige el catálogo, no los tres conceptos |
| **Las 4 colisiones: 3 se separan, 1 se da de baja** · 8-ago-2026 | `ARR6011`, `CIM-0001` y `HRR10004` eran pares de conceptos reales distintos. `EXV0001` era captura basura (`"xxxxxxx"`) |
| **21 partidas sin conceptos: 5 activas, 16 de baja** · 8-ago-2026 | Criterio: Dravya hace arquitectura y construcción, no eventos. `MOB` gana sobre `MBR`; `AVV` y `AVS` se dan de baja las dos |
| **"Esquema congelado" en tres niveles** · 8-ago-2026 | Tabla nueva o columna en tabla nueva es aditiva y no espera aviso; columna nueva en tabla existente se avisa y se aprueba antes; cambiar o quitar algo existente se detiene todo. La primera redacción sonaba a que nunca se podía agregar nada |
| **Esquema aprobado y congelado** · 8-ago-2026 | Ver [[V10-ESQUEMA-SQL]], que pasó de R01 a R02 el mismo día con las dos precisiones de arriba antes de aprobarse |
| **`documento_contador` para folios atómicos** · 8-ago-2026 | El campo 9 de la norma ISO es consecutivo por tipo. Un contador de app genera folios repetidos si dos personas emiten al mismo tiempo. Tabla nueva, aditiva, con bloqueo `SELECT ... FOR UPDATE` en la misma transacción que crea el documento |
| **El presupuesto autorizado es el contrato** · 8-ago-2026 | No se crea entidad `contrato`. `A5` ya significa "presupuesto que el cliente firmó" en la norma de nomenclatura, y los términos —tramos de cobranza, vigencia, alcance por concepto— ya viven en el sistema. Un contrato formal con cláusulas queda como decisión diferida: sería tabla nueva |
| **Nombres de documentos de oficina, no de la norma** · 8-ago-2026 | Gana `Flujo semanal` sobre `Flujograma`. Pendiente que Stefanno actualice `DRAVYA-NOM-NomenclaturaDocumental-R01` fuera de este repositorio — ver [[V10-CATALOGO-DOCUMENTOS]] §8.4 |
| **Frontera de almacenamiento: CDE en la nube nunca entra a TAAW Builder** · 8-ago-2026 | Del manual de trabajo colaborativo §10. El volumen del servidor sólo guarda lo que la app genera —fotos, adjuntos, PDF—; un plano se referencia por enlace, nunca se sube |
| **Sólo el catálogo reusable de la V8 migra en bloque** · 8-ago-2026 | Lo transaccional de otros proyectos (`PRY-014`, `PRY-010`, `PRY-015`, `PRY-020`) se conserva como respaldo histórico, fuera de la base nueva. Mezclarlo contaminaría el catálogo vivo |
| **El juego de datos de prueba de F-19 es `docs/referencia-f19/`, no la V8** · 8-ago-2026 | Verificado: `presupuesto_conceptos`, `Finanzas`, `Bitacora` de F-19 dan **cero filas** en `TAAW_DB_Master.xlsx`. `DONDE_VA_TODO.md` decía que había 24 tarjetas armadas — estaba desactualizado. El presupuesto real de F-19 (135/201/267 conceptos en 3 opciones) vive en hoja de cálculo aparte, terminado el 8-ago-2026 |
| **`precio_costo` no exige tarjeta completa** · 8-ago-2026 | Confirmado contra F-19 real: 602 de 603 conceptos presupuestados no tienen tarjeta construida, sólo precio a juicio experto. El esquema ya lo permitía sin cambios |
| **Proveedores en estado no confirmado migran inactivos** · 8-ago-2026 | 9 de 75 proveedores en `Borrador`/`En Evaluación`/`Incompleto`. Migran con `activo = false` y el estado en notas — regla 7, nada se borra |
| **`costos_herramienta` se vacía y reconstruye** · 8-ago-2026 | Ejecuta la decisión del 28-jul-2026 nunca aplicada. Verificado: dividir entre 1.16 da números redondos en toda la muestra, confirma el IVA embebido |
| **La tarjeta nunca es obligatoria** · 8-ago-2026 | Confirmado con F-19 real: 602 de 603 conceptos presupuestados no tienen tarjeta. El catálogo marca discreto, nunca bloquea presupuestar |
| **Sólo 4 pantallas son teléfono primero** · 8-ago-2026 | Bitácora, alta de evento con fotos, requisición y recepción de trabajo. Todo lo demás, incluido cronograma y control de obra, es escritorio primero |
| **Sin señal: cola local con reintento, no falla-y-avisa ni modo offline completo** · 8-ago-2026 | IndexedDB (sobrevive al cierre) · indicador permanente que escala si algo lleva demasiado esperando · folio asignado por `documento_contador` sólo al llegar al servidor, nunca en el teléfono |
| **Permiso por pantalla y por acción, unión de roles por proyecto** · 8-ago-2026 | Un usuario con varios roles tiene la unión de lo que cada rol permite en el proyecto donde aplica ese rol, no un máximo global |
| **1 · Las tres pantallas de junta quedan aprobadas** · 9-ago-2026 | Los seis indicadores propuestos en [[V10-PANTALLAS-Y-ROLES]] §11 se programan tal cual. El banner de propuesta pendiente se retiró de ese documento |
| **2 · No existe rol `CLIENTE`, ni ahora ni después** · 9-ago-2026 | El cliente recibe documentos y nunca entra a la app. Escrito como decisión explícita en [[V10-ARQUITECTURA]] §4 para que dentro de un año nadie lo agregue pensando que faltó |
| **3 · Alertas sólo dentro de la app** · 9-ago-2026 | Campana con pendientes por rol. Correo y WhatsApp quedan anotados como posibles en la rebanada 8 del plan, no como pendientes — evita prometer un canal que no se va a construir todavía |
| **4 · Escala de diseño: 1 a 5 proyectos activos** · 9-ago-2026 | La pantalla `Proyectos` de [[V10-PANTALLAS-Y-ROLES]] se diseña como lista simple, sin buscador avanzado ni tablero de cartera. Diseñar para una escala que no existe es la misma clase de error que sobre-construir el esquema |
| **5 · Aero cálido, cierra el pendiente 1 de diseño** · 9-ago-2026 | Estructura Frutiger Aero con la temperatura de la marca de Dravya. En oscuro el vidrio se densifica pero nunca se vuelve frío — ya escrito así en [[V10-DISENO]] §6, ahora confirmado como parte de la misma decisión |
| **6 · Las nueve categorías de gasto, confirmadas** · 9-ago-2026 | Ya estaban resueltas y aplicadas desde el 8-ago-2026 en [[V10-MODELO-DOMINIO]] §14 y en el `enum categoria_gasto_n1` de [[V10-ESQUEMA-SQL]]. Se confirma aquí, no cambia nada |
| **7 · Anticipo a proveedor — evaluado, es tabla nueva aditiva** | Ver el hallazgo completo abajo. No toca `compromiso` ni `abono` |
| **8 · Vigencia del presupuesto: 15 días por omisión, confirmada** · 9-ago-2026 | Ya estaba en el esquema: `empresa.vigencia_dias_cotizacion int not null default 15`. Se confirma, no cambia nada |
| **9 · Supervisor de obra: mismo usuario en los dos roles, con tope** · 9-ago-2026 | **RESUELTO Y APLICADO.** `autorrevision_motivo` obligatorio cuando levanta y valida es la misma persona · `empresa.monto_maximo_autorrevision` ($5,000 inicial, configurable) bloquea por trigger, no por `CHECK`, porque depende de otra tabla · marca visible en pantalla y en el documento — migración 003, `V10-ESQUEMA-SQL` §19 |
| **10 · Moneda: sólo pesos mexicanos, confirmado** · 9-ago-2026 | Ya estaba en el esquema: `empresa.moneda char(3) not null default 'MXN'`, sin columna de tipo de cambio. Se confirma, no cambia nada |
| **11 · Respaldo semanal a nube personal, con su razón completa** · 9-ago-2026 | Protege contra robo o incendio, no sólo contra falla de disco — un disco externo conectado al mismo mini PC no cubre esos dos casos. Añadido a [[V10-PLATAFORMA-Y-MIGRACION]] §3.2 |
| **12 · IA: lectura de cotizaciones de proveedor en PDF, alcance concreto** · 9-ago-2026 | Extraer conceptos, cantidades y precios de una cotización para alimentar una requisición o una tarjeta sin captura manual. Reservado en la rebanada 8 del plan con este alcance exacto, no como "integración de IA" genérica |

### Hallazgo · decisión 7, anticipo a proveedor — es tabla nueva, aditiva

**Evaluado antes de escribir una línea, como se pidió.** Un anticipo a proveedor y su
amortización contra entregas futuras se modelan completos con dos tablas nuevas, sin
tocar `compromiso` ni `abono`:

```sql
create table anticipo_proveedor (
  ‹comunes›
  proyecto_id   char(26) not null references proyecto(id),
  proveedor_id  char(26) not null references proveedor(id),
  monto         numeric(16,4) not null,
  fecha         date not null,
  movimiento_id char(26) not null references movimiento(id),  -- el pago real de salida
  notas         text,
  constraint ck_anticipo_monto check (monto > 0)
);

create table anticipo_aplicacion (
  id             char(26) primary key,
  empresa_id     char(26) not null references empresa(id),
  anticipo_id    char(26) not null references anticipo_proveedor(id) on delete restrict,
  requisicion_id char(26) not null references requisicion(id),
  monto          numeric(16,4) not null,
  fecha          date not null,
  constraint ck_anticipo_aplicacion_monto check (monto > 0)
);
```

El saldo del anticipo se calcula igual que el de un compromiso: monto menos la suma de
sus aplicaciones, en una vista, nunca guardado. Cuando una requisición se liquida en
parte o en todo con anticipo en vez de con dinero nuevo, la lógica de aplicación lee
**dos** ledgers —`abono` y `anticipo_aplicacion`— en vez de uno; eso vive en la capa de
servicios, no exige tocar la estructura de `compromiso` ni de `abono`.

**Conclusión: caso "tabla nueva de amortización" — aditiva, adelante.** No se escribe
todavía en `V10-ESQUEMA-SQL` porque la funcionalidad completa —anticipos, destajos,
nómina— es de la rebanada 7, igual que ya quedó dicho para inventario. Queda aquí como
diseño verificado, listo para entrar sin sorpresas cuando le toque.

### Hallazgo · decisión 9, autorrevisión de requisición — resuelto y aplicado, con tope

**Detenido el 9-ago-2026 al encontrar el conflicto con la restricción ya congelada,
resuelto el mismo día con la condición que Stefanno agregó: no es una excepción libre,
tiene tope.** Es migración 003, completa en `V10-ESQUEMA-SQL` §19.

`requisicion` tenía, congelada desde el 8-ago-2026, una restricción sin excepción:
`validada_por is null or validada_por <> levantada_por` — prohibía sin condición que la
misma persona levantara y validara. Con Stefanno cubriendo residencia y supervisión a la
vez, la requisición se habría quedado atorada en `SOLICITADA` para siempre.

**Lo que se aplicó, con las dos piezas que Stefanno pidió:**

1. `autorrevision_motivo text` en `requisicion`, y la excepción dentro de la misma
   restricción — sólo se permite la autorrevisión si el motivo quedó escrito
2. `empresa.monto_maximo_autorrevision numeric(16,4) default 5000`, con un **trigger**
   —`tg_requisicion_autorrevision_tope`, no un `CHECK`, porque depende de otra tabla—
   que **bloquea** la autorrevisión si el importe la rebasa. Por debajo del tope, pasa
   con motivo escrito; por encima, obliga a que otro rol valide, sin excepción
3. La marca visible en pantalla y en documento — `V10-PANTALLAS-Y-ROLES` pantalla 20 y
   `V10-CATALOGO-DOCUMENTOS` documento 18, actualizados el mismo día

**La razón del tope, con las palabras de Stefanno:** comprar un bulto de cemento parado
en la obra no puede esperar a que alguien más firme. Autorizarse solo una compra de
cincuenta mil pesos sí es un problema, y ningún despacho pequeño debería permitírselo
aunque sean tres personas.

---

## 6. Lo que falta decidir

| # | Pendiente | De quién |
|---|---|---|
| ~~1~~ | ~~Formato definitivo de clave de concepto y de partida~~ · **RESUELTO 8-ago-2026.** Ver [[V10-MODELO-DOMINIO]] §2 | — |
| ~~2~~ | ~~Aero cálido contra aero frío~~ · **RESUELTO 9-ago-2026: aero cálido.** Ver [[V10-DISENO]] §2 | — |
| ~~3~~ | ~~Las dos familias tipográficas~~ · **RESUELTO 9-ago-2026: Fraunces, Inter y JetBrains Mono.** Ver [[V10-DISENO]] §5 | — |
| ~~4~~ | ~~Catálogo definitivo de categorías de gasto~~ · **RESUELTO 8-ago-2026.** Ver [[V10-MODELO-DOMINIO]] §14 | — |
| 5 | Logotipo de TAAW Builder y su relación con el de Dravya | Stefanno |
| ~~6~~ | ~~Aprobar `firmado_por` / `firmado_en` en `presupuesto`~~ · **RESUELTO 8-ago-2026.** Ver [[V10-ESQUEMA-SQL]] §19, migración 001 | — |
| ~~7~~ | ~~Confirmar los tipos ISO sin ejemplo previo~~ · **RESUELTO 8-ago-2026.** Aprobados tal como se propusieron. Ver [[V10-CATALOGO-DOCUMENTOS]] §8.5 | — |
| 8 | Actualizar `DRAVYA-NOM-NomenclaturaDocumental-R01` fuera de este repositorio: §12 `Flujograma` → `Flujo semanal`, §8 marcar `VS` en negritas como tipo que sí produce Dravya | Stefanno, fuera de este repositorio |
| ~~9~~ | ~~Aprobar el mecanismo de autorrevisión de requisición~~ · **RESUELTO 9-ago-2026, con tope.** Ver [[V10-ESQUEMA-SQL]] §19, migración 003 | — |
| ~~10~~ | ~~Numeración de etapas inconsistente entre documentos~~ · **RESUELTO 9-ago-2026: gana `V10-CONCEPTO`, cuatro etapas.** Ver [[V10-PLAN-DE-TRABAJO-R02]] | — |
| 11 | **Revisar si Prisma sigue fijo en 6.** Se fijó porque `@auth/prisma-adapter` no declaraba soporte para Prisma 7 — ver [[V10-ARQUITECTURA]] §1.1. El adapter se quitó ese mismo día (no hacía falta, con Credentials + JWT), así que la razón original ya no existe. **No subir todavía** — instrucción explícita de Stefanno el 9-ago-2026: revisar hasta que la rebanada 2 (catálogo técnico) esté terminada, para no correr un salto de mayor con el catálogo a medio construir | Revisar después de la rebanada 2 |

---

## 7. Cómo arrancar la sesión de Claude Code

**Preparativos, en orden:**

1. Crear el repositorio **`taaw-builder-v10`**, vacío
2. Copiar dentro la carpeta `APP-V10` completa, como `docs/`
3. Copiar también, en `docs/referencia-v8/`, los cuatro archivos de `.agents/context/`
   listados en §1
4. Abrir Claude Code en la raíz del repositorio nuevo
5. Pegar el mensaje de arranque de abajo

**Mensaje de arranque:**

```
Trabajamos en TAAW Builder v10, plataforma de control de proyecto para el
despacho de arquitectura y construcción Dravya.

Antes de responder nada, lee en este orden:
  docs/V10-CONCEPTO-ParaQueEsLaApp-R02.md
  docs/V10-PLAN-DE-TRABAJO-R02.md
  docs/V10-ARQUITECTURA.md
  docs/V10-DISENO.md
  docs/V10-REQ-CicloDeObra-Cobranza-Bitacora-R01.md
  docs/V10-HANDOFF-ClaudeCode.md

Reglas de trabajo:
- Estamos en etapa de anteproyecto. NO se programa todavía.
- El siguiente entregable es docs/V10-MODELO-DOMINIO.md
- Las nueve reglas invariantes del §3 del handoff no se rompen. Si algo
  las contradice, se replantea la función, no la regla.
- Hablo español. Cada instrucción para otro agente va como bloque copiable.
- Nunca confíes en un reporte sin verificar el código.
- Ninguna operación destructiva sin verificar antes y después contra el original.

Empieza escribiendo docs/V10-MODELO-DOMINIO.md, y antes de escribirlo
propón el formato de clave de concepto y de partida, que es la decisión
pendiente número 1.
```

---

## 8. Qué sigue después del modelo de dominio

```
V10-MODELO-DOMINIO      entidades, relaciones, máquinas de estado
      ↓
V10-ESQUEMA-SQL         el esquema que se congela
      ↓
V10-PLATAFORMA-Y-MIGRACION    migración de los 877 conceptos
      ↓
V10-CATALOGO-DOCUMENTOS       qué PDF emite cada entidad
      ↓
V10-PANTALLAS-Y-ROLES
      ↓
V10-API
      ↓
REBANADA 1 · arquitectura y sistema de diseño   ← aquí empieza el código
```

---

*Este archivo es la memoria del proyecto. Si algo importante se decide, se anota aquí.*
