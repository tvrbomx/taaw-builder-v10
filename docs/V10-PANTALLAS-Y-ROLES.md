# TAAW V10 · PANTALLAS Y ROLES

**R01 · 8-ago-2026 · documento 7 de [[V10-PLAN-DE-TRABAJO-R02]]**

Pantalla por pantalla, permiso por rol. Con este documento un agente programa sin
adivinar.

Depende de [[V10-MODELO-DOMINIO]], [[V10-ESQUEMA-SQL]], [[V10-CATALOGO-DOCUMENTOS]] y
[[V10-DISENO]]. Los cuatro patrones de interfaz —tabla, formulario, ficha, línea de
tiempo— están cerrados en `V10-DISENO` §7 y **no se redefinen aquí**: cada pantalla sólo
dice cuál usa.

---

## Índice

```
 1  Qué resuelve este documento y qué no
 2  La ficha de pantalla — los ocho campos que declara toda pantalla
 3  Regla dura · la tarjeta nunca es obligatoria
 4  Regla dura · teléfono primero en las pantallas de obra
 5  Regla dura · sin señal — cola local con reintento automático
 6  Regla dura · el estado vacío es una pantalla
 7  Regla dura · crear en línea sin salir del flujo
 8  Regla dura · permiso por pantalla y por acción
 9  Regla dura · qué nunca ve el cliente, aplicado a pantalla completa
10  El catálogo de pantallas — 34, con la ficha aplicada:
    10.1 Catálogo técnico (4)          10.5 Obra (5)
    10.2 Proyecto y documentación (5)  10.6 Dinero (6)
    10.3 Presupuesto (4)               10.7 Ajustes del sistema (3)
    10.4 Programa y control (4)
11  Las tres pantallas de la junta — APROBADAS, se programan
12  Qué quedó fuera
```

---

## 1. Qué resuelve este documento y qué no

**Resuelve:** para cada una de las 34 pantallas de las ocho rebanadas funcionales, quién
la ve, quién edita, quién aprueba, qué patrón de `V10-DISENO` usa, si se diseña primero
para teléfono o para escritorio, qué puede crear sin salir de ella, cómo se ve vacía el
día uno, y si es segura para proyectarse frente al cliente.

**No resuelve:** el layout pixel a pixel de cada pantalla —eso lo definen los cuatro
patrones ya cerrados, aplicados caso por caso durante la construcción— ni la superficie
de API que los sirve, que es [[V10-API]], el documento siguiente.

---

## 2. La ficha de pantalla — los ocho campos

Toda pantalla del catálogo de la sección 10 declara estos ocho campos, sin excepción.

| # | Campo | Qué significa |
|---|---|---|
| 1 | **Entidad(es)** | qué tabla o vista del modelo de dominio muestra o edita |
| 2 | **Rol y acción** | quién **ve**, quién **edita**, quién **aprueba** — nunca sólo "quién entra" |
| 3 | **Patrón** | tabla · formulario · ficha · línea de tiempo, de `V10-DISENO` §7 |
| 4 | **Caso primario** | teléfono u escritorio — sección 4 |
| 5 | **Crea en línea** | qué entidad se puede dar de alta sin salir de esta pantalla — sección 7 |
| 6 | **Estado vacío** | qué ve el usuario el día uno, con la base limpia — sección 6 |
| 7 | **Segura para cliente** | sí, no, o "según el documento" — sección 9 |
| 8 | **Sin señal** | sólo en las pantallas donde aplica la cola local — sección 5 |

---

## 3. Regla dura · la tarjeta nunca es obligatoria

**Confirmado sin buscarlo, al leer el presupuesto real de F-19** en
[[V10-PLATAFORMA-Y-MIGRACION]] §7.4: 602 de 603 conceptos presupuestados no tienen
tarjeta construida. Un precio a juicio experto es un precio válido, no un pendiente de
captura. Así trabaja el despacho.

**Regla de pantalla:**

- La app **jamás bloquea** por falta de tarjeta. Un concepto sin tarjeta se presupuesta
  igual que uno con tarjeta completa
- El `Catálogo de conceptos` muestra una **marca discreta** —un ícono, no un color de
  alerta— en cada concepto sin tarjeta. Informa, no regaña
- La tarjeta se construye **cuando conviene**: cuando un insumo se repite en muchos
  conceptos y vale la pena que su cambio de precio cascadee solo. No antes

