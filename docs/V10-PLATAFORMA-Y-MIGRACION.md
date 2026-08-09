# TAAW V10 · PLATAFORMA Y MIGRACIÓN

**R01 · 8-ago-2026 · documento 5 de [[V10-PLAN-DE-TRABAJO-R02]]**

Dónde vive la base, cómo se respalda, dónde termina TAAW Builder y empieza la nube de
planos, y qué entra a la base nueva desde la V8 y desde el presupuesto real de F-19.

Depende de [[V10-ARQUITECTURA]] §7 (la decisión de plataforma ya tomada),
[[V10-MODELO-DOMINIO]], [[V10-ESQUEMA-SQL]] (el esquema congelado que recibe los datos)
y de `docs/normativa-dravya/MANUAL_TRABAJO_COLABORATIVO_DRAVYA.md`.

---

## Índice

```
 1  Qué resuelve este documento y qué no
 2  Plataforma — el detalle operativo de lo ya decidido
 3  Respaldo — la mecánica concreta
 4  La frontera de almacenamiento
 5  Qué se migra y qué no — la regla de alcance
 6  Los catálogos de la V8, uno por uno
 7  F-19 — el juego de datos de prueba real
 8  Orden de migración
 9  Mecánica de ejecución
10  Qué se descarta de la V8, y por qué
11  Qué quedó fuera
```

---

## 1. Qué resuelve este documento y qué no

**Resuelve:** el detalle operativo de dónde vive la base y cómo se respalda —la decisión
ya está tomada en [[V10-ARQUITECTURA]] §7, aquí se hace ejecutable—, la frontera exacta
entre lo que guarda TAAW Builder y lo que guarda la nube de planos, y el plan completo de
qué entra a la base congelada desde la V8 y desde el presupuesto real de F-19, con orden
de dependencias y verificación.

**No resuelve:** el esquema —está congelado en [[V10-ESQUEMA-SQL]]— ni las pantallas de
captura —es [[V10-PANTALLAS-Y-ROLES]]. Tampoco ejecuta la migración: deja las reglas, las
decisiones y la mecánica. Ejecutar es trabajo de la rebanada 1, con el esquema ya
desplegado.

---

## 2. Plataforma — el detalle operativo de lo ya decidido

La decisión está tomada en [[V10-ARQUITECTURA]] §7: **mini PC propio, Dokploy, Postgres
como su servicio.** No se reabre aquí. Lo que faltaba era el detalle operativo, y ninguno
estaba escrito en ningún documento todavía.

### 2.1 Despliegue

| | |
|---|---|
| Orquestador | Dokploy, en el mini PC |
| Base de datos | Postgres 16, servicio de Dokploy en el mismo servidor |
| Aplicación | Next.js 15, contenedor propio, build con Nixpacks |
| Dominio | Túnel o dominio dinámico — **pendiente el proveedor exacto**, ver §11 |
| Certificado | El que resuelva Dokploy sobre el dominio elegido, automático |

### 2.2 Variables de entorno y secretos

**No documentado hasta hoy en ningún lugar del proyecto, y es la primera vez que se
escribe.** Sin esto, desplegar la rebanada 1 obliga a inventar sobre la marcha.

| Variable | Qué guarda | Dónde vive |
|---|---|---|
| `DATABASE_URL` | Cadena de conexión a Postgres | Variable de entorno de Dokploy, nunca en el repositorio |
| `AUTH_SECRET` | Firma de sesión de Auth.js | Generado una vez, guardado en Dokploy |
| `STORAGE_PATH` | Ruta del volumen local de archivos — §4 | Variable de entorno, apunta al volumen montado |
| `NODE_ENV` | `production` | Fijo en Dokploy |

**Regla:** ningún secreto se escribe en `.env` dentro del repositorio, ni siquiera en un
`.env.example` con valores reales. Dokploy los inyecta en tiempo de despliegue.

---

## 3. Respaldo — la mecánica concreta

[[V10-ARQUITECTURA]] §7 ya fijó el esquema en tres puntos. Aquí se vuelve ejecutable.

### 3.1 Volcado diario

```bash
# cron diario, 03:00 — hora de menor uso
pg_dump -Fc "$DATABASE_URL" > /respaldo/taaw_$(date +%F).dump

# retención: 14 días de volcados diarios en el propio servidor
find /respaldo -name 'taaw_*.dump' -mtime +14 -delete
```

`-Fc` (formato custom) porque admite restauración parcial con `pg_restore`, y comprime
mejor que un volcado plano.

