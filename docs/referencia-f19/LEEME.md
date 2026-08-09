# Referencia · Proyecto F-19 · Departamentos F-19

**Instantánea del 8-ago-2026. NO es la fuente viva.**
La fuente vive en `Desktop/Felipe/04_PRESUPUESTO/VERSIONES PARA TERMINAR/` y Stefanno
la sigue editando. Esta copia existe para dos cosas:

1. **Es el presupuesto real de F-19.** No está en la base de la V8: ahí sólo hay
   82 filas de cronograma. Todo lo demás vive aquí.
2. **Es el juego de datos de prueba** de las rebanadas de presupuesto y programa.
   La definición de terminado del proyecto exige que un dato real de F-19 recorra
   el flujo completo. Este archivo es ese dato.

## Qué contiene

| Pestaña | Qué es |
|---|---|
| CARATULA | Datos del proyecto, parámetros, esquema de cobranza con parcialidades, hitos, roles, posición financiera, resumen por partidas |
| PRESUPUESTO | 135 conceptos en 5 módulos y 25 partidas · Opción A, sólo planta baja |
| PRESUPUESTO OPCIÓN B | 201 conceptos · planta baja más planta alta |
| PRESUPUESTO OPCIÓN C | 267 conceptos · tres niveles |
| CRONOGRAMA · FLUJO SEMANAL · CONTROL DE OBRA | Programa, reparto semanal con bloques de cobranza, avance |
| BOLSILLO OPERATIVO | Interno · costo directo contra precio de venta, utilidad y margen por concepto |
| GENERADORES · TPU · INSUMOS | Catálogos del proyecto |
| MOVIMIENTOS · REQUISICIONES · RAYA · PROVEEDORES · ESTADO DE RESULTADOS · BITACORA | Operación, todavía vacías |

## Advertencias

- Las claves son las **viejas** de la V8. La equivalencia está en `docs/migracion/`
- El IVA está en **cero** por decisión de Stefanno: este cliente va sin IVA
- La escalera del Módulo 5 va en cero: Stefanno la captura aparte
- Los conceptos nuevos —árbol, tierra física, tarja, servicio CFE— aún no tienen precio
