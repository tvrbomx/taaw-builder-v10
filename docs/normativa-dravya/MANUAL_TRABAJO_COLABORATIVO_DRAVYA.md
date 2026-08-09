# Manual de trabajo colaborativo — DRAVYA

**Revisión 01 · 1-ago-2026**

| | |
|---|---|
| **Elaboró** | Stefanno Pasquai — Dirección de proyecto |
| **Revisó** | Stefanno Pasquali — *ver nota de autorrevisión, §6.1* |
| **Aprobó** | Pendiente |
| **Aplica a** | DRAVYA — constructora, despacho de diseño y consultoría |
| **Proyecto piloto** | F-19 · Departamentos · Av. 19 Poniente 705, Puebla |
| **Reemplaza a** | `FLUJO_BIM_DRAVYA.md` · `PROTOCOLO_REVISION_DE_PLANOS.md` |

Este es **el manual de trabajo colaborativo de la empresa**. No es un documento de software.
Define cómo producimos un proyecto entre varias personas sin que se pierda información, sin
que se construya la versión equivocada y sin que nadie tenga que preguntar en qué va todo.

Está basado en normas internacionales, **adaptadas a lo que esta empresa realmente puede
sostener hoy**: tres personas, sin licencias de plataforma colaborativa, con AutoCAD como
herramienta principal de dibujo y la nube como repositorio.

---

## 1 · Qué normas adoptamos, y hasta dónde

Adoptar una norma completa cuando somos tres es la mejor forma de no adoptar ninguna. Esto es
lo que sí tomamos, lo que dejamos fuera **a propósito**, y por qué.

| Norma | Qué es | Qué adoptamos | Qué dejamos fuera |
|---|---|---|---|
| **ISO 19650** | Gestión de información en proyectos de construcción. Es la norma BIM internacional | Entorno común de datos, estados del documento, nomenclatura de archivos, control de revisiones, matriz de quién produce y quién revisa | Los documentos contractuales formales —EIR, BEP, plan maestro de entrega—. Son para licitaciones grandes y hoy no nos aportan |
| **LOD (BIMForum)** | Nivel de desarrollo: qué tan confiable es un elemento dibujado | La escala 100–500 como criterio de cierre de etapa | La especificación por familia de elementos, que es de modelador |
| **ISO 5455** | Escalas normalizadas en dibujo técnico | La tabla de escalas completa. Es obligatoria | Nada. Esta se adopta entera |
| **Reglamento municipal / INAH / protección civil** | Marco legal local | Filtro F del checklist de revisión | — |

**El principio de adaptación:** una norma se adopta cuando produce un cambio observable en el
trabajo esta semana. Si adoptarla solo genera un documento que nadie lee, no se adopta todavía.

### Lo que ISO 19650 nos aporta de verdad

Tres ideas, y las tres son gratis:

1. **Un solo lugar donde vive la información**, con estado declarado. No cinco WhatsApp con
   PDFs distintos.
2. **Un archivo dice qué es con su nombre.** Sin abrirlo se sabe proyecto, disciplina, tipo,
   contenido y revisión.
3. **Todo entregable tiene quién lo produjo, quién lo revisó y quién lo aprobó.** Sin eso no
   hay a quién preguntarle cuando algo sale mal.

Lo demás de la norma es infraestructura para consorcios de cincuenta personas. No es para
nosotros, y fingir que sí solo genera papel.

---

## 2 · El entorno común de datos (CDE)

ISO 19650 le llama CDE. En la práctica es **dónde viven los archivos y en qué estado está cada
uno**.

**Nosotros no pagamos Autodesk Construction Cloud.** El nuestro es la nube compartida —Drive o
Dropbox— con versionado de archivos y una estructura de carpetas que se respeta. Funciona
igual de bien si la disciplina se respeta, y cuesta cero.

### Estructura

