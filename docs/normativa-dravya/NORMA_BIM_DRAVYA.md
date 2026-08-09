# Norma interna BIM — DRAVYA

**1-ago-2026 · Revisión 01.** Norma interna basada en ISO 19650. Define **el orden en que se
produce un proyecto**, **qué se entrega y quién lo revisa en cada etapa**, y **cómo migramos a
Revit sin romper a nadie**.

Unifica y reemplaza a `FLUJO_BIM_DRAVYA.md` y `PROTOCOLO_REVISION_DE_PLANOS.md`.

Aplica a los tres giros: constructora, despacho de diseño y consultoría.
Proyecto piloto: **F-19** (Departamentos, Av. 19 Poniente 705, Puebla).

---

## 1 · El esquema

```
                    ENTREGA                      REVISA                    APRUEBA
        ┌──────────────────────────┬────────────────────────┬────────────────────────┐
        │                          │                        │                        │
  ┌─────┴─────┐              ┌─────┴─────┐            ┌─────┴─────┐
  │  ETAPA 1  │  LOD 100     │ Fernanda  │            │ Stefanno  │            Cliente
  │  CONCEPTO │  volumetría  │  diseño   │            │ dirección │         elige opción
  └─────┬─────┘              └───────────┘            └───────────┘         + rango $$
        │  cierra: cliente eligió opción y aceptó un RANGO de inversión
        ▼
  ┌───────────┐              ┌───────────┐            ┌───────────┐
  │  ETAPA 2  │  LOD 200     │ Fernanda  │            │ Stefanno  │
  │    ARQ    │  geometría   │  diseño   │            │  filtros  │
  └─────┬─────┘  genérica    └───────────┘            │  A B E    │
        │  cierra: el proyecto es CUANTIFICABLE       └───────────┘
        ▼
  ┌───────────┐              ┌───────────┐            ┌───────────┐
  │  ETAPA 3  │  LOD 300     │ Max/Memo  │            │ Stefanno  │
  │   EST     │  geometría   │ externos  │            │  filtros  │
  └─────┬─────┘  específica  │  (Revit)  │            │  A B C E  │
        │  cierra: COORDINA con arquitectura · cuantificación cuadra <5%
        ▼
  ┌───────────┐              ┌───────────┐            ┌───────────┐
  │  ETAPA 4  │  LOD 350     │ Stefanno  │            │  Fernanda │
  │ EJECUTIVO │  INTERFACES  │coordinación│           │  filtros  │
  └─────┬─────┘  entre       └───────────┘            │   E F     │
        │        sistemas                             └───────────┘
        │  cierra: CERO interferencias críticas · catálogo cerrado
        │  ◄── de aquí sale el presupuesto que se FIRMA
        ▼
  ┌───────────┐              ┌───────────┐            ┌───────────┐
  │  ETAPA 5  │  LOD 400     │ Stefanno  │            │  Fernanda │
  │ PLANEACIÓN│  fabricación │           │            │  compras  │
  └─────┬─────┘              └───────────┘            └───────────┘
        │  cierra: cada concepto con proveedor y precio, o marcado como riesgo abierto
        ▼
  ┌───────────┐              ┌───────────┐
  │  ETAPA 6  │  LOD 500     │ Residente │
  │ EJECUCIÓN │  as-built    │  en obra  │
  └───────────┘              └───────────┘
           cierra: entrega firmada · expediente completo
```

**La regla que sostiene todo:** una etapa no cierra por calendario, cierra porque su criterio
se cumple. Cerrada a la fuerza, el error se paga tres etapas después y multiplicado.

**LOD** (Level of Development, BIMForum) no es adorno: define qué se puede confiar de un
dibujo. Un plano LOD 200 sirve para estimar, no para comprar material.

---

## 2 · Las seis etapas, en detalle

