# Especificación — Módulo de Tarjetas de Precio Unitario (TPU)

**Fecha:** 25-jul-2026 · **Autor:** Claude
**Aplica a:** V8 y V9. Es la pieza de la que dependen presupuesto, cronograma, avance de obra, bitácora, cotizaciones y control financiero.
**Estado:** especificación aprobada por Stefanno para arrancar la reparación.

---

## 1. Qué existe hoy y qué está roto

### Lo que sí existe

| Pieza | Dónde | Estado |
|---|---|---|
| Hoja de tarjetas | `tarjetas_precios_unitarios!A:L` (12 columnas) | Estructura correcta, **vacía** |
| Lectura / escritura de tarjetas | `sheets-budget.ts` 192-310 (`getPricingCardItems`, `getAllPricingCards`, `savePricingCardItems`) | Funciona |
| Página de tarjetas | `/tpu` (529 líneas) | Funciona |
| Consumo real en obra | `consumo_tpu!A:O` + `sheets-pricing.ts` (`getTPUConsumption`, `addTPUConsumption`) | Existe |
| Comparativo tarjeta vs presupuesto | `sheets-pricing.ts` (`getBudgetItemsWithPU`, `checkTPUBudgetStatus`) | Existe |
| Catálogos de insumos | 6 hojas (ver sección 3) | Estructura correcta, **vacías** |

### Los tres bloqueos reales

**BLOQUEO 1 — El motor de cascada lee la hoja equivocada.**
`recalculateAllPrices()` (`sheets-catalog.ts` línea 611, duplicada en el monolito línea 2318) lee sus partidas desde `ANALISIS_PU_SHEET_NAME`, que es **`analisis_pu`** — la hoja **deprecada, con 0 filas**, confirmada vacía cuando se convirtió `/catalog/pu-builder` en redirect. Las tarjetas reales viven en `tarjetas_precios_unitarios`. El motor recorre una hoja vacía y devuelve `{updated: 0, errors: 0}`.

**BLOQUEO 2 — Nadie llama al motor.**
`recalculateAllPrices()` no tiene un solo consumidor en `src/`. Tampoco `syncTPUToBudgetConceptPrices()` (`sheets-pricing.ts` línea 56), que propaga el precio de la tarjeta al presupuesto. Ambas están escritas y completas, y ninguna se invoca desde ninguna parte de la app.

**BLOQUEO 3 — Falta el eslabón insumo → tarjeta.**
En `tarjetas_precios_unitarios`, la columna `unitCost` (I) guarda una **copia congelada** del precio del insumo al momento de armar la tarjeta, y `sourceId` (D) guarda la referencia al insumo en su catálogo. **Nada relee `sourceId` para refrescar `unitCost`.** Aunque el motor apuntara a la hoja correcta, seguiría faltando la función que va de "subió el precio de la varilla" a "recalcula todas las tarjetas que la usan".

**Consecuencia conjunta:** la cascada de precios —la razón de ser de todo el sistema— no existe todavía, aunque haya código que aparenta implementarla.

---

## 2. Estructura de la tarjeta

`tarjetas_precios_unitarios!A:L` — una fila por **insumo dentro de una tarjeta**, no una fila por tarjeta:

| Col | Campo | Qué es |
|---|---|---|
| A | `id` | ID de la fila (`TPU-XXX`) |
| B | `conceptId` | Concepto al que pertenece — es la llave que agrupa la tarjeta |
| C | `type` | Tipo de insumo (ver `INSUMO_TYPES`) |
| D | `sourceId` | **Referencia al insumo en su catálogo.** La llave de la cascada |
| E | `description` | Descripción del insumo (copia legible) |
| F | `unit` | Unidad del insumo |
| G | `quantity` | Cantidad del insumo por unidad del concepto |
| H | `rendimiento` | Rendimiento — divide la cantidad |
| I | `unitCost` | **Copia del precio del insumo.** Lo que hoy nadie refresca |
| J | `totalCost` | Importe de la fila |
| K | `wastePct` | Porcentaje de desperdicio |
| L | `notes` | Notas |

Fórmula por fila, tal como la calcula hoy `checkTPUBudgetStatus`:

```
importe = (quantity / rendimiento) * unitCost * (1 + wastePct/100)
```

