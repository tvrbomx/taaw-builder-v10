# TAAW BUILDER V10 · REGLAS DEL PROYECTO

> Este archivo se carga solo al abrir Claude Code en este repositorio.
> Cópialo también como `AGENTS.md` si trabajas con opencode.

---

## Qué es esto

**TAAW Builder v10** es una plataforma de control de proyecto para **Dravya**, despacho
de arquitectura que además construye. Cubre diseño, cálculo, cuantificación, costo,
programa, obra y documentación. **El dinero es una de las cosas que controla, no el eje.**

La desarrolla **TAAW · ThArqum Architecture Workshop**.

Es la tercera versión. Las dos anteriores se degradaron por construir antes de saber qué
se construía. Este repositorio existe para no repetirlo.

---

## Antes de responder cualquier cosa, lee

```
docs/V10-CONCEPTO-ParaQueEsLaApp-R02.md          qué es y para qué · APROBADO
docs/V10-PLAN-DE-TRABAJO-R02.md                  orden de construcción y rebanadas
docs/V10-ARQUITECTURA.md                         stack, estructura, roles, despliegue
docs/V10-DISENO.md                               dirección visual y filosofía de interfaz
docs/V10-REQ-CicloDeObra-Cobranza-Bitacora-R01.md  el requisito funcional más detallado
docs/V10-HANDOFF-ClaudeCode.md                   estado, decisiones y errores ya cometidos
```

Sólo cuando necesites entender qué existía antes:

```
docs/referencia-v8/ESQUEMA_BASE_DE_DATOS.md      las 59 pestañas y sus anomalías
docs/referencia-v8/FORMULA_CANONICA_TPU.md       la fórmula de precio unitario
docs/referencia-v8/ESPEC_MODULO_TPU.md
docs/referencia-v8/FLUJO_COTIZACION_REQUISICION_PAGO.md
```

**No leas el repositorio de la V8 salvo que se te pida.** Es referencia histórica,
no fuente de verdad.

---

## Etapa actual

**Anteproyecto. NO SE PROGRAMA.**

El siguiente entregable es `docs/V10-MODELO-DOMINIO.md`.

El código empieza cuando estén los seis documentos pendientes y el esquema esté congelado.
Si te piden programar antes, dilo y explica por qué no conviene.

---

## Las nueve reglas invariantes

Gobiernan el modelo de datos y no se tocan. **Si una función exige romper una, no se hace
la función: se replantea.**

1. **Clave de concepto única y con formato fijo.** La base rechaza lo que no cumple
2. **Todo gasto ligado a uno o más conceptos.** Sin liga no se aprueba
3. **Los precios se guardan sin IVA.** El IVA es parámetro, nunca valor almacenado
4. **Una columna significa una sola cosa.** Nada de campos polivalentes
5. **Todo pago es un abono contra un compromiso.** Nunca un "pagado sí/no"
6. **Ningún concepto llega a 100% de avance sin carta entrega**
7. **Nada se borra.** Sólo se marca inactivo
8. **Todo cambio de estado deja rastro y dispara alerta**
9. **Todo dato pertenece a una empresa.** Nada existe fuera de una empresa

---

## Cómo trabajar conmigo

**Idioma.** Español. Siempre.

**Verifica antes de afirmar.** Nunca digas que algo funciona sin haberlo comprobado.
Nunca confíes en el reporte de otro agente sin leer el código.

**Nada destructivo sin verificación doble.** Antes de borrar, sobrescribir o mover:
comprueba el estado original, ejecuta, y vuelve a comprobar. Reporta ambos estados.

**Nunca asumas el tipo de un dato.** Un campo que parece número puede ser una fórmula,
un texto o estar vacío. Verifícalo. Este error ya costó horas de retrabajo.

**No inventes.** Si un dato no existe, dilo y márcalo como pendiente. Un hueco marcado
vale más que un dato inventado.

**Prohibido el `catch` silencioso.** Todo error se registra y se propaga o se muestra.
La versión anterior tenía 26, y de una de ellas salió un bug que borraba datos.

**Cada instrucción para otro agente va como bloque copiable** en el chat.

**Di lo que no hiciste.** Todo reporte termina con qué quedó fuera y por qué.

---

## Convenciones de código

**Regla de dependencia**, y no se rompe:

```
app  →  services  →  domain  →  data
```

Nunca al revés. Una pantalla jamás llama a Prisma directo.