### 3.2 Copia semanal fuera de la máquina

```bash
# cron semanal, domingo 04:00 — después del volcado diario
rclone copy /respaldo/taaw_$(date +%F).dump remoto:taaw-respaldos/ --min-age 1h
```

`remoto:` es el almacenamiento personal que ya se paga —Drive o Dropbox—, **el mismo
principio de "no pagar de más" que rige el resto de la plataforma.** No es el mismo
almacenamiento que el CDE de proyecto de la sección 4: es una carpeta propia, sin
compartir, sólo para respaldo de base de datos.

**Por qué tiene que ser fuera de la máquina, y no basta con el volcado diario local —
decisión de Stefanno, 9-ago-2026:** el volcado diario protege contra el error humano —el
caso más frecuente— pero vive en el mismo disco que la base. Un disco externo conectado
al mini PC protegería contra la falla del disco principal, pero no contra **robo o
incendio**: si algo le pasa al mini PC, le pasa también a cualquier cosa conectada a él
físicamente. La nube personal es la única de las tres capas que sobrevive a que el
servidor entero desaparezca.

### 3.3 La prueba de restauración

**Un respaldo que nunca se restauró no es un respaldo, es una esperanza.** Trimestral,
manual, en una base de prueba:

```bash
createdb taaw_prueba_restauracion
pg_restore -d taaw_prueba_restauracion /respaldo/taaw_<fecha>.dump
# verificar: conteo de filas de concepto, presupuesto y compromiso contra el respaldo
dropdb taaw_prueba_restauracion
```

Se registra en la bitácora técnica de la aplicación —[[V10-ARQUITECTURA]] §5— con fecha y
resultado. Si falla, se avisa de inmediato: es la única forma en que un respaldo roto se
descubre antes de necesitarlo.

---

## 4. La frontera de almacenamiento

**Hallazgo de este documento, al leer `MANUAL_TRABAJO_COLABORATIVO_DRAVYA.md` §10.**
[[V10-ARQUITECTURA]] §1 decía "archivos y fotos: volumen local del servidor" sin decir
frente a qué. El manual de trabajo colaborativo ya lo resuelve, y se adopta aquí sin
ambigüedad:

> **Los planos y modelos BIM viven en el CDE en la nube, según el manual de trabajo
> colaborativo. NUNCA entran a TAAW Builder.**
> **El volumen del servidor guarda SÓLO lo que la propia app genera: fotos de bitácora,
> adjuntos de requisición y PDFs emitidos.**
> **La app puede guardar el ENLACE a un plano del CDE. El archivo, no.**

| | Nube del CDE (Drive/Dropbox) | Volumen local de TAAW Builder |
|---|---|---|
| Qué guarda | DWG, RVT, PDF de planos, modelos | Fotos de `evento_foto`, adjuntos de `requisicion_renglon` y `evento_adjunto`, PDF que la propia app genera |
| Quién lo escribe | Fernanda, Stefanno, los externos (Max, Memo) | La aplicación, en respuesta a una acción del usuario |
| Estructura | La del manual: `{PROYECTO}/{DISCIPLINA}/{WIP·PUBLICADO·PDF·SUPERADO}` | Por empresa y proyecto, sin estructura de disciplinas — no aplica |
| Lo que TAAW guarda de esto | El **enlace** — un campo `url_externa` en el documento o evento que lo referencia | — |

**Por qué la frontera es dura y no una preferencia:** un `.rvt` pesa cientos de megas y
tiene su propio ciclo de vida —WIP, Publicado, Superado— gobernado por el manual de
trabajo colaborativo, no por las reglas invariantes de esta plataforma. Meterlo al
volumen del servidor duplicaría el respaldo, duplicaría la fuente de verdad, y el día que
alguien suba una versión al CDE y otra a TAAW, nadie sabría cuál es la vigente. Es
exactamente el problema que el CDE existe para resolver, y TAAW Builder no lo resuelve
mejor: lo respeta.

---

## 5. Qué se migra y qué no — la regla de alcance

**Resuelto por Stefanno el 8-ago-2026, después de que el análisis de datos reales
mostrara qué existe de verdad.**

