# TAAW V10 · CONCEPTUALIZACIÓN · PARA QUÉ ES LA APP

**R02 · 7-ago-2026**

> **Corrección sobre R01.** La versión anterior organizaba la app alrededor del dinero.
> Estaba mal. TAAW es una **plataforma de control de proyecto para un despacho de
> arquitectura que además construye.** Controla el proyecto de principio a fin —diseño,
> cálculo, cuantificación, costo, programa, obra y documentación— y el dinero es **una
> de las cosas que controla, no el motivo por el que existe.**

Escrito después de leer el código de la V8 (`src/app/(app)`, 60 pantallas), el esquema
real de la base (`.agents/context/ESQUEMA_BASE_DE_DATOS.md`, 59 pestañas) y el dictado
de objetivos (`.agents/MUCHO TRABAJO.MD`).

---

## 1. Qué es TAAW

**El expediente vivo de un proyecto de arquitectura y construcción.**

Un proyecto de Dravya recorre anteproyecto, proyecto arquitectónico, ejecutivo, estructural
y ejecución de obra, con las etapas traslapadas. En ese recorrido se calcula, se cuantifica,
se cotiza, se programa, se construye, se paga y se documenta.

Hoy eso vive repartido entre la cabeza de una persona, hojas de cálculo, PDFs sueltos y
una libreta de campo. TAAW es donde todo eso vive junto y se alimenta entre sí.

**El criterio de valor:** un dato se captura **una vez** y sirve en todos lados. La salida
eléctrica que el ingeniero cuantificó es el concepto que se presupuesta, es la actividad
que se programa, es el trabajo que se recibe, es el renglón que se paga y es la línea del
reporte fotográfico.

---

## 2. Los siete dominios

Todo lo que hace TAAW cae en uno de estos siete. Si algo no cabe aquí, no entra a la V10.

### 2.1 Catálogo técnico — el corazón

Conceptos de obra con su **tarjeta de precio unitario**: materiales, mano de obra,
herramienta, herramienta menor, indirectos, subcontratos. Más el catálogo de partidas.

Hoy: **877 conceptos** en `conceptos_globales`, 72 materiales, 122 herramientas,
47 partidas. Es el activo más valioso de la empresa y el que se reutiliza proyecto
tras proyecto.

Lo que resuelve: sube la varilla de 3/8" y cambia sola en todos los conceptos que la usan.

### 2.2 Cálculo de ingeniería

Cargas eléctricas, alimentadores, factor de potencia, cortocircuito, protecciones,
salidas eléctricas. Ya existe como módulo completo en la V8 y **no es un accesorio**:
es la parte que convierte a TAAW en herramienta de arquitecto, no en software de oficina.

De aquí salen cantidades que alimentan el catálogo y el presupuesto directamente.

### 2.3 Proyecto y cliente

Datos del proyecto, cliente, colaboradores, zonas, etapa BIM vigente, revisión,
folio documental según ISO 19650. Es el marco al que todo lo demás se cuelga.

### 2.4 Cuantificación y presupuesto

Generadores de volumen → conceptos con cantidad → presupuesto por módulos, con opciones
comparables para que el cliente elija.

Y lo que pediste explícitamente y hoy no existe: **exportables selectivos del presupuesto.**
El mismo presupuesto exporta la versión al cliente, la de sólo volúmenes, la de sólo mano
de obra, la de sólo materiales, o una lista de compras — según lo que traiga cada tarjeta
de precio unitario.

### 2.5 Programa y control de obra

Cronograma planeado, cronograma vivo, reparto semanal, avance real, desviación.
El programa se planea completo antes de arrancar y **se actualiza contra obra real**
durante la ejecución.

### 2.6 Operación en obra

Bitácora, requisiciones, cotizaciones, entregas, inventario de material y herramienta,
destajos, raya semanal, viáticos.