---

## 4. Regla dura · teléfono primero en las pantallas de obra

**Cuatro pantallas, y sólo cuatro, se diseñan primero para teléfono:**

```
Bitácora en línea de tiempo · Alta de evento con fotos
Requisición (creación)       · Recepción de trabajo
```

El supervisor y el residente las usan parados en el terreno, con una mano. Todo lo
demás —catálogo, presupuesto, cronograma, dinero, ajustes, y dentro de la propia obra la
bandeja de aprobación— se diseña primero para escritorio: son pantallas que se abren
sentado, revisando, con las dos manos libres.

**Lo que "primero" significa en la práctica:**

| | Teléfono primero | Escritorio primero |
|---|---|---|
| Objetivo táctil | Grande, una columna, cámara como entrada principal | Denso, tabla con columnas fijas |
| Captura | Selección sobre texto libre siempre que se pueda | Puede pedir texto y detalle |
| Funciona en el otro dispositivo? | Sí, pero no es el caso que se optimiza | Sí, pero no es el caso que se optimiza |

Ninguna pantalla queda rota en el dispositivo que no es su caso primario — es una
cuestión de qué se prueba primero y para qué se afina, no de qué se abandona.

---

## 5. Regla dura · sin señal — cola local con reintento automático

**Decisión, con su razón:** opción (b), cola local que reintenta sola. No (a) —fallar y
avisar pierde justo lo más caro de recapturar, cinco fotos paradas en el terreno—, no
(c) —un modo sin conexión completo obliga a sincronizar también las lecturas y resolver
conflictos, ingeniería que tres personas no necesitan todavía.

Aplica a las tres pantallas de escritura de la sección 4: **Alta de evento con fotos**,
**Requisición** y **Recepción de trabajo**. `Bitácora en línea de tiempo` es lectura, no
necesita cola.

**Tres condiciones, sin las cuales la cola no sirve — las tres de Stefanno, con su
mecanismo:**

### a · La cola es visible, siempre

Un **indicador permanente** en el marco de la aplicación —no un mensaje que desaparece—
muestra cuántos elementos están pendientes de subir y desde cuándo el más viejo. Toca el
indicador, se abre el detalle: cada elemento, su tipo, su antigüedad, su estado de
reintento.

**Si un elemento lleva más de lo razonable esperando** —treinta minutos es el umbral de
partida, ajustable— **el indicador escala**: cambia al color de estado `atencion` de los
tokens de `V10-DISENO`, y el detalle lo marca explícitamente. Una cola silenciosa es un
fallo silencioso, y eso rompe la regla del proyecto de que ningún error se pierde sin
aviso.

### b · La cola sobrevive al cierre

**IndexedDB, no memoria y no `localStorage`.** `localStorage` guarda cadenas de texto con
un límite de unos pocos megabytes — no sirve para cinco fotos. IndexedDB es
almacenamiento persistente del navegador diseñado para datos binarios grandes, y
sobrevive a que el usuario cierre la pestaña, cierre el navegador o se le apague el
teléfono.

Si el residente reabre la app dos horas después, sus cinco fotos siguen en la cola,
exactamente donde las dejó.

### c · El folio se asigna al llegar, nunca en el teléfono

**Un elemento en la cola no tiene `id` de base de datos, no tiene `clave`, no tiene
folio, y no existe para nadie más que para quien lo capturó.** Es un borrador local, no
un registro.

Sólo cuando la cola logra enviarlo al servidor, la transacción del servidor —la misma de
`documento_contador` con `SELECT ... FOR UPDATE` de [[V10-ESQUEMA-SQL]] §5— crea el
registro real y le asigna su número. Si dos personas sin señal levantan una requisición
al mismo tiempo, cada una vive sólo en su propio teléfono hasta que llega; el servidor
las numera en el orden en que de verdad llegaron, nunca en el orden en que se capturaron.

**La pantalla lo dice sin que nadie tenga que preguntarlo:** un elemento en cola se
etiqueta `BORRADOR — pendiente de subir, sin folio todavía`, con una tipografía y un
color distintos de un registro ya confirmado. En cuanto sincroniza, la etiqueta cambia
al folio real.

### Qué pasa si el error no es de señal