El precio unitario del concepto es la suma de los importes de sus filas, más los factores que viven en `conceptos_globales`: `utilityPct` (I), `extraChargesPct` (J), `htaMenorPct` (K), `indirectsPct` (Q), `financingPct` (R).

---

## 3. Los seis catálogos de insumos y sus campos de precio

Esto es lo que la cascada tiene que leer. Campos verificados en `src/lib/types.ts`:

| Tipo de insumo | Hoja | Llave | Campo de precio | Extras relevantes |
|---|---|---|---|---|
| Material | `materiales` | `id` | `basePrice` | `wastePercentage` (se aplica encima del precio), `unit`, `providerName` |
| Mano de obra | (vía `getLaborCosts`) | `id_cuadrilla` | `realSalary` | `baseSalary` × `fasarFactor` = `realSalary`; `unit` default `JOR` |
| Equipo | (vía `getEquipmentCosts`) | `id` | `costPrice` | `tipo` (Propia/Rentada/Subcontratada), `rendimiento`, `consumoCombustible`, `costoCombustibleDia`, `operadorRequerido`; `unit` default `DIA` |
| Herramienta menor | `herramienta_menor` | `id` | — | Se aplica como **porcentaje** (`htaMenorPct` del concepto), no como fila de insumo |
| Costo indirecto | `costos_indirectos` | `id` | `costoUnitario` | `tipo` (Combustible/Viático/Renta/Desgaste/Admin), `factorAplicacion` (Por concepto / Por día / % MO / % total), `unidad` default `DIA` |
| Subcontrato | `subcontratos_catalogo` | `id` | `precioUnitarioRef` | `partida`, `idProveedor`, `incluyeMateriales`, `unidad` default `GLOBAL` |

**Nota sobre `factorAplicacion` en costos indirectos:** ese campo define cómo se aplica el indirecto (importe fijo por concepto, por día, porcentaje sobre mano de obra, o porcentaje sobre el total). El motor de cálculo tiene que respetarlo; no puede tratar todos los indirectos igual. Aquí es donde entra el indirecto de EPP y el de trabajos de riesgo de la regla del 25-jul (`docs/REGLA_INDIRECTOS_EPP_Y_ALTURA.md`).

---

## 4. Lo que hay que construir

### 4.1 Repuntar el motor a la hoja correcta

`recalculateAllPrices()` debe leer de `tarjetas_precios_unitarios!A:L` en vez de `analisis_pu!A2:E`. No es cambiar el nombre de la hoja y ya: el mapeo de columnas es distinto (`analisis_pu` tenía 5 columnas: conceptId, insumoType, insumoId, quantity; la tarjeta tiene 12 y agrega `rendimiento` y `wastePct` a la fórmula). Hay que reescribir el cuerpo del bucle usando la fórmula de la sección 2.

Existe **duplicada** en el monolito (`google-sheets-service.ts` línea 2318) y en el split (`sheets-catalog.ts` línea 611). **Las dos hay que corregir, o dejar una sola.** Es exactamente el problema de las dos capas paralelas que ya nos mordió en el barrel de `index.ts`.

### 4.2 La función que falta: insumo → tarjetas

Nueva función. Dado un insumo que cambió de precio:

1. Busca en `tarjetas_precios_unitarios` todas las filas cuyo `sourceId` coincida y cuyo `type` corresponda.
2. Actualiza su `unitCost` con el precio nuevo del catálogo, y recalcula `totalCost` con la fórmula de la sección 2.
3. Junta los `conceptId` afectados (sin repetir).
4. Para cada concepto afectado, recalcula su precio unitario completo y actualiza `conceptos_globales`.
5. Para cada concepto afectado, llama a `syncTPUToBudgetConceptPrices` para propagar al presupuesto.

Debe existir también la versión masiva: "refresca **todas** las tarjetas contra los precios actuales de los catálogos", que es la que se corre después de una actualización de precios en bloque.

**Requisito de seguridad:** esta función escribe sobre precios de presupuestos reales. Necesita **modo simulación** — que devuelva qué cambiaría, cuántas tarjetas y cuántos conceptos, sin escribir. Nada de esto se ejecuta contra producción sin haber visto antes el simulacro.

