# FÓRMULA CANÓNICA DE UNA TARJETA DE PRECIOS UNITARIOS

> **MANDATORIO.** V8 y V9 escriben en el mismo Google Sheet. Si calculan distinto, el
> mismo concepto vale dos cosas según la app desde la que se abra, y nadie se entera hasta
> que un presupuesto sale mal. Esta es la única fórmula. No hay variantes.
>
> Escrito el 28-jul-2026, después de que V9 reportara que su motor de cascada seguía usando
> `CD * (1+ind%) * (1+fin%) * (1+util%)` sin descontar `laborPct`.

---

## 1. Las dos clases de indirecto, que no son lo mismo

Esto es lo que más se confunde. Hay **dos** cosas que se llaman "indirecto" y viven en
lugares distintos:

| | Dónde vive | Qué es |
|---|---|---|
| **Indirecto de renglón** | fila de `tarjetas_precios_unitarios` con `type = indirecto`, apuntando por `sourceId` a `costos_indirectos` | Un costo concreto de ejecutar ESE concepto: el EPP de la cuadrilla, el andamio, el derecho de tiro |
| **Indirecto de empresa** | columna `indirects(%)` de `conceptos_globales` | El sobrecosto de estructura: oficina, administración, seguros |

**El de renglón entra al costo directo. El de empresa se aplica encima, al final.**
Meter uno donde va el otro cambia el resultado y es el error más fácil de cometer aquí.

---

## 2. El cálculo, paso a paso

### Paso 1 — Sumar los renglones que no son mano de obra

De `tarjetas_precios_unitarios`, para las filas de este `conceptId`:

```
importeRenglon = (quantity / (rendimiento || 1)) * unitCost * (1 + wastePct/100)
```

```
Materiales = suma de importeRenglon donde type = material
Equipo     = suma de importeRenglon donde type = herramienta | equipo | subcontrato
```

`rendimiento` en cero o vacío se trata como 1. Nunca dividir entre cero.

### Paso 2 — Aplicar los indirectos de renglón

Cada indirecto trae su `factor_aplicacion` en `costos_indirectos` (columna F). Son cuatro
valores y ya hay datos reales con los cuatro:

| `factor_aplicacion` | Cómo se calcula |
|---|---|
| `% MO` | `ManoDeObra * costo_unitario/100` — depende de la mano de obra, que aún no se conoce. **Ver paso 4.** |
| `% total` | `TotalCostoDirecto * costo_unitario/100` — igual, depende del total. **Ver paso 4.** |
| `Por concepto` | `costo_unitario`, tal cual, una sola vez |
| `Por día` | `costo_unitario * duracionDias` del concepto |

```
IndirectosFijos = suma de los de tipo "Por concepto" y "Por día"
```

Los porcentuales se resuelven en el paso 4, porque dependen de un número que todavía no
existe.

### Paso 3 — Base sin mano de obra

```
BaseSinMO = Materiales + Equipo + IndirectosFijos
```

### Paso 4 — Despejar el total y la mano de obra

La regla de negocio de Stefanno: **la mano de obra es un porcentaje del total del
concepto**, no salario por rendimiento. Si `laborPct = 40`, la mano de obra es el 40% del
total y todo lo demás es el 60%.

```
pctPorcentualesMO    = suma de costo_unitario de los indirectos con factor "% MO"
pctPorcentualesTotal = suma de costo_unitario de los indirectos con factor "% total"

L = laborPct / 100
a = pctPorcentualesMO / 100
b = pctPorcentualesTotal / 100

TotalCostoDirecto = BaseSinMO / (1 - L - L*a - b)

ManoDeObra          = TotalCostoDirecto * L
IndirectosPorcMO    = ManoDeObra * a
IndirectosPorcTotal = TotalCostoDirecto * b
```

**De dónde sale ese denominador.** Por definición el total se compone así:

```
TotalCostoDirecto = BaseSinMO + ManoDeObra + IndirectosPorcMO + IndirectosPorcTotal
                  = BaseSinMO + T*L + (T*L)*a + T*b
```

Se despeja `T` y queda la fórmula de arriba. Con `a = 0` y `b = 0` se reduce al caso
simple que ya conocemos:

```
TotalCostoDirecto = BaseSinMO / (1 - laborPct/100)
```

**Guardas obligatorias:**

- `laborPct` por omisión **40**, tope **50**. Si viene mayor a 50, se recorta a 50.
- Si `(1 - L - L*a - b) <= 0.05`, **no calcular**: devolver error legible
  (`"los porcentajes suman más del 95% del concepto"`). Sin esta guarda el total se
  dispara a infinito y el presupuesto sale con números absurdos.
- Si `BaseSinMO = 0` (concepto sin materiales ni equipo, como una demolición a mano), el
  total da 0 y la mano de obra da 0. **Es correcto que dé cero**, no es un bug: significa
  que a ese concepto hay que ponerle el precio a mano o darle un renglón de equipo.
  Marcarlo con una alerta en la UI, no inventarle un número.
