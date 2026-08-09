# TAAW V10 · PLAN DE TRABAJO

**R01 · 7-ago-2026 · Etapa 2 de 4 · Anteproyecto**

El manifiesto (`V10-CONCEPTO-ParaQueEsLaApp-R02.md`) dice qué es y para qué.
Este documento dice **cómo se construye**: qué documentos hacen falta, en qué orden se
programa, qué toca cada rebanada y cómo se sabe que quedó.

---

## 1. Mapa de documentos

El manifiesto es el punto de partida. Estos son los documentos que lo completan, en orden
de escritura. Cada uno depende del anterior.

| # | Documento | Qué resuelve | Estado |
|---|---|---|---|
| 0 | `V10-CONCEPTO-ParaQueEsLaApp-R02` | Qué es, para quién, qué no será | **Aprobado** |
| 1 | `V10-PLAN-DE-TRABAJO-R01` | Orden de construcción, rebanadas, criterios de terminado | **Este documento** |
| 2 | `V10-MODELO-DOMINIO` | Entidades, relaciones, máquinas de estado, reglas invariantes | Siguiente |
| 3 | `V10-ESQUEMA-SQL` | Tablas, llaves, restricciones, índices. El esquema que se congela | Depende del 2 |
| 4 | `V10-PLATAFORMA-Y-MIGRACION` | Dónde vive la base, cómo se migran los 877 conceptos | Depende del 3 |
| 5 | `V10-CATALOGO-DOCUMENTOS` | Qué PDF emite cada entidad y con qué folio | Depende del 2 |
| 6 | `V10-PANTALLAS-Y-ROLES` | Pantalla por pantalla, permiso por rol | Depende del 2 y 5 |
| 7 | `V10-API` | Superficie de servicios | Depende del 3 y 6 |
| 8 | `V10-REQ-CicloDeObra-Cobranza-Bitacora-R01` | Requisito funcional del ciclo de obra | **Escrito** |

**Regla:** ningún documento se escribe antes que aquel del que depende. Es la misma
disciplina que evita rehacer planos.

---

## 2. Reglas invariantes

Se definen en el modelo de dominio y **no se tocan después**. Son el mecanismo que impide
que la V10 se degrade como la V8.

| # | Regla | Por qué existe |
|---|---|---|
| 1 | **La clave de concepto es única y con formato fijo.** La base la rechaza si no cumple | Hoy hay 877 conceptos con 40 formatos de ID distintos |
| 2 | **Todo gasto está ligado a uno o más conceptos.** Sin liga no se puede aprobar | Sin esto el ahorro con proveedores es invisible |
| 3 | **Los precios se guardan sin IVA.** El IVA es un parámetro, nunca un valor almacenado | Hoy hay tablas con IVA incluido y otras sin él |
| 4 | **Una columna significa una sola cosa.** Nada de campos polivalentes | Hoy la columna E de materiales cambia de significado según el renglón |
| 5 | **Todo pago es un abono contra un compromiso.** Nunca un campo "pagado sí/no" | Ni el cliente ni nosotros pagamos completo de una vez |
| 6 | **Ningún concepto llega a 100% de avance sin carta entrega** | Es lo que convierte utilidad estimada en utilidad real |
| 7 | **Nada se borra.** Sólo se marca inactivo | Trazabilidad y respaldo ante el cliente |
| 8 | **Todo cambio de estado deja rastro y dispara alerta** | La bitácora es la memoria del proyecto |

**Si una función futura exige romper una de estas ocho, no se hace la función:
se replantea.**

---

## 3. Las ocho rebanadas

Cada rebanada atraviesa base de datos, lógica y pantalla, y **sirve sola** al terminar.
No se construye por capas.

### Rebanada 1 · Catálogo técnico y tarjetas de precios unitarios

**Por qué primero.** Es el activo más valioso de la empresa, es lo que se usa todos los
días, y hoy está corrupto. Y porque la señal de éxito que definiste —ver la utilidad desde
que cotizas— nace aquí.

