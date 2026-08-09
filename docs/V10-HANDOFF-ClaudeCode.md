# TAAW BUILDER V10 · TRASPASO A CLAUDE CODE

**R01 · 7-ago-2026**

Este documento existe para que una sesión nueva de Claude Code, sin haber estado en
ninguna conversación previa, sepa **todo lo necesario** para continuar.

**El contexto no vive en un chat. Vive en esta carpeta.**

---

## 1. Orden de lectura obligatorio

```
1. V10-CONCEPTO-ParaQueEsLaApp-R02      qué es y para qué. APROBADO
2. V10-PLAN-DE-TRABAJO-R02              orden de construcción y rebanadas
3. V10-ARQUITECTURA                     stack, estructura, roles, despliegue
4. V10-DISENO                           dirección visual y filosofía de interfaz
5. V10-REQ-CicloDeObra-Cobranza-Bitacora-R01   el requisito funcional más detallado
6. SAT-ELECTRICO-CONCEPTO               app satélite, no se desarrolla todavía
```

Después, del repositorio de la V8, **sólo para entender qué existe y qué no repetir**:

```
.agents/context/ESQUEMA_BASE_DE_DATOS.md      las 59 pestañas y sus anomalías
.agents/context/FORMULA_CANONICA_TPU.md       la fórmula de precio unitario
.agents/context/ESPEC_MODULO_TPU.md
.agents/context/FLUJO_COTIZACION_REQUISICION_PAGO.md
src/app/(app)/                                 las 60 pantallas, como referencia
```

---

## 2. Estado en una página

| | |
|---|---|
| **Producto** | TAAW Builder v10 · plataforma de control de proyecto |
| **Quién la hace** | TAAW ThArqum Architecture Workshop |
| **Quién la usa** | Dravya — arquitectura y construcción |
| **Repositorio nuevo** | `TAAW Builder v10` · aún no creado |
| **Etapa** | 2 de 4 · anteproyecto |
| **Escrito** | Concepto · Plan · Arquitectura · Diseño · Requisito de ciclo de obra |
| **Falta** | Modelo de dominio · Esquema SQL · Plataforma y migración · Catálogo de documentos · Pantallas y roles · API |
| **Código** | Cero líneas. No se programa hasta cerrar el anteproyecto |

**Nada del código de la V8 se reutiliza tal cual.** Se rescatan ideas, plantillas PDF y
la fórmula de precio unitario. Todo lo demás se rehace.

---

## 3. Las nueve reglas que no se rompen

Están en el plan de trabajo, y son la razón de existir de este proyecto.
Si una función futura exige romper una, **no se hace la función: se replantea.**

1. Clave de concepto única y con formato fijo. La base rechaza lo que no cumple
2. Todo gasto ligado a uno o más conceptos
3. Los precios se guardan sin IVA. El IVA es parámetro
4. Una columna significa una sola cosa
5. Todo pago es un abono contra un compromiso
6. Ningún concepto llega a 100% de avance sin carta entrega
7. Nada se borra. Sólo se marca inactivo
8. Todo cambio de estado deja rastro y dispara alerta
9. Todo dato pertenece a una empresa

---

## 4. Errores ya cometidos · no repetir

Esto es lo más valioso del traspaso. Cada punto costó tiempo o dinero real.

**En las versiones anteriores de la app:**

- Se construyó antes de saber qué se construía. Cada requisito nuevo movía el esquema,
  y mover el esquema rompía lo que ya servía
- **877 conceptos con 40 formatos de identificador.** Nadie lo decidió: se acumuló por
  no tener restricción de clave
- **26 capturas de error silenciosas** en cronograma, pagos, destajos, bitácora y programa
  vivo. De una de ellas salió un bug que borraba filas de la base
- Se metieron temas cuando la app ya existía y se rompió, porque los colores estaban
  escritos dentro de cada pantalla
- 28 de 59 pestañas creadas y vacías: estructura antes que contenido
- Pantallas hablando directo con la fuente de datos, sin capa intermedia

**Al preparar los documentos de esta etapa:**

- Se encuadró la aplicación alrededor del dinero. **Está mal.** Es control de proyecto;
  el dinero es una de las cosas que controla
- Se mezcló el hub informativo de Dravya con los requisitos de la app. Son productos
  distintos con públicos distintos
- Se propuso construir sin haber leído el código y el esquema reales. Leer primero

**Trabajando la hoja de cálculo del proyecto F-19:**

