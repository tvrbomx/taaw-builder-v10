# Flujo de trabajo real — de la TPU al pago a proveedor

**Origen:** explicación de Stefanno, 26-jul-2026, corrigiendo un adelanto de Claude.
**Por qué importa:** este flujo **define comportamiento obligatorio de la app**, no es solo una descripción de cómo trabajan. Hay una regla dura al final que la app debe hacer cumplir.

---

## El orden correcto, y por qué no se puede saltar

### 1. Tarjeta de precio unitario, con precios estimados reales

La TPU se arma **antes** de tener cotizaciones de proveedor, con precios estimados pero realistas (de mercado, de obras anteriores, de referencia).

Su función es **consolidar el precio unitario real de cada concepto**. Ese precio es el que sostiene el presupuesto que se entrega al cliente.

**Consecuencia para las TPU de FASE I:** se arman **descompuestas** — material, mano de obra, equipo, indirectos — para todos los conceptos, incluidos los que después se van a subcontratar. No se toman atajos metiendo un subcontrato como fila única solo porque ya hay una cotización. Esa cotización pertenece a la etapa 3, no a esta.

*Error que cometió Claude y que esto corrige:* propuso armar los conceptos 3 a 8 de FASE I como subcontrato, porque el maestro Jorge ya cotizó. Eso mezcla dos etapas del flujo y pierde el precio unitario real del concepto, que es justamente lo que la TPU existe para producir.

### 2. Presupuesto

Con los precios unitarios consolidados de las TPU, el presupuesto queda con números defendibles y trazables hasta el insumo.

### 3. Cotización con proveedores (ya en obra)

Aquí sí se cotiza con proveedores reales. En el caso de PRY-0001, el maestro Jorge cotiza los trabajos de plomería y electricidad.

**Esa cotización se ingresa a la app, foliada y registrada.** Y desde la app **se le asigna qué conceptos cubre** — una cotización puede cubrir varios conceptos del presupuesto.

### 4. Pago a proveedor — la regla dura

> **Jamás se realiza un pago a un proveedor si no se tiene antes su cotización ingresada como requisición.**

Todo pago a proveedor va **atado a una cotización**. Sin cotización registrada, no hay pago. La app debe impedirlo, no solo advertirlo.

Los pagos y anticipos van ligados, además, a: cliente, fecha, proyecto, folio, y la cotización correspondiente.

---

## Los tres tipos de requisición

Una cotización, al ingresarse, se convierte en una requisición. Hay tres tipos según qué se está comprando:

| Tipo | Qué cubre |
|---|---|
| **Compra de materiales** | Cotizaciones para adquisición de material |
| **Mano de obra / nómina** | Cotizaciones por trabajos de mano de obra o nómina |
| **Trabajos, rentas y servicios** | Compras o rentas de maquinaria y equipo, indirectos, viáticos, servicios |

---

## Qué implica esto para la app

Esta es la cadena de datos que la app tiene que sostener, y cada eslabón tiene que existir antes del siguiente:

```
insumo (catálogo)
  → TPU (tarjeta del concepto)
      → precio unitario del concepto
          → presupuesto (contenedor + conceptos + volúmenes)
              → cotización de proveedor (foliada, registrada)
                  → asignación cotización ↔ conceptos que cubre
                      → requisición (materiales / mano de obra / trabajos)
                          → pago o anticipo al proveedor
```

**Reglas que se derivan y que hay que verificar en el código:**

1. **Un pago a proveedor sin cotización asociada debe ser imposible**, no solo desaconsejado. Hay que revisar si hoy el módulo financiero lo permite.
2. **La asignación cotización ↔ conceptos es de muchos a muchos**: una cotización cubre varios conceptos, y en principio un concepto podría recibir cotizaciones de más de un proveedor (para comparar).
3. **El folio de la cotización** debe generarse en la app, no capturarse a mano — igual que los IDs de todo lo demás.
4. **La TPU no se altera cuando llega la cotización real.** La TPU guarda el precio estimado con el que se presupuestó; la cotización guarda el precio real del proveedor. La diferencia entre ambos **es un dato de valor** (te dice si estimaste bien) y se perdería si la cotización sobrescribiera la tarjeta. Esto es consistente con la decisión de que `unitCost` en la tarjeta es una copia congelada a propósito.

---

## Estado actual y qué falta revisar

Pendiente de auditar, cuando toque esa etapa del flujo:

- La hoja `cotizaciones` y `cotizaciones_items` ya existen en la base de datos (`cotizaciones_items` tuvo un rango truncado `A:I`→`A:K` que ya se corrigió).
- Existe un módulo `quotes-analyzer` en V8 con 4 errores de TypeScript pendientes, en área reservada.
- El módulo de pagos (`Pagos_Programados`, 33 columnas) tiene campos `requisitionId` y `quoteId`. **Falta verificar si el flujo los exige o si son opcionales** — si son opcionales, la regla dura del punto 4 no está implementada.
- `getRequisitions` / `addRequisition` / `updateRequisitionStatus` existen en `sheets-payments.ts`. Falta auditar contra este flujo.

**Nada de esto se toca ahora.** Estamos en la etapa 1 del flujo (TPU). Se documenta aquí para que cuando lleguemos a las etapas 3 y 4 no haya que redescubrirlo, y para que ningún agente construya algo que después contradiga esta cadena.

---

## Regla de proceso que Stefanno pidió respetar

> "Vamos paso a paso que esto es mandatorio irlo realizando conforme al flujo de trabajo real en esta etapa de anteproyecto y planeación de la obra."

El desarrollo de la app va **de la mano del avance real de la obra**. No se construye una etapa del flujo antes de que la obra la necesite. Eso evita construir sobre suposiciones y permite que cada módulo se pruebe con datos reales en el momento en que se usan por primera vez.
