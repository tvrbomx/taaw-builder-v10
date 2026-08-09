# NORMA DE NOMENCLATURA DOCUMENTAL · DRAVYA / TAAW

**Basada en ISO 19650-2.** Adaptada de la norma que Stefanno Pasquali diseñó para ALFA
Proveedores y Contratistas en el Cablebús Línea 4 (`ISO BIM NOM2`).

**Documento de empresa, no de proyecto.** Aplica a todo proyecto de DRAVYA y a todo entregable
generado por TAAW Project Builder.

**R01 · 4-ago-2026**

---

## 1. Estructura del código

```
PROYECTO - CREADOR - PROGRESO - FUNCIÓN - BLOQUE - NÚM.BLOQUE - NIVEL - TIPO - NÚMERO - REVISIÓN - ESTADO
   1          2         3          4         5         6          7       8       9         10        11
```

**Ejemplo real — el presupuesto de este proyecto:**

```
F19-DRV-PE-Q-G-01-ZZ-BQ-001-03-S3
```

> Proyecto F-19 · creado por Dravya · en proyecto ejecutivo · función quantity surveyor ·
> bloque generales 01 · niveles múltiples · bill of quantities · documento 001 · revisión 03 ·
> apto para revisión y comentarios.

**Lo que cambia respecto a la norma de ALFA:** el campo 5 pasa de *Frente* (estación, poste,
bucle) a *Bloque*, porque en edificación no hay frentes lineales sino módulos y cuerpos. Todo
lo demás se conserva para que un documento de DRAVYA sea legible por cualquiera que ya conozca
ISO 19650.

---

## 2. Campo 1 · PROYECTO

Código corto del proyecto, 2 a 4 caracteres. Es el mismo que se usa en el nombre de la carpeta
y en el ID de la app.

| Clave | Proyecto |
|---|---|
| `F19` | Departamentos F-19 · Av. 19 Poniente 705, Centro Histórico, Puebla |
| `C256` | Casa Habitación 256 · Chignahuapan 256, San Francisco Acatepec |
| `EMP` | Documento de empresa, sin proyecto asociado |

Se da de alta un código nuevo por cada proyecto en `proyectos` de la base de datos.

---

## 3. Campo 2 · CREADOR

Siglas de la empresa u organización que genera el documento.

| Clave | Organización |
|---|---|
| `DRV` | Dravya Estudio de Arquitectura |
| `TAAW` | TAAW Project Builder — documentos generados por la plataforma |
| `MAAK` | Maak — administración |
| `EXT` | Externo sin clave asignada |

**Colaboradores externos recurrentes:**

| Clave | Quién |
|---|---|
| `MAP` | Ing. Maximino Ayala Pozo — estructural |
| `SGA` | Arq. Sergio García Ayala — revisión |

---

## 4. Campo 3 · PROGRESO DE PROYECTO

| Clave | Etapa |
|---|---|
| `AP` | Anteproyecto |
| `PE` | Proyecto Ejecutivo |
| `OB` | Obra en ejecución |
| `AS` | As Built |

`OB` es adición nuestra: ALFA no lo necesitaba porque entregaba proyecto, no obra. Nosotros sí
construimos, y los documentos de control de obra no son ni ejecutivo ni as-built.

---

## 5. Campo 4 · FUNCIÓN

Disciplina de quien genera el documento. Se conserva íntegra la tabla ISO.

| Clave | Función | | Clave | Función |
|---|---|---|---|---|
| `A` | Arquitectura | | `M` | Ingeniería mecánica |
| `B` | Levantamiento de obra | | `P` | Ingeniería sanitaria |
| `C` | Ingeniería civil | | **`Q`** | **Costos y presupuestos** |
| `D` | Drenaje y vialidad | | `S` | Estructural |
| `E` | Instalación eléctrica | | `T` | Urbanismo |
| `F` | Facility management | | `W` | Contratista |
| `G` | Topografía | | `X` | Subcontratista |
| `I` | Diseño de interiores | | `Y` | Diseñador especialista |
| `K` | Cliente | | `Z` | General, no disciplinar |
| `L` | Arquitectura de paisaje | | | |