| | Se migra | No se migra |
|---|---|---|
| **Catálogo reusable de la V8** | Conceptos, insumos (materiales, herramienta, mano de obra, indirectos), proveedores, clientes, colaboradores, partidas | — |
| **Transaccional de otros proyectos** (`PRY-014`, `PRY-010`, `PRY-015`, `PRY-020`) | — | Nada. Son proyectos cerrados o de otro giro. El archivo original de la V8 se conserva completo como **respaldo histórico**, fuera de la base nueva |
| **Cronograma de F-19 en la V8** (82 filas, `cronograma_actividades`) | — | El cronograma real es el del Excel de F-19 — sección 7. Las 82 filas de la V8 no se tocan |
| **F-19 real** | El presupuesto, la carátula, el cronograma, el flujo semanal y el control de obra del archivo `docs/referencia-f19/` — sección 7 | Lo que ese mismo archivo todavía no tiene: movimientos, requisiciones, raya, proveedores del proyecto, bitácora — están vacíos, arrancan vacíos en la V10 también |

**Por qué arrastrar los otros cuatro proyectos contaminaría la base nueva:** cada uno
vive en su propio momento —cerrado, de otro giro, con su propia versión de precios— y
mezclarlos con el catálogo vivo de Dravya obligaría a decidir, para cada uno, las mismas
preguntas que ya costaron un día completo resolver para los 877 conceptos y los 75
proveedores. Se resuelve cuando ese proyecto lo necesite, no antes.

---

## 6. Los catálogos de la V8, uno por uno

Todos leídos del archivo real `TAAW_DB_Master.xlsx`, no del diagnóstico escrito sobre
ellos — el diagnóstico ya demostró estar desactualizado dos veces en esta sesión.

### 6.1 Conceptos — 877, ya resuelto

No se repite aquí. La clave, la migración y las siete decisiones de datos están cerradas
en [[V10-MODELO-DOMINIO]] §15 y `docs/migracion/`.

### 6.2 Materiales — 72 filas, limpio salvo un punto

Sin duplicados de ID, sin costos vacíos. Un solo problema real, ya documentado y
verificado de nuevo: la columna `Tienda_Proveedor` mezcla identificador (34 filas,
formato `PROV-####`) y texto libre (38 filas, `"TAMEX"`, `"COPREMAPSA"`).

**Resolución:** al migrar, cada texto libre se compara por nombre normalizado contra el
catálogo de proveedores ya migrado. Si coincide, se liga por `id`. Si no existe, se crea
un registro mínimo de proveedor —nombre, nada más— **exactamente el mismo patrón que ya
está diseñado para el formulario de tarjeta**: *"si no existe el proveedor se crea aquí
mismo."* No es una regla nueva, es la misma aplicada un paso antes.

### 6.3 Herramienta y equipo — 122 filas, se vacía y se reconstruye

**Ejecuta la decisión del 28-jul-2026 que nunca se aplicó.** Verificado contra el archivo
real antes de ejecutarla, no de memoria: dividir `costo_unitario` entre 1.16 da números
redondos en toda la muestra —`406 ÷ 1.16 = 350.00`, `1102 ÷ 1.16 = 950.00`,
`1624 ÷ 1.16 = 1400.00`—, lo que confirma que el 16% de IVA está embebido en el precio,
tal como el diagnóstico decía.

**Resolución, la que ya estaba decidida:** la tabla de insumos tipo `HERRAMIENTA` **no
migra estas 122 filas.** Arranca vacía, igual que arrancan vacías hoy
`tarjetas_precios_unitarios`, `costos_mano_obra`, `costos_indirectos` y
`subcontratos_catalogo` en la V8 — es la misma clase de catálogo sin construir. Se
reconstruye con precios netos e identificadores nuevos, cuando el equipo capture las
tarjetas reales.

**Nota técnica para cuando se reconstruya, no una decisión de este documento:** si se
opta por recalcular en bloque en vez de recapturar a mano, `costo_unitario ÷ 1.16`
reproduce el precio neto para las filas cuyo IVA está embebido — verificado arriba, no
supuesto.

### 6.4 Proveedores — 75 filas, tres duplicados y nueve sin confirmar

**La colisión, ya decidida y verificada línea por línea:**

| ID viejo | Filas | Contenido |
|---|---|---|
| `PROV-007` | 3 | Una fila **Activo** con contacto real (WALMART) + dos filas **Borrador** idénticas entre sí |
| `PROV-012` | 2 | Dos filas **Borrador**, byte por byte idénticas |
| `PROV-013` | 2 | Dos filas **Borrador**, byte por byte idénticas |

