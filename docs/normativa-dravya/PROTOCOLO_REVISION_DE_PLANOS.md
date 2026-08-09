# Protocolo de revisión de planos — DRAVYA

**1-ago-2026.** Documento operativo. Dice **qué se hace, en qué orden y con qué se cierra**
cuando hay que revisar un juego de planos.

Complementa a `FLUJO_BIM_DRAVYA.md`, que define las seis etapas del proyecto y la transición
a Revit. Aquel dice *cuándo* se revisa; este dice *cómo*.

Nace de las notas de revisión del proyecto ALFA, generalizadas. Aquellas eran una lista
suelta de recordatorios personales; aquí quedan como procedimiento repetible que puede
ejecutar alguien más.

---

## PARTE 0 — Los dos tipos de revisión

No son lo mismo y confundirlos es el error de origen.

| | **Revisión de emisión** | **Revisión de terceros** |
|---|---|---|
| Qué se revisa | Planos que DRAVYA va a emitir | Planos que alguien nos entrega |
| Para qué | Que no salga un error nuestro | Detectar qué NO podemos construir o autorizar |
| Quién la hace | Alguien que no dibujó el plano | El coordinador o especialista |
| Qué produce | Plano corregido, revisión que sube | **Reporte de observaciones al emisor** |
| Ejemplo | Los arquitectónicos de Fernanda para F-19 | Los planos de taller de estructura de ALFA |

El núcleo del checklist es el mismo. Cambian tres cosas: **quién corrige**, **qué entregas**
y **quién se queda con el riesgo si no se corrige**.

En revisión de terceros hay una regla que no se negocia: **si observaste algo y quedó por
escrito, el riesgo pasó al emisor. Si no lo escribiste, el riesgo es tuyo.** Por eso el
registro no es burocracia, es la única defensa que existe cuando algo sale mal en obra.

---

## PARTE 1 — Preparación, antes de abrir el primer plano

Estos cuatro pasos son los que Stefanno ya hace de memoria en ALFA. Escritos, cualquiera
los puede ejecutar.

### 1. Carpeta de PDF dentro de la especialidad

Antes de revisar nada, el paquete completo se guarda en la carpeta de su disciplina, en su
propia subcarpeta con la fecha del paquete. No se revisa desde Descargas ni desde el correo.

```
{PROYECTO}/
└── {DISCIPLINA}/          ← ARQ · EST · INS · TOP
    └── PDF/
        └── {AAAA-MM-DD} paquete recibido/
```

**Por qué importa:** cuando llegue el siguiente paquete, la única forma de saber qué cambió
es tener el anterior donde debe estar. Un paquete que se revisó desde Descargas no se puede
comparar después.

### 2. Archivo de revisión

En la carpeta `REVISIONES/` de la raíz del proyecto se crea el archivo de esta ronda:

```
{PROYECTO}-REV-{AAAA-MM-DD}.xlsx
```

La fecha es la **del paquete recibido**, no la del día que uno lo abre. Si se revisa en tres
sesiones distintas, siguen siendo la misma revisión y el mismo archivo.

El encabezado del archivo lleva: proyecto, disciplina, fecha del paquete, quién revisa,
número de ronda.

> A futuro esto vive en la app como incidencias con folio. El Excel es el paso intermedio
> mientras el módulo existe — pero el formato de columnas ya es el de la app (Parte 4), para
> que la migración sea copiar y pegar y no rehacer.

### 3. El modelo, no solo el PDF

Se descarga y se abre el modelo de la fuente oficial —en ALFA es Autodesk Construction Cloud,
en F-19 es el `.rvt` del Ing. Memo—. **Siempre el más reciente.**

Revisar un PDF sin el modelo detecta errores de dibujo. Revisar con el modelo abierto detecta
errores de proyecto. No es lo mismo y la diferencia se paga en obra.

### 4. La referencia comparable

Se busca un proyecto anterior del mismo tipo, resuelto y aprobado, y se abre su documentación
al lado. No para copiar: para tener a la mano cómo se resolvió lo mismo la última vez.

En ALFA la referencia es el proyecto de Morelia. En DRAVYA, F-19 va a ser la referencia de
todo lo que venga después — **por eso conviene documentarlo bien ahora**, aunque cueste, porque
es el molde de los siguientes.

---

## PARTE 2 — Revisión por lámina

Cada lámina pasa por dos filtros: la solapa y el contenido.

### A. Solapa (cajetín)

- [ ] Nombre del plano, número y **revisión** visibles
- [ ] Fecha de emisión
- [ ] Simbología de niveles **con los mismos niveles que aparecen en las vistas**
- [ ] Proyecto, cliente, ubicación, disciplina
- [ ] Quién elaboró, quién revisó, quién autorizó
- [ ] Escala principal indicada
- [ ] Estado del documento: WIP · Publicado · Superado