> **`Q` es la función de todo lo que hace TAAW en presupuesto y control de obra.**

---

## 6. Campo 5 · BLOQUE  ·  Campo 6 · NÚMERO DE BLOQUE

| Clave | Bloque |
|---|---|
| `G` | Generales — aplica a todo el proyecto |
| `M` | Módulo de presupuesto (M1 a M6 del esquema modular) |
| `E` | Edificio o cuerpo |
| `X` | Exterior, obra exterior, barda, patio |

Número de bloque: dos dígitos, `01` a `99`. Con `G` se usa `01`.

---

## 7. Campo 7 · NIVEL / UBICACIÓN

| Clave | Nivel | | Clave | Nivel |
|---|---|---|---|---|
| `ZZ` | Niveles múltiples | | `PB` | Planta baja |
| `XX` | Sin nivel aplicable | | `N1` | Nivel 1 |
| `CIM` | Cimentación | | `N2` | Nivel 2 |
| `AZ` | Azotea | | `B1` | Sótano 1 |
| `MZ` | Mezzanine | | | |

---

## 8. Campo 8 · TIPO DE DOCUMENTO

La tabla ISO completa. **Marcados los que produce TAAW.**

| Clave | Tipo | | Clave | Tipo |
|---|---|---|---|---|
| **`BQ`** | **Catálogo de conceptos / presupuesto** | | `MI` | Minuta |
| **`CP`** | **Plan de costos** | | `MS` | Procedimiento constructivo |
| **`PR`** | **Programa / cronograma** | | `PP` | Presentación |
| **`RP`** | **Reporte** | | `RD` | Ficha de local |
| **`SH`** | **Tabla / schedule** | | `RI` | Solicitud de información |
| **`CA`** | **Memoria de cálculo / generadores** | | `SA` | Programa de necesidades |
| `DR` | Plano | | `SN` | Lista de pendientes |
| `M2` | Modelo 2D | | `SP` | Especificación |
| `M3` | Modelo 3D | | `SU` | Levantamiento |
| `CM` | Modelo federado | | `VS` | Visualización |
| `CR` | Reporte de interferencias | | `DB` | Base de datos |
| `CO` | Correspondencia | | `FN` | Nota de archivo |
| `HS` | Seguridad e higiene | | `IE` | Archivo de intercambio |
| `AF` | Archivo de animación | | | |

---

## 9. Campo 9 · NÚMERO  ·  Campo 10 · REVISIÓN

- **Número:** consecutivo del documento dentro de su tipo. Hasta 6 dígitos, mínimo 3: `001`.
- **Revisión:** hasta 2 dígitos, empieza en `00`: `00`, `01`, `02`…

La revisión del documento **no** es la revisión del proyecto. Un presupuesto puede ir en su
revisión 02 mientras el proyecto arquitectónico va en REV.03.

---

## 10. Campo 11 · ESTADO

| Clave | Significado |
|---|---|
| `S0` | Estado inicial, trabajo en curso |
| `S1` | Apto para coordinación |
| `S2` | Apto para información |
| **`S3`** | **Apto para revisión y comentarios** |
| `S4` | Apto para aprobación de etapa |
| `S6` | Apto para autorización PIM |
| `S7` | Apto para autorización AIM |
| `A0`–`A7` | Autorizado y aceptado, por etapa |
| `B0`–`B7` | Firma parcial, por etapa |
| `CR` | Documento de registro as-built |

**Los que usamos en la práctica:**

| Momento | Estado |
|---|---|
| Presupuesto en elaboración | `S0` |
| Presupuesto que se manda al cliente a revisar | `S3` |
| Presupuesto que el cliente firmó | `A5` |
| Cronograma autorizado para construir | `A5` |
| Control de obra de la semana | `S2` |
| Cierre de obra | `CR` |

