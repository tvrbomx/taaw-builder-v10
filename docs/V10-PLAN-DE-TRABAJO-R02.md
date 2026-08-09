# TAAW V10 · PLAN DE TRABAJO

**R02 · 7-ago-2026 · Etapa 2 de 4 · Anteproyecto**

Documento raíz. De aquí cuelga todo lo demás.
Vault de Obsidian: la carpeta `APP-V10`. Los enlaces `[[así]]` dibujan el grafo solos.

---

## 1. Por qué existe este documento

Las versiones 8 y 9 no fallaron por falta de talento ni de horas. Fallaron porque se
empezó a construir antes de saber qué se estaba construyendo. Cada semana aparecía un
requisito nuevo —legítimo, necesario— y cada requisito nuevo obligaba a mover el esquema
de datos. Mover el esquema rompía lo que ya funcionaba. Y lo que se rompía se parchaba,
no se rediseñaba.

El síntoma más claro: **877 conceptos con 40 formatos distintos de identificador.**
Nadie decidió eso. Se acumuló.

La V10 no arranca hasta que exista el plano. Es la misma disciplina con la que Dravya
hace un edificio: nadie cuela una losa sin despiece. Este documento y los que cuelgan de
él son ese despiece.

**Cómo se usa:** esta es la introducción y el mapa. Cada rebanada y cada dominio tiene
—o tendrá— su propio documento que lo explica a fondo. Aquí sólo se ve el conjunto y
cómo se conecta. Si algo no está enlazado desde aquí, no está en el alcance.

---

## 2. Mapa de documentos

| # | Documento | Qué resuelve | Estado |
|---|---|---|---|
| 0 | [[V10-CONCEPTO-ParaQueEsLaApp-R02]] | Manifiesto: qué es, para quién, qué no será | **Aprobado** |
| 1 | **V10-PLAN-DE-TRABAJO-R02** | Este documento. Orden, rebanadas, criterios | **Vigente** |
| 2 | [[V10-ARQUITECTURA]] | Stack, estructura, sistema de diseño, multiempresa | Siguiente |
| 3 | [[V10-MODELO-DOMINIO]] | Entidades, relaciones, máquinas de estado, invariantes | Depende de 2 |
| 4 | [[V10-ESQUEMA-SQL]] | Tablas, llaves, restricciones. El esquema que se congela | Depende de 3 |
| 5 | [[V10-PLATAFORMA-Y-MIGRACION]] | Dónde vive la base, cómo migran los 877 conceptos | Depende de 4 |
| 6 | [[V10-CATALOGO-DOCUMENTOS]] | Qué PDF emite cada entidad y con qué folio | Depende de 3 |
| 7 | [[V10-PANTALLAS-Y-ROLES]] | Pantalla por pantalla, permiso por rol | Depende de 3 y 6 |
| 8 | [[V10-API]] | Superficie de servicios | Depende de 4 y 7 |
| 9 | [[V10-REQ-CicloDeObra-Cobranza-Bitacora-R01]] | Requisito funcional del ciclo de obra | **Escrito** |
| 10 | [[SAT-ELECTRICO-CONCEPTO]] | App satélite de cálculo eléctrico | **Escrito** |

**Regla:** ningún documento se escribe antes que aquel del que depende.

---

## 3. Reglas invariantes

Se definen en [[V10-MODELO-DOMINIO]] y **no se tocan después**. Cada una nació de un
defecto real de la V8.

| # | Regla | Defecto que corrige |
|---|---|---|
| 1 | Clave de concepto única y con formato fijo. La base rechaza lo que no cumple | 877 conceptos, 40 formatos de ID |
| 2 | Todo gasto ligado a uno o más conceptos. Sin liga no se aprueba | El ahorro con proveedores es hoy invisible |
| 3 | Los precios se guardan sin IVA. El IVA es parámetro, nunca valor almacenado | Tablas con IVA incluido y otras sin él |
| 4 | Una columna significa una sola cosa | La columna E de materiales cambia de significado por renglón |
| 5 | Todo pago es un abono contra un compromiso. Nunca un "pagado sí/no" | Ni el cliente ni nosotros pagamos completo de una vez |
| 6 | Ningún concepto llega a 100% de avance sin carta entrega | Es lo que vuelve real la utilidad estimada |
| 7 | Nada se borra. Sólo se marca inactivo | Trazabilidad ante el cliente |
| 8 | Todo cambio de estado deja rastro y dispara alerta | La bitácora es la memoria del proyecto |
| 9 | Todo dato pertenece a una empresa. Nada existe fuera de una empresa | Multiempresa desde el día uno, no como parche |

