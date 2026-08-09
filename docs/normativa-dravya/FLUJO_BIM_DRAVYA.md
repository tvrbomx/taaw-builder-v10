# Flujo de trabajo BIM — DRAVYA

**1-ago-2026.** Documento de proceso, no de software. Define **en qué orden se produce un
proyecto**, **qué se entrega en cada etapa**, **cómo se revisa un plano antes de que salga**
y **cómo migramos a Revit sin romper a nadie**.

Aplica a los tres giros: constructora, despacho de diseño y consultoría. El proyecto piloto
es **F-19 (Departamentos, Av. 19 Poniente 705, Puebla)**.

---

## PARTE 0 — Por qué esto ahora

Tres cosas se juntaron y conviene aprovecharlas:

1. **El Ing. Memo ya trabaja en Revit** y su modelo estructural de F-19 existe hoy
   (`Est.Deptos(0707).rvt`). Es un modelo real, coordinado, gratis para nosotros. No hay
   que convencer a nadie ni pagar nada para empezar a coordinar contra él.
2. **La carpeta F-19 ya está organizada como CDE** sin que le pusiéramos el nombre:
   disciplina (ARQ/EST/INS), estado (WIP → Published → Archived) y nomenclatura
   `F19-DISCIPLINA-TIPO-DESCRIPCION-REVISION`. Eso es, literalmente, lo que pide la ISO
   19650. Ya lo estamos haciendo; falta nombrarlo y aplicarlo siempre.
3. **La app ya guarda lo que el proceso produce**: conceptos, volúmenes, cronograma,
   bitácora. Lo que falta no es guardar, es **decidir en qué momento se guarda qué**.

El riesgo real no es técnico. Es que Fernanda lleve finanzas, diseño y ahora una
herramienta nueva, y truene. La Parte 3 está escrita alrededor de eso.

---

## PARTE 1 — Las seis etapas

Cada etapa tiene **entregable**, **criterio de cierre** y **nivel de detalle**. Una etapa no
se cierra por calendario, se cierra porque su criterio se cumple. Si se cierra a la fuerza,
el error se paga tres etapas después y multiplicado.

El nivel de detalle usa la escala **LOD** (Level of Development, estándar BIMForum). No es
adorno: define qué se puede confiar de un dibujo. Un plano LOD 200 sirve para estimar, no
para comprar material.

---

### Etapa 1 — Conceptualización (anteproyecto)

| | |
|---|---|
| **LOD** | 100 — volumen, superficie, orientación. Nada tiene medida definitiva |
| **Quién** | Fernanda (diseño) con dirección de Stefanno |
| **Herramienta hoy** | AutoCAD + SketchUp + Canva |
| **Herramienta destino** | Revit masas conceptuales *(etapa lejana, no urge)* |

**Entregables**

- Levantamiento del predio o del inmueble existente, con fotos fechadas
- Programa arquitectónico: cuántos espacios, de qué tamaño, para quién
- Volumetría y una o varias opciones de partido
- **Presupuesto paramétrico** — precio por m² por tipología, no por concepto

**Criterio de cierre:** el cliente eligió una opción y aceptó un rango de inversión.
No un número: un **rango**. Cerrar el anteproyecto con un número exacto es la forma más
común de perder dinero, porque después todo cambio se lee como sobrecosto.

**En la app:** se crea el proyecto y el cliente. Se crea un contenedor de presupuesto de
tipo *paramétrico*. Todavía no hay conceptos con tarjeta.

---

### Etapa 2 — Proyecto arquitectónico

| | |
|---|---|
| **LOD** | 200 — geometría genérica con tamaño, forma y ubicación aproximados |
| **Quién** | Fernanda |
| **Herramienta hoy** | AutoCAD |
| **Herramienta destino** | Revit — **aquí es donde entra, y solo aquí** (ver Parte 3) |

**Entregables**

- Plantas, cortes y fachadas acotados
- Cuadro de áreas
- Plano de albañilerías y plano de acabados
- Memoria descriptiva

**Criterio de cierre:** el proyecto es **cuantificable**. Si de estos planos no se pueden
sacar volúmenes de muro, piso, plafón y ventana, la etapa no está cerrada aunque el dibujo
se vea terminado. Esta es la prueba que hay que aplicar, no "¿ya está bonito?".

**En la app:** los volúmenes salen de aquí y entran a *catálogo de conceptos* con su
partida. El presupuesto pasa de paramétrico a **por concepto**.

---

### Etapa 3 — Proyecto estructural

