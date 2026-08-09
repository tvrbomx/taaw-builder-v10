# Migración del catálogo de conceptos · archivos de trabajo

**R02 · 8-ago-2026 · las siete decisiones de datos, resueltas. Nada pendiente.**

Archivos generados leyendo el archivo real `TAAW_DB_Master.xlsx`, no un reporte
intermedio. Sirven para dos cosas: **decidir** lo que sólo Stefanno puede decidir, y
**mantener vivo el puente con el Excel de F-19** mientras la app y la hoja conviven.

---

## `EQUIVALENCIA-CLAVES.csv` · 877 filas

**R01 · con las decisiones de Stefanno del 8-ago-2026 ya aplicadas.**

Una fila por concepto. Columnas:

| Columna | Qué trae |
|---|---|
| `clave_anterior` | el identificador de la V8, tal cual está hoy en la hoja y en el Excel de F-19 |
| `clave_nueva` | la clave V10, formato `ALB-0072` |
| `partida` · `partida_clave` | nombre y clave de 3 caracteres |
| `activo` | `NO` en los dos conceptos dados de baja |
| `tipo_precio` · `porcentaje` | `FIJO` salvo los dos porcentuales |
| `unidad` | ya con la corrección de `TRA1009` |
| `precio_venta_anterior` | el valor tal cual, sin tocar |
| `descripcion` | completa |
| `notas_migracion` | qué se le hizo a esa fila y por qué |

**Los conceptos dados de baja se numeran al final de su partida.** Una clave baja no se
gasta en una fila basura: `EXV03001` conserva `EXV-0001` y la captura basura (`EXV0001`)
se va al final de la partida como `EXV-0018`. Igual `ALB8206` ("barda", sin terminar),
que se va al final de Albañilerías como `ALB-0208`.

**Verificación hecha al generarlo, en una sola pasada final:** 877 registros entran, 877
salen · 877 claves nuevas únicas · todas cumplen `^[0-9A-Z]{3}-[0-9]{4}$` ·
correspondencia 1 a 1 con el origen · la única `clave_anterior` repetida es `ARR6011`,
que es la colisión real conocida · **53 filas con `activo = NO`**: 2 por captura basura
o sin terminar, 51 por la regla de descripciones repetidas de abajo · cero notas
duplicadas u obsoletas.

### Cómo se usa en el Excel de F-19

En la hoja del presupuesto, con la clave vieja en la columna `A`:

```
=BUSCARV(A2, EQUIVALENCIA!$A:$B, 2, FALSO)
```

Devuelve la clave nueva. Se pega como valor y el Excel queda hablando el idioma de la
V10 sin perder nada: la clave vieja sigue guardada en `concepto.clave_anterior` y **es
buscable desde la app**, así que un documento viejo se puede rastrear siempre.

### Estabilidad de este archivo

Las claves nuevas **no cambian** cuando se resuelvan las decisiones pendientes. Se
asignaron por orden de aparición, así que dar de baja un concepto deja un hueco en la
numeración y no recorre a los demás. Un hueco es aceptable: la clave es un
identificador, no un contador.

Las únicas filas que pueden cambiar de clave son las 3 de `TCL`, y sólo si se decide que
la forma correcta es `TLC`. Están marcadas en la columna `revisar`.

---

## `DESCRIPCIONES-REPETIDAS.md` · 60 grupos, 140 conceptos — **CERRADO**

**Regla final de Stefanno, 8-ago-2026. No hubo revisión grupo por grupo:**

- **Mismo precio** → se conserva la clave **mayor** (la más nueva), las demás se dan de
  baja — **38 grupos, 51 conceptos dados de baja, 38 sobreviven**
- **Precio distinto** → se conservan todas. No se fusiona nada — **22 grupos, 51
  conceptos, todos activos**

La razón de la segunda regla: un concepto con unos pesos de diferencia no justifica el
tiempo de nadie, y en la V10 el problema desaparece solo, porque los precios de un
presupuesto salen de las tarjetas y no del concepto — el concepto sólo aporta la
descripción y la clasificación.

---

## Decisiones · resueltas el 8-ago-2026

| Decisión | Resolución |
|---|---|
| `TCL` contra `TLC` | **Gana `TCL`.** *Toldos, Cortinas y Lonas* da T-C-L y el prefijo debe ser mnemónico del nombre. Se corrigen las dos filas del catálogo, no los tres conceptos |
| `ARR6011` duplicado | **Se separan** → `ARR-0011` y `ARR-0012`. Carretilla y volteo son trabajos distintos |
| `CIM-0001` / `CIM04001` | **Se separan.** Cimentación y plantilla no son lo mismo |
| `EXV0001` / `EXV03001` | `EXV0001` (`"xxxxxxx"`) **se da de baja** → `EXV-0018`. `EXV03001` conserva `EXV-0001` |
| `HRR10004` / `HRR1004` | **Se separan** → `HRR-0004` y `HRR-0029`. Peldaños de escalera marinero y pérgola metálica |
| `HNR90001` | `PORCENTAJE_OBRA`, valor **15** → `HNR-0001` |
| `EXT89001` | `PORCENTAJE_OBRA`, valor **5** — retención por vicios ocultos → `EXT-0001` |
| `TRA1009` | **Es `FIJO`**: unidad corregida de `%` a `lote`, **conserva el precio** de $6,248.15 → `TRA-0010` |
| `TRA1009` y `TRA-1009` | Dos conceptos distintos → `TRA-0010` y `TRA-0009` |
| `ALB8206` "barda", precio 0 | Migra **inactivo** con alerta → `ALB-0208` |
| 21 partidas sin conceptos | Se quedan `SYS`, `CTV`, `DOM`, `VIA`, `MOB`. Se dan de baja `AVV`, `AVS`, `RIG`, `MBR` y las trece restantes del giro de eventos |
| **60 grupos de descripción repetida** | **Cerrado por regla** — ver arriba. No fue revisión grupo por grupo |

## Nada sigue abierto en este archivo

Las siete decisiones de datos de la migración están resueltas. Lo único que queda fuera
de este archivo es la aprobación de las columnas `firmado_por` / `firmado_en` en
`presupuesto` — eso es [[V10-ESQUEMA-SQL]] §19, no migración de datos.
