# TAAW V10 · CONCEPTUALIZACIÓN · PARA QUÉ ES LA APP

**R01 · 7-ago-2026**

Primer documento del desarrollo. Antes de cualquier esquema, pantalla o línea de código.
Su función es doble: decir para qué existe la app, y **dar el argumento para decir que no**
cuando aparezca una idea buena pero fuera de alcance.

Método: el mismo de un proyecto arquitectónico —
**conceptualización → anteproyecto → proyecto → ejecución.**

---

## 1. El problema real

Dravya son tres personas cubriendo ocho roles. Un proyecto pasa por proyecto arquitectónico,
ejecutivo, estructural y ejecución de obra, con las etapas traslapadas entre sí. En ese
recorrido se genera dinero que entra, dinero que sale, trabajos que avanzan y documentos
que hay que emitir.

Hoy todo eso vive en la cabeza de una persona y en hojas de cálculo que esa persona tiene
que manejar en vivo frente a los demás.

Tres consecuencias medibles:

**La junta ejecutiva depende de un operador.** Nadie puede consultar un número sin que
alguien mueva una tabla y espere a que salga la fórmula.

**La utilidad real es desconocida.** Lo que se cobra trae 20% de utilidad sobre el
presupuesto. Lo que de verdad se gana es ese 20% **más lo que se negocie con cada proveedor**.
Ese ahorro hoy es invisible porque ningún gasto está amarrado a un concepto. Se gana o se
pierde dinero sin saber dónde.

**Documentar cuesta un trabajo aparte.** Presupuesto, estimación, requisición, recibo,
reporte fotográfico, estado de cuenta. Cada uno se arma a mano aunque los datos ya existan.

---

## 2. Para qué es la V10

> **Para que la información que ya se genera operando un proyecto se convierta sola
> en decisiones, documentos y utilidad medida.**

Tres frases que la definen:

**Una sola verdad, tres lecturas.** Fernanda abre finanzas, Sergio abre dirección de
proyecto, Stefanno abre control de obra y mueve el cronograma. Los tres ven la misma base
de datos desde su ángulo, y el movimiento de uno se refleja en la pantalla de los otros.

**Cada peso amarrado a un concepto.** Todo gasto nace de una requisición, toda requisición
apunta a uno o más conceptos del presupuesto. Así el ahorro con proveedores deja de ser
intuición y se vuelve un número.

**Documentar es un efecto secundario, no una tarea.** Si el residente registró el evento
con fotos, el reporte fotográfico ya existe. Si la requisición llegó a entregada, la carta
entrega ya existe.

---

## 3. Quién la usa

| ROL | QUIÉN | QUÉ HACE EN LA APP |
|---|---|---|
| Dirección de proyecto | Arq. Sergio | Tablero de dirección: avance, desviación, riesgos, hitos |
| Finanzas y compras | Fernanda | Requisiciones, pagos, proveedores, estado financiero operativo |
| Residencia y control | Stefanno | Presupuesto, cronograma, control de obra, bitácora |
| Supervisor de obra | campo | Levanta y valida requisiciones, registra eventos con fotos |
| Cliente | Felipe y siguientes | Recibe documentos. No entra a la app |

Una persona cubre varios roles. **El permiso va por rol, no por persona.**

---

## 4. Los cinco ciclos que la app gobierna

Todo lo que hace la V10 cae en uno de estos cinco. Si algo no cabe aquí, no entra.

**Ciclo 1 · Cotizar.** Catálogo de conceptos → tarjetas de precios unitarios sobre un
catálogo de insumos → presupuesto modular con opciones. Cambia el precio de la varilla,
cascadea a todos los conceptos que la usan.

**Ciclo 2 · Planear.** El presupuesto se reparte en el cronograma. Del cronograma sale el
flujo semanal, y del flujo salen los tramos de cobranza: el 60% no vence en una fecha,
**cubre el bloque de semanas donde el avance acumulado llega al 60%**.

**Ciclo 3 · Gastar.** Requisición → cotización → aprobación → pago → entrega → carta entrega.
Con abonos parciales, porque nadie paga completo de una vez. Cada cambio de estado dispara
una alerta.

**Ciclo 4 · Cobrar.** Los tres tramos reciben parcialidades. El cliente casi nunca paga el
tramo entero de un jalón. El tramo sólo se cierra cuando el saldo llega a cero.

**Ciclo 5 · Documentar.** Cada entidad emite uno o varios PDF. La bitácora es la navaja
suiza: desde ahí se levanta una requisición, se registra un evento, se suben fotos, se
capturan comprobantes. La bitácora es la mano que escribe; el cronograma es la vista de
calendario de lo que esa mano escribió.

El detalle completo de los ciclos 2 a 5 vive en
`V10-REQ-CicloDeObra-Cobranza-Bitacora-R01.md`.

---

## 5. Lo que la V10 NO es