**Si una función futura exige romper una de las nueve, no se hace la función: se replantea.**

---

## 4. Las nueve rebanadas

Cada una atraviesa base de datos, lógica y pantalla, y **sirve sola** al terminar.
No se construye por capas horizontales.

### Rebanada 1 · Arquitectura y sistema de diseño

**La que faltaba, y es la más importante.** Todo lo que si no existe desde el principio,
después rompe la aplicación al intentar agregarlo. Ya pasó: en la V9 meter temas quebró
lo que funcionaba.

| | |
|---|---|
| **Contenido** | Stack y estructura de carpetas · Capa de acceso a datos · Autenticación y sesión · **Permisos por rol** · **Multiempresa** · **Sistema de diseño con tokens** · Tema claro y oscuro · Escala tipográfica y de tamaños · Manejo de errores y estados de carga · Bitácora técnica de cambios |
| **Sistema de diseño** | Paleta cálida hueso y cafés, la línea de marca de Dravya, la misma que quedó bien en el hub informativo. Definida como **tokens**, no como colores escritos en cada pantalla. Cambiar el tema debe ser cambiar un archivo |
| **Multiempresa** | Ver §5 |
| **Terminado cuando** | Existe una pantalla de ejemplo que respeta permisos, cambia de tema claro a oscuro sin tocar código, y muestra datos de dos empresas distintas sin mezclarlos |

> Esta rebanada no entrega función de negocio. Entrega **el terreno nivelado**.
> Saltársela es lo que ya costó dos versiones.

### Rebanada 2 · Catálogo técnico y tarjetas de precios unitarios

**El activo más valioso de la empresa, y hoy el más dañado.**

| | |
|---|---|
| **Entidades** | `insumo`, `concepto`, `tarjeta_pu`, `tarjeta_renglon`, `partida` |
| **Pantallas** | Catálogo de insumos · Catálogo de conceptos · Constructor de tarjeta · Buscador |
| **Funciones** | Insumos por tipo: material, mano de obra, herramienta, herramienta menor, indirecto, subcontrato · Tarjeta con rendimiento y desperdicio · Costo directo y precio de venta separados **desde el día uno** · **Cascada: cambia un insumo y se recalculan todos los conceptos que lo usan** |
| **Documentos** | Catálogo de conceptos · Tarjeta de precio unitario · Catálogo de insumos |
| **Terminado cuando** | Se sube el precio de la varilla y aparece la lista de todos los conceptos que cambiaron, y en cuánto |

### Rebanada 3 · Proyecto, cliente y documentación

**Corregí el orden respecto al R01.** Un presupuesto pertenece a un proyecto: el marco
tiene que existir antes que lo que se cuelga de él.

| | |
|---|---|
| **Entidades** | `proyecto`, `cliente`, `colaborador`, `rol`, `documento`, `folio` |
| **Pantallas** | Proyectos · Ficha de proyecto · Clientes · Colaboradores y roles · Documentos |
| **Funciones** | Etapa BIM vigente · **Folio ISO 19650 generado solo** · Versionado y estado documental · Asignación de roles por proyecto |
| **Documentos** | Carátula de proyecto · Índice documental |
| **Terminado cuando** | Todo PDF que emite la app sale con folio correcto sin que nadie lo escriba |

### Rebanada 4 · Presupuesto

**El hito que libera a Stefanno de la hoja de cálculo.**

| | |
|---|---|
| **Entidades** | `presupuesto`, `presupuesto_modulo`, `presupuesto_partida`, `presupuesto_concepto`, `generador` |
| **Pantallas** | Armado de presupuesto · Generadores de volumen · Comparador de opciones · Vista de impresión |
| **Funciones** | Módulo → partida → concepto · Opciones comparables del mismo presupuesto · Crear concepto sin salir del presupuesto · Volúmenes desde generadores · Vigencia y precio por m² · **Margen visible al armar, nunca en la vista del cliente** |
| **Documentos** | Presupuesto al cliente · Sólo volúmenes · **Exportables selectivos: sólo mano de obra, sólo materiales, lista de compras, indirectos, viáticos, rentas** — según las tarjetas |
| **Terminado cuando** | El presupuesto de F-19 completo se arma en la app y sale en PDF igual o mejor que el de la hoja |