- **TypeScript estricto.** Nada de `any` sin justificar en comentario
- **Sin colores literales en las pantallas.** Todo sale de los tokens de diseño
- **Toda escritura múltiple va en transacción.** Si algo falla, no se guarda nada
- **Toda consulta filtra por `empresa_id`.** El repositorio lo hace, no la pantalla
- **Los errores de negocio son tipos del dominio**, no cadenas de texto
- **Migraciones versionadas.** Nunca se edita el esquema anterior ni la base a mano
- Nombres en español para el dominio, en inglés para lo técnico del framework

---

## Convenciones de documentación

- Nombre: `V10-TEMA.md` o `V10-TEMA-R##.md` cuando haya revisiones
- Enlaces internos con `[[corchetes dobles]]`, para que el grafo de Obsidian los dibuje
- Toda decisión se registra **con su razón**, no sólo el resultado
- Cuando una decisión cambia, se escribe una revisión nueva y se marca la anterior
  como reemplazada. No se borra
- Los folios de documentos siguen la norma ISO 19650 de Dravya

---

## Definición de terminado

Nada se declara listo hasta que:

1. Un dato **real** del proyecto F-19 recorrió el flujo completo
2. Los estados vacío, cargando y error están resueltos en la interfaz
3. Se probó en modo claro y en modo oscuro
4. Se probó con dos empresas distintas y no se mezclaron los datos
5. Está escrito qué quedó fuera

---

## Qué hacer cuando aparece un requisito nuevo

Va a pasar. Es lo normal y no es un problema — **el problema es meterlo sin pensar.**

1. Pregúntate a cuál de los siete dominios pertenece. Si no pertenece a ninguno,
   **no entra**: se anota como pendiente y se decide después
2. Revisa si contradice alguna de las nueve reglas. Si la contradice, se replantea
   el requisito
3. Si obliga a cambiar el esquema y el esquema ya está congelado, **se detiene todo**
   y se avisa. No se parcha
4. Se documenta antes de programarse

**Esto es exactamente lo que quebró a las dos versiones anteriores.**

---

## Errores ya cometidos · no repetir

**En las versiones anteriores de la app:**

- Se construyó antes de saber qué se construía
- **877 conceptos con 40 formatos de identificador**, por no tener restricción de clave
- **26 capturas de error silenciosas**. De una salió un bug que borraba filas
- Se metieron temas con la app ya construida y se rompió: los colores estaban escritos
  dentro de cada pantalla
- 28 de 59 tablas creadas y vacías: estructura antes que contenido
- Pantallas hablando directo con la fuente de datos

**Al preparar la documentación:**

- Se encuadró la aplicación alrededor del dinero. Es control de proyecto
- Se mezcló el hub informativo de Dravya con los requisitos de la app
- Se propuso construir sin haber leído el código y el esquema reales

**Trabajando la hoja de cálculo del proyecto F-19:**

- Se leyeron como vacías celdas que contenían fórmulas, y se sobrescribieron
- Combinar celdas sobre filas equivocadas destruyó datos en silencio

---

## Flujos de trabajo

### Escribir un documento del anteproyecto

1. Lee el documento del que depende, completo
2. Propón el índice y espera visto bueno
3. Escribe. Cada decisión con su razón
4. Enlaza con `[[dobles corchetes]]` los documentos relacionados
5. Actualiza el mapa en `V10-PLAN-DE-TRABAJO` y el estado en `V10-HANDOFF`

### Construir una rebanada

1. Relee la rebanada en `V10-PLAN-DE-TRABAJO`
2. Verifica que su parte del esquema exista y esté congelada
3. Construye de abajo hacia arriba: datos → dominio → servicio → pantalla
4. Prueba con datos reales de F-19
5. Recorre la definición de terminado, punto por punto
6. Reporta qué quedó fuera

### Revisar trabajo de otro agente

1. **Lee el código. No creas el reporte**
2. Verifica contra las nueve reglas
3. Busca capturas silenciosas de error
4. Busca colores literales fuera de los tokens
5. Busca consultas sin filtro de empresa
6. Reporta con archivo y número de línea

---

## Decisiones pendientes

| # | Pendiente |
|---|---|
| 1 | **Formato de clave de concepto y de partida** — el prefijo y su lógica. Bloquea el esquema |
| 2 | Aero cálido contra aero frío |
| 3 | Las dos familias tipográficas |
| 4 | Catálogo definitivo de categorías de gasto |
| 5 | Logotipo de TAAW Builder y su relación con el de Dravya |

---

## Contactos y roles reales

| Persona | Roles |
|---|---|
| Stefanno Pasquali | Dirección · Coordinación de proyectos · Residencia · Administrador de la aplicación |
| Arq. Sergio García | Dirección · Validador de documentos |
| María Fernanda García | Administración de finanzas · Compras |

Un usuario puede tener varios roles a la vez. Es obligatorio.