| # | Etapa | LOD | Entregables | Criterio de cierre | En la app |
|---|---|---|---|---|---|
| 1 | **Conceptualización** | 100 | Levantamiento con fotos fechadas · programa arquitectónico · volumetría y partido · presupuesto paramétrico por m² | Cliente eligió opción y aceptó un **rango**, no un número | Se crea proyecto y cliente. Contenedor de presupuesto tipo *paramétrico*. Sin conceptos con tarjeta |
| 2 | **Proyecto arquitectónico** | 200 | Plantas, cortes y fachadas acotados · cuadro de áreas · plano de albañilerías y de acabados · memoria descriptiva | Es **cuantificable**: de estos planos salen volúmenes de muro, piso, plafón y ventana | Los volúmenes entran a catálogo de conceptos con su partida. El presupuesto pasa de paramétrico a **por concepto** |
| 3 | **Proyecto estructural** | 300 | Modelo `.rvt` · planos con despiece · memoria de cálculo · cuantificación de acero y concreto | **Coordina** con arquitectura y la cuantificación cuadra dentro de 5% | Conceptos de estructura con volumen del ingeniero. Es el dato más confiable del presupuesto — se marca como tal |
| 4 | **Proyecto ejecutivo** | 350 | Planos de instalaciones · **reporte de interferencias resuelto** · detalles de encuentros · especificaciones · catálogo definitivo con volúmenes | **Cero interferencias críticas abiertas** y catálogo cerrado | El presupuesto llega a revisión final. Se emite la hoja de aceptación |
| 5 | **Planeación de ejecución** | 400 | Cronograma · programa de erogaciones · cotizaciones amarradas a conceptos · plan de compras y rentas · trámites | Cada concepto con proveedor y precio, o marcado como riesgo abierto con su monto | Cronograma, flujograma y cotizaciones |
| 6 | **Ejecución** | 500 | Bitácora diaria · estimaciones y avance · reporte fotográfico · as-built · manual y garantías | Entrega firmada y expediente completo | Bitácora como centro de control, cronograma con avances, libro contable |

**Por qué la etapa 4 es la que decide todo.** La diferencia entre LOD 300 y LOD 350 es una
sola cosa: **350 modela cómo se tocan las disciplinas.** El paso de la tubería por la trabe. El
registro bajo el muro de carga. La altura libre real ya con plafón y ductos. Un proyecto que
llega a obra en LOD 300 se resuelve a martillazos en campo, y eso son los extraordinarios.

**Por qué el rango en la etapa 1.** Cerrar el anteproyecto con un número exacto es la forma más
común de perder dinero: después todo cambio se lee como sobrecosto.

---

## 3 · Revisión: quién revisa qué

Con tres personas no hay revisor dedicado, así que la regla se reduce a una:
**nadie revisa lo que dibujó.** Autorrevisar no funciona — el que dibuja ve lo que quiso
dibujar.

| Etapa | Lo produce | Lo revisa | Filtros que aplican |
|---|---|---|---|
| 1 | Fernanda | Stefanno | — (es exploración) |
| 2 | Fernanda | Stefanno | A · B · **E** |
| 3 | Max y Memo (externos) | Stefanno | A · B · **C** · E |
| 4 | Stefanno | Fernanda | **E · F** |
| 5 | Stefanno | Fernanda | A · B · **D** |
| 6 | Residente | Stefanno | A · B |

La asignación de la etapa 4 a Fernanda no es de relleno: es la que mejor detecta si un plano
permite cotizar, porque es la que sufre cuando no permite.

### Los seis filtros