Si la cola reintenta y el servidor **rechaza** el envío —un dato inválido, no un
problema de red—, **deja de reintentar solo** y lo marca como error explícito, distinto
del estado "pendiente de señal". Reintentar para siempre algo que nunca va a funcionar es
la misma clase de `catch` silencioso que el proyecto prohíbe, sólo que repetido.

### El cruce con "crear en línea"

**Crear un insumo o un proveedor nuevo dentro del flujo exige conexión**, porque su
clave la asigna el servidor. Sin señal, sólo se puede elegir de lo que ya está en el
catálogo descargado al teléfono — no se puede dar de alta algo nuevo. La pantalla lo
declara: si no hay señal, la opción "crear nuevo" se ve pero está deshabilitada, con la
razón visible al tocarla.

---

## 6. Regla dura · el estado vacío es una pantalla

Se diseña para cada módulo, no se deja como accidente. Con la base recién desplegada:

| Módulo | Qué ve | Por dónde empieza |
|---|---|---|
| Catálogo técnico | Vacío real sólo si no se ha corrido la migración. Si ya corrió, los 877 conceptos y sus insumos | Botón "crear concepto" o "importar catálogo" |
| Proyecto y documentación | Sin proyectos | "Crea tu primer proyecto" — el primer paso de todos |
| Presupuesto | Sin proyecto elegido: pide elegir uno. Proyecto sin módulos: "agrega el primer módulo" | Depende del nivel: elegir proyecto, o agregar módulo |
| Programa y control | Sin presupuesto autorizado, el cronograma no tiene de dónde sacar actividades | Mensaje explicativo, no un cronograma vacío fingiendo que hay algo que ver |
| Obra | Bitácora sin eventos: "registra el primero" | Botón `+` siempre visible, el de más peso visual de la pantalla |
| Dinero | Sin movimientos, sin tramos de cobranza si el presupuesto no está autorizado | Mensaje que explica la dependencia, no un cero desnudo |
| Ajustes del sistema | Dravya y TAAW ya existen desde la instalación — no está vacío en la práctica | — |

**Regla general:** un estado vacío nunca es una tabla en blanco sin explicación. Dice
qué falta y qué botón lo resuelve.

---

## 7. Regla dura · crear en línea sin salir del flujo

*Un dato se captura una vez.* Si hace falta algo que no existe, se crea ahí mismo.

| Pantalla | Qué se puede crear sin salir |
|---|---|
| Constructor de tarjeta | Insumo nuevo → si el insumo pide un proveedor que no existe, proveedor nuevo. Los tres niveles anidados, ya especificado en `ESPEC_MODULO_TPU.md` de la V8 y conservado aquí |
| Armado de presupuesto | Concepto nuevo, sin salir del presupuesto |
| Proyectos / Ficha de proyecto | Cliente nuevo · colaborador nuevo |
| Requisición | Proveedor nuevo, cuando la cotización es implícita —el maestro que no cotiza en papel— |
| Catálogo de insumos / Catálogo de conceptos / Proveedores | Son el destino de esas altas; también admiten alta directa, completa, sin estar embebidos en otro flujo |

**Regla dura, y ya está en la sección 5:** crear en línea exige conexión. La clave la
asigna el servidor, nunca el dispositivo.

---

## 8. Regla dura · permiso por pantalla y por acción

**Nunca "quién entra".** Cada pantalla de la sección 10 declara sus tres niveles: quién
**ve**, quién **edita**, quién **aprueba** — y algunas tienen más de una acción de cada
tipo, según el estado de la entidad.

**Un usuario con varios roles tiene la unión de lo que cada rol permite en esa pantalla**,
no el máximo de uno solo ni el mínimo. Si Stefanno es residencia en un proyecto y
supervisión en otro, en cada proyecto tiene exactamente los permisos del rol que
corresponde a ese proyecto — la unión se calcula por proyecto, no de forma global.

**La regla de que quien edita no aprueba lo que editó**, ya escrita en
[[V10-ESQUEMA-SQL]] §9 para requisición, se aplica en la interfaz igual: un botón de
aprobación nunca se habilita para el mismo usuario que hizo la edición que se está
aprobando, sin importar cuántos roles tenga. Se comprueba sobre el usuario, no sobre el
rol.

---

## 9. Regla dura · qué nunca ve el cliente, aplicado a pantalla completa