**La bitácora es la navaja suiza:** desde ahí se levanta una requisición, se registra un
evento, se suben fotos, se capturan comprobantes. La bitácora es la mano que escribe;
el cronograma es la vista de calendario de lo que esa mano escribió.

### 2.7 Dinero — consecuencia, no eje

Finanzas, recibos, pagos programados, anticipos, amortización, rentabilidad.
Incluye la cobranza del cliente por tramos y las parcialidades en ambas direcciones.

**Está al final de la lista a propósito.** El dinero es el resultado de controlar bien
el proyecto. Cuando cada gasto está amarrado a un concepto, la utilidad real —la del
presupuesto **más** lo que se negocie con proveedores— deja de ser intuición.

### Y atravesando los siete: documentación

Cada dominio emite documentos en PDF con folio ISO 19650. Documentar no es una tarea
aparte: es una salida de lo que ya se capturó operando.

---

## 3. Quién la usa

| ROL | QUIÉN | SU PANTALLA |
|---|---|---|
| Dirección de proyecto | Arq. Sergio | Avance, desviación, riesgos, hitos |
| Finanzas y compras | Fernanda | Requisiciones, pagos, proveedores, rentabilidad |
| Residencia y control | Stefanno | Catálogo, presupuesto, cronograma, control de obra |
| Supervisión en campo | campo | Bitácora, requisiciones, fotos, recepción de trabajos |
| Cliente | Felipe y los que siguen | Recibe documentos. No entra a la app |

Tres personas cubren ocho roles. **El permiso va por rol, no por persona.**

En junta ejecutiva los tres abren su pantalla y ven la misma base desde su ángulo.
Lo que uno mueve aparece en la del otro. Nadie espera a que alguien maneje una tabla.

---

## 4. Lo que la V10 NO es

Es la lista que evita repetir lo que pasó con la V8 y la V9: el alcance crecía mientras
el esquema se movía debajo.

| NO es | Por qué |
|---|---|
| Un ERP | Administra proyectos, no la empresa |
| Contabilidad ni facturación fiscal | Eso lo lleva el contador. TAAW lleva el libro operativo |
| SaaS multiempresa | Es para Dravya. Si algún día se vende, se decide entonces |
| Modelador ni visor BIM | De BIM se adopta la nomenclatura documental. Nada más |
| CRM ni herramienta de ventas | No persigue clientes |
| Gestor de tareas genérico | No compite con Asana ni con Notion |

**Regla de admisión:** si una función no pertenece a uno de los siete dominios, no entra.
Se anota y se decide después.

---

## 5. Por qué la V8 y la V9 se volvieron frágiles

No fue el código. Fue el dato. Lo dice el propio diagnóstico de la V8:

- **877 conceptos con 40 formatos de ID distintos.** No hay clave única real.
- **28 de 59 pestañas vacías.** Se creó estructura antes de saber qué iba adentro.
- Pestañas muertas y de respaldo mezcladas con las de producción.
- Precios con IVA incluido en unas tablas y sin IVA en otras.
- Columnas cuyo significado cambia según el renglón.
- Google Sheets no puede rechazar un dato inválido. Acepta todo y falla después.

**Diagnóstico:** el problema no es que falten funciones. Es que **no hay integridad
referencial**. Sin eso, cada función nueva es una oportunidad más de corromper el dato.

De ahí sale la regla dura de la V10, en la sección 6.

---

## 6. Cómo se construye la V10

### La regla que lo sostiene todo

**Al cerrar el anteproyecto, el modelo de dominio se congela.** De ahí en adelante se
agregan funciones, nunca se cambia el esquema. Cada rebanada nueva es aditiva y no puede
tocar lo que ya funciona.

Eso es exactamente lo que pediste: *cosas que se agreguen de manera modulada sin que la
dañen o la confundan.*

### Etapa 1 · Conceptualización — este documento

Qué es, quién la usa, qué no será.
**Estado:** entregado. Falta que Stefanno lo apruebe.

### Etapa 2 · Anteproyecto — el modelo de dominio