| | Filtro | Pregunta | Qué se revisa |
|---|---|---|---|
| **A** | Identificación | ¿Es rastreable? | Cajetín · nombre de archivo según convención · **revisión visible** y cuadro de cambios · fecha y responsables · escala numérica **y gráfica** · norte · estado WIP/Publicado/Superado |
| **B** | Consistencia interna | ¿Cuadra consigo mismo? | Ejes iguales en todas las vistas · cotas parciales suman la general · NPT de planta = NPT de corte · toda referencia existe · simbología en leyenda · muros con espesor real · cuadros de vanos que coinciden |
| **C** | Coordinación | ¿Chocan? | Ejes y niveles ARQ = EST · ninguna instalación cruza trabe sin paso previsto · bajadas no caen en columna · registros accesibles · altura libre real ≥ mínimo · preparaciones previstas en el colado · cuantificación del estructurista vs la nuestra <5% |
| **D** | Constructibilidad | ¿Se puede construir? | Secuencia lógica · cabe maquinaria, andamio y material · materiales que se consiguen en Puebla · tolerancias realistas · juntas definidas · impermeabilización y pendientes resueltas |
| **E** | Cuantificable | ¿De aquí sale presupuesto? | Cada elemento con medida suficiente · acabados por espacio, no "según proyecto" · cuadro de áreas · cuadros de vanos, muebles y herrería · cada concepto con respaldo en un plano identificable |
| **F** | Normativo | ¿Es autorizable? | Reglamento municipal vigente · alineamiento, COS, CUS, altura · Centro Histórico e INAH cuando aplique · accesibilidad · protección civil · firma de perito o DRO |

> **El filtro C es el que paga la revisión.** Una interferencia detectada en plano cuesta una
> hora de dibujo. La misma en obra cuesta demoler, rehacer y discutir de quién es la culpa.

> **Prueba dura del filtro E:** si un tercero que no conoce el proyecto puede sacar el volumen
> de un concepto usando solo el plano, pasa. Si tiene que preguntar, no pasa.

---

## 4 · Cómo se ejecuta una revisión

### Antes de abrir el primer plano

1. **Guardar el paquete** en la carpeta de su disciplina, en su subcarpeta con la fecha del
   paquete. Nunca se revisa desde Descargas ni desde el correo.
   `{PROYECTO}/{DISCIPLINA}/PDF/{AAAA-MM-DD} paquete recibido/`
2. **Crear el archivo de revisión** en `REVISIONES/`, nombrado `{PROYECTO}-REV-{AAAA-MM-DD}`.
   La fecha es la **del paquete**, no la del día que uno lo abre. Si se revisa en tres
   sesiones, sigue siendo la misma revisión y el mismo archivo.
3. **Abrir el modelo**, siempre el más reciente de la fuente oficial. Revisar un PDF sin el
   modelo detecta errores de dibujo; revisar con el modelo detecta errores de proyecto.
4. **Abrir la referencia comparable**: un proyecto anterior del mismo tipo, resuelto y
   aprobado. No para copiar, para tener a la mano cómo se resolvió lo mismo la última vez.

> F-19 va a ser la referencia de todo lo que venga después. Por eso conviene documentarlo bien
> ahora aunque cueste: es el molde de los siguientes.

### Por lámina

**Solapa** — nombre, número y **revisión** · fecha · simbología de niveles **con los mismos
niveles que aparecen en las vistas** · proyecto, cliente, ubicación, disciplina · quién
elaboró, revisó y autorizó · escala principal · estado del documento.

> La simbología de niveles que no coincide con las vistas es el hallazgo más frecuente y el más
> engañoso: el plano se ve completo, pero declara niveles que no dibuja o dibuja niveles que no
> declara. Quien construye no sabe a cuál hacerle caso.

**Contenido, vista por vista** — no la lámina de un vistazo:

- **Nombre de la vista** describe lo que muestra —planta, corte, detalle, alzado, isométrico— y
  la clave está homologada
- **Nivel de la vista** declarado: losa, estructura, desplante, NPT
- **Elemento – Tipo – Nombre**: el elemento está nombrado y respeta la nomenclatura del
  proyecto. Un elemento sin nombre no se puede pedir, ni cotizar, ni reclamar
- **Escala** dentro de **ISO 5455**

**Escalas ISO 5455** — solo estas, múltiplos decimales de 1, 2 y 5:

| Ampliación | Natural | Reducción |
|---|---|---|
| 50:1 · 20:1 · 10:1 · 5:1 · 2:1 | 1:1 | 1:2 · 1:5 · 1:10 · 1:20 · 1:50 · 1:100 · 1:200 · 1:500 · 1:1000 · 1:2000 · 1:5000 · 1:10000 |