| | |
|---|---|
| **Entidades** | `insumo`, `concepto`, `tarjeta_pu`, `tarjeta_renglon`, `partida`, `zona` |
| **Pantallas** | Catálogo de insumos · Catálogo de conceptos · Constructor de tarjeta · Buscador de conceptos |
| **Funciones** | Alta y edición de insumos por tipo (material, mano de obra, herramienta, herramienta menor, indirecto, subcontrato) · Armado de tarjeta con rendimiento y desperdicio · Cálculo de costo directo · Aplicación de utilidad · **Cascada: cambia un insumo y se recalculan todos los conceptos que lo usan** |
| **Documentos** | Catálogo de conceptos · Tarjeta de precio unitario · Catálogo de insumos |
| **Terminado cuando** | Se puede subir el precio de la varilla y ver, en una lista, todos los conceptos que cambiaron y en cuánto |

### Rebanada 2 · Presupuesto

**Sustituye el Excel de F-19.** Es la rebanada que libera a Stefanno de la hoja de cálculo.

| | |
|---|---|
| **Entidades** | `presupuesto`, `presupuesto_modulo`, `presupuesto_partida`, `presupuesto_concepto`, `generador` |
| **Pantallas** | Armado de presupuesto · Generadores de volumen · Comparador de opciones · Vista de impresión |
| **Funciones** | Estructura módulo → partida → concepto · Opciones comparables del mismo presupuesto · Crear concepto nuevo sin salir del presupuesto · Volúmenes desde generadores · Vigencia y precio por m² · **Margen visible al armar, nunca en la vista del cliente** |
| **Documentos** | Presupuesto al cliente · Sólo volúmenes · **Exportables selectivos: sólo mano de obra, sólo materiales, lista de compras, indirectos** — según las tarjetas |
| **Terminado cuando** | El presupuesto de F-19 completo se arma en la app y sale en PDF idéntico o mejor que el de la hoja |

### Rebanada 3 · Proyecto, cliente y documentación

| | |
|---|---|
| **Entidades** | `proyecto`, `cliente`, `colaborador`, `rol`, `documento`, `folio` |
| **Pantallas** | Proyectos · Ficha de proyecto · Clientes · Colaboradores y roles · Documentos del proyecto |
| **Funciones** | Etapa BIM vigente · Generación automática de folio ISO 19650 · Versionado y estado documental · Permisos por rol |
| **Documentos** | Carátula de proyecto · Índice documental |
| **Terminado cuando** | Todo PDF que emite la app sale con su folio correcto sin que nadie lo escriba |

### Rebanada 4 · Bitácora, requisiciones y entregas

**El corazón de la operación diaria.**

| | |
|---|---|
| **Entidades** | `evento`, `foto`, `adjunto`, `requisicion`, `requisicion_renglon`, `cotizacion`, `entrega`, `carta_entrega`, `alerta` |
| **Pantallas** | Bitácora (línea de tiempo) · Alta de evento con fotos · Requisición · Bandeja de aprobación · Recepción de trabajo |
| **Funciones** | Máquina de estados completa: solicitada → aprobada → pagada → por entregar → parcial entregado → entregada · Requisición que se convierte en cotización cuando el proveedor no cotiza · Liga obligatoria a concepto · Alerta en cada cambio de estado · Carta entrega que sella |
| **Documentos** | Requisición · Orden de compra · Carta entrega de trabajo · **Reporte fotográfico** semanal, quincenal, mensual, bimestral y general · Entrada y salida de inventario |
| **Terminado cuando** | Una compra real recorre los seis estados desde el teléfono en obra y genera su carta entrega |

### Rebanada 5 · Cronograma, flujo y control de obra

| | |
|---|---|
| **Entidades** | `actividad`, `cronograma_plan`, `cronograma_vivo`, `avance`, `semana` |
| **Pantallas** | Cronograma · Flujo semanal · Control de obra · Comparativo plan contra real |
| **Funciones** | Reparto de conceptos en el tiempo · Cronograma vivo actualizado con obra real · Bloques de cobranza leídos del avance acumulado · Desviación y semáforo · **El cronograma se apoya en la línea de tiempo de la bitácora** |
| **Documentos** | Programa de obra · Programa valorizado · Flujo de efectivo · Estimación · Avance semanal |
| **Terminado cuando** | Mover una actividad recorre los tramos de cobranza y la desviación sin capturar nada más |