**Regla aplicada — la misma que conceptos:** mismo dato → se conserva el más nuevo, las
demás se dan de baja. `PROV-012` y `PROV-013` colapsan cada uno a un solo proveedor.
`PROV-007` tiene **dos proveedores reales distintos** bajo la misma clave vieja —el
contacto Activo y el placeholder Borrador, que sí difieren entre sí— y sus dos copias
Borrador colapsan a una: resultado, dos proveedores nuevos donde había tres filas.

**Hallazgo nuevo, resuelto con la regla 7 del proyecto:** 9 de 75 proveedores no están en
`Activo` — 7 `Borrador`, 1 `En Evaluación`, 1 `Incompleto`. Migran con `activo = false` y
el estado original conservado en notas. No se borran ni se excluyen: **nada se borra,
sólo se marca inactivo**, y quedan disponibles si alguien los activa después de
completarlos.

### 6.5 Clientes y colaboradores

12 clientes, 5 colaboradores. Migran completos y sin anomalías de ID. Sólo el cliente y
los colaboradores que F-19 usa entran con relación viva al proyecto; el resto del
catálogo de clientes migra igual, porque es reusable —el mismo criterio de la sección 5.

### 6.6 Partidas

47, ya resueltas en [[V10-MODELO-DOMINIO]] §15: 5 activas de las 21 sin conceptos, 16 de
baja por ser del giro de eventos que Dravya no opera.

---

## 7. F-19 — el juego de datos de prueba real

**No es un ejemplo. Es el dato que exige la definición de terminado del proyecto:** *"un
dato real del proyecto F-19 recorrió el flujo completo"* — y este archivo es ese dato.

Fuente: `docs/referencia-f19/F19-PRESUPUESTO-Y-CONTROL-V11-REV04.FINAL.xlsx`, terminado
el 8-ago-2026 en hoja de cálculo, mientras la app no existía. Su propio `LEEME.md` trae
cuatro advertencias, leídas y aplicadas abajo.

### 7.1 Lo que trae, y contra qué parte del modelo se verifica

| Pestaña | Contenido real | Verifica en el modelo |
|---|---|---|
| `CARATULA` | Datos del proyecto, `% UTILIDAD` y `% IVA` como parámetros, esquema de cobranza 60/20/20, hitos por etapa BIM (`AP·PE·OB·AS`), posición financiera (cobrado, por cobrar, gastado, caja), parcialidades recibidas, roles y autorizaciones | `proyecto`, `tramo_cobranza`, `v_posicion_financiera`, `abono`, `usuario_rol` |
| `PRESUPUESTO` | **135 conceptos, 5 módulos, 25 partidas.** Opción A, sólo planta baja | `presupuesto_concepto`, `presupuesto_modulo` |
| `PRESUPUESTO OPCIÓN B` | 201 conceptos — planta baja + planta alta | `presupuesto_opcion` |
| `PRESUPUESTO OPCIÓN C` | 267 conceptos — tres niveles | `presupuesto_opcion` |
| `CRONOGRAMA` · `FLUJO SEMANAL` · `CONTROL DE OBRA` | Programa, reparto semanal, avance | `actividad`, `semana_flujo`, `avance` |
| `BOLSILLO OPERATIVO` | Interno: costo directo contra precio de venta, utilidad y margen por concepto | `presupuesto_concepto.precio_costo/precio_venta`, nunca visible al cliente — regla 3 de [[V10-CATALOGO-DOCUMENTOS]] |
| `GENERADORES` · `TPU` · `INSUMOS` | Catálogos del proyecto: memoria de cálculo, tarjetas, insumos | `generador`, `tarjeta`, `insumo` |
| `MOVIMIENTOS` · `REQUISICIONES` · `RAYA` · `PROVEEDORES` · `ESTADO DE RESULTADOS` · `BITACORA` | **Vacías, confirmado.** Sólo encabezados | Arrancan vacías también en la V10: no hay nada que migrar |

**El modelo aguanta el archivo, y en varios puntos coincide casi textual:**

- El esquema de cobranza de la carátula es **60/20/20**, los mismos tres tramos de
  `tramo_cobranza`, con "semana de corte" derivada del cronograma — exactamente como
  quedó modelado, no una coincidencia de nombres
- `POSICIÓN FINANCIERA DEL PROYECTO`: cobrado a la fecha, por cobrar, gastado a la
  fecha, caja del proyecto — son los cuatro campos literales de `v_posicion_financiera`
- `PARCIALIDADES RECIBIDAS` (fecha, monto, a qué tramo, forma de pago, folio de
  movimiento) es `abono`, columna por columna