| | |
|---|---|
| **LOD** | 300 — geometría específica, con cantidad, tamaño, forma y ubicación reales |
| **Quién** | Ing. Maximino Ayala y M.I. Guillermo Guerrero (externos) |
| **Herramienta** | Revit — **ellos ya lo hacen** |

**Entregables**

- Modelo estructural `.rvt`
- Planos estructurales con despiece
- Memoria de cálculo
- **Cuantificación de acero y concreto** (en F-19 es la hoja ES-7)

**Criterio de cierre:** el modelo estructural **coordina** con el arquitectónico. No que
exista: que no choque. Y que la cuantificación del ingeniero cuadre con la nuestra dentro
de un 5%. Si no cuadra, alguno de los dos está mal y hay que saber cuál **antes** de comprar
varilla.

**En la app:** los conceptos de estructura entran con volumen del ingeniero, no estimado
por nosotros. Es el dato más confiable de todo el presupuesto — se marca como tal.

---

### Etapa 4 — Proyecto ejecutivo

| | |
|---|---|
| **LOD** | 350 — **incluye las interfaces entre sistemas** |
| **Quién** | Coordinación (Stefanno) con las tres disciplinas |

Esta es la etapa que casi nadie hace bien y la que decide si la obra se atora.

La diferencia entre LOD 300 y LOD 350 es una sola cosa: **350 modela cómo se tocan las
disciplinas**. El paso de la tubería por la trabe. El registro que cae bajo el muro de
carga. La altura libre real después de plafón y ductos. Un proyecto que llega a obra en
LOD 300 se resuelve a martillazos en campo, y eso son los extraordinarios.

**Entregables**

- Planos de instalaciones: hidráulica, sanitaria, eléctrica, gas
- **Reporte de interferencias resuelto** — el clash detection
- Detalles constructivos de los encuentros
- Especificaciones técnicas por concepto
- **Catálogo de conceptos definitivo con volúmenes**

**Criterio de cierre:** cero interferencias críticas abiertas y catálogo cerrado. De aquí
sale el presupuesto que se firma.

**En la app:** el presupuesto llega a su revisión final. Se emite la hoja de aceptación.

---

### Etapa 5 — Planeación de ejecución

| | |
|---|---|
| **LOD** | 400 en lo que se fabrica a medida (herrería, cancelería, muebles) |
| **Quién** | Stefanno con Fernanda (compras) |

**Entregables**

- Cronograma de obra
- **Programa de erogaciones** — el cronograma visto desde la caja
- Cotizaciones por partida, amarradas a conceptos
- Plan de compras y rentas
- Plan de seguridad y trámites

**Criterio de cierre:** cada concepto del presupuesto tiene proveedor asignado y precio
cotizado, o está marcado como riesgo abierto con su monto. Un presupuesto donde el 20% no
está cotizado no está planeado, está apostado.

**En la app:** cronograma, flujograma y cotizaciones. Todo lo que ya existe.

---

### Etapa 6 — Ejecución

| | |
|---|---|
| **LOD** | 500 — as-built, lo que realmente quedó |
| **Quién** | Residente en obra, coordinación en oficina |

**Entregables**

- Bitácora diaria
- Estimaciones y avance
- Reporte fotográfico
- Planos as-built
- Manual de operación y garantías

**Criterio de cierre:** entrega firmada y expediente completo.

**En la app:** bitácora como centro de control, cronograma con avances, libro contable.

---

## PARTE 2 — Checklist de revisión de planos

**Regla:** ningún plano sale a obra ni al cliente sin pasar este filtro. Lo aplica alguien
que **no** lo dibujó. Autorrevisar no funciona; el que dibuja ve lo que quiso dibujar.

Cada casilla que falla se levanta como **incidencia con folio**, se corrige, y sube la
revisión. No se corrige en silencio.

---

### A. Identificación — ¿este plano es rastreable?

- [ ] Cajetín completo: proyecto, cliente, ubicación, disciplina, contenido
- [ ] Nombre de archivo según convención `F19-DISCIPLINA-TIPO-DESCRIPCION-REVISION`
- [ ] Número de revisión visible **y** cuadro de control de cambios con qué cambió
- [ ] Fecha de emisión y quién lo elaboró, revisó y autorizó
- [ ] Escala indicada **y** escala gráfica (el PDF se imprime a cualquier tamaño)
- [ ] Norte en todas las plantas
- [ ] Estado del documento: WIP · Publicado · Superado