**No es sólo regla de documento impreso — es regla de pantalla.** Ninguna vista que se
pueda proyectar en una junta o mostrar en un teléfono frente al cliente muestra costo
directo, utilidad, margen ni proveedor. Extiende [[V10-DISENO]] §8 y la regla 3 de
[[V10-CATALOGO-DOCUMENTOS]] a la interfaz viva, no sólo al PDF.

Cada pantalla de la sección 10 declara **segura** o **no segura** para proyectar. Tres
casos:

| Marca | Significa |
|---|---|
| **Sí** | Se puede compartir pantalla o proyectar sin preparación. Diseñada así desde el origen |
| **No** | Nunca, bajo ninguna circunstancia, con el cliente presente |
| **Según el documento** | La pantalla lista o navega documentos de naturaleza distinta; la seguridad la determina el documento abierto, no la pantalla contenedora |

---

## 10. El catálogo de pantallas — 34

### 10.1 Catálogo técnico (4)

| # | Pantalla | Entidad(es) | Ve / edita / aprueba | Patrón | Caso | Crea en línea | Vacío | Cliente |
|---|---|---|---|---|---|---|---|---|
| 1 | Catálogo de insumos | `insumo` | Ve: catálogo técnico y obra · Edita: coordinación, admin. app | Tabla | Escritorio | Alta directa | §6 | No |
| 2 | Catálogo de conceptos | `concepto`, `tarjeta` | Ve: todos con acceso · Edita: coordinación | Tabla, con marca de "sin tarjeta" — §3 | Escritorio | Concepto nuevo | §6 | No |
| 3 | Constructor de tarjeta | `tarjeta`, `renglon_tarjeta` | Edita: coordinación | Formulario | Escritorio | Insumo → proveedor, anidado | "sin tarjeta, agrega un renglón" | No |
| 4 | Buscador | transversal | Ve: todos, filtrado por permiso | Tabla de resultados | **Los dos** — clave vieja desde obra, catálogo completo desde escritorio | No | "escribe para buscar" | No por defecto |

### 10.2 Proyecto y documentación (5)

| # | Pantalla | Entidad(es) | Ve / edita / aprueba | Patrón | Caso | Crea en línea | Vacío | Cliente |
|---|---|---|---|---|---|---|---|---|
| 5 | Proyectos | `proyecto` | Ve: según rol asignado · Edita: coordinación, dirección | Tabla — **lista simple, diseñada para 1 a 5 proyectos activos.** Sin buscador avanzado, sin filtros compuestos, sin tablero de cartera | Escritorio | Cliente nuevo | §6 | No |
| 6 | Ficha de proyecto | `proyecto`, agregados | Ve: rol asignado a ese proyecto · Edita: según campo | Ficha | Escritorio, consulta rápida en teléfono | Colaborador nuevo | "arma tu presupuesto" | Sí la carátula; no el resto de pestañas |
| 7 | Clientes | `cliente` | Edita: coordinación | Tabla | Escritorio | — | §6 | No |
| 8 | Colaboradores y roles | `usuario`, `usuario_rol` | Edita: administrador de la aplicación | Tabla + Formulario | Escritorio | — | Sólo el admin. existe | No |
| 9 | Documentos | `documento` | Ve: todos, filtrado · Aprueba: validador de documentos, `S3→A5` | Tabla | Escritorio | No | "nada emitido todavía" | Según el documento |

### 10.3 Presupuesto (4)

| # | Pantalla | Entidad(es) | Ve / edita / aprueba | Patrón | Caso | Crea en línea | Vacío | Cliente |
|---|---|---|---|---|---|---|---|---|
| 10 | Armado de presupuesto | `presupuesto_concepto` y árbol | Edita: coordinación · Aprueba (`AUTORIZADO`): dirección | Tabla jerárquica + Ficha | Escritorio | Concepto nuevo | "agrega el primer módulo" | No |
| 11 | Generadores de volumen | `generador` | Edita: quien arma el presupuesto | Formulario/Tabla | Escritorio | — | "cantidad capturada a mano, sin generador" — válido, no error | No |
| 12 | Comparador de opciones | `presupuesto_opcion` (varias) | Ve: coordinación, dirección, y el cliente en junta · Edita: coordinación | Tabla comparativa | Escritorio | — | "arma al menos dos opciones" | **Sí** — es el documento diseñado para el cliente |
| 13 | Vista de impresión | el documento que previsualiza | Ve: quien tenga acceso al documento origen | — | Escritorio | — | — | Según el documento |