> La simbología de niveles que no coincide con las vistas es el hallazgo más frecuente y el
> más engañoso: el plano se ve completo y correcto, pero declara niveles que no están
> dibujados o dibuja niveles que no declara. Quien construye no sabe a cuál hacerle caso.

### B. Contenido — cada vista de la lámina

Se revisa vista por vista, no lámina completa de un vistazo.

- [ ] **Nombre de la vista** describe lo que muestra: planta, corte, detalle, alzado, isométrico.
      La clave está homologada al estándar del proyecto
- [ ] **Nivel de la vista** declarado: nivel de losa, de estructura, de desplante, NPT
- [ ] **Elemento – Tipo – Nombre**: el elemento mostrado está nombrado y respeta la
      nomenclatura homologada del proyecto. Un elemento sin nombre no se puede pedir, ni
      cotizar, ni reclamar
- [ ] **Escala** dentro de las permitidas por **ISO 5455**

**Escalas ISO 5455** — solo estas. Son múltiplos decimales de 1, 2 y 5:

| Ampliación | Natural | Reducción |
|---|---|---|
| 50:1 · 20:1 · 10:1 · 5:1 · 2:1 | 1:1 | 1:2 · 1:5 · 1:10 · 1:20 · 1:50 · 1:100 · 1:200 · 1:500 · 1:1000 · 1:2000 · 1:5000 · 1:10000 |

La escala principal va en el cajetín. Las de detalle van **junto a cada vista**, no en el
cajetín. Una escala fuera de esta tabla —1:25, 1:75, 1:150— es observación, aunque se vea
bien: rompe el escalímetro y hace que nadie pueda medir sobre el plano impreso.

Y en todo plano que se imprima: **escala gráfica además de la numérica**. El PDF se imprime a
cualquier tamaño y la escala numérica miente en cuanto alguien lo escala a otro papel.

### C. Reglas condicionales

Son las que solo aplican en cierto contexto. Se revisan **únicamente si se cumple la
condición**, y anotarlas cuando no aplica es ruido que hace que nadie lea el reporte.

| Condición | Qué se revisa |
|---|---|
| Hay placas con perforación en esta lámina o grupo | **Tabla de avellanados** presente y completa |
| Hay elementos soldados | Simbología de soldadura según norma, con tamaño y tipo |
| Hay elementos atornillados | Cuadro de tornillería: diámetro, grado, longitud, cantidad |
| Hay despiece de acero | Cuantificación que cierre contra la del cálculo |
| Hay instalaciones cruzando estructura | Pasos previstos y aprobados por el estructurista |

> La regla de avellanados es un buen ejemplo de por qué esto tiene que estar escrito: es un
> detalle que solo importa cuando hay placas perforadas, y si no está en una lista se olvida
> exactamente en la lámina donde sí importaba.

---

## PARTE 3 — Los seis filtros de fondo

Los de la Parte 2 son de forma: que el plano esté bien hecho. Estos son de fondo: que el
proyecto esté bien resuelto. Están desarrollados completos en `FLUJO_BIM_DRAVYA.md`, Parte 2.

| | Filtro | Pregunta que responde |
|---|---|---|
| **A** | Identificación | ¿Este plano es rastreable? |
| **B** | Consistencia interna | ¿Cuadra consigo mismo? |
| **C** | Coordinación entre disciplinas | ¿Chocan? |
| **D** | Constructibilidad | ¿Se puede construir? |
| **E** | Cuantificable | ¿De aquí sale presupuesto? |
| **F** | Normativo y legal | ¿Es autorizable? |

**El filtro C es el que paga la revisión.** Una interferencia detectada en plano cuesta una
hora de dibujo. La misma en obra cuesta demoler, rehacer y discutir de quién es la culpa.

---

## PARTE 4 — Cómo se registra un hallazgo

Un hallazgo mal escrito no se corrige. Estas son las columnas, y son las mismas en el Excel
de hoy y en la app de mañana:

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

**Cómo se escribe un hallazgo.** Tres partes, en este orden: **dónde** (plano, vista, eje o
nivel), **qué** (el hecho observable), **por qué** (la consecuencia si se construye así).

- ❌ *"Revisar cimentación"* — no dice nada, nadie sabe qué corregir
- ❌ *"Está mal la trabe del eje 3"* — dice dónde pero no qué ni por qué
- ✅ *"Planta de cimentación, eje 3 entre B y C: la bajada sanitaria del baño N2 cruza el
  peralte de la trabe TR-02. Si se construye así hay que perforar la trabe fuera de la zona
  permitida o reubicar el mueble."*

**Severidad — criterio único:**

- **Crítica** — si se construye así, se demuele. **Detiene la emisión del plano.**
- **Mayor** — genera costo o retraso. Se corrige antes de mandar a obra.
- **Menor** — no afecta obra. Se acumula para la siguiente revisión.

Un hallazgo crítico no se negocia por calendario. Es lo único de este documento que no admite
excepción, porque el día que se admita una, deja de servir todo lo demás.