> Un plano sin revisión visible es la causa número uno de que se construya la versión
> equivocada. Si dos personas tienen dos PDF distintos y ninguno dice cuál es más nuevo,
> alguien va a colar el que tenía a la mano.

---

### B. Consistencia interna — ¿el plano cuadra consigo mismo?

- [ ] Ejes nombrados igual en todas las plantas, cortes y con estructura
- [ ] Las cotas parciales suman la cota general
- [ ] Niveles NPT declarados en planta coinciden con los cortes
- [ ] Todo corte y detalle referenciado **existe** y está en el plano que dice
- [ ] Simbología usada aparece en la leyenda
- [ ] Muros con espesor real, no línea doble genérica
- [ ] Puertas y ventanas con número de cuadro, y el cuadro coincide

---

### C. Coordinación entre disciplinas — ¿chocan?

- [ ] Ejes y niveles arquitectónicos = ejes y niveles estructurales
- [ ] Ninguna instalación cruza trabe o castillo sin paso previsto
- [ ] Bajadas de agua pluvial y sanitaria no caen en columna ni trabe
- [ ] Registros sanitarios accesibles, no bajo muro de carga ni bajo mueble fijo
- [ ] Altura libre real ≥ mínimo, ya descontando plafón, ductos y luminarias
- [ ] Tableros y medidores en lugar accesible y permitido
- [ ] Preparaciones de instalación previstas en el colado, no picadas después
- [ ] Cuantificación del estructurista contra la nuestra, diferencia < 5%

> Esta sección es la que ahorra dinero. Una interferencia detectada en plano cuesta una
> hora de dibujo. La misma interferencia detectada en obra cuesta demoler, rehacer y
> discutir con el cliente de quién es la culpa.

---

### D. Constructibilidad — ¿se puede construir?

- [ ] Existe secuencia lógica: lo que se construye primero es accesible
- [ ] Cabe la maquinaria, el andamio y el material por donde tiene que entrar
- [ ] Los detalles usan materiales y medidas que se consiguen en Puebla
- [ ] Tolerancias realistas — nada que exija precisión de taller en obra
- [ ] Juntas constructivas y de dilatación definidas
- [ ] Impermeabilización y pendientes resueltas, con dirección de escurrimiento

---

### E. Cuantificable — ¿de aquí sale presupuesto?

- [ ] Cada elemento tiene medida suficiente para sacar volumen
- [ ] Acabados especificados por espacio, no "según proyecto"
- [ ] Cuadro de áreas por nivel y total
- [ ] Cuadros de vanos, muebles y herrería completos
- [ ] Cada concepto del presupuesto tiene respaldo en un plano identificable

> Prueba dura: si un tercero que no conoce el proyecto puede sacar el volumen de un
> concepto usando solo el plano, pasa. Si tiene que preguntar, no pasa.

---

### F. Normativo y legal

- [ ] Cumple reglamento de construcción municipal vigente
- [ ] Restricciones del predio respetadas: alineamiento, COS, CUS, altura
- [ ] Centro Histórico: criterios de imagen urbana e INAH cuando aplique
- [ ] Accesibilidad donde sea exigible
- [ ] Protección civil: salidas, señalización, extintores
- [ ] Firma de perito o DRO cuando el trámite lo requiera

---

### Cómo se registra

| Campo | Ejemplo |
|---|---|
| Folio | `F19-RFI-003` |
| Plano y revisión | `F19-ARQ-PLANO-Arquitectonico-R02` |
| Sección del checklist | C — coordinación |
| Hallazgo | Bajada sanitaria de baño N2 cae sobre trabe eje 3 |
| Severidad | Crítica · Mayor · Menor |
| Responsable | Fernanda |
| Estado | Abierto · En revisión · Cerrado |
| Revisión que lo cierra | R03 |

**Severidad, criterio único:**

- **Crítica** — si se construye así, se demuele. Detiene la emisión del plano.
- **Mayor** — genera costo o retraso. Se corrige antes de mandar a obra.
- **Menor** — no afecta obra. Se acumula para la siguiente revisión.

Esto vive en la app como incidencias ligadas al proyecto, con el mismo folio consecutivo
que ya usan los demás documentos.

---

## PARTE 3 — Transición a Revit, sin romper a nadie

**El error a evitar:** pedirle a Fernanda que aprenda Revit. Revit no se aprende, se
adopta por partes, y cada parte tiene que devolverle algo antes de pedirle lo siguiente.

Ella hoy tiene tres cargas: finanzas, compras y diseño. Y ya dijo que la propia app le
parece agresiva. Si Revit entra como una cuarta carga, no entra.