### 10.4 Programa y control de obra (4)

| # | Pantalla | Entidad(es) | Ve / edita / aprueba | Patrón | Caso | Crea en línea | Vacío | Cliente |
|---|---|---|---|---|---|---|---|---|
| 14 | Cronograma | `actividad`, `linea_base` | Edita: residencia · Aprueba (línea base): coordinación | Línea de tiempo | Escritorio | — | "sin presupuesto autorizado no hay actividades" | Sí sin importes; no con ellos |
| 15 | Flujo semanal | `semana_flujo` | Ve: coordinación, dirección, finanzas | Tabla | Escritorio | — | §6 | No |
| 16 | Control de obra | `avance` | Ve: todos con acceso al proyecto · Edita: se alimenta de bitácora, no se captura directo aquí | Tabla | Escritorio | — | "sin avance capturado todavía" | No |
| 17 | Comparativo plan contra real | `linea_base_actividad` vs `actividad` | Ve: dirección, coordinación | Tabla | Escritorio | — | §6 | No |

### 10.5 Obra (5)

| # | Pantalla | Entidad(es) | Ve / edita / aprueba | Patrón | Caso | Crea en línea | Vacío | Cliente | Sin señal |
|---|---|---|---|---|---|---|---|---|---|
| 18 | Bitácora en línea de tiempo | `evento` | Ve: supervisión, residencia, coordinación, dirección | Línea de tiempo | **Teléfono** | — | "registra el primer evento" | No | No aplica — es lectura |
| 19 | Alta de evento con fotos | `evento`, `evento_foto` | Edita: supervisión, residencia | Formulario | **Teléfono** | Abre Requisición si aplica | — | No | **Sí — §5** |
| 20 | Requisición | `requisicion`, `cotizacion` | Edita (`SOLICITADA`): residente + supervisor · Aprueba: coordinación, finanzas | Formulario + Ficha. **Si `autorrevision_motivo` tiene valor, la ficha lleva una marca visible con el motivo — nunca se esconde** | **Teléfono** para crear, escritorio para aprobar/pagar | Proveedor nuevo si aplica | — | No, nunca | **Sí — §5** |
| 21 | Bandeja de aprobación | `requisicion` | Aprueba: coordinación, finanzas, según transición | Tabla | Escritorio | — | "sin pendientes" | No | No aplica |
| 22 | Recepción de trabajo | `entrega`, `carta_entrega` | Edita: quien recibe · Firma: quien entrega y quien recibe | Formulario | **Teléfono** | — | — | Sí la carta entrega resultante; no la captura | **Sí — §5** |

### 10.6 Dinero (6)

| # | Pantalla | Entidad(es) | Ve / edita / aprueba | Patrón | Caso | Crea en línea | Vacío | Cliente |
|---|---|---|---|---|---|---|---|---|
| 23 | Movimientos | `movimiento`, `movimiento_concepto` | Edita: administración de finanzas | Tabla | Escritorio | — | §6 | No |
| 24 | Cobranza y parcialidades | `tramo_cobranza`, `abono` | Edita: finanzas · Ve: dirección | Tabla + Ficha | Escritorio | — | "autoriza el presupuesto primero" | Sí el estado de cuenta derivado; no la pantalla interna |
| 25 | Proveedores | `proveedor` | Edita: finanzas, coordinación | Tabla | Escritorio | Alta directa | 71 ya migrados | No |
| 26 | Estado financiero cliente | `v_estado_financiero_cliente` | Ve: dirección, finanzas | Tabla jerárquica | Escritorio | — | "sin presupuesto autorizado" | **Sí** — diseñada sin costo, utilidad ni proveedor desde el origen |
| 27 | Estado financiero operativo | `v_estado_financiero_operativo` | Ve: dirección, finanzas | Tabla | Escritorio | — | §6 | **No, nunca** |
| 28 | Rentabilidad | derivada de compromiso/movimiento | Ve: dirección | Ficha/Tabla resumen | Escritorio | — | §6 | **No, nunca** |

### 10.7 Ajustes del sistema y de la empresa (3)

