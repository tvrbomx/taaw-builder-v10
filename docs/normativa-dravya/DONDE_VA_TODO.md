# Dónde va todo — mapa del desarrollo

**28-jul-2026.** Este documento existe porque el trabajo se fragmentó en muchos mensajes y
se perdió el hilo. Aquí está todo lo que has pedido, en qué estado real está, y quién lo
tiene. Yo lo mantengo al día.

---

## 1. Lo que se logró hoy

Hoy pasaron cuatro cosas que llevaban tiempo atoradas:

| | |
|---|---|
| **El catálogo de insumos existe** | 156 materiales, 128 equipos, 12 indirectos, 4 cuadrillas, 6 destajos, 9 proveedores. Traducido del archivo de la Arq. Fernanda al esquema de las pestañas. |
| **El presupuesto de Felipe está en la base** | FASE I de PRY-0001: 24 conceptos redactados con la volumetría de los planos. |
| **Las 24 tarjetas de precios unitarios están armadas** | 131 renglones, cada uno apuntando por `sourceId` al insumo real del catálogo. |
| **La cascada de precios funciona** | `recalculateAllPrices()` leía una hoja muerta y no tenía quién la llamara. Ahora lee las tarjetas de verdad y usa la fórmula canónica. **Esto llevaba año y medio roto** y era lo que impedía que un presupuesto se calculara solo. |

Y algo que no es visible pero vale: **V8 y V9 calculan idéntico**. Los dos implementaron la
misma función y los dos pasan el mismo caso de prueba. Antes cada app daba un número
distinto para el mismo concepto.

---

## 2. El flujo de trabajo, paso a paso

Este es el flujo que describiste en `MUCHO TRABAJO.MD`. Es el mapa real.

| # | Paso | Estado | Quién |
|---|---|---|---|
| 1 | Crear proyecto y cliente | ✅ funciona | — |
| 2 | Presupuesto con conceptos | ✅ funciona, cargado | — |
| 3 | Tarjeta de precios por concepto | ✅ 24 tarjetas armadas | — |
| 4 | El precio del concepto sale de su tarjeta | ✅ **cerrado hoy** | V8 |
| 5 | Subir un material mueve todos los conceptos | 🔄 el motor está; falta conectarlo a los catálogos | V8 |
| 6 | Exportar presupuesto en sus variantes | ✅ en V8 · 🔄 en V9 | V9 |
| 7 | Lista de compras consolidada | ✅ **cerrado hoy** | V8 |
| 8 | Cronograma desde el presupuesto | ⚠️ existe, nadie lo ha probado con datos reales | — |
| 9 | Flujograma desde el cronograma | ⚠️ existe · ❌ falta imprimirlo por semana | — |
| 10 | Hoja de aceptación del cliente | ❌ no existe | — |
| 11 | Cotizaciones ligadas a conceptos | ❌ no existe | — |
| 12 | Requisición y pago | ❌ hoja vacía | — |
| 13 | Bitácora como centro de control | ⚠️ existe, desconectada del resto | — |

**Los pasos 8 y 9 son el siguiente cuello de botella.** De ahí salen las tres pantallas
simultáneas que le describiste a Fernanda: tú mueves el cronograma y ella ve cambiar el
flujo de dinero en su pantalla.

---

## 3. Todo lo que has pedido

### Ya está

- Presupuesto FASE I de PRY-0001 con volumetría de planos
- Las 24 tarjetas de precios unitarios
- Catálogo completo de insumos, homologado del archivo de la Arq. Fernanda
- La cascada: el precio del concepto sale de su tarjeta
- Lista de compras consolidada, con página propia y en el PDF
- Fracciones de consumibles que se acumulan y redondean **una sola vez** al final
- Alerta de conceptos sin tarjeta
- Alerta de insumos sin precio, en los cinco catálogos y en la tarjeta
- Mano de obra como porcentaje del concepto (`laborPct`), y también como cuadrilla × rendimiento
- Indirectos con cuatro formas de aplicarse: % de mano de obra, % del total, por concepto, por día
- Utilidad e indirectos de empresa en cero al crear, se calibran al presupuestar
- PDF: notas de concepto, nota general del contenedor, logo con su proporción real
- Página de presupuestos reordenada en V9: cuatro grupos, carga perezosa, ajuste global con confirmación y deshacer

### En curso ahora

- Conectar la cascada a los catálogos, con aviso de "esto afecta N conceptos" — **V8**
- Exportar funcional en V9 — **V9**
- Módulo de captación de JSON dentro de la app, para no depender de la terminal — **V9**