### Lo que sí motiva

Revit tiene **tablas de planificación** (*schedules*): tablas que cuentan solo lo que
existe en el modelo y se actualizan cuando el modelo cambia. Si mueves un muro, el m² de
aplanado cambia en la tabla. Sola.

Eso es exactamente el trabajo de Excel que ella hace hoy a mano para sacar volúmenes, y es
el trabajo que más se rehace cada vez que el proyecto cambia. **Ese es el gancho**, no
"modelar en 3D". A ella no le vendemos un CAD nuevo, le vendemos dejar de recontar
volúmenes cada revisión.

### Los cuatro pasos, en orden

**Paso 1 — Su DWG entra al modelo sin que ella cambie nada.**
Revit **vincula** archivos de AutoCAD de forma nativa. Stefanno abre Revit, vincula el DWG
de Fernanda, y vincula el `.rvt` del Ing. Memo. Ya hay coordinación entre las dos
disciplinas y Fernanda no hizo nada distinto.
*Duración: inmediato. Lo que ella aprende: nada.*

**Paso 2 — Ella aprende a ver.**
Se le instala Revit y aprende **solo a navegar**: abrir, moverse en 3D, mirar un corte,
abrir una vista. Cero modelado, cero edición. El objetivo es que vea su propio proyecto en
tres dimensiones y encuentre por sí sola los choques que en planta no se ven.
*Duración: una tarde. Lo que gana: entender el modelo sin depender de nadie.*

**Paso 3 — Ella hace láminas y tablas.**
Aquí entra el gancho. Aprende a armar hojas (colocar vistas en un plano con cajetín) y a
hacer tablas de planificación. Es lo más parecido a lo que ya hace en Canva y Excel, y es
lo que le devuelve tiempo de inmediato.
*Duración: dos o tres sesiones. Lo que gana: deja de recontar volúmenes a mano.*

**Paso 4 — Ella modela.**
Hasta aquí, y solo si los tres pasos anteriores ya se sienten cómodos. Empieza por muros,
pisos y vanos de **un solo nivel** de un proyecto chico. No F-19 completo.
*Duración: meses, sin prisa.*

### Qué hace Stefanno mientras tanto

Modelar F-19 en Revit sobre el DWG vinculado, en paralelo, sin detener el proyecto. Si el
Revit se atora, AutoCAD sigue siendo la fuente vigente. **Nunca se apuesta el proyecto a
la herramienta nueva.**

### Reglas de la transición

1. **F-19 no se detiene por Revit.** AutoCAD es la fuente vigente hasta que el modelo esté
   probado y firmado.
2. **Una disciplina a la vez.** Estructura ya está en Revit (Memo). Sigue arquitectura.
   Instalaciones al final.
3. **Nadie aprende algo que no va a usar esa semana.** Nada de cursos completos.
4. **El estándar de nombres es el mismo** en DWG y en RVT. La convención de F-19 ya sirve
   para los dos.
5. **Si algo se hace más lento que antes, se para y se revisa.** La adopción se justifica
   sola o no se justifica.

### Qué se le pide al Ing. Memo

Aprovechando que ya trabaja en BIM y con buena disposición:

- Su **plantilla de proyecto** (`.rte`) o al menos sus estándares de nombres y niveles
- Que fije **origen compartido y niveles** para que su modelo y el nuestro peguen sin
  reubicar nada
- Media hora de pantalla compartida enseñando cómo organiza vistas y láminas

Es la vía más barata que existe para adoptar un estándar: copiar uno que ya funciona y está
probado en el mismo proyecto.

---

## PARTE 4 — Qué necesita la app para sostener esto

Sin desarrollo nuevo mayor, solo conexiones:

| Necesidad | Cómo se resuelve |
|---|---|
| Etapa del proyecto visible | Campo *etapa* en el proyecto con los seis valores de la Parte 1 |
| Hallazgos de revisión | Incidencias con folio, severidad, responsable y estado |
| Revisión de documentos | El campo `REV. NN` que ya define el catálogo de imprimibles |
| Confianza del volumen | Marca por concepto: estimado · de plano · del estructurista |
| Trazabilidad concepto→plano | Campo de plano de respaldo en el concepto |
| Checklist ejecutable | El de la Parte 2, como lista marcable por plano y revisión |

Lo primero de esa lista es el **campo de etapa**. Es barato y es lo que permite que la
carátula de proyecto diga algo verdadero.