### Rebanada 5 · Bitácora, requisiciones y entregas

**El corazón de la operación diaria.** Detalle completo en
[[V10-REQ-CicloDeObra-Cobranza-Bitacora-R01]].

| | |
|---|---|
| **Entidades** | `evento`, `foto`, `adjunto`, `requisicion`, `requisicion_renglon`, `cotizacion`, `entrega`, `carta_entrega`, `alerta` |
| **Pantallas** | Bitácora en línea de tiempo · Alta de evento con fotos · Requisición · Bandeja de aprobación · Recepción de trabajo |
| **Funciones** | Máquina de estados de seis pasos · Requisición que se convierte en cotización cuando el proveedor no cotiza · Liga obligatoria a concepto · Alerta en cada cambio de estado · Carta entrega que sella |
| **Documentos** | Requisición · Orden de compra · Carta entrega de trabajo · **Reporte fotográfico** semanal, quincenal, mensual, bimestral y general · Entrada y salida de inventario |
| **Terminado cuando** | Una compra real recorre los seis estados desde el teléfono en obra y genera su carta entrega |

### Rebanada 6 · Cronograma, flujo y control de obra

| | |
|---|---|
| **Entidades** | `actividad`, `cronograma_plan`, `cronograma_vivo`, `avance`, `semana` |
| **Pantallas** | Cronograma · Flujo semanal · Control de obra · Comparativo plan contra real |
| **Funciones** | Reparto de conceptos en el tiempo · Cronograma vivo actualizado con obra real · **Bloques de cobranza leídos del avance acumulado, no capturados** · Desviación y semáforo |
| **Relación con bitácora** | **Dos entidades ligadas, no una.** La bitácora es la herramienta del agente: quien registra un evento en la línea de tiempo. El cronograma es la visualización de esa línea de tiempo, apoyada en los conceptos del presupuesto |
| **Documentos** | Programa de obra · Programa valorizado · Flujo de efectivo · Estimación · Avance semanal |
| **Terminado cuando** | Mover una actividad recorre los tramos de cobranza y la desviación sin capturar nada más |

### Rebanada 7 · Dinero

| | |
|---|---|
| **Entidades** | `movimiento`, `abono`, `compromiso_cobranza`, `proveedor`, `estado_cuenta`, `nomina`, `viatico` |
| **Pantallas** | Movimientos · Cobranza y parcialidades · Proveedores · Estado financiero cliente · Estado financiero operativo · Rentabilidad |
| **Funciones** | Abonos contra compromiso en ambas direcciones · Gasto ligado a concepto · **Ahorro contra tarjeta = utilidad extra** · Caja del proyecto |
| **Documentos** | Recibo de ingreso · Recibo de egreso · Estado de cuenta de cliente · Estado de cuenta de proveedor · Reporte de utilidad y ahorros |
| **Terminado cuando** | Se puede decir, concepto por concepto, cuánto se presupuestó, cuánto costó y dónde se ganó |

### Rebanada 8 · Ajustes del sistema y de la empresa

| | |
|---|---|
| **Entidades** | `empresa`, `grupo_empresa`, `preferencia_usuario`, `integracion` |
| **Pantallas** | Administración de empresas · Preferencias del usuario · Integraciones |
| **Funciones de empresa** | Alta de empresas del grupo · Logotipo, nombre, correos, datos fiscales, **disclaimers y pies de página de los documentos** · Plantillas de documento por empresa |
| **Funciones de usuario** | Tema claro y oscuro · Tamaño de fuente y densidad · Idioma · Notificaciones y alertas |
| **Integraciones** | Conexión con modelos de IA · Conectores y MCP · Respaldo y exportación de la base |
| **Terminado cuando** | Se da de alta una empresa nueva, se le pone su logo y sus disclaimers, y sus documentos salen con su identidad sin tocar código |

> Los **tokens de tema** viven en la rebanada 1. Aquí sólo vive el interruptor que los
> cambia. Es la separación que faltó en la V9.

### Rebanada 9 · Las tres pantallas de la junta

| | |
|---|---|
| **Pantallas** | Dirección de proyecto (Sergio) · Finanzas (Fernanda) · Control de obra (Stefanno) |
| **Funciones** | Cada rol ve sus indicadores · Actualización en vivo · **Línea de tiempo de eventos del proyecto** |
| **Terminado cuando** | La junta ejecutiva corre sin que nadie maneje una tabla |