La mezcla que pediste: lo que sirve de la V8, lo que la V9 resolvió mejor, el esquema real
de Sheets con sus 59 pestañas y sus anomalías, y lo aprendido operando el Excel de F-19.

**Salidas:**
- Entidades, relaciones y máquinas de estado de los siete dominios
- Las reglas que no se pueden romper: clave única de concepto, todo gasto ligado a concepto,
  abonos contra compromiso, ningún avance al 100% sin carta entrega
- Esquema SQL con integridad referencial real
- Plan de migración de los 877 conceptos, con normalización de los 40 formatos de ID
- Decisión de plataforma y base de datos

### Etapa 3 · Proyecto ejecutivo

Pantallas y flujos por rol, catálogo de documentos exportables, superficie de API, permisos.
Con este documento un agente programa sin adivinar.

### Etapa 4 · Ejecución

Fuera del chat, en Claude Code u opencode, en **rebanadas verticales**: cada una atraviesa
base, lógica y pantalla, y cada una sirve sola.

| # | Rebanada | Por qué en ese lugar |
|---|---|---|
| 1 | Catálogo técnico y tarjetas de precios unitarios | Es el activo de la empresa y hoy está corrupto |
| 2 | Presupuesto con módulos, opciones y exportables selectivos | Sustituye el Excel de F-19 |
| 3 | Proyecto, cliente, folios y documentación | El marco de todo lo demás |
| 4 | Bitácora, requisiciones y entregas | La operación diaria de obra |
| 5 | Cronograma, flujo y control de obra | Ya con obra corriendo tiene sentido |
| 6 | Dinero: movimientos, cobranza, rentabilidad | Se alimenta de las cuatro anteriores |
| 7 | Módulo de cálculo eléctrico | Se migra tal cual de la V8 si funciona |
| 8 | Las tres pantallas de la junta | El objetivo original |

La V8 y la V9 quedan de respaldo hasta que la rebanada 2 esté en producción.

---

## 7. Decisiones resueltas

**Stefanno aprobó este documento y resolvió las seis. 7-ago-2026.**

| # | Decisión | Resolución |
|---|---|---|
| 1 | Señal de que la V10 sirvió | **Poder cotizar y presupuestar desde la app, y que la utilidad sea visible desde ese momento.** No al final de la obra: desde que se cotiza |
| 2 | Migración de Google Sheets | Se migra. Propuesta de plataforma a cargo de Claude, con **una condición dura: costo cero**. Servidor propio o servicio en línea gratuito |
| 3 | Módulo de cálculo eléctrico | **Se rehace desde cero.** Es un módulo de cálculo de cargas basado en circuitos y salidas |
| 4 | Cronograma y bitácora | **Dos entidades ligadas, no una.** La bitácora es la herramienta del agente: cualquier persona que agrega un evento a la línea de tiempo. El cronograma es la visualización de esa línea de tiempo, apoyada en los conceptos del presupuesto |
| 5 | Los 877 conceptos | **Se migran todos** y se depuran sobre la marcha. No se detiene el desarrollo esperando una limpieza previa |
| 6 | Excel y app | **Conviven en paralelo.** Cuando la V10 alcance lo que hoy hace el Excel, se integra al flujo y ambos corren a la par |

### Corrección al orden de construcción

Por la decisión 1, la utilidad debe ser visible **desde la cotización**, no sólo al cierre.
Eso adelanta una parte del dominio de dinero a la rebanada 1: la tarjeta de precio unitario
tiene que separar **costo directo** de **precio de venta** desde el primer día, y el margen
tiene que verse al armar el presupuesto.

Por la decisión 3, el módulo eléctrico pasa de "migrar" a "rehacer", y por eso se queda al
final del orden: no hay nada que rescatar con prisa.

---

*Etapa 1 de 4 · APROBADA. El desglose vive en `V10-PLAN-DE-TRABAJO-R01.md`.*