```
{PROYECTO}/
├── 00-ENTRADA/              recibido de terceros, tal como llegó, sin tocar
├── ARQ/  EST/  INS/  TOP/   una carpeta por disciplina
│   ├── WIP/                 trabajo en proceso — solo lo ve quien lo hace
│   ├── PUBLICADO/           revisado y emitido — esto es lo que se usa
│   ├── PDF/                 el emitido en PDF, por fecha de paquete
│   └── SUPERADO/            versiones anteriores. NO se borran
├── REVISIONES/              archivos de revisión y reportes de observaciones
└── ENTREGA/                 lo que se le da al cliente
```

### Los cuatro estados

| Estado | Significa | Quién lo puede usar |
|---|---|---|
| **WIP** | En proceso. Puede estar mal | Solo quien lo está haciendo |
| **PUBLICADO** | Revisado, firmado, vigente | Todos. Es la única versión válida |
| **SUPERADO** | Lo reemplazó una revisión nueva | Nadie, pero **no se borra**: es el respaldo de qué se dijo y cuándo |
| **ARCHIVADO** | Proyecto cerrado | Consulta |

> **Lo que no se borra nunca es lo superado.** El día que un cliente reclame algo, la única
> defensa es poder mostrar qué versión estaba vigente en qué fecha y quién la aprobó.

### Nomenclatura

```
{PROYECTO}-{DISCIPLINA}-{TIPO}-{DESCRIPCION}-{REVISION}
```

`F19-ARQ-PLANO-PlantaBaja-R02` · `F19-EST-MEM-CalculoCimentacion-R01`

| Campo | Valores |
|---|---|
| PROYECTO | Clave corta: `F19` |
| DISCIPLINA | `ARQ` · `EST` · `INS` · `TOP` · `ADM` |
| TIPO | `PLANO` · `MEM` · `REP` · `COT` · `PRE` · `MOD` |
| DESCRIPCION | Sin espacios ni acentos, en CamelCase |
| REVISION | `R00`, `R01`, `R02`… `R00` es la primera emisión |

**Sin espacios, sin acentos, sin "final" ni "final2" ni "final_bueno".** La revisión es el
único mecanismo para decir cuál es más nuevo, y por eso es obligatoria.

### Versionado

La nube guarda historial de versiones, pero **el historial de la nube no sustituye a la
revisión en el nombre**. La nube te dice que un archivo cambió; la revisión te dice que se
emitió algo distinto y que alguien lo aprobó. No son lo mismo.

Regla: **mientras un archivo está en WIP, la nube versiona. En cuanto se publica, sube la
revisión y se copia a PUBLICADO.**

---

## 3 · El esquema de producción

```
                        PRODUCE                REVISA              APRUEBA
  ┌───────────┐  LOD 100
  │  ETAPA 1  │  volumetría    Fernanda        Stefanno           Cliente
  │  CONCEPTO │                (diseño)        (dirección)     elige opción + RANGO $$
  └─────┬─────┘
        │  cierra: el cliente eligió una opción y aceptó un RANGO de inversión
        ▼
  ┌───────────┐  LOD 200
  │  ETAPA 2  │  geometría     Fernanda        Stefanno           Stefanno
  │    ARQ    │  genérica      (diseño)        filtros A·B·E
  └─────┬─────┘
        │  cierra: el proyecto es CUANTIFICABLE
        ▼
  ┌───────────┐  LOD 300
  │  ETAPA 3  │  geometría     Max y Memo      Stefanno           Stefanno
  │    EST    │  específica    (externos,      filtros A·B·C·E
  └─────┬─────┘                 en Revit)
        │  cierra: COORDINA con arquitectura · cuantificación cuadra dentro de 5%
        ▼
  ┌───────────┐  LOD 350
  │  ETAPA 4  │  INTERFACES    Stefanno        Fernanda           Cliente
  │ EJECUTIVO │  entre         (coordinación)  filtros E·F      FIRMA presupuesto
  └─────┬─────┘  sistemas
        │  cierra: CERO interferencias críticas abiertas · catálogo cerrado
        │  ◄────── de aquí sale el presupuesto que se firma
        ▼
  ┌───────────┐  LOD 400
  │  ETAPA 5  │  fabricación   Stefanno        Fernanda           Stefanno
  │ PLANEACIÓN│                                (compras) A·B·D
  └─────┬─────┘
        │  cierra: cada concepto con proveedor y precio, o marcado como riesgo abierto
        ▼
  ┌───────────┐  LOD 500
  │  ETAPA 6  │  as-built      Residente       Stefanno           Cliente
  │ EJECUCIÓN │                                filtros A·B      recibe la obra
  └───────────┘
        cierra: entrega firmada · expediente completo
```