- **Tres opciones comparables de un mismo presupuesto, con distinto alcance —A, B y
  C— es exactamente la forma para la que se diseñó `presupuesto_opcion` y el documento
  nuevo "Comparativo de opciones" de [[V10-CATALOGO-DOCUMENTOS]] §7.4.** No hubo que
  forzar el archivo real al modelo: encajó.

### 7.2 Las cuatro advertencias del `LEEME.md`, aplicadas

| Advertencia | Cómo se resuelve en la migración |
|---|---|
| Las claves son las viejas de la V8 | Se resuelven contra `docs/migracion/EQUIVALENCIA-CLAVES.csv`. Los conceptos con **clave provisional** —nuevos, sin equivalencia todavía— entran por el flujo de alta de concepto nuevo, con clave definitiva asignada por partida, igual que cualquier concepto nuevo capturado desde la app |
| El IVA está en cero, decisión de Stefanno | Migra tal cual: `empresa.iva_pct` no se toca — es un parámetro de empresa —, pero `documento.iva_pct` de los documentos de este presupuesto se captura en 0, como manda la regla 3: el IVA es parámetro, nunca inventado |
| La escalera del Módulo 5 va en cero | Migra en cero, sin alerta de "sin precio": es una decisión de captura pendiente, no un dato faltante por error. Se anota en la nota del concepto |
| Los conceptos nuevos —árbol, tierra física, tarja, servicio CFE— sin precio | Verificados: son 5 conceptos (`PRE02227`–`PRE02231`, el derribo de árbol y su secuela). Migran con `tipo_precio = FIJO` y `valor = null`, con alerta activa de "concepto sin precio" — es el caso real para el que esa alerta se diseñó |

### 7.3 Un hallazgo técnico, verificado antes de asumirlo

**`P.UNITARIO` y `TOTAL` de la hoja `PRESUPUESTO` son fórmulas sin valor cacheado — la
exportación de Google Sheets no guardó el resultado.** Comprobado leyendo el archivo con
y sin fórmulas: `P.UNITARIO` es `=P.U.BASE × (1 + %UTILIDAD)`, y `%UTILIDAD` sale de la
carátula. `P.U. BASE`, en cambio, **sí es un valor capturado**, no una fórmula.

Esto no bloquea nada: la migración **calcula** `precio_venta` a partir de `P.U. BASE` y
los parámetros de la carátula, en vez de leer una celda que no trae el número. Es
exactamente el mismo cálculo que hace la carátula, reproducido por el script de carga.

### 7.4 Segundo hallazgo, y es una validación del modelo, no un defecto

**Sólo 1 de los 603 conceptos (135+201+267) tiene tarjeta construida en `TPU`** —
`DEM5029`, la demolición de muro, con sus renglones de mano de obra reales. Los otros 602
traen su precio como `P.U. BASE` capturado directamente, a juicio experto, sin tarjeta
que lo respalde todavía.

**El esquema congelado ya lo permite sin cambiar nada:** `presupuesto_concepto.precio_costo`
se captura de forma independiente del estado de la `tarjeta` del concepto global — no
hay, ni debe haber, una restricción que exija tarjeta completa para presupuestar. Es
exactamente cómo trabaja Dravya en la práctica: el precio se estima primero, la tarjeta
se construye después. El archivo real confirmó que el modelo ya lo soporta; no hizo
falta tocar el esquema.

---

## 8. Orden de migración

Por dependencia de llave foránea, y porque el orden equivocado hace que un `insert`
falle contra una referencia que todavía no existe:

```
partida
   ↓
proveedor  (con la depuración de duplicados y estados aplicada)
   ↓
unidad, categoria_gasto  (catálogos controlados, semilla fija)
   ↓
insumo  (materiales resueltos · herramienta vacía a propósito)
   ↓
concepto  (877, con la migración ya cerrada)
   ↓
cliente, colaborador → usuario
   ↓
proyecto  (F-19, con su cliente y colaboradores ya migrados)
   ↓
presupuesto → presupuesto_opcion (A · B · C) → presupuesto_modulo → presupuesto_concepto
   ↓
generador  (memoria de cálculo de F-19)
   ↓
tramo_cobranza, abono  (esquema de cobranza y parcialidades de la carátula)
   ↓
actividad  (cronograma de F-19, del Excel — nunca de los 82 registros de la V8)
```

---

## 9. Mecánica de ejecución

La misma disciplina que ya se aplicó a los 877 conceptos, extendida a todo lo de esta
sección.