- **`laborPct = 0` es válido.** Un concepto de puro suministro (ej. suministro de block,
  varilla, tubería) no tiene mano de obra. Con `L = 0`, el denominador es `1` y:
  `TotalCostoDirecto = BaseSinMO`. No confundir con el default (40) ni forzar un mínimo.
  El tope es solo superior (50), no inferior.

### Paso 5 — Herramienta menor

```
HerramientaMenor = ManoDeObra * (htaMenorPct / 100)
CostoDirecto     = TotalCostoDirecto + HerramientaMenor
```

`htaMenorPct` es la columna K de `conceptos_globales`. **No es un renglón de la tarjeta**,
es un porcentaje sobre la mano de obra.

### Paso 6 — Precio de venta

```
PrecioVenta = CostoDirecto
            * (1 + indirectsPct/100)     ← columna Q, indirecto de EMPRESA
            * (1 + financingPct/100)     ← columna R
            * (1 + utilityPct/100)       ← columna I
```

Los tres se multiplican en cascada, no se suman. Por decisión de Stefanno del 27-jul-2026,
**los tres se crean en cero** y se calibran al armar el presupuesto, no al crear el concepto.

---

## 3. Ejemplo numérico completo

Concepto de aplanado, `laborPct = 40`, EPP al 3% de mano de obra, sin indirectos de
empresa todavía.

```
Materiales (mortero, agua)          $  600.00
Equipo (revolvedora, andamio)       $  200.00
IndirectosFijos (derecho de tiro)   $   50.00
                                    ---------
BaseSinMO                           $  850.00

L = 0.40    a = 0.03    b = 0
denominador = 1 - 0.40 - 0.40*0.03 - 0 = 0.588

TotalCostoDirecto = 850 / 0.588     = $1,445.58
ManoDeObra        = 1445.58 * 0.40  = $  578.23
IndirectosPorcMO  = 578.23 * 0.03   = $   17.35

comprobación: 850 + 578.23 + 17.35   = $1,445.58  ✓

HerramientaMenor (htaMenorPct = 3)  = 578.23 * 0.03 = $17.35
CostoDirecto                        = $1,462.93

utilityPct = 0, indirectsPct = 0, financingPct = 0
PrecioVenta                         = $1,462.93
```

**Este ejemplo es el caso de prueba.** Cualquier implementación tiene que dar estos
números. Si tu motor da otra cosa, está mal.

---

## 4. Dónde se implementa

**Función pura, aparte, en su propio archivo.** No dentro de `recalculateAllPrices`.

Razones:

1. `recalculateAllPrices` existe **duplicada** en V8 (`google-sheets-service.ts` y
   `sheets/sheets-catalog.ts`) y las dos leen `analisis_pu`, una hoja deprecada con cero
   filas. Meter lógica nueva ahí es escribirla dos veces sobre una base rota.
2. Una función pura —entran números, salen números, no toca la red— se puede probar con el
   ejemplo de arriba sin llamar a Google.
3. V8 y V9 pueden tener el mismo archivo, y comparar que dan lo mismo es trivial.

Firma sugerida:

```ts
export function calcularTarjeta(input: {
  renglones: TPURow[];        // filas de tarjetas_precios_unitarios de este conceptId
  indirectos: IndirectoRow[]; // filas de costos_indirectos referenciadas por sourceId
  concepto: {
    laborPct?: number;        // col S, default 40, tope 50
    htaMenorPct?: number;     // col K
    indirectsPct?: number;    // col Q
    financingPct?: number;    // col R
    utilityPct?: number;      // col I
    duracionDias?: number;    // col F, para los indirectos "Por día"
  };
}): {
  materiales: number;
  equipo: number;
  indirectosFijos: number;
  baseSinMO: number;
  totalCostoDirecto: number;
  manoDeObra: number;
  indirectosPorcentuales: number;
  herramientaMenor: number;
  costoDirecto: number;
  precioVenta: number;
  alertas: string[];          // "sin materiales ni equipo", "porcentajes > 95%", etc.
};
```

`alertas` no es decorativo: es lo que la UI muestra cuando un concepto no se puede
calcular. Un cero silencioso es peor que un cero explicado.

---

# ADENDA 28-jul-2026 — Los dos modos de una tarjeta

Al armar las 24 tarjetas de FASE I del proyecto PRY-0001 quedó claro que el modelo de
`laborPct` **no aplica a todos los conceptos**, y que forzarlo produce precios absurdos.

## El problema

`laborPct` supone que la mano de obra es proporcional al material. Eso es cierto en un
aplanado: más metros de muro, más mortero y más jornales, en proporción estable. El ejemplo
canónico de este documento es justo ese caso.

Pero:

| Concepto | Material | Con `laborPct = 40` daría | Precio real |
|---|---|---|---|
| Trazo y nivelación | $0.50/m² de hilo y cal | $1.25/m² | ~$40/m² |
| Demolición de muro a mano | ninguno | **$0.00** | ~$250/m³ |
| Acarreo de escombro | ninguno | **$0.00** | ~$85/m³ |

En esos conceptos el costo **es** la mano de obra. No hay proporción que despejar.

## La regla

Una tarjeta puede armarse de dos maneras, y la propia tarjeta dice cuál:

### Modo A — mano de obra explícita

La tarjeta trae uno o más renglones con `type = mano_obra`, apuntando por `sourceId` a
`costos_mano_obra`. Se calculan como cualquier otro renglón:

```
importe = (quantity / (rendimiento || 1)) * unitCost * (1 + wastePct/100)
```

donde `quantity` son los integrantes de la cuadrilla y `rendimiento` es cuántas unidades de
obra saca esa cuadrilla en una jornada. Ejemplo: 1 oficial + 1 ayudante que demuelen 3.5 m³
por jornada → `quantity = 1`, `rendimiento = 3.5` en cada uno de los dos renglones.

**En este modo `laborPct` se IGNORA.** La mano de obra ya está medida, no hay nada que
despejar. El total es la suma directa:

```
TotalCostoDirecto = Materiales + Equipo + ManoDeObra + Indirectos
```

Los indirectos con factor `% MO` se aplican sobre la mano de obra ya calculada, y los de
`% total` sobre ese total. Sin despeje, sin denominador.

### Modo B — mano de obra como porcentaje

La tarjeta **no** trae renglones de mano de obra. Entonces se usa `laborPct` y se despeja,
como está descrito arriba en la sección 2.

### Cómo se elige

Automático, sin preguntarle nada al usuario:

```
si hay al menos un renglón con type = mano_obra  →  Modo A
si no                                             →  Modo B
```

**La UI tiene que decir cuál está usando.** Un rótulo en el resumen de la tarjeta:
"Mano de obra: medida por cuadrilla" o "Mano de obra: 40% del concepto". Si el usuario no
sabe en qué modo está, no entiende por qué el número cambió al agregar un renglón.

### Cuándo usar cuál

| | Modo A (cuadrilla) | Modo B (`laborPct`) |
|---|---|---|
| Cuándo | El trabajo es el costo | El material es el costo |
| Ejemplos | demoliciones, acarreos, trazo, desmantelamientos, excavación a mano | aplanados, muros, firmes, pintura, acabados |
| Ventaja | preciso, se calibra con el rendimiento real de obra | rápido, no hace falta medir rendimientos |
| Riesgo | rendimientos mal estimados | material marginal → precio absurdo |

## Qué cambia en `calcularTarjeta()`

La firma no cambia. Adentro:

1. Clasificar los renglones. Si hay alguno con `type = mano_obra`, sumar su importe y usar
   Modo A.
2. En Modo A no hay despeje: `TotalCostoDirecto = Materiales + Equipo + ManoDeObra +
   IndirectosFijos + IndirectosPorcentuales`, con los porcentuales calculados sobre las
   bases ya conocidas.
3. Devolver en el resultado un campo **`modo: 'A' | 'B'`** para que la UI lo muestre.
4. La alerta "sin materiales ni equipo → precio manual" **solo aplica al Modo B**. En Modo A
   un concepto sin material es perfectamente normal.

**El ejemplo canónico de la sección 3 sigue siendo válido y es el caso de prueba del Modo B.**
Para el Modo A el caso de prueba es:

> **Nota — `laborPct = 0` en Modo B para puro suministro.** Si un concepto es solo
> materiales (ej. suministro de block, varilla, tubería), se usa Modo B con `laborPct = 0`.
> El cálculo se reduce a `TotalCostoDirecto = BaseSinMO`, sin mano de obra. Esto no es un
> error — es el comportamiento correcto para una tarjeta que solo suma materiales. No forzar
> un mínimo. En PRY-0001, ARR06009 es Modo B con `laborPct=0`, aunque el dato esté
> incorrecto en la DB y deba corregirse.
>
> **Regla para la UI:** si el concepto tiene `type = mano_obra` → Modo A. Si no → Modo B.
> Si `laborPct = 0` y no hay renglones de mano de obra, es simplemente un concepto de
> suministro puro.

Para el Modo A el caso de prueba es:

```
Demolición de muro, 1 m³
  Equipo:      martillo eléctrico 30 kg, 1 día / 3.5 m³ por jornada   = $228.57
  Mano obra:   1 oficial   ($583.33) / 3.5                            = $166.67
               1 ayudante  ($466.67) / 3.5                            = $133.33
  ManoDeObra                                                          = $300.00
  EPP al 3% de mano de obra                                           = $  9.00
                                                                        --------
  TotalCostoDirecto                                                   = $537.57
  laborPct se ignora: hay renglones de mano de obra
```