**1:25, 1:75 y 1:150 no existen en la norma**, aunque se usen mucho. Rompen el escalímetro. La
escala principal va en el cajetín; las de detalle junto a cada vista. Y siempre escala gráfica
además de la numérica: el PDF se imprime a cualquier tamaño y la numérica miente en cuanto
alguien lo escala a otro papel.

### Reglas condicionales

Solo aplican si se cumple la condición. Anotarlas cuando no aplica es ruido que hace que nadie
lea el reporte.

| Condición | Qué se revisa |
|---|---|
| Hay placas con perforación en esta lámina o grupo | **Tabla de avellanados** presente y completa |
| Hay elementos soldados | Simbología de soldadura con tamaño y tipo |
| Hay elementos atornillados | Cuadro de tornillería: diámetro, grado, longitud, cantidad |
| Hay despiece de acero | Cuantificación que cierre contra la del cálculo |
| Hay instalaciones cruzando estructura | Pasos previstos y aprobados por el estructurista |

> La regla de avellanados es el ejemplo de por qué esto va escrito: solo importa cuando hay
> placas perforadas, y si no está en una lista se olvida justo en la lámina donde sí importaba.

---

## 5 · Registro de hallazgos

Un hallazgo mal escrito no se corrige. Estas columnas son las mismas en el Excel de hoy y en el
módulo de la app de mañana:

| Campo | Ejemplo |
|---|---|
| Folio | `F19-OBS-003` |
| Plano y revisión | `F19-EST-PLANO-Cimentacion-R02` |
| Vista | Planta de cimentación, eje 3 |
| Filtro | C — coordinación |
| Hallazgo | Bajada sanitaria de baño N2 cae sobre trabe eje 3 |
| Severidad | Crítica |
| Responsable | Fernanda |
| Estado | Abierto |
| Revisión que lo cierra | R03 |

**Cómo se escribe.** Tres partes en este orden: **dónde** (plano, vista, eje o nivel), **qué**
(el hecho observable), **por qué** (la consecuencia si se construye así).

- ❌ *"Revisar cimentación"* — nadie sabe qué corregir
- ❌ *"Está mal la trabe del eje 3"* — dice dónde, no qué ni por qué
- ✅ *"Planta de cimentación, eje 3 entre B y C: la bajada sanitaria del baño N2 cruza el
  peralte de la trabe TR-02. Si se construye así hay que perforar la trabe fuera de la zona
  permitida o reubicar el mueble."*

**Severidad, criterio único:**

- **Crítica** — si se construye así, se demuele. **Detiene la emisión del plano.**
- **Mayor** — genera costo o retraso. Se corrige antes de mandar a obra.
- **Menor** — no afecta obra. Se acumula para la siguiente revisión.

Un hallazgo crítico no se negocia por calendario. Es lo único de esta norma que no admite
excepción: el día que se admita una, deja de servir todo lo demás.

**Cierre de ronda.** Una ronda cierra con entregable, no con un correo suelto: el plano
corregido con la revisión subida y el cuadro de cambios, o —cuando revisamos a un tercero— el
reporte de observaciones enviado con acuse. Si el calendario aprieta se emite parcial: las
láminas limpias salen, las que tienen crítica se retienen y se dice por escrito cuáles y por
qué.

---

## 6 · Transición a Revit

**El error a evitar:** pedirle a Fernanda que aprenda Revit. Revit no se aprende, se adopta por
partes, y cada parte tiene que devolverle algo antes de pedirle la siguiente.

Ella hoy carga finanzas, compras y diseño, y ya dijo que la propia app le parece agresiva. Si
Revit entra como cuarta carga, no entra.

### El gancho

Revit tiene **tablas de planificación**: tablas que cuentan solo lo que existe en el modelo y se
actualizan cuando el modelo cambia. Mueves un muro y el m² de aplanado cambia solo.

Eso es exactamente el trabajo de Excel que ella hace hoy a mano, y el que más se rehace cada vez
que el proyecto cambia. **Ese es el argumento**, no "modelar en 3D". No le vendemos un CAD
nuevo: le vendemos dejar de recontar volúmenes en cada revisión.