### 4.3 Conectarlo a la interfaz

Hoy no hay forma de disparar el recálculo desde la app. Hace falta, en el módulo de precios unitarios: un botón de "Actualizar precios en cascada" que primero muestre el simulacro (qué tarjetas y qué conceptos se afectan, precio anterior y nuevo) y solo entonces permita confirmar.

### 4.4 Cuidados obligatorios

- **No usar el patrón "borrar y reescribir toda la hoja"** para estas actualizaciones. `savePricingCardItems` hoy hace clear + rewrite, con el riesgo de "último que guarda gana" ya documentado. El recálculo en cascada debe actualizar filas por rango, no reescribir la hoja.
- **`unitCost` sigue siendo una copia, a propósito.** Es correcto que la tarjeta guarde el precio con el que se cotizó: un presupuesto entregado al cliente no debe cambiar solo porque subió un material. La cascada es una acción **explícita** de Stefanno, no automática. Esto es una decisión de diseño, no una limitación.
- **Precisión decimal.** Los importes deben redondearse en un solo punto y de forma consistente, o los totales del presupuesto no van a cuadrar contra los del PDF.

---

## 5. Reparto de trabajo

**V8** (app en producción, tiene el motor y los datos reales):
1. Reescribir `recalculateAllPrices()` para leer de `tarjetas_precios_unitarios` con la fórmula correcta. Resolver primero si se conserva la copia del monolito o solo la del split.
2. Construir la función insumo → tarjetas → conceptos → presupuesto, con modo simulación.
3. Conectar el botón de recálculo en la interfaz, con confirmación previa mostrando el simulacro.

**V9** (aún en construcción, no tiene nada de esto):
1. Cerrar primero las dos brechas ya diagnosticadas del formulario de concepto: partida como `Select` con catálogo real en vez de texto libre, y el equivalente de `normalizeUnit`.
2. Construir el módulo de TPU siguiendo esta misma especificación, sin inventar esquema propio: mismas 12 columnas, misma fórmula, mismos catálogos.

**Claude:** auditar las dos implementaciones contra esta espec y verificar que la cascada realmente funciona con datos reales, no solo que compila.

---

## 6. Cómo se llenan los catálogos — RESUELTO (Stefanno, 26-jul-2026)

Los catálogos de insumos están vacíos, y **no se llenan por separado antes de armar la tarjeta.** Se llenan **desde la propia tarjeta, en el momento en que se necesitan.**

Requisito funcional, dicho por Stefanno textualmente: *"desde la app debemos hacer el TPU; si no existe un insumo se registra en ese mismo formulario de TPU junto con proveedor, y si no existe ese proveedor es igual, con otro formulario se agrega el proveedor."*

Es decir, tres niveles de creación en línea, sin salir del flujo:

```
Formulario de TPU
  └─ agregar insumo → si no existe en el catálogo, se crea aquí mismo
       └─ asignarle proveedor → si el proveedor no existe, se crea aquí mismo
```

**Esto es requisito de construcción, no un "nice to have".** Es lo que evita que armar una tarjeta se convierta en salir de la pantalla, ir a otro módulo, capturar, volver y perder el hilo. Es el mismo patrón que ya existe en el formulario de proyecto de V8 con el botón "+ Nuevo Cliente".

Implicaciones para quien lo construya:

- El insumo creado en línea debe quedar registrado en su catálogo real (`materiales`, mano de obra, equipo, etc.), no solo en la tarjeta. Un insumo creado así debe poder reutilizarse en la siguiente tarjeta.
- El ID del insumo y el del proveedor se generan en el backend, nunca se escriben a mano.
- Al crear el insumo en línea, su `sourceId` debe quedar correctamente ligado en la fila de la tarjeta. Si no, la cascada de precios no lo alcanza — y ese es justamente el punto de todo el módulo.
- El formulario mínimo de proveedor debe ser corto (nombre y teléfono bastan para no romper el flujo), igual que el de cliente en el formulario de proyecto. Los datos completos se llenan después desde el módulo de proveedores.

## 7. Lo único que sigue pendiente de Stefanno

