# TAAW V10 · REQUISITOS · CICLO DE OBRA, COBRANZA Y BITÁCORA

**R01 · 7-ago-2026 · insumo para el desarrollo de la app V10 desde cero.**

Dictado de Stefanno. Describe cómo opera realmente un proyecto de Dravya: cómo se cobra,
cómo se paga, cómo se cierra un trabajo y cómo se documenta todo.

**Esto NO es material del sitio informativo DRAVYABIM.** Aquí vive el requisito funcional
de la app. Mientras la V10 no exista, lo que se pueda se opera en hoja de cálculo.

---

## 1. El principio que reordena todo

Los porcentajes de cobranza **no son fechas, son tramos del cronograma**.

El 60% no vence "en la semana 2": cubre **el bloque de semanas cuyo avance programado
acumulado llega al 60% del presupuesto**. Igual el 20% siguiente y el 20% de cierre.

Consecuencia directa: si el cronograma se mueve, los bloques de cobranza se mueven solos.
No se capturan a mano.

```
CRONOGRAMA (fechas por concepto)
        ↓
FLUJO SEMANAL (importe repartido por semana)
        ↓
% ACUMULADO POR SEMANA
        ↓
BLOQUE DE COBRANZA  →  ANTICIPO | SEGUNDO PAGO | FINIQUITO
        ↓
CARÁTULA (monto y semana de corte de cada pago)
```

---

## 2. Carátula rediseñada

### 2.1 Bloque nuevo · ESQUEMA DE COBRANZA

Sustituye a los dos renglones sueltos de anticipo y finiquito.

| # | PAGO | % | MONTO | SEMANA CORTE | FECHA PROGRAMADA | ESTADO | FECHA REAL | FOLIO MOVIMIENTO |
|---|---|---|---|---|---|---|---|---|
| 1 | Anticipo de obra | 60% | fórmula | fórmula | fórmula | Pendiente | captura | captura |
| 2 | Segundo pago | 20% | fórmula | fórmula | fórmula | Pendiente | captura | captura |
| 3 | Finiquito | 20% | fórmula | fórmula | fórmula | Pendiente | captura | captura |

- **%** se captura. Validación: la suma debe dar exactamente 100%.
- **MONTO** = `TOTAL × %`
- **SEMANA CORTE** = primera semana en que el acumulado programado alcanza el % acumulado
  de ese pago. Sale de FLUJO SEMANAL, no se escribe.
- **FECHA PROGRAMADA** = fecha de inicio de obra + (semana corte × 7)
- **ESTADO** = Pendiente · Solicitado · Cobrado
- **FECHA REAL** y **FOLIO MOVIMIENTO** los captura administración cuando entra el dinero.

Alertas: si FECHA REAL rebasa FECHA PROGRAMADA, semáforo en rojo. Si el avance real
rebasó la semana de corte y el pago sigue Pendiente, alerta de **obra financiada por nosotros**.

### 2.2 Bloque nuevo · HITOS DEL PROYECTO

La obra no empieza en cero: viene arrastrando etapas ya cobradas. La carátula debe mostrarlo.

| HITO | ETAPA BIM | MONTO | ESTADO | FECHA |
|---|---|---|---|---|
| Anticipo de proyecto arquitectónico | AP | | Cobrado | |
| Finiquito arquitectónico + parciales de ejecutivo y estructural | PE | | Cobrado | |
| **Anticipo de obra** | **OB** | | **Pendiente ← hito actual** | |
| Segundo pago de obra | OB | | Pendiente | |
| Finiquito de obra | OB | | Pendiente | |
| Cierre y entrega | AS | | Pendiente | |

Campo nuevo en datos generales: **ETAPA BIM ACTUAL** con lista `AP · PE · OB · AS`,
tomada de la norma de nomenclatura. Es la que define el campo 3 de todos los folios
que emite el libro.

### 2.3 Roles · ampliar

El flujo de requisición necesita cuatro firmas que hoy no existen en la carátula:

| ROL | QUIÉN | QUÉ AUTORIZA |
|---|---|---|
| Residente de obra | | Levanta la requisición |
| Supervisor de obra | | Valida la requisición (se validan entre sí) |
| Coordinador de proyectos | | Solicitada → Aprobada |
| Gerente administrativo / Administrador de finanzas | | Aprobada → Pagada |

### 2.4 Bloque nuevo · POSICIÓN FINANCIERA

Cuatro números que hoy no están en ningún lado:

- **COBRADO A LA FECHA** — suma de movimientos de ingreso
- **POR COBRAR** — total menos cobrado
- **GASTADO A LA FECHA** — suma de egresos
- **CAJA DEL PROYECTO** — cobrado menos gastado

Este último es el que dice si la obra se está autofinanciando o si la estás pagando tú.