1. **Simulación primero, siempre.** El script produce el mapa completo de qué entra,
   con qué clave nueva, y qué no mapea — nada se escribe hasta leer ese informe
2. **Una transacción por catálogo migrado**, no una transacción gigante para todo. Si
   falla la migración de proveedores, no debe arrastrar a materiales, que depende de
   ella pero es una escritura separada
3. **Verificación antes y después, contra el archivo original** — no contra un reporte
   de lo que el script cree que hizo. Conteo de filas de entrada, conteo de filas de
   salida, conteo de claves únicas, conteo de relaciones rotas
4. **El informe de migración se guarda como documento del proyecto, con folio** — igual
   que quedó decidido para los conceptos
5. **`docs/referencia-f19/` es una instantánea, no la fuente viva.** Su propio `LEEME.md`
   lo dice: la fuente sigue siendo el Excel que Stefanno edita. La migración parte de
   esta copia porque es la que se congeló para esta sesión; si el Excel cambió desde el
   8-ago-2026, se vuelve a copiar antes de ejecutar

---

## 10. Qué se descarta de la V8, y por qué

Para que nadie las migre por accidente creyendo que son catálogo vivo:

| Pestaña | Por qué se descarta |
|---|---|
| `analisis_pu` | Esquema deprecado de tarjetas, 0 filas. `recalculateAllPrices()` de la V8 la leía por error — no se repite el error migrándola |
| `Budgets` | Modelo de presupuesto anterior a `presupuesto_contenedores` |
| `BKUP`, `bckuocontenedores`, `BKUPpresupuesto_conceptos`, `bckupcronograma` | Respaldos internos de la V8. Su función la cumple ahora el respaldo real de Postgres — sección 3 |
| `primer DESTAJO`, `primer FLUJORAMA` | Hojas de trabajo manual sin encabezado, 189 y 33 columnas. No tienen estructura que migrar |
| `presupuesto_contenedores`, `presupuesto_conceptos`, `cronograma_actividades`, `Finanzas`, `recibos`, `Pagos_Programados`, `Bitacora`, `INVENTARIO` | **No se descartan: se conservan íntegras como respaldo histórico**, fuera de la base nueva — es lo transaccional de otros proyectos, sección 5 |

---

## 11. Qué quedó fuera

| # | Quedó fuera | Por qué |
|---|---|---|
| 1 | El dominio o túnel exacto de acceso remoto | Depende de qué esté disponible cuando se despliegue; la mecánica ya está descrita en §2.1 |
| 2 | La ejecución real del script de migración | Es trabajo de la rebanada 1, con Prisma y el esquema ya desplegado. Este documento deja las reglas, no el código |
| 3 | La reconstrucción de `costos_herramienta` con precios reales | Vaciar está decidido; volver a llenarla con datos reales de proveedor es trabajo operativo posterior, no de este documento |
| 4 | Los conceptos con clave provisional del archivo de F-19, dados de alta uno por uno | Se resuelven con el mismo flujo de "concepto nuevo" de la app, no con una lista estática aquí — cambiarían en cuanto alguien edite el Excel vivo |
| 5 | Nómina, raya, destajos, inventario de F-19 | Están vacíos en el archivo real y sus tablas no existen en el esquema congelado — rebanada 7, igual que en el modelo de dominio |
| 6 | Estructura de carpetas de proyecto nuevo, más allá de la referencia al CDE | Es `MANUAL_TRABAJO_COLABORATIVO_DRAVYA.md` §2, ya completo y de sólo lectura; este documento sólo fija la frontera de qué NO vive en TAAW Builder |

### Lo que este documento decidió y no estaba resuelto

1. Variables de entorno y secretos, documentadas por primera vez
2. La frontera dura entre el CDE en la nube y el volumen local de TAAW Builder
3. Sólo el catálogo reusable de la V8 migra en bloque; lo transaccional de otros
   proyectos se conserva como respaldo histórico y no entra a la base nueva
4. El presupuesto real de F-19 —no las 82 filas huérfanas de la V8— es el juego de
   datos de prueba, y el modelo lo representa sin necesitar un solo cambio de esquema
5. `precio_costo` de un renglón de presupuesto no depende de que exista tarjeta
   completa — confirmado contra el archivo real, no supuesto
6. Proveedores en estado no confirmado migran inactivos, no se excluyen ni se fuerzan
   a activos

---

*Documento 5 de 8. El siguiente es [[V10-PANTALLAS-Y-ROLES]], que ya tiene sus dos
dependencias —el modelo de dominio y el catálogo de documentos— completas.*