| # | Pantalla | Entidad(es) | Ve / edita / aprueba | Patrón | Caso | Crea en línea | Vacío | Cliente |
|---|---|---|---|---|---|---|---|---|
| 29 | Administración de empresas | `empresa`, `grupo_empresa` | Edita: administrador de la aplicación | Formulario | Escritorio | — | Dravya y TAAW ya existen | No |
| 30 | Preferencias del usuario | `usuario` | Edita: cada usuario, las suyas | Formulario | Responsive, no es "primero" de ninguno — es personal | — | Valores por omisión | No aplica |
| 31 | Integraciones | config. de empresa | Edita: administrador de la aplicación, único | Formulario | Escritorio | — | §6 | No |

---

## 11. Las tres pantallas de la junta

**Aprobadas por Stefanno el 9-ago-2026. Se programan tal cual.**

**Compartido por las tres, per la rebanada 9 del plan:** una línea de tiempo de eventos
recientes del proyecto, con actualización en vivo. Es lo que permite que los tres abran
su pantalla en la misma junta y vean que lo que uno mueve aparece en la del otro.

### 32 · Dirección de proyecto (Sergio)

| Indicador | Por qué éste y no otro |
|---|---|
| Avance ponderado de obra | Es la pregunta que dirección hace primero: ¿vamos bien? |
| Desviación programa contra real | El avance solo no dice si se está tarde. La desviación sí |
| Alertas críticas abiertas | Dirección necesita saber qué requiere su atención, no cada alerta menor |
| Hitos del proyecto y su fecha | La carátula ya los tiene; mostrarlos aquí evita abrir el documento |
| Documentos pendientes de `S3 → A5` | Dirección aprueba etapas documentales — `V10-ARQUITECTURA` §4. Este es su trabajo pendiente, no un dato de contexto |

### 33 · Finanzas (Fernanda)

| Indicador | Por qué éste y no otro |
|---|---|
| Posición financiera consolidada — cobrado, por cobrar, gastado, caja | Los cuatro campos de `v_posicion_financiera`, la pregunta que finanzas hace primero |
| Requisiciones pendientes de pago | Es la acción que finanzas ejecuta desde esta pantalla, no sólo información |
| Tramos de cobranza vigentes y su semana de corte | Le dice qué cobrar y cuándo, sin tener que abrir cada proyecto |
| Proveedores con saldo por vencer | Anticipa el problema antes de que sea una llamada de cobranza |
| Rentabilidad por proyecto | Es lo que Fernanda reporta hacia arriba; tenerlo aquí evita construirlo a mano cada vez |

### 34 · Control de obra (Stefanno / Residencia)

| Indicador | Por qué éste y no otro |
|---|---|
| Conceptos sin tarjeta, resumen | No bloquea nada —regla 3—, pero residencia decide cuándo vale la pena construir una |
| Presupuesto activo y su estado de autorización | Sin esto no hay de dónde sacar cronograma ni requisiciones |
| Cronograma vivo contra plan, con semáforo | Es la vista operativa diaria de quien construye |
| Bitácora reciente | Los últimos eventos, sin tener que entrar a la línea de tiempo completa |
| Requisiciones en curso, por estado | Residencia necesita saber qué está atorado y en qué paso |

---

## 12. Qué quedó fuera

| # | Quedó fuera | Por qué |
|---|---|---|
| 1 | El layout exacto —espaciado, tipografía aplicada— de cada pantalla | Sale de los cuatro patrones ya cerrados en `V10-DISENO`, se resuelve al construir |
| 2 | La superficie de API que sirve a estas 34 pantallas | Es [[V10-API]], el documento siguiente |
| 3 | ~~Los indicadores de las tres pantallas de junta~~ | **Ya no falta — aprobados por Stefanno el 9-ago-2026.** Se programan tal como quedaron en la sección 11 |
| 4 | El umbral exacto de "demasiado tiempo en cola" (propuse treinta minutos) | Es un parámetro de configuración, no una decisión de arquitectura; se calibra con uso real |
| 5 | Pantallas de autenticación y recuperación de sesión | Son genéricas de `V10-ARQUITECTURA` §1, no aportan una ficha distinta de las de cualquier aplicación con Auth.js |
| 6 | El detalle de qué se muestra en el "detalle de la cola" al tocar el indicador | Es diseño visual de un componente, no arquitectura de pantalla |

---

*Documento 7 de 8. El siguiente es [[V10-API]].*