Esto pesa tanto como lo anterior. **Es la lista que mató a la V8 y a la V9:** el alcance
crecía mientras el esquema se movía debajo.

| NO es | Por qué |
|---|---|
| Un ERP | No administra la empresa, administra proyectos |
| Contabilidad fiscal ni facturación | Eso lo lleva el contador. La app lleva el libro operativo |
| SaaS multiempresa | Es para Dravya. Si algún día se vende, se decide entonces |
| Modelador ni visor BIM | De BIM se adopta la nomenclatura documental, nada más |
| CRM ni herramienta de ventas | No persigue clientes |
| Gestor de tareas o proyectos genérico | No compite con Asana ni con Notion |

**Regla de admisión:** si una función no sirve para cotizar, planear, gastar, cobrar o
documentar un proyecto de Dravya, no entra a la V10. Se anota y se decide después.

---

## 6. Criterios de éxito

**Propuestos. Falta que Stefanno confirme cuál pesa más.**

| # | Criterio | Cómo se mide |
|---|---|---|
| 1 | Cotizar un proyecto completo sin abrir Excel | Un presupuesto entregado al cliente generado 100% desde la app |
| 2 | La junta corre sin operador | Los tres consultan sus pantallas sin que nadie mueva una tabla |
| 3 | Cerrar una obra sabiendo la utilidad real | Utilidad presupuestada vs. utilidad asimilada, con el ahorro identificado por proveedor |
| 4 | Subir un precio de material y que cascadee | Un cambio en insumos actualiza todos los conceptos afectados sin tocarlos |
| 5 | Emitir cualquier documento en un clic | Los nueve documentos del catálogo salen sin captura adicional |

---

## 7. El plan

### Etapa 1 · Conceptualización — este documento

Para qué existe, quién la usa, qué no hará, cómo se mide el éxito.
**Salida:** este archivo. **Estado:** entregado, pendiente de confirmar los criterios.

### Etapa 2 · Anteproyecto — el modelo de dominio

Aquí se hace la mezcla: se leen los artefactos de la V8 (`ESQUEMA_BASE_DE_DATOS.md`,
`FLUJO_COTIZACION_REQUISICION_PAGO.md`, `ESPEC_MODULO_TPU.md`, `FORMULA_CANONICA_TPU.md`,
`DIAGNOSTICO_BASE_DE_DATOS.md`), lo que la V9 resolvió mejor, y lo aprendido operando el
Excel del proyecto F-19.

**Salidas:**
- Entidades, relaciones y máquinas de estado
- Las reglas que no se pueden romper: clave única, abonos contra compromiso, ningún avance
  al 100% sin carta entrega, todo gasto ligado a concepto
- Esquema SQL
- Decisión de plataforma y base de datos

**Regla dura:** al cerrar el anteproyecto, **el modelo de dominio se congela.** De ahí en
adelante se agregan funciones, nunca se cambia el esquema. Ese es el mecanismo que impide
que la app se vuelva a caer.

### Etapa 3 · Proyecto ejecutivo

Pantallas y flujos por rol, catálogo de documentos, superficie de API, permisos.
Con este documento un agente puede programar sin adivinar.

### Etapa 4 · Ejecución

Fuera del chat, en Claude Code u opencode. En **rebanadas verticales**: cada una atraviesa
base de datos, lógica y pantalla, y cada una sirve sola.

| # | Rebanada | Por qué en ese lugar |
|---|---|---|
| 1 | Catálogo de conceptos, insumos y tarjetas | Es lo que se hace todos los días |
| 2 | Presupuesto modular con opciones | Sustituye el Excel de F-19 |
| 3 | Requisición → pago → entrega, con abonos | Aquí aparece el dinero real |
| 4 | Cronograma, flujo semanal y control de obra | Ya con dinero corriendo tiene sentido |
| 5 | Bitácora y línea de tiempo | Alimenta a todas las anteriores |
| 6 | Las tres pantallas de la junta | El objetivo original |
| 7 | Generación de documentos | Sale de lo ya capturado |

Cada rebanada se entrega funcionando. La V8 y la V9 quedan de respaldo hasta que la
rebanada 2 esté en producción.

---

## 8. Decisiones pendientes

| # | Decisión | De quién |
|---|---|---|
| 1 | Cuál de los cinco criterios de éxito pesa más | Stefanno |
| 2 | ¿Se migra de Google Sheets? ¿A qué? | Stefanno, con propuesta mía en el anteproyecto |
| 3 | ¿Cronograma y bitácora son una entidad con dos vistas o dos ligadas? | Anteproyecto |
| 4 | Catálogo definitivo de categorías de gasto | Stefanno |
| 5 | Autorizadores de cada transición de estado documental | Stefanno |
| 6 | ¿La app y el Excel conviven un tiempo o hay corte? | Stefanno |

---

*Etapa 1 de 4. No se avanza al anteproyecto hasta que este documento esté aprobado.*