- Se leyeron como vacías celdas que contenían **fórmulas**, y se sobrescribieron con
  números. Nunca asumir el tipo de un dato: verificarlo
- Combinar celdas sobre filas equivocadas **destruyó datos en silencio**. Toda operación
  destructiva se verifica contra el original antes y después

---

## 5. Decisiones tomadas, con su razón

| Decisión | Razón |
|---|---|
| PostgreSQL, no Sheets | Sheets no puede rechazar un dato inválido. Es la causa raíz de todo |
| Next.js 15 + TypeScript | Se conserva: el equipo lo conoce y Dokploy lo despliega sin configuración |
| Prisma | Migraciones versionadas y tipos generados del esquema |
| Servidor propio, mini PC con Dokploy | Costo cero, sin suspensión por inactividad, respaldo local |
| Multiempresa desde el día uno | Meterlo después obliga a tocar todas las tablas |
| Un usuario, varios roles | Tres personas cubren ocho funciones |
| El eléctrico sale a satélite | Cálculos con normativa y ritmo propios. Cargárselos a la V10 la vuelve pesada |
| El esquema se congela al cerrar el anteproyecto | Es el mecanismo que impide repetir la degradación |
| La app y el Excel conviven | Hasta que la rebanada de presupuesto esté en producción |
| Los 877 conceptos se migran completos | Se depuran sobre la marcha, conservando la clave vieja en columna de trazabilidad |

---

## 6. Lo que falta decidir

| # | Pendiente | De quién |
|---|---|---|
| 1 | Formato definitivo de clave de concepto y de partida — **el prefijo y su lógica** | Stefanno, con propuesta previa |
| 2 | Aero cálido contra aero frío | Stefanno |
| 3 | Las dos familias tipográficas | Propuesta y aprobación |
| 4 | Catálogo definitivo de categorías de gasto | Stefanno |
| 5 | Logotipo de TAAW Builder y su relación con el de Dravya | Stefanno |

---

## 7. Cómo arrancar la sesión de Claude Code

**Preparativos, en orden:**

1. Crear el repositorio **`taaw-builder-v10`**, vacío
2. Copiar dentro la carpeta `APP-V10` completa, como `docs/`
3. Copiar también, en `docs/referencia-v8/`, los cuatro archivos de `.agents/context/`
   listados en §1
4. Abrir Claude Code en la raíz del repositorio nuevo
5. Pegar el mensaje de arranque de abajo

**Mensaje de arranque:**

```
Trabajamos en TAAW Builder v10, plataforma de control de proyecto para el
despacho de arquitectura y construcción Dravya.

Antes de responder nada, lee en este orden:
  docs/V10-CONCEPTO-ParaQueEsLaApp-R02.md
  docs/V10-PLAN-DE-TRABAJO-R02.md
  docs/V10-ARQUITECTURA.md
  docs/V10-DISENO.md
  docs/V10-REQ-CicloDeObra-Cobranza-Bitacora-R01.md
  docs/V10-HANDOFF-ClaudeCode.md

Reglas de trabajo:
- Estamos en etapa de anteproyecto. NO se programa todavía.
- El siguiente entregable es docs/V10-MODELO-DOMINIO.md
- Las nueve reglas invariantes del §3 del handoff no se rompen. Si algo
  las contradice, se replantea la función, no la regla.
- Hablo español. Cada instrucción para otro agente va como bloque copiable.
- Nunca confíes en un reporte sin verificar el código.
- Ninguna operación destructiva sin verificar antes y después contra el original.

Empieza escribiendo docs/V10-MODELO-DOMINIO.md, y antes de escribirlo
propón el formato de clave de concepto y de partida, que es la decisión
pendiente número 1.
```

---

## 8. Qué sigue después del modelo de dominio

```
V10-MODELO-DOMINIO      entidades, relaciones, máquinas de estado
      ↓
V10-ESQUEMA-SQL         el esquema que se congela
      ↓
V10-PLATAFORMA-Y-MIGRACION    migración de los 877 conceptos
      ↓
V10-CATALOGO-DOCUMENTOS       qué PDF emite cada entidad
      ↓
V10-PANTALLAS-Y-ROLES
      ↓
V10-API
      ↓
REBANADA 1 · arquitectura y sistema de diseño   ← aquí empieza el código
```

---

*Este archivo es la memoria del proyecto. Si algo importante se decide, se anota aquí.*