**La regla que sostiene todo:** una etapa no cierra por calendario, cierra porque su criterio
se cumple. Cerrada a la fuerza, el error se paga tres etapas después y multiplicado.

---

## 4 · Las seis etapas

| # | Etapa | LOD | Entregables | Criterio de cierre | En TAAW Builder |
|---|---|---|---|---|---|
| 1 | **Conceptualización** | 100 | Levantamiento con fotos fechadas · programa arquitectónico · volumetría y partido · presupuesto paramétrico por m² | Cliente eligió opción y aceptó un **rango**, no un número | Se crea proyecto y cliente. Contenedor de presupuesto *paramétrico*. Sin conceptos con tarjeta |
| 2 | **Proyecto arquitectónico** | 200 | Plantas, cortes y fachadas acotados · cuadro de áreas · albañilerías y acabados · memoria descriptiva | Es **cuantificable**: de estos planos salen volúmenes de muro, piso, plafón y ventana | Los volúmenes entran a catálogo de conceptos con su partida. El presupuesto pasa a **por concepto** |
| 3 | **Proyecto estructural** | 300 | Modelo `.rvt` · planos con despiece · memoria de cálculo · cuantificación de acero y concreto | **Coordina** con arquitectura y la cuantificación cuadra dentro de 5% | Conceptos de estructura con volumen del ingeniero. El dato más confiable del presupuesto — se marca como tal |
| 4 | **Proyecto ejecutivo** | 350 | Planos de instalaciones · **reporte de interferencias resuelto** · detalles de encuentros · especificaciones · catálogo definitivo con volúmenes | **Cero interferencias críticas abiertas** y catálogo cerrado | El presupuesto llega a revisión final. Se emite la hoja de aceptación |
| 5 | **Planeación de ejecución** | 400 | Cronograma · programa de erogaciones · cotizaciones amarradas a conceptos · plan de compras y rentas · trámites | Cada concepto con proveedor y precio, o marcado como riesgo abierto con su monto | Cronograma, flujograma, cotizaciones y programa de pagos |
| 6 | **Ejecución** | 500 | Bitácora diaria · estimaciones y avance · reporte fotográfico · as-built · manual y garantías | Entrega firmada y expediente completo | Bitácora como centro de control, cronograma con avances, libro contable |

**Por qué la etapa 4 decide todo.** La diferencia entre LOD 300 y 350 es una sola cosa: **350
modela cómo se tocan las disciplinas.** El paso de la tubería por la trabe. El registro bajo el
muro de carga. La altura libre real ya con plafón y ductos. Un proyecto que llega a obra en LOD
300 se resuelve a martillazos en campo, y eso son los extraordinarios.

**Por qué un rango en la etapa 1.** Cerrar el anteproyecto con un número exacto es la forma más
común de perder dinero: después todo cambio se lee como sobrecosto.

---

## 5 · Firmas: quién produce, quién revisa, quién aprueba

**Todo entregable lleva las tres firmas.** No es formalidad: es lo que permite saber a quién
preguntarle y quién se hace cargo.