### Rebanada 6 · Dinero

| | |
|---|---|
| **Entidades** | `movimiento`, `abono`, `compromiso_cobranza`, `proveedor`, `estado_cuenta`, `nomina`, `viatico` |
| **Pantallas** | Movimientos · Cobranza y parcialidades · Proveedores · Estado financiero cliente · Estado financiero operativo · Rentabilidad |
| **Funciones** | Abonos contra compromiso en ambas direcciones · Gasto ligado a concepto · **Ahorro contra tarjeta = utilidad extra** · Caja del proyecto |
| **Documentos** | Recibo de ingreso · Recibo de egreso · Estado de cuenta de cliente · Estado de cuenta de proveedor · Reporte de utilidad y ahorros |
| **Terminado cuando** | Se puede decir, por concepto, cuánto se presupuestó, cuánto costó y dónde se ganó |

### Rebanada 7 · Cálculo eléctrico

**Se rehace desde cero.** No se migra nada de la V8.

| | |
|---|---|
| **Entidades** | `circuito`, `salida`, `carga`, `alimentador`, `tablero`, `proteccion` |
| **Pantallas** | Cuadro de cargas · Circuitos y salidas · Alimentadores · Protecciones |
| **Funciones** | Cálculo de carga por circuito y por salida · Balanceo de fases · Caída de tensión · Selección de protección · **Las cantidades alimentan conceptos del presupuesto** |
| **Documentos** | Cuadro de cargas · Memoria de cálculo eléctrico |
| **Terminado cuando** | Las salidas eléctricas de F-19 se calculan en la app y sus cantidades entran solas al presupuesto |

### Rebanada 8 · Las tres pantallas de la junta

| | |
|---|---|
| **Pantallas** | Dirección de proyecto (Sergio) · Finanzas (Fernanda) · Control de obra (Stefanno) |
| **Funciones** | Cada rol ve sus indicadores · Actualización en vivo · Línea de tiempo de eventos del proyecto |
| **Terminado cuando** | La junta ejecutiva corre sin que nadie maneje una tabla |

---

## 4. Plataforma · propuesta

**Condición dura: costo cero.**

Propuesta a detallar en `V10-PLATAFORMA-Y-MIGRACION`:

- **Base de datos: PostgreSQL.** Es lo único que da integridad referencial real —llave
  única de concepto, llave foránea de gasto a concepto, transacciones. Es exactamente lo
  que Sheets no puede hacer y lo que quebró a la V8.
- **Hospedaje gratuito:** hay opciones de Postgres administrado sin costo. La que se elija
  debe cumplir dos cosas: **que no se suspenda por inactividad** y que permita respaldo
  descargable. Se compara y se decide en el documento 4.
- **Alternativa de respaldo:** Postgres en servidor propio. Cero costo mensual, a cambio
  de que el servidor esté prendido.
- **Migración:** los 877 conceptos se migran completos. Se normaliza la clave al formato
  único y **se conserva la clave vieja en una columna de trazabilidad**, para que nada se
  pierda y la depuración se pueda hacer sobre la marcha.

---

## 5. Qué se necesita de Stefanno, por etapa

| Etapa | Qué se necesita |
|---|---|
| Modelo de dominio | Confirmar el formato definitivo de clave de concepto · Cerrar el catálogo de categorías de gasto · Confirmar los roles y quién autoriza cada transición |
| Plataforma | Decidir entre servicio gratuito o servidor propio, con la comparación en mano |
| Pantallas | Revisar los tres tableros de junta antes de programarlos |
| Cada rebanada | Probarla con datos reales de F-19 antes de pasar a la siguiente |

---

## 6. Ritmo

Una rebanada a la vez, terminada y probada con F-19 antes de empezar la siguiente.
Nada se declara terminado sin que un dato real haya recorrido el flujo completo.

La V8 y la V9 quedan de respaldo hasta que la rebanada 2 esté en producción. A partir de
ahí la app y el Excel corren en paralelo, como quedó decidido.

---

*Etapa 2 de 4. El siguiente documento es `V10-MODELO-DOMINIO`.*