---

## 5. Multiempresa

**Sí, desde el día uno.** No como función futura: como forma de la base.

El modelo que describiste es el de un grupo con empresas operativas distintas. Aristos era
dueño, Alfa hacía los proyectos, Presforza los prefabricados de concreto y Jepsa los de
acero. El grupo no opera; las empresas sí.

Para Dravya:

| Empresa | Qué hace |
|---|---|
| **Dravya** | Arquitectura y construcción. La operativa principal |
| **TAAW** | Tecnología e innovación. Desarrolla la plataforma y los medios digitales |
| *(futura)* | Mantenimiento industrial y comercial |

**Consecuencia de diseño:** cada registro pertenece a una empresa. Un proyecto puede ser
de Dravya y facturarse desde otra. Cada empresa tiene su logotipo, sus datos, sus
disclaimers y sus plantillas de documento. **Meter esto después obligaría a tocar todas
las tablas**, y por eso es regla invariante desde ahora.

---

## 6. Aplicaciones satélite

El módulo eléctrico **sale de la V10 y se vuelve app independiente**. La razón es sana:
son cálculos de ingeniería con su propia normativa y su propio ritmo de desarrollo, y
cargárselos a la V10 la vuelve pesada sin hacerla mejor.

**Cada satélite es independiente pero consume el núcleo de la V10:** cliente, proyecto,
colaborador, proveedor, insumos y conceptos. Una navaja suiza de aplicaciones que
comparten expediente.

| Satélite | Qué resuelve | Estado |
|---|---|---|
| **Cálculo eléctrico** | Cuadros de carga, circuitos, salidas, tableros, protecciones | [[SAT-ELECTRICO-CONCEPTO]] escrito |
| **Cálculo hidrosanitario** | Gastos, diámetros, unidades mueble, bajadas pluviales | Propuesto |
| **Cuantificador** | Levantamiento de volúmenes que alimenta generadores y presupuesto | Propuesto |
| **Comparador de cotizaciones** | Misma partida, varios proveedores, decisión con criterio | Propuesto |
| **Honorarios de proyecto** | Cotizar el trabajo de despacho por etapa y por m², no la obra | Propuesto |
| **Índice de planos** | Control de láminas, revisiones y folios ISO 19650 | Propuesto |

De estos, el que más pronto pagaría es el **comparador de cotizaciones**: es donde nace
el ahorro que hoy no se ve.

---

## 7. Plataforma · propuesta

**Condición dura: costo cero.** Se detalla en [[V10-PLATAFORMA-Y-MIGRACION]].

- **PostgreSQL.** Es lo único que da integridad referencial real: clave única de concepto,
  llave foránea de gasto a concepto, transacciones. Exactamente lo que Sheets no puede
  hacer y lo que quebró a la V8.
- **Hospedaje gratuito** con dos condiciones no negociables: que **no se suspenda por
  inactividad** y que permita **respaldo descargable**.
- **Alternativa:** Postgres en servidor propio. Cero costo mensual a cambio de tenerlo
  prendido.
- **Migración:** los 877 conceptos se migran completos. Se normaliza la clave al formato
  único y **se conserva la clave vieja en una columna de trazabilidad**, para depurar sobre
  la marcha sin perder nada.

---

## 8. Qué se necesita de Stefanno

| Etapa | Qué se necesita |
|---|---|
| Arquitectura | Aprobar la paleta y la tipografía de la app · Confirmar las empresas del grupo |
| Modelo de dominio | Formato definitivo de clave de concepto · Catálogo de categorías de gasto · Quién autoriza cada transición |
| Plataforma | Elegir entre servicio gratuito o servidor propio, con la comparación en mano |
| Cada rebanada | Probarla con datos reales de F-19 antes de pasar a la siguiente |

---

## 9. Ritmo

Una rebanada a la vez, probada con F-19 antes de empezar la siguiente. Nada se declara
terminado sin que un dato real haya recorrido el flujo completo.

La V8 y la V9 quedan de respaldo hasta que la rebanada 4 esté en producción. De ahí en
adelante la app y el Excel corren en paralelo, como quedó decidido.

---

*Etapa 2 de 4. El siguiente documento es [[V10-ARQUITECTURA]].*