### Los cuatro pasos

| Paso | Qué pasa | Duración | Qué aprende ella |
|---|---|---|---|
| **1** | Stefanno **vincula** su DWG y el `.rvt` de Memo en Revit. Ya hay coordinación entre disciplinas | Inmediato | Nada |
| **2** | Ella aprende **solo a navegar**: abrir, moverse en 3D, mirar un corte. Cero modelado | Una tarde | Ver su proyecto en 3D y hallar sola los choques que en planta no se ven |
| **3** | Ella hace **láminas y tablas**. Es lo más parecido a lo que ya hace en Canva y Excel | 2–3 sesiones | Deja de recontar volúmenes a mano ← *el gancho* |
| **4** | Ella **modela**. Muros, pisos y vanos de **un solo nivel** de un proyecto chico | Meses, sin prisa | — |

Mientras tanto Stefanno modela F-19 sobre el DWG vinculado, en paralelo. Si el Revit se atora,
AutoCAD sigue siendo la fuente vigente.

### Reglas de la transición

1. **F-19 no se detiene por Revit.** AutoCAD es la fuente vigente hasta que el modelo esté
   probado y firmado. Nunca se apuesta el proyecto a la herramienta nueva.
2. **Una disciplina a la vez.** Estructura ya está (Memo). Sigue arquitectura. Instalaciones al
   final.
3. **Nadie aprende algo que no va a usar esa semana.** Nada de cursos completos.
4. **El estándar de nombres es el mismo** en DWG y en RVT.
5. **Si algo se hace más lento que antes, se para y se revisa.** La adopción se justifica sola o
   no se justifica.

### Qué se le pide al Ing. Memo

- Su **plantilla** (`.rte`), o al menos sus estándares de nombres, niveles y claves de vista
- Que fije **origen compartido y niveles** para que su modelo y el nuestro peguen sin reubicar
- Media hora de pantalla compartida sobre cómo organiza vistas y láminas

Copiar un estándar que ya funciona y ya está probado **en este mismo proyecto** es la forma más
barata de adoptar uno. Inventar el nuestro desde cero cuesta meses y sale peor.

---

## 7 · Qué necesita la app

Nada mayor. Cuatro cosas, en orden de valor:

| # | Necesidad | Cómo se resuelve |
|---|---|---|
| 1 | **Incidencias con folio** | La tabla de la sección 5 como módulo, ligada al proyecto. Es lo único que hoy vive en Excel y debería vivir en la app |
| 2 | **Etapa del proyecto** | Campo con los seis valores de la sección 2. Barato, y hace que la carátula del proyecto diga algo verdadero |
| 3 | **Confianza del volumen** | Marca por concepto: *estimado* · *de plano* · *del estructurista* |
| 4 | **Plano de respaldo** | Campo en el concepto. Responde "¿de dónde salió este volumen?" sin abrir cinco archivos |

Más un **módulo de consulta** que muestre esta norma dentro de la app: el esquema de la sección
1 como diagrama, y cada etapa desplegable con sus entregables, su criterio de cierre y quién
revisa. Ligero, de lectura, sin escribir en la base de datos. Sirve para que Fernanda y Sergio
sepan en qué etapa está el proyecto sin tener que abrir un MD.

---

## Resumen operativo

```
PRODUCIR          1 concepto → 2 arq → 3 est → 4 ejecutivo → 5 planeación → 6 ejecución
                  una etapa cierra por criterio, no por calendario

REVISAR           nadie revisa lo que dibujó
                  A identificación · B consistencia · C coordinación
                  D constructibilidad · E cuantificable · F normativo

EJECUTAR          guardar paquete con fecha → archivo de revisión → modelo más reciente
                  → referencia comparable → solapa → vista por vista → condicionales

REGISTRAR         dónde · qué · por qué · severidad
                  ninguna crítica abierta al emitir

MIGRAR            vincular → navegar → láminas y tablas → modelar
                  una disciplina a la vez, y el proyecto nunca se apuesta
```