**Los porcentajes.** EPP base, herramienta menor, riesgo por trabajos peligrosos y administración. Sin esos números ninguna tarjeta cierra su precio unitario, por muy bien capturados que estén los insumos. Ver `REGLA_INDIRECTOS_EPP_Y_ALTURA.md` en esta misma carpeta.

---

# ADENDA 27-jul-2026 — Reglas de cálculo confirmadas por Stefanno

**Esta adenda tiene prioridad sobre cualquier supuesto de las secciones anteriores.** Son criterios reales de la empresa, confirmados en junta. Si algo de arriba los contradice, gana esta adenda.

## A. La mano de obra NO se calcula por salario × rendimiento

Es el error de diseño más importante que traía esta especificación.

> **La mano de obra nunca pasa del 50% del costo del concepto. El estándar es 40%. Lo ideal es menos.**

Textual de Stefanno: *"en cualquier trabajo la mano de obra siempre es el costo hasta el 50% máximo del costo de todo el concepto. Por ejemplo, si hacer un aplanado cuesta 300 ya con materiales y mano de obra por metro cuadrado, se debe pensar que máximo el trabajador debe cobrar 150 pesos, y eso es máximo; lo ideal es pagarle 110."*

**Los conceptos se cuantifican por rendimiento o destajo, no por salario.** El salario sirve cuando se administra obra, no para armar el precio unitario.

Fórmula despejada:

```
Total          = (Materiales + Equipo + Indirectos) ÷ 0.60
Mano de obra   = Total × 0.40
```

Equivalente: **la mano de obra vale dos tercios de la suma de todo lo demás.**

Verificación con el ejemplo real: si materiales + equipo + indirectos suman $180, entonces total = $300 y mano de obra = $120, que cae entre los $110 ideales y los $150 máximos de Stefanno.

**Implicación para el motor:** debe soportar que una fila de mano de obra se exprese como **porcentaje del concepto**, no solo como cantidad × costo unitario. Hoy el esquema no lo contempla. Hay que resolverlo antes de construir el cálculo, o todas las tarjetas van a salir mal.

**Caso abierto:** en conceptos sin material (demolición, acarreo, desmantelamiento, corte) no hay de qué sacar el 40%. Propuesta pendiente de confirmación: mano de obra al tope de 50%, equipo 40%, indirectos 10%.

## B. Los catálogos de mano de obra siguen existiendo, pero para otra cosa

Los salarios se capturan en `costos_mano_obra` porque se necesitan para **control de obra y nómina**, no para armar la tarjeta.

Salarios vigentes (sin prestaciones, FASAR = 1.00, jornada = semanal ÷ 6):

| Puesto | Semanal | Jornada |
|---|---:|---:|
| Maestro | $4,000 | $666.67 |
| Oficial de 1ª | $3,500 | $583.33 |
| Fierrero (oficial de 1ª) | $3,500 | $583.33 |
| Ayudante | $2,800 | $466.67 |

## C. Consumibles: siempre como fracción por unidad de concepto

Todo consumible —discos, brocas, cinceles, puntas, hojas de sierra, lijas— se registra como **fracción de pieza por unidad del concepto**, nunca como pieza completa.

Ejemplo: si un disco de diamante rinde 200 ml de corte y en una jornada se cortan 32 ml, el consumo es **0.16 pza/jornada**.

**El propósito es el módulo de lista de compras consolidada:** al sumar todas las fracciones del presupuesto sale la cantidad exacta a comprar. Si se registra la pieza completa, ese módulo no sirve.

## D. Utilidad e indirectos se calibran en la app, no en la captura

Las tarjetas se arman **a costo directo con precios reales de proveedor**. Utilidad 0%, indirectos 0%.

**Pero las líneas de indirectos se registran igual, con importe cero.** No se omiten. Así, cuando se calibren los porcentajes en el módulo de TPU, ya están ahí y solo hay que ponerles número.

La calibración de utilidad es **por concepto y desde el formulario de TPU de la app**. Nunca en un Excel ni en la captura inicial.

## E. Referencia de contraste

Los presupuestos históricos de la empresa cierran con **"UTILIDAD E INDIRECTOS 18%"** aplicado al total de todas las partidas. Ese 18% es el **piso de referencia**: si la utilidad promedio que arroje la app queda por debajo, algo se está subestimando en las tarjetas.