| Rol | Qué significa |
|---|---|
| **Elaboró** | Lo produjo. Responde por el contenido |
| **Revisó** | Aplicó el checklist. Responde por lo que dejó pasar |
| **Aprobó** | Autorizó su emisión. Responde por la decisión de emitirlo |

Van en el cajetín del plano, en el encabezado del documento y en el registro de la app. Con
nombre y fecha, no con iniciales.

### 5.1 · Autorrevisión — el riesgo declarado

**Hoy Stefanno solicita, produce y revisa la mayoría de los entregables.** Eso rompe la regla
de que nadie revisa lo que dibujó, y hay que decirlo en vez de disimularlo.

Mientras dure, esto es lo que aplica:

- **Se declara.** Si Elaboró y Revisó son la misma persona, el documento lo dice. No se
  inventa un segundo nombre.
- **Se separa en el tiempo.** La revisión no se hace el mismo día que el dibujo. Al día
  siguiente se ven cosas que el día anterior eran invisibles.
- **Se revisa contra la lista, no de memoria.** El checklist del §7 se recorre casilla por
  casilla. Autorrevisar "dándole una leída" no sirve para nada.
- **Se prioriza pasar los filtros E y F a Fernanda.** Son los que ella domina —cuantificable y
  normativo— y son los que menos requieren haber dibujado el plano.

Salir de la autorrevisión es la mejora de proceso con mejor retorno que tiene la empresa hoy.
No requiere software ni dinero: requiere que una segunda persona mire.

---

## 6 · Cómo se ejecuta una revisión

### Antes de abrir el primer plano

1. **Guardar el paquete** en `00-ENTRADA/` si viene de un tercero, o en la carpeta de su
   disciplina si es nuestro, en su subcarpeta con la **fecha del paquete**. Nunca se revisa
   desde Descargas ni desde el correo.
2. **Crear el archivo de revisión** en `REVISIONES/`, nombrado `{PROYECTO}-REV-{AAAA-MM-DD}`.
   La fecha es la del paquete, no la del día que uno lo abre. Si se revisa en tres sesiones,
   sigue siendo la misma revisión y el mismo archivo.
3. **Abrir el modelo o el DWG vigente**, siempre el más reciente de PUBLICADO. Revisar un PDF
   sin el archivo vivo detecta errores de dibujo; revisar con el archivo vivo detecta errores
   de proyecto.
4. **Abrir la referencia comparable**: un proyecto anterior del mismo tipo, resuelto y
   aprobado. No para copiar, para tener a la mano cómo se resolvió lo mismo la última vez.

> F-19 va a ser la referencia de todo lo que venga después. Por eso conviene documentarlo bien
> ahora aunque cueste: es el molde de los siguientes.

### Por lámina — la solapa

Nombre, número y **revisión** · fecha · simbología de niveles **con los mismos niveles que
aparecen en las vistas** · proyecto, cliente, ubicación, disciplina · **elaboró, revisó y
aprobó, con nombre y fecha** · escala principal · estado del documento.

> La simbología de niveles que no coincide con las vistas es el hallazgo más frecuente y el más
> engañoso: el plano se ve completo, pero declara niveles que no dibuja o dibuja niveles que no
> declara. Quien construye no sabe a cuál hacerle caso.

### Por lámina — el contenido, vista por vista

No la lámina de un vistazo:

- **Nombre de la vista** describe lo que muestra —planta, corte, detalle, alzado, isométrico—
  y la clave está homologada
- **Nivel de la vista** declarado: losa, estructura, desplante, NPT
- **Elemento – Tipo – Nombre**: el elemento está nombrado y respeta la nomenclatura del
  proyecto. Un elemento sin nombre no se puede pedir, ni cotizar, ni reclamar
- **Escala** dentro de ISO 5455

**Escalas ISO 5455** — solo estas. Son múltiplos decimales de 1, 2 y 5:

| Ampliación | Natural | Reducción |
|---|---|---|
| 50:1 · 20:1 · 10:1 · 5:1 · 2:1 | 1:1 | 1:2 · 1:5 · 1:10 · 1:20 · 1:50 · 1:100 · 1:200 · 1:500 · 1:1000 · 1:2000 · 1:5000 · 1:10000 |

**1:25, 1:75 y 1:150 no existen en la norma**, aunque se usen mucho. Rompen el escalímetro. La
principal va en el cajetín; las de detalle junto a cada vista. Y siempre **escala gráfica
además de la numérica**: el PDF se imprime a cualquier tamaño y la numérica miente en cuanto
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

## 7 · Los seis filtros

| | Filtro | Pregunta | Qué se revisa |
|---|---|---|---|
| **A** | Identificación | ¿Es rastreable? | Cajetín completo · nombre según convención · **revisión visible** y cuadro de cambios · **las tres firmas** · escala numérica y gráfica · norte · estado del documento |
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

## 8 · Registro de hallazgos

Un hallazgo mal escrito no se corrige. Estas columnas son las mismas en el archivo de revisión
de hoy y en el módulo de incidencias de la app:

| Campo | Ejemplo |
|---|---|
| Folio | `F19-OBS-003` |
| Plano y revisión | `F19-EST-PLANO-Cimentacion-R02` |
| Vista | Planta de cimentación, eje 3 |
| Filtro | C — coordinación |
| Hallazgo | Bajada sanitaria de baño N2 cae sobre trabe eje 3 |
| Severidad | Crítica |
| **Lo detectó** | Stefanno · 1-ago-2026 |
| Responsable de corregir | Fernanda |
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

Un hallazgo crítico no se negocia por calendario. Es lo único de este manual que no admite
excepción: el día que se admita una, deja de servir todo lo demás.

**Cierre de ronda.** Una ronda cierra con entregable, no con un correo suelto: el plano
corregido con la revisión subida, el cuadro de cambios y las tres firmas; o —cuando revisamos a
un tercero— el reporte de observaciones enviado con acuse. Si el calendario aprieta se emite
parcial: las láminas limpias salen, las que tienen crítica se retienen y se dice **por escrito**
cuáles y por qué.

---

## 9 · Transición a Revit

**El error a evitar:** pedirle a Fernanda que aprenda Revit. Revit no se aprende, se adopta por
partes, y cada parte tiene que devolverle algo antes de pedirle la siguiente.

Ella hoy carga finanzas, compras y diseño, y ya dijo que la propia app le parece agresiva. Si
Revit entra como cuarta carga, no entra.

**El gancho:** Revit tiene tablas de planificación —tablas que cuentan solo lo que existe en el
modelo y se actualizan cuando el modelo cambia—. Mueves un muro y el m² de aplanado cambia
solo. Eso es exactamente el trabajo de Excel que ella hace hoy a mano, y el que más se rehace
cada vez que el proyecto cambia. **Ese es el argumento**, no "modelar en 3D". No le vendemos un
CAD nuevo: le vendemos dejar de recontar volúmenes en cada revisión.

| Paso | Qué pasa | Duración | Qué aprende ella |
|---|---|---|---|
| **1** | Stefanno **vincula** su DWG y el `.rvt` de Memo en Revit. Ya hay coordinación entre disciplinas | Inmediato | Nada |
| **2** | Ella aprende **solo a navegar**: abrir, moverse en 3D, mirar un corte. Cero modelado | Una tarde | Ver su proyecto en 3D y hallar sola los choques que en planta no se ven |
| **3** | Ella hace **láminas y tablas**. Es lo más parecido a lo que ya hace en Canva y Excel | 2–3 sesiones | Deja de recontar volúmenes a mano ← *el gancho* |
| **4** | Ella **modela**. Muros, pisos y vanos de **un solo nivel** de un proyecto chico | Meses, sin prisa | — |