### 2.5 Lo que ya quedó decidido

- Los módulos se muestran al cliente **sin número**, sólo el nombre. La clave `M1`…`M7`
  vive en la columna N, interna, y sostiene la comparación entre las tres opciones.
- El **% IVA puede ir en 0** y es una decisión de negocio, no un error. Si va en 0,
  las notas deben decir explícitamente que el precio no incluye IVA.
- Precio por m² validado contra C256. El match es correcto, los precios se quedan.

### 2.6 Parcialidades · el pago es un proceso, no un evento

**Nadie paga completo de una sola vez, ni el cliente a nosotros ni nosotros al maestro.**
El tramo de cobranza es un compromiso; las parcialidades son la realidad.

**Del cliente hacia nosotros.** Cada tramo (60 / 20 / 20) recibe abonos parciales.
Se registran con fecha, monto, a qué tramo se aplican, forma de pago y folio de movimiento.
El tramo muestra **cobrado** y **saldo**, y sólo se cierra cuando el saldo llega a cero.

**De nosotros hacia el proveedor.** Igual. La cotización queda registrada en la requisición
por su monto total, pero se abona en el tiempo. La requisición muestra **pagado** y **saldo**.

Consecuencia de diseño: **ni la cobranza ni el pago pueden modelarse como un campo.**
Son una tabla de abonos contra un compromiso. En la app, tabla `abonos` ligada tanto a
`cobranza` como a `requisicion`.

### 2.7 Carta entrega · lo que sella un estado

Un trabajo no está terminado porque alguien lo diga. Está terminado cuando existe
**carta entrega firmada**.

| NIVEL | DOCUMENTO | QUÉ SELLA |
|---|---|---|
| Trabajo o requisición | **Carta entrega de trabajo** | El estado ENTREGADA de esa requisición |
| Obra | **Carta entrega de obra** | El finiquito y el fin de la ejecución |
| Proyecto | **Carta entrega de proyecto** | El cierre de la etapa de proyecto |

Reglas:

- Ningún concepto pasa a 100% de avance en el cronograma sin carta entrega del trabajo
  que lo produjo.
- La carta entrega parcial existe y deja el trabajo en **PARCIAL ENTREGADO**, con alerta
  de seguimiento viva hasta que se cierre.
- La carta entrega es el documento que permite **asimilar la utilidad** de ese concepto:
  antes de firmarla, la ganancia es estimada; después, es real.

---

## 3. Flujo semanal · fila de bloques de cobranza

Al pie de FLUJO SEMANAL, tres filas nuevas:

```
% ACUMULADO      = acumulado programado de la semana / total del presupuesto
BLOQUE           = IF(%acum<=%anticipo,"ANTICIPO",
                     IF(%acum<=%anticipo+%segundo,"SEGUNDO PAGO","FINIQUITO"))
COBRANZA         = el monto del pago, sólo en la última columna de su bloque
```

Con formato condicional de tres colores sobre la fila BLOQUE se ve de un golpe qué grupo
de columnas cubre cada pago. Es exactamente el requerimiento: *ver el rango de columnas
semanales que cubre cada abono*.

**Fila adicional de valor real:** `DESFASE DE CAJA` = cobrado acumulado − gastado acumulado,
semana por semana. Es la curva que avisa antes de quedarse sin dinero.

---

## 4. Dos estados financieros gemelos

Misma información, dos lecturas. Uno se entrega, el otro no sale de la empresa.

### 4.1 ESTADO FINANCIERO · CLIENTE  (pestaña azul)

Responde una sola pregunta: **en qué se ha gastado tu dinero**.

Jerarquía desplegable: **MÓDULO → PARTIDA → CONCEPTO**

| columna | contenido |
|---|---|
| CONTRATADO | importe del presupuesto |
| % AVANCE | de control de obra |
| EJECUTADO | contratado × avance |
| COBRADO | ingresos aplicados a ese módulo |
| POR EJECUTAR | contratado − ejecutado |

Nunca muestra costo directo, utilidad ni proveedores.

### 4.2 ESTADO FINANCIERO · OPERATIVO  (pestaña roja)

Responde: **cuánto nos costó de verdad y dónde ganamos**.

| columna | contenido |
|---|---|
| CATEGORÍA | material · mano de obra · nómina · renta de equipo · subcontrato · viáticos · combustible · trámites · indirectos |
| GASTO REAL | de movimientos, ligado a concepto |
| COSTO PRESUPUESTADO | de la tarjeta de precios unitarios |
| AHORRO / SOBRECOSTO | presupuestado − real |
| UTILIDAD ASIMILADA | utilidad del presupuesto + ahorro conseguido |