### Pedido y todavía no empezado

| Qué | De dónde salió |
|---|---|
| Dashboard con widgets en vez de muro de datos | `MUCHO TRABAJO.MD` |
| Página de proyecto con widgets | `MUCHO TRABAJO.MD` |
| Flujograma imprimible por semana | `MUCHO TRABAJO.MD` |
| Hoja de aceptación del presupuesto, con versión y revisión BIM | `MUCHO TRABAJO.MD` |
| Cotizaciones que amarren con los conceptos aunque el proveedor los agrupe distinto | dictado del 27-jul |
| Requisiciones en sus tres tipos | dictado del 27-jul |
| Pagos ligados al cronograma, que muevan el estado del concepto | `MUCHO TRABAJO.MD` |
| Bitácora como origen de incidencias y avances | `MUCHO TRABAJO.MD` |
| Actualización masiva de precios con vista previa | dictado del 24-jul |
| Tres pantallas en vivo: finanzas, dirección, control de obra | tu junta con Fernanda |
| Métricas y análisis de datos para la empresa | dictado inicial |
| Herramientas con IA | dictado inicial |
| Rediseño de interfaz con glassmorfismo | dictado inicial |
| FASE II del presupuesto: estructural e instalaciones | dictado del 24-jul |
| Depurar las 28 pestañas vacías y las 8 muertas | análisis del 28-jul |
| Consolidar proveedores duplicados | análisis del 28-jul |
| Migrar los IDs de conceptos al formato correcto | análisis del 28-jul |

---

## 4. Lo que solo tú puedes desbloquear

Cuatro cosas. Ninguna la puedo resolver yo y todas bloquean lo demás.

**1. Los porcentajes de los 12 indirectos.** Están todos en cero. Sin ellos las tarjetas
salen incompletas. El más urgente es el EPP (`IND-001`): con ponerle **3** en la columna E,
los 24 conceptos de FASE I cierran con el número que yo calculé a mano. Los otros once
pueden esperar, pero el EPP no.

**2. `ARR06009` con `laborPct = 0`.** Es el viaje de escombro: puro suministro, el camión
trae su chofer. Hoy el motor le suma 40% de mano de obra que no existe. Columna S,
un cero.

**3. Los dos rendimientos que te marqué.** La excavación me dio $520/m³ y el registro
sanitario $2,064. Los dos me parecen altos pero tú conoces el terreno y el trabajo.

**4. Utilidad e indirectos de empresa para FASE I.** Dijiste que se definen al armar el
presupuesto. Ya toca.

---

## 5. Qué sigue, en orden

**Ahora**

1. Fernanda instala la app con `INSTRUCTIVO_FERNANDA_ABRIR_LA_APP.md` y empieza a
   alimentar catálogos
2. Tú pones el 3 del EPP y el 0 de `ARR06009`
3. V8 conecta la cascada a los catálogos
4. V9 termina Exportar

Con eso **abres PRY-0001 y ves un presupuesto que se calcula solo desde sus tarjetas**.
Eso es lo que no ha pasado nunca.

**Luego**

5. Probar cronograma y flujograma con los 24 conceptos reales
6. Flujograma imprimible por semana
7. Hoja de aceptación del cliente

**Después**

8. Cotizaciones ligadas a conceptos
9. Requisiciones y pagos
10. Dashboard y página de proyecto con widgets

---

## 6. Cómo funciona el trabajo con los agentes

Para que no se pierda el hilo:

- **Yo** leo los datos reales, decido el esquema, escribo las especificaciones y verifico
  lo que reportan. No escribo código de la app.
- **V8 y V9** escriben el código. Cada uno en su repo.
- **Tú** eres el único canal entre nosotros: me pasas sus reportes y les pasas mis prompts.

Cada agente tiene un archivo donde queda todo lo que le pedí y lo que respondió:

- `.agents/CHAT_CLAUDE_OPENCODE_V8.md`
- `.agents/CHAT_CLAUDE_OPENCODE_V9.md`

Y hay tres documentos que los dos leen obligatoriamente al arrancar:

- `.agents/context/ESQUEMA_BASE_DE_DATOS.md` — el esquema real de las 59 pestañas
- `.agents/context/FORMULA_CANONICA_TPU.md` — cómo se calcula una tarjeta
- `.agents/rules/MANDATORIO_FORMATO_REPORTE.md` — que cierren con un bloque copiable

Si algún día se pierde el contexto, esos tres archivos y este documento son suficientes
para retomar.