**Reglas de la transición**

1. **F-19 no se detiene por Revit.** AutoCAD es la fuente vigente hasta que el modelo esté
   probado y firmado. Nunca se apuesta el proyecto a la herramienta nueva.
2. **Una disciplina a la vez.** Estructura ya está (Memo). Sigue arquitectura. Instalaciones al
   final.
3. **Nadie aprende algo que no va a usar esa semana.** Nada de cursos completos.
4. **El estándar de nombres es el mismo** en DWG y en RVT.
5. **Si algo se hace más lento que antes, se para y se revisa.** La adopción se justifica sola o
   no se justifica.

**Qué se le pide al Ing. Memo:** su plantilla (`.rte`) o al menos sus estándares de nombres,
niveles y claves de vista · que fije origen compartido y niveles para que su modelo y el nuestro
peguen sin reubicar · media hora de pantalla compartida sobre cómo organiza vistas y láminas.

Copiar un estándar que ya funciona y ya está probado **en este mismo proyecto** es la forma más
barata de adoptar uno. Inventar el nuestro desde cero cuesta meses y sale peor.

---

## 10 · TAAW Builder — dónde entra la app

Los archivos viven en la nube. **Los datos viven en TAAW Builder.** No es lo mismo y conviene
tenerlo claro:

| | Nube (Drive / Dropbox) | TAAW Builder |
|---|---|---|
| Guarda | Planos, modelos, PDF, fotos | Conceptos, precios, volúmenes, cronograma, pagos, bitácora |
| Versiona | Archivos | Registros con folio |
| Se consulta | Abriendo el archivo | Leyendo un tablero |

F-19 es el proyecto donde la app se está probando de verdad. Todo lo que este manual produce
como **dato** —no como archivo— tiene que terminar ahí, o el manual se queda en papel.

**Lo que la app necesita para sostener este manual:**

| # | Necesidad | Para qué |
|---|---|---|
| 1 | **Incidencias con folio** — la tabla del §8 | Es lo único que hoy vive en Excel y debería vivir en la app |
| 2 | **Etapa del proyecto**, con los seis valores del §4 | Que la carátula del proyecto diga algo verdadero |
| 3 | **Confianza del volumen** por concepto: *estimado* · *de plano* · *del estructurista* | Saber qué parte del presupuesto está en dato duro y qué parte en cálculo nuestro |
| 4 | **Plano de respaldo** en cada concepto | Responder "¿de dónde salió este volumen?" sin abrir cinco archivos |
| 5 | **Módulo de consulta de este manual** | Que Fernanda y Sergio vean el esquema y la etapa vigente sin abrir un MD |

---

## Resumen operativo

```
NORMAS      ISO 19650 (CDE, estados, nomenclatura, firmas) · LOD 100–500 · ISO 5455
            se adopta lo que cambia el trabajo esta semana; lo demás espera

GUARDAR     nube con versionado, no ACC
            00-ENTRADA · DISCIPLINA/{WIP·PUBLICADO·PDF·SUPERADO} · REVISIONES · ENTREGA
            {PROYECTO}-{DISCIPLINA}-{TIPO}-{DESCRIPCION}-{REVISION}
            lo superado NUNCA se borra

PRODUCIR    1 concepto → 2 arq → 3 est → 4 ejecutivo → 5 planeación → 6 ejecución
            una etapa cierra por criterio, no por calendario

FIRMAR      elaboró · revisó · aprobó — con nombre y fecha, en los tres
            si elaboró y revisó son la misma persona, se declara

REVISAR     A identificación · B consistencia · C coordinación
            D constructibilidad · E cuantificable · F normativo

REGISTRAR   dónde · qué · por qué · severidad · quién lo detectó
            ninguna crítica abierta al emitir

MIGRAR      vincular → navegar → láminas y tablas → modelar
            una disciplina a la vez, y el proyecto nunca se apuesta
```