**Aquí está el punto que más valor tiene:** la utilidad real no es sólo el % del presupuesto.
Es ese % **más lo que se negocie con proveedores**. Ese ahorro sólo se ve si cada gasto
está ligado a uno o varios conceptos. Sin esa liga, el ahorro es invisible y se diluye.

---

## 5. Requisición · máquina de estados

Es el documento que conecta la obra con el dinero. Toda salida de dinero nace aquí.

```
SOLICITADA          residente + supervisor la levantan y se validan entre sí
     ↓
APROBADA            coordinador de proyectos
     ↓
PAGADA              administrador de finanzas · admite ABONOS PARCIALES
     ↓                 el estado no avanza hasta que el saldo llega a cero
POR ENTREGAR        el proveedor debe entregar
     ↓
PARCIAL ENTREGADO   ← alerta de seguimiento viva hasta el cierre
     ↓
ENTREGADA           ← exige CARTA ENTREGA DE TRABAJO firmada
```

Reglas:

- Toda requisición va ligada a **una cotización**. Si el proveedor no cotiza —el maestro
  albañil de palabra o de libreta— **la requisición se convierte en la cotización**
  y debe traer el desglose completo.
- Toda requisición va ligada a **uno o más conceptos del presupuesto**. Sin esa liga
  no se puede aprobar.
- La requisición declara **forma de pago**: efectivo o transferencia, con los datos
  necesarios para ejecutarlo.
- **Cada cambio de estado genera una alerta.** Sin excepción.
- Al llegar a ENTREGADA, el o los conceptos ligados actualizan su estado en el cronograma.

---

## 6. Bitácora · la navaja suiza

La bitácora es **la mano que escribe los eventos**. Casi todo lo que pasa en el proyecto
entra por ahí, y algunas cosas sólo existen ahí.

Desde bitácora se puede:

- Levantar una requisición o una cotización
- Registrar un evento con fotografías
- Registrar una anomalía
- Reportar trabajos ejecutados
- Captar documentos: recibos, cotizaciones en PDF, comprobantes
- Emitir recibos de entrada y salida de dinero
- Emitir entradas y salidas de material y herramienta de inventario

**Un solo módulo alimenta muchos documentos.** Ejemplo: las fotos ligadas a trabajos
generan solas el **reporte fotográfico**, en cortes semanal, quincenal, mensual, bimestral
o general de todo el proyecto.

### Relación bitácora ↔ cronograma

No son pestañas separadas. El cronograma es **la vista de calendario de los eventos
de la bitácora**. La bitácora escribe, el cronograma muestra. Pendiente decidir si en la app
se fusionan en una sola entidad con dos vistas.

### Vista de línea de tiempo

Pendiente de diseño: un tablero cronológico de eventos del proyecto, tipo resumen de partida
de estrategia — hitos, micro-hitos, pagos, entregas, anomalías, sobre un eje de tiempo.
Es la vista que cuenta la historia del proyecto de un vistazo.

---

## 7. Documentos que emite cada entidad

Cada entidad genera uno o varios exportables en PDF. Es la razón de ser del sistema:
**documentar todo el desarrollo del proyecto**.

| ENTIDAD | DOCUMENTOS |
|---|---|
| Presupuesto | Presupuesto al cliente · Catálogo de volúmenes sin precios · Explosión de insumos desde las tarjetas (materiales, mano de obra, rentas, indirectos, viáticos) |
| Cronograma | Programa de obra · Programa valorizado |
| Flujo semanal | Flujo de efectivo · Calendario de cobranza |
| Control de obra | Estimación · Avance semanal |
| Requisición | Orden de compra · Orden de trabajo · **Carta entrega de trabajo** |
| Movimientos | Recibo de ingreso · Recibo de egreso · Estado de cuenta de proveedor |
| Cierre | **Carta entrega de obra** · **Carta entrega de proyecto** |
| Bitácora | Bitácora de obra · Reporte fotográfico · Entrada y salida de inventario |
| Estado financiero cliente | Estado de cuenta del cliente |
| Estado financiero operativo | Reporte de utilidad y ahorros |

Todos con folio según la norma de nomenclatura `DRAVYA-NOM-NomenclaturaDocumental-R01`.

---

## 8. Pendientes de decisión

| # | Pendiente |
|---|---|
| 1 | ¿Cronograma y bitácora son una entidad con dos vistas o dos entidades ligadas? |
| 2 | ¿La semana de corte de cada pago se calcula sola o se puede forzar a mano? |
| 3 | ¿El estado financiero del cliente se entrega en cada corte o sólo a solicitud? |
| 4 | Catálogo de categorías de gasto — cerrar la lista definitiva |
| 5 | Diseño de la vista de línea de tiempo |
| 6 | Cotización de closets `CAR09183` — si no llega, se estima |

---

*Norma interna de Dravya. La herramienta que la ejecuta es TAAW.*