---

## PARTE 5 — Cierre de la ronda

Una ronda de revisión cierra con **un entregable**, no con un correo suelto.

**Revisión de emisión** → el plano corregido, con la revisión subida y el cuadro de control de
cambios diciendo qué cambió. Los hallazgos menores no corregidos quedan abiertos y visibles
para la siguiente ronda.

**Revisión de terceros** → **reporte de observaciones** al emisor: portada con proyecto,
paquete, fecha y quién revisó; tabla de hallazgos ordenada por severidad; y las láminas
marcadas si aplica. Se envía con acuse. Sin acuse la revisión no ocurrió.

**Nunca se cierra una ronda con hallazgos críticos abiertos.** Si el calendario aprieta, se
emite parcial: las láminas limpias salen, las que tienen crítica se retienen y se dice por
escrito cuáles y por qué.

---

## PARTE 6 — Cómo esto se conecta con el trabajo de DRAVYA

### En qué etapa se revisa qué

Contra las seis etapas de `FLUJO_BIM_DRAVYA.md`:

| Etapa | Qué se revisa | Filtros que aplican |
|---|---|---|
| 1 · Conceptualización | Nada formal. Es exploración | — |
| 2 · Proyecto arquitectónico | Plantas, cortes, fachadas de Fernanda | A · B · **E** |
| 3 · Proyecto estructural | Lo que entregan Max y Memo | A · B · **C** · E |
| 4 · Proyecto ejecutivo | Todo el juego coordinado | **A · B · C · D · E · F** |
| 5 · Planeación | Planos de taller y fabricación | A · B · **D** |
| 6 · Ejecución | As-built contra lo construido | A · B |

La etapa 4 es la única donde aplican los seis. Es también donde se decide si la obra se atora,
y por eso es la que no se puede acelerar.

### Quién revisa qué

Con tres personas no hay revisor dedicado, así que la regla se vuelve simple: **nadie revisa
lo que dibujó**.

- Fernanda dibuja arquitectónicos → **Stefanno los revisa**
- Externos entregan estructura → **Stefanno los revisa** contra el arquitectónico
- Stefanno arma el ejecutivo → **Fernanda revisa** los filtros E y F, que son los que ella
  domina por hacer compras y trámites

Esa última asignación no es de relleno. Fernanda tiene el mejor criterio del despacho sobre si
un plano permite cotizar, porque es la que sufre cuando no permite.

### Qué se le pide al Ing. Memo

Aprovechando que ya trabaja en BIM y con buena disposición:

- Su **plantilla** (`.rte`) o al menos sus estándares de nombres, niveles y claves de vista
- Que fije **origen compartido y niveles** para que su modelo y el nuestro peguen sin reubicar
- Media hora de pantalla compartida sobre cómo organiza vistas y láminas

Copiar un estándar que ya funciona y ya está probado **en este mismo proyecto** es la forma más
barata que existe de adoptar uno. Inventar el nuestro desde cero cuesta meses y sale peor.

### Lo que NO se le pide a Fernanda todavía

Este protocolo **no le pide a Fernanda que aprenda Revit**. Ella revisa filtros E y F sobre
PDF, que es exactamente lo que ya sabe hacer. La transición a Revit va aparte, en cuatro pasos
y sin prisa, en `FLUJO_BIM_DRAVYA.md` Parte 3.

Si el protocolo de revisión y la migración a Revit entran juntos, no entra ninguno.

---

## PARTE 7 — Qué necesita la app

Nada mayor. Cuatro cosas, en orden de valor:

1. **Incidencias con folio** — la tabla de la Parte 4 como módulo, ligada al proyecto. Es lo
   único que hoy vive en Excel y debería vivir en la app.
2. **Campo de etapa** en el proyecto, con los seis valores. Barato y hace que la carátula diga
   algo verdadero.
3. **Confianza del volumen** por concepto: *estimado* · *de plano* · *del estructurista*. Saber
   qué parte del presupuesto está sostenida en dato duro y qué parte en cálculo nuestro.
4. **Plano de respaldo** en cada concepto. Es lo que permite responder "¿de dónde salió este
   volumen?" sin abrir cinco archivos.

El checklist en sí **no tiene que estar en la app todavía**. Funciona en papel y en Excel. Lo
que sí urge es el registro de hallazgos, porque es lo que se pierde.

---

## Resumen operativo

```
1. Guardar el paquete en su carpeta de disciplina, con fecha
2. Crear el archivo de revisión con la fecha del paquete
3. Abrir el modelo más reciente y la referencia comparable
4. Por lámina:  solapa  →  cada vista  →  reglas condicionales
5. Por juego:   los seis filtros de fondo
6. Registrar cada hallazgo: dónde · qué · por qué · severidad
7. Cerrar con entregable, no con correo
8. Ninguna crítica abierta al emitir
```