---

## 11. Prefijo de documentación

Para documentos que **no son de proyecto** sino de la empresa, el campo 1 es `EMP` y el campo 5
identifica el área:

| Clave | Área de empresa |
|---|---|
| `NOM` | Normativa y estándares |
| `ADM` | Administración |
| `FIN` | Finanzas |
| `RH` | Recursos humanos |
| `CAL` | Calidad y procesos |
| `SIS` | Sistemas y plataforma |

**Este documento:**

```
EMP-DRV-PE-Z-NOM-01-XX-SP-001-01-A5
```

---

## 12. Folios de los entregables de TAAW

Así se arman los folios que la plataforma y las hojas de cálculo generan solos:

| Entregable | Folio | Tipo |
|---|---|---|
| Presupuesto | `F19-DRV-PE-Q-G-01-ZZ-BQ-001-03-S3` | `BQ` |
| Generadores de volumen | `F19-DRV-PE-Q-G-01-ZZ-CA-001-03-S3` | `CA` |
| Tarjetas de precios unitarios | `F19-DRV-PE-Q-G-01-ZZ-CP-001-03-S3` | `CP` |
| Cronograma de obra | `F19-DRV-OB-Q-G-01-ZZ-PR-001-00-A5` | `PR` |
| Flujograma | `F19-DRV-OB-Q-G-01-ZZ-CP-002-00-A5` | `CP` |
| Control de obra semanal | `F19-DRV-OB-Q-G-01-ZZ-RP-001-00-S2` | `RP` |
| Estado de cuenta de cliente | `F19-DRV-OB-Q-G-01-ZZ-RP-002-00-S2` | `RP` |
| Bitácora de obra | `F19-DRV-OB-W-G-01-ZZ-RP-003-00-S2` | `RP` |
| Reporte fotográfico | `F19-DRV-OB-W-G-01-ZZ-VS-001-00-S2` | `VS` |
| Requisición de material | `F19-DRV-OB-W-G-01-ZZ-SH-001-00-S2` | `SH` |
| Presupuesto de un módulo | `F19-DRV-PE-Q-M-02-PB-BQ-002-03-S3` | `BQ` |

**Fórmula para la hoja de cálculo:**

```
= PROYECTO &"-"& CREADOR &"-"& PROGRESO &"-"& FUNCIÓN &"-"& BLOQUE & NÚM
  &"-"& NIVEL &"-"& TIPO &"-"& TEXT(NÚMERO,"000") &"-"& TEXT(REVISIÓN,"00") &"-"& ESTADO
```

Los campos fijos por documento se dejan escritos; los variables se jalan de la carátula.

---

## 13. Nombre de archivo

El nombre del archivo es **el código, más un descriptor legible**:

```
F19-DRV-PE-Q-G-01-ZZ-BQ-001-03-S3_Presupuesto-General-Modular.pdf
```

El código va primero para que el ordenamiento alfabético agrupe por proyecto, creador,
disciplina y tipo. El descriptor va después del guion bajo, para leerlo sin descifrar.

**Nunca** se pone la fecha en el nombre: para eso está la revisión, y la fecha vive dentro del
documento.

---

## 14. Qué falta por definir

| # | Pendiente |
|---|---|
| 1 | Confirmar las siglas de creador de DRAVYA: `DRV` es propuesta |
| 2 | Dar de alta el código de proyecto de los proyectos anteriores para migrar su documentación |
| 3 | Decidir si el álbum fotográfico usa `VS` o un tipo propio |
| 4 | Definir quién autoriza el paso de `S3` a `A5` — hoy es Stefanno de facto, conviene dejarlo escrito |

---

*Adaptado de `06_REFERENCIAS/NORMATIVA/ISO BIM NOM2.pdf` — norma diseñada para ALFA Proveedores
y Contratistas, Cablebús Línea 4, Ciudad de México.*
