# ESQUEMA REAL DE LA BASE DE DATOS TAAW — lectura obligatoria

> **MANDATORIO.** Antes de tocar cualquier lectura o escritura al Google Sheet, lee este
> documento. No inventes el esquema ni lo deduzcas del código: el código tiene tres
> versiones distintas del mismo esquema y al menos una está mal. Esto se leyó de la hoja real.
>
> **Fuente:** `docs/base de datos taaw en google sheets/TAAW_DB_Master.xlsx`, exportación del
> 28-jul-2026. 59 pestañas. Lo verificó Claude leyendo el archivo, no un agente reportando
> sobre su propio código.
>
> **Cuando cambie el esquema, se actualiza este archivo en el mismo commit.** Un esquema
> documentado que miente es peor que no tener ninguno.

---

## 0. Las cinco cosas que más veces nos han roto la app

1. **`conceptos_globales` tiene 19 columnas: A–S.** No 17. `sheets-core.ts` de V8 declaraba
    un encabezado de 17 columnas con nombres y orden completamente distintos: decía que D era
    `area` y E era `categoria`. El bueno es el del monolito
    `google-sheets-service.ts`, que coincide con V9 y con la hoja real. La columna S
    (`laborPct`, default 40, tope 50) se agregó el 28-jul-2026.

2. **`costos_mano_obra` guarda su ID en la columna C (`id_cuadrilla`), no en la A.** La A es
   `id_proveedor` y la B es `partida`. Cualquier lector que asuma "el ID está en A" devuelve
   la mano de obra con ID vacío.

3. **Los rangos con interpolación cuentan.** Un grep de `A:R` no encuentra
   `${SHEET}!A${rowIdx}:R${rowIdx}`. El patrón completo es:

   ```bash
   grep -rn 'A:R\|A2:R\|:R\$\{' src/
   ```

   Extender solo el rango de lectura y olvidar los de escritura hace que la columna nueva se
   borre sola en cada edición, en silencio. El síntoma es "a veces se me borra el dato" y
   nadie lo relaciona con el rango.

4. **Hay dos capas que leen las mismas hojas** en V8: el monolito
   `src/services/google-sheets-service.ts` y el split `src/services/sheets/*.ts`. Divergen.
   Un cambio de esquema se aplica en LAS DOS, y además en V9.

5. **`Proveedores` llega legítimamente hasta la columna S.** No confundir con las hojas que
   llegan a R. Al buscar y reemplazar rangos, esa es un falso positivo.

---

## 1. Formatos de ID por pestaña

| Pestaña | Prefijo | Formato correcto | Columna | Estado real |
|---|---|---|---|---|
| `conceptos_globales` | según partida | `PPP` + código de partida 2 díg + 3 díg | A | **roto**, ver §3.1 |
| `materiales` | `MAT` | `MAT-0000` | A | consistente |
| `costos_herramienta` | `HER` | `HER-0000` | A | consistente |
| `costos_mano_obra` | `MO` | `MO-000` | **C** | vacía |
| `costos_indirectos` | `IND` | `IND-000` | A | vacía |
| `subcontratos_catalogo` | `SUB` | `SUB-000` | A | vacía |
| `herramienta_menor` | `HM` | `HM-000` | A | vacía |
| `tarjetas_precios_unitarios` | `TPU` | `TPU-0000` | A | vacía |
| `Proveedores` | `PROV` | `PROV-0000` | A | **roto**, ver §3.2 |
| `Clientes` | `CLI` | `CLI-000` | A | consistente |
| `Colaboradores` | `COL` | `COL-000` | A | 1 con 4 díg |
| `proyectos` | `PRY` | `PRY-000` | A | 2 con 4 díg, 1 con `PROJ-` |
| `partidas_catalogo` | `PART` | `PART-000` | A | consistente |
| `presupuesto_contenedores` | — | UUID v4 | A | consistente |
| `presupuesto_conceptos` | — | UUID v4 | A | consistente |
| `cronograma_actividades` | — | UUID v4 | A | consistente |
| `Finanzas`, `recibos`, `Pagos_Programados` | — | `FIN-LEGACY-000` y `MARB-FIN-000` | A | dos linajes conviviendo |

---

## 2. Las diez pestañas que alimentan una tarjeta de precios unitarios

Una tarjeta se arma con renglones que apuntan a un insumo de alguno de estos catálogos. El
renglón guarda el ID del insumo en `sourceId`, y ese ID es lo que permite que un cambio de
precio en el catálogo se propague a todas las tarjetas que lo usan.

### `conceptos_globales` — 19 columnas (A–S), 877 filas con datos

A=ID · B=Partida · C=Descripción · D=Unidad de Medida · E=Precio de Venta · F=Duración Estimada (horas) · G=notas · H=Costo Directo · I=Utilidad % · J=Cargos Extra % · K=Hta. Menor % · L=claveSat · M=fullSpec · N=weight · O=volume · P=standardPerformance · Q=indirects(%) · R=financing(%) · S=laborPct

### `tarjetas_precios_unitarios` — 12 columnas (A–L), 0 filas con datos

A=id · B=conceptId · C=type · D=sourceId · E=description · F=unit · G=quantity · H=rendimiento · I=unitCost · J=totalCost · K=wastePct · L=notes

### `materiales` — 8 columnas (A–H), 72 filas con datos

A=id_material · B=descripcion · C=unidad · D=costo_unitario · E=Tienda_Proveedor · F=Ciudad · G=Estado · H=Notas

### `costos_mano_obra` — 11 columnas (A–K), 0 filas con datos

A=id_proveedor · B=partida · C=id_cuadrilla · D=category · E=unidad · F=baseSalary · G=fasarFactor · H=realSalary · I=Ciudad · J=Estado · K=descripcion

### `costos_herramienta` — 14 columnas (A–N), 122 filas con datos

A=id_herramienta · B=descripcion · C=tipo · D=unidad · E=costo_unitario · F=rendimiento · G=consumo_combustible · H=costo_combustible_dia · I=operador_requerido · J=id_proveedor_renta · K=ciudad · L=Estado · M=Notas · N=created_at

### `costos_indirectos` — 8 columnas (A–H), 0 filas con datos

A=id_indirecto · B=descripcion · C=tipo · D=unidad · E=costo_unitario · F=factor_aplicacion · G=zona_region · H=notas

### `herramienta_menor` — 9 columnas (A–I), 0 filas con datos

A=id_item · B=descripcion · C=categoria · D=unidad · E=costo_unitario · F=vida_util · G=aplica_a_partida · H=proveedor · I=notes

### `subcontratos_catalogo` — 12 columnas (A–L), 0 filas con datos

A=id_subcontrato · B=descripcion · C=partida · D=unidad · E=precio_unitario_ref · F=id_proveedor · G=incluye_materiales · H=incluye_herramienta · I=ciudad · J=estado · K=notas · L=created_at

### `partidas_catalogo` — 5 columnas (A–E), 47 filas con datos

A=id · B=name · C=prefix · D=order · E=status

### `Proveedores` — 19 columnas (A–S), 75 filas con datos

A=ID · B=empresa · C=nombrePersona · D=Speciality · E=email · F=Phone · G=RFC · H=ADDRESS · I=Ciudad · J=Estado · K=METODO DE PAGO · L=RAZON SOCIAL · M=NUMERO DE CUENTA · N=CLABE · O=BANCO · P=CORREO FISCCAL · Q=NOTES · R=CREATEDAT · S=status


**Fórmula canónica del renglón:**

```
importe = (quantity / (rendimiento || 1)) * unitCost * (1 + wastePct/100)
```

**Herramienta menor no es un renglón:** se aplica como porcentaje del concepto
(`Hta. Menor %`, columna K de `conceptos_globales`).

**Mano de obra como porcentaje (decisión 27-jul-2026):** la mano de obra es un porcentaje del
total del concepto, no salario × rendimiento. Va como campo `laborPct` en `conceptos_globales`
(columna S, pendiente de crear), default 40, tope 50.

```
Total        = (Materiales + Equipo + Indirectos) / (1 - laborPct/100)
Mano de obra = Total * laborPct/100
```

---

## 3. Anomalías reales de los datos, al 28-jul-2026

### 3.1 `conceptos_globales` — 40 formatos de ID distintos en 877 filas

El generador cambió de comportamiento y quedaron linajes conviviendo:

| Linaje | Ejemplo | Aprox. | Qué pasó |
|---|---|---|---|
| Sin cero a la izquierda | `ALB8072`, `PRE2223`, `DEM5013` | 270 | `parseInt("08")` = 8, se perdió el cero |
| Con cero a la izquierda | `ALB08001`, `PRE02001`, `DEM05012` | 500 | formato correcto |
| Con guion | `EVE-0001`, `CIM-0001`, `TRA-1009` | 38 | otro generador más |

`getNextConceptId` en `sheets-catalog.ts` ya se corrigió para producir el formato con cero.
**Los IDs viejos no se han migrado.** Si se migran, hay que actualizar en cascada
`presupuesto_conceptos.conceptId`, `cronograma_actividades.conceptId` y
`tarjetas_precios_unitarios.conceptId`. No es un rename simple.

- **`ARR6011` está duplicado**: dos filas distintas con el mismo ID.
- 1 concepto sin precio de venta.
- 1 concepto con partida `Sistemas`, que no existe en `partidas_catalogo`, donde se llama
  `Sistemas y Redes`.

### 3.2 `Proveedores` — IDs repetidos y dos formatos

- `PROV-007` aparece **3 veces**, `PROV-012` **2 veces**, `PROV-013` **2 veces**. Son filas
  distintas con el mismo ID: `findRowIndexByValue` toma la primera y las demás quedan
  inalcanzables.
- Dos formatos: `PROV-0000` (63 filas) y `PROV-000` (12 filas). Por eso `PROV-074` no
  colisionó con `PROV-0074` y se creó un duplicado el 27-jul-2026.
- **52 de 75 proveedores no tienen especialidad.**
- Candidatos a fusión: `PROV-0042 Material San Francisco` / `PROV-0043 Materiales San
  Francisco`; `PROV-0020 Candido Cocone` / `PROV-0053 Sr Candido` / `PROV-0054 Sr Cocone`;
  `PROV-0015 Adrian` / `PROV-0016 Adrian Gomez Lucero`; `PROV-0022 David Hernandez / Taller
  Mecanico` / `PROV-0069 Taller`.

### 3.3 `materiales` — la columna E no tiene un solo significado

`Tienda_Proveedor` trae **34 filas con un ID** (`PROV-0006`) y **38 con texto libre**
(`TAMEX`, `COPREMAPSA`). Para que la cascada de precios funcione tiene que ser siempre el ID.

La columna H (`Notas`) se está usando de facto como partida: sus únicos dos valores son
`Electrico` y `Tablaroca y Durock`.

**Decisión 28-jul-2026:** `materiales` no tiene columna de partida y no se le agrega por ahora.
La partida se escribe al inicio de `Notas` con el formato `[PARTIDA: NOMBRE]`, que es parseable
y no rompe el esquema.

### 3.4 `costos_herramienta` — precios con IVA incluido

Las filas del catálogo de Renta Maq. Rivas traían el 16% de IVA dentro del `costo_unitario`
(precio viejo = precio neto × 1.16, verificado en las 116 filas). **El costo directo de una
tarjeta va SIN IVA.** El 28-jul-2026 se decidió vaciar la pestaña y reconstruirla con precios
netos e IDs regenerados.

### 3.5 Pestañas vacías: 28 de 59

Ninguna es basura: todas tienen encabezado y corresponden a un módulo previsto. Las que
bloquean el trabajo actual son `tarjetas_precios_unitarios`, `costos_mano_obra`,
`costos_indirectos`, `subcontratos_catalogo` y `herramienta_menor`.

### 3.6 Pestañas muertas o de respaldo — no leer, no escribir

| Pestaña | Filas | Qué es |
|---|---|---|
| `analisis_pu` | 0 | **Esquema deprecado** de tarjetas. `recalculateAllPrices()` de V8 lee ESTA hoja: por eso la cascada nunca funcionó. No copiar esa función. |
| `Budgets` | 202 | Modelo de presupuesto anterior a `presupuesto_contenedores` |
| `BKUP` | 438 | Respaldo de un catálogo de conceptos anterior |
| `bckuocontenedores` | 8 | Respaldo |
| `BKUPpresupuesto_conceptos` | 132 | Respaldo |
| `bckupcronograma` | 189 | Respaldo |
| `primer DESTAJO` | 89 | Hoja de trabajo manual, 189 columnas, sin encabezado |
| `primer FLUJORAMA` | 89 | Hoja de trabajo manual, 33 columnas, sin encabezado |

---

## 4. Esquema de las pestañas en producción

### `Clientes` — 10 columnas (A–J), 12 filas con datos

A=id · B=name · C=phone · D=email · E=address · F=rfc · G=zone · H=TIPO · I=notes · J=createdAt

### `Colaboradores` — 11 columnas (A–K), 5 filas con datos

A=ID · B=ATT · C=NAME · D=CARGO · E=AREA · F=PERFIL · G=TEL · H=CORREO · I=Pass · J=ROL · K=FECHA

### `proyectos` — 25 columnas (A–Y), 20 filas con datos

A=id · B=name · C=clientId · D=address · E=managerId · F=projectType · G=projectSubtype · H=status · I=clientEstimate · J=budgeted · K=paid · L=remaining · M=creationDate · N=zone · O=notes · P=googleDriveFolderId · Q=modalidad · R=submodalidad · S=project_json · T=nextTask · U=nextTaskDate · V=nextTaskTime · W=nextTaskLocation · X=nextTaskResponsibleId · Y=budgetItemId

### `presupuesto_contenedores` — 13 columnas (A–M), 8 filas con datos

A=id · B=projectId · C=name · D=modality · E=status · F=generalNotes · G=squareMeters · H=utilityPct · I=subtotal · J=createdAt · K=includeIva · L=areaOrder · M=areaNotes

### `presupuesto_conceptos` — 14 columnas (A–N), 132 filas con datos

A=id · B=containerId · C=projectId · D=conceptId · E=conceptName · F=area · G=category · H=unit · I=qty · J=unitPrice · K=catalogPrice · L=costPrice · M=totalPrice · N=notes

### `cronograma_actividades` — 21 columnas (A–U), 189 filas con datos

A=id · B=projectId · C=budgetItemId · D=conceptId · E=conceptName · F=category · G=quantity · H=unit · I=status · J=startDate · K=endDate · L=notes · M=progress · N=subTasks · O=predecessorId · P=events · Q=type_taskmilestone · R=BaselineStartdate · S=BaselineEndDate · T=lagDays · U=recurrencecount

### `Finanzas` — 27 columnas (A–AA), 320 filas con datos

A=id · B=date · C=concept · D=type · E=amount · F=contactId · G=projectId · H=containerId · I=budgetItemId · J=category · K=status · L=notes · M=receiptLink · N=invoiceId · O=location · P=paymentMethod · Q=createdBy · R=createdAt · S=updatedAt · T=ambito · U=modalidad · V=subModalidad · W=subtotal · X=tax · Y=includeIva · Z=ivaRate · AA=folio

### `recibos` — 26 columnas (A–Z), 320 filas con datos

A=id · B=folio · C=fecha · D=ProjectID · E=type · F=category · G=subcategory · H=involvedType · I=involvedID · J=concept · K=amount · L=subtotal · M=tax · N=status · O=paymentMethod · P=reference · Q=budgetItemID · R=contractID · S=pieceworkID · T=evidenceLink · U=notes · V=createdAt · W=createdBy · X=clientID · Y=providerID · Z=collaboratorID

### `Pagos_Programados` — 23 columnas (A–W), 265 filas con datos

A=id · B=projectId · C=providerId · D=budgetItemId · E=conceptName · F=category · G=amount · H=paymentMethod · I=status · J=periodStart · K=periodEnd · L=notes · M=receiptId · N=totalQuoteAmount · O=paymentType · P=requestedBy · Q=requisitionDate · R=quoteId · S=quoteAmount · T=evidenceLink · U=receiptLink · V=validatedBy · W=validatedAt

### `INVENTARIO` — 16 columnas (A–P), 6 filas con datos

A=ID · B=Nombre Herramienta · C=Tipo · D=Categoría · E=Marca · F=Modelo · G=serialNumber · H=status · I=location · J=assignedToId · K=deliveryDate · L=returnDate · M=Bitácora Link · N=projectId · O=Observaciones · P=locacion

### `Bitacora` — 29 columnas (A–AC), 18 filas con datos

A=id · B=projectid · C=date · D=entryType · E=description · F=area · G=location · H=attendees · I=attachments · J=createdBy · K=createdAt · L=hora · M=criticidad · N=Notas Técnicas (AAR) · O=item_referencia · P=ejes · Q=hasFinancialRecord · R=amount · S=movementType · T=responsibleId · U=involvedId · V=financeCategory · W=receiptFolio · X=avancePercentage · Y=cotizacionLink · Z=weather · AA=personnelReport · AB=machineryReport · AC=materialsReceived

### `datos_empresa` — 24 columnas (A–X), 2 filas con datos

A=id_empresa · B=nombre_comercial · C=nombre_corto · D=nombre_fiscal_empresa · E=rfc_empresa · F=direccion_fiscal · G=ubicacion · H=telefono_principal · I=telefono_alterno · J=email_contacto · K=sitio_web · L=representante_nombre · M=representante_rol · N=leyenda_confidencialidad · O=leyenda_legal_general · P=leyenda_powered_by · Q=version_builder · R=licencia_software_activa_hasta · S=vigencia_dias_cotizacion · T=iva_porcentaje · U=moneda_local · V=formato_fecha · W=mostrar_firma_representante · X=logo_svg_code

### `zonas_regiones` — 4 columnas (A–D), 2 filas con datos

A=ESTADO · B=CIUDAD · C=REGION · D=FACTOR COSTO

### `Servicios` — 7 columnas (A–G), 12 filas con datos

A=id · B=concepto · C=categoria · D=rangoPrecio · E=unidad · F=descripcion · G=variables

### `Salidas_electricas` — 11 columnas (A–K), 98 filas con datos

A=ID · B=Descripción · C=Categoría · D=Voltaje (V) · E=Potencia unitaria (W) o (VA) · F=Factor de potencia (fp) · G=Factor de demanda (%) · H=Fases · I=Corriente nominal (A) · J=Notas · K=shortDescription

### `estimador_base` — 6 columnas (A–F), 1 filas con datos

A=Tipo de Proyecto · B=Etapa · C=Unidad · D=Precio m² · E=Incluye · F=Editable

### `Usuarios` — 2 columnas (A–B), 1 filas con datos

A=MAIL · B=password

### `Partidas` — 3 columnas (A–C), 32 filas con datos

A=Partida · B=Prefijo · C=Número


---

## 5. Pestañas previstas, todavía vacías

### `requisiciones` — 7 columnas (A–G), 0 filas con datos

A=id · B=projectId · C=date · D=requestedBy · E=status · F=totalAmount · G=notes

### `requisicion_items` — 7 columnas (A–G), 0 filas con datos

A=id · B=requisitionId · C=budgetItemId · D=description · E=unit · F=quantityRequested · G=status

### `cotizaciones` — 9 columnas (A–I), 0 filas con datos

A=id · B=projectId · C=providerId · D=budgetItemId · E=date · F=amount · G=status · H=fileLink · I=notes

### `cotizaciones_items` — 11 columnas (A–K), 0 filas con datos

A=id · B=cotizacionId · C=budgetItemId · D=description · E=unit · F=quantity · G=unitPrice · H=totalPrice · I=type · J=status · K=notes

### `cotizacion_conceptos` — 9 columnas (A–I), 0 filas con datos

A=id · B=cotizacionId · C=conceptId · D=conceptName · E=percentage · F=tpuPrice · G=quotedPrice · H=amount · I=status

### `destajos` — 16 columnas (A–P), 0 filas con datos

A=id · B=projectId · C=providerId · D=budgetItemId · E=scheduleItemId · F=conceptName · G=contractorName · H=unit · I=executedQty · J=unitCostLabor · K=totalPayment · L=cutoffDate · M=periodName · N=status · O=notes · P=logbookEntryId

### `subcontratos` — 12 columnas (A–L), 0 filas con datos

A=id_subcontrato · B=descripcion · C=partida · D=unidad · E=precio_unitario_ref · F=id_proveedor · G=incluye_materiales · H=incluye_herramienta · I=ciudad · J=estado · K=notas · L=created_at

### `anticipos` — 15 columnas (A–O), 0 filas con datos

A=id · B=projectId · C=providerId · D=providerName · E=staffRosterId · F=workerName · G=amount · H=totalAmortized · I=remaining · J=status · K=startDate · L=numInstallments · M=installmentAmount · N=notes · O=createdAt

### `amortizacion_schedule` — 9 columnas (A–I), 0 filas con datos

A=id · B=advanceId · C=installmentNumber · D=dueDate · E=amount · F=status · G=paidDate · H=paidAmount · I=notes

### `nomina` — 17 columnas (A–Q), 0 filas con datos

A=id · B=collaboratorId · C=collaboratorName · D=projectId · E=periodStart · F=periodEnd · G=daysWorked · H=dailyRate · I=extraPay · J=bonuses · K=extraHours · L=deductions · M=totalNet · N=status · O=paymentDate · P=receiptId · Q=notes

### `staff_roster` — 13 columnas (A–M), 0 filas con datos

A=id · B=project_id · C=providerId · D=name · E=role · F=dailyRate · G=paymentMode · H=pieceworkId · I=status · J=joinDate · K=leaveDate · L=notes · M=attendance

### `Raya_Semanal` — 12 columnas (A–L), 0 filas con datos

A=ID · B=projectId · C=workerId · D=name · E=role · F=caboProviderId · G=payType · H=dailyRate · I=weekStart · J=lun–dom · K=totalWeek · L=notes

### `Viaticos` — 8 columnas (A–H), 0 filas con datos

A=Concepto. · B=Cantidad · C=Fecha · D=(Vacío) · E=(Vacío) · F=(Vacío) · G=(Vacío) · H=(Vacío)

### `INVENTARIO_MATERIALES` — 14 columnas (A–N), 0 filas con datos

A=id · B=projectId · C=materialName · D=quantity · E=unit · F=unitCost · G=totalCost · H=providerId · I=budgetItemId · J=entryDate · K=location · L=lotNumber · M=status · N=notes

### `cronograma_vivo` — 16 columnas (A–P), 0 filas con datos

A=id · B=projectId · C=budgetContainerId · D=budgetItemId · E=weekNumber · F=startDate · G=endDate · H=percentage · I=accumulatedPercentage · J=status · K=source · L=logbookEntryId · M=notes · N=createdBy · O=createdAt · P=updatedAt

### `consumo_tpu` — 15 columnas (A–O), 0 filas con datos

A=id · B=projectId · C=budgetItemId · D=conceptId · E=insumoType · F=insumoId · G=insumoName · H=consumedQuantity · I=purchaseAmount · J=unitPrice · K=receiptId · L=movementId · M=period · N=notes · O=createdAt

### `Tareas_de_Trabajo` — 13 columnas (A–M), 0 filas con datos

A=id · B=title · C=description · D=type · E=status · F=date · G=startTime · H=endTime · I=userId · J=userName · K=responsibleId · L=responsibleName · M=version

### `areas_fisicas` — 3 columnas (A–C), 0 filas con datos

A=ID · B=NAME · C=DESCRIPTION

### `eventos_globales` — 10 columnas (A–J), 0 filas con datos

A=ID · B=Título · C=Fecha · D=Hora Inicio · E=Hora Fin · F=Tipo de Evento · G=Descripción · H=Proyecto Relacionado · I=Participantes · J=Estado

### `finanzas_globales` — 7 columnas (A–G), 0 filas con datos

A=Proyecto ID · B=Nombre Proyecto · C=Ingresos Totales · D=Egresos Totales · E=Margen Actual · F=Estado · G=Fecha Corte

### `Cuadros de Cargas` — 7 columnas (A–G), 0 filas con datos

A=id · B=name · C=loadWatts · D=powerFactor · E=voltage · F=breakerSize · G=phase

### `LoadLibrary` — 1 columnas (A–A), 0 filas con datos

A=id


---

## 6. Homologación de archivos externos

"Homologar" significa **traducir** un archivo que vive en otro formato al esquema de estas
pestañas. No es copiar: es mapear columna por columna.

### 6.1 Catálogo de la Arq. Fernanda 2026

`Felipe/Cotizaciones/catalogo arqui fer/MANO DE OBRA, MATERIALES, MAQUINARIA Y HERRAMIENTA 2026.xlsx`

13 pestañas. Ella **separa los materiales por partida en pestañas distintas**; nosotros los
tenemos todos en `materiales`. Ese es el corazón de la traducción.

| Pestaña de ella | Filas | Destino | Traducción |
|---|---|---|---|
| `MAT. ALBAÑILERIA` | 23 | `materiales` | `[PARTIDA: ALBAÑILERÍAS]` en Notas |
| `ACERO` | 12 | `materiales` | `[PARTIDA: ACERO / ALBAÑILERÍAS]` |
| `FERRETERIA` | 10 | `materiales` | `[PARTIDA: FERRETERÍA]` |
| `PLOMERIA` | 45 | `materiales` | `[PARTIDA: INSTALACIONES HIDROSANITARIAS]` |
| `ELÉCTRICO` | 35 | `materiales` | `[PARTIDA: INSTALACIONES ELÉCTRICAS]` |
| `ACABADOS` | 15 | `materiales` | `[PARTIDA: ACABADOS]` |
| `CANCELERIA` | 1 | `materiales` | `[PARTIDA: CANCELERÍA Y ALUMINIO]` |
| `CARPINTERIA` | 15 | `materiales` | `[PARTIDA: CARPINTERÍA]` |
| `MAQUINARIA Y HERRAMIENTA` | 6 | `costos_herramienta` | `tipo` = Rentada |
| `SALARIO CUADRILLA` | 4 | `costos_mano_obra` | el ID va a la columna C |
| `MANO DE OBRA` | 6 | `subcontratos_catalogo` | son **destajos** ($/m² de obra terminada), no salarios |
| `PROVEEDORES` | 7 | `Proveedores` | 10 de sus proveedores ya existían con otro nombre |
| `SERVICIOS DRAVYA` | 15 | `conceptos_globales` | son conceptos **vendibles**, partida Proyecto |

**Mapeo de columnas de sus hojas de material:**

| Ella | Nosotros |
|---|---|
| `DESCRIPCION` | `materiales.descripcion` (B) |
| `UNIDAD` | `materiales.unidad` (C), normalizada contra `unitOptions` |
| `COSTO UNITARIO` | `materiales.costo_unitario` (D) |
| `TIENDA/PROVEEDOR` | `materiales.Tienda_Proveedor` (E), resuelto a ID |
| `MUNICIPIO` | `materiales.Ciudad` (F) |
| `ESTADO` | `materiales.Estado` (G) |
| `CANTIDAD` | no se guarda: siempre vale 1, es su forma de escribir el unitario |
| pestaña de origen | `materiales.Notas` (H), como `[PARTIDA: ...]` |

**Cosas que hay que saber de su archivo:**

- **Un material aparece varias veces a propósito**, uno por proveedor: es su comparativo de
  precios. `POLIN` x3, `CABLE NO. 10` x3, `TABIQUE` x2, `TEPETATE` x2. Hay que conservarlos todos.
- El `WC` de `PLOMERIA` trae descripción y unidad pero **sin precio**.
- Varias filas de `PLOMERIA` y `FERRETERIA` traen precio pero **sin proveedor**.
- Nota suya en `SALARIO CUADRILLA`: *lo máximo que se le paga al maestro por cada trabajador
  es el 10% de su salario*.
- Su ayudante está en $2,500 semanales; Stefanno lo actualizó a $2,800 el 27-jul-2026.

### 6.2 Presupuestos de proyectos anteriores

`Felipe/Cotizaciones/Referencias para TPU/PRESUPUESTOS/` — 7 archivos.

Todos siguen la **misma plantilla**, con las partidas como filas de encabezado
(`1.0 PERMISOS Y SERVICIOS`) y los conceptos numerados debajo (`1.1`, `1.2`):

```
CLAVE | CONCEPTO | CANTIDAD | UNIDAD | PRECIO UNITARIO | TOTAL
```

En algunos archivos `UNIDAD` y `CANTIDAD` están invertidas. Hay que leer el encabezado, no
asumir el orden.

| Archivo | Hojas útiles |
|---|---|
| `CASA HABITACIÓN TEQUISQUIAPAN 2024.xlsx` | 26 hojas. `PRESUPUESTO FINAL `, `GENERADORES`, `ADITIVAS Y DEDUCTIVAS`, `PAGO DE DERECHOS` |
| `PRESUPUESTO DE OBRA SR. FRANCISCO 2026.xlsx` | `PRESUPUESTO COMPLETO`, `GENERADORES`, `TRÁMITES`, `CRONOGRAMA` |
| `REMODELACIÓN CASA CRISTINA 2025.xlsx` | `PRESUPUESTO AUTORIZADO`, `GASTOS SEMANA 1..7`, `PENDIENTES POR PROVEEDOR` |
| `PRESUPUESTO REMODELACION DEPARTAMENTOS 2025.xlsx` | `PRESUPUESTO DEPARTAMENTO 1`, `CRONOGRAMA` |
| `REMODELACIÓN DEPARTAMENTO ANITA 2026.xlsx` | `INVERSIÓN TOTAL DEPARTAMENTO` |
| `LOSA ESCUELA CHALCHIHUAPAN 2025.xlsx` | `PRESUPUESTO ENTREGA`, `REQUISICIÓN DE MATERIALES` |
| `PRESUPUESTO LOSA PRESIDENCIA ACATEPEC 2025.xlsx` | `PRESUPUESTO`, `LOSA NUEVA GENERADORES` |

**Ojo:** varios se copiaron entre sí como plantilla y repiten hojas idénticas (`Hoja1`,
`RESUMEN`, `CONCEPTOS PENDIENTES`, `PRESUPUESTO CASA` aparecen en 4 archivos con el mismo
contenido). Al homologar hay que deduplicar por descripción, no por archivo.

**Qué se extrae y a dónde va:**

- Los **conceptos** (descripción + unidad + precio unitario) → `conceptos_globales`, como
  catálogo histórico. Son la fuente más rica que existe: precios reales ya cobrados.
- Las **cantidades** NO se suben: pertenecen a un proyecto ya ejecutado.
- Los **`GENERADORES`** son el cálculo de volumetría (ejes, tramos, largo × ancho ×
  profundidad). No van a la base, pero documentan cómo se sacó cada cantidad.
- Las hojas **`GASTOS SEMANA n`** son el antecedente directo del control de obra: ingresos,
  egresos de material, mano de obra y nómina por semana.

### 6.3 Catálogos de referencia

`Felipe/Cotizaciones/catalogos/` — 14 PDF de costos directos (2018 y 2022): vivienda,
carreteras, salud, infraestructura educativa, cimentaciones profundas, pozos, eco-tecnologías,
materiales reciclados, horario de maquinaria. Se usan como **contraste** para validar un precio
unitario propio, no como fuente de carga.

`Felipe/Cotizaciones/Referencias para TPU/Maquinaría/` — 3 PDF con las listas de precios 2025
de Rivas. Es el origen de `costos_herramienta`.

---

## 7. Cómo se carga información a la base

Herramienta única: **`scripts/bulk-import.mjs`**.

```bash
node scripts/bulk-import.mjs <payload.json> --dry-run   # siempre primero
node scripts/bulk-import.mjs <payload.json>
```

**El script no borra nada.** No tiene `deleteDimension`, no tiene `clear()`, no tiene
`batchClear`. Solo sabe dos cosas: agregar una fila al final (`values.append`) y reemplazar el
valor de una celda localizada por su ID (`update_cell`). Los borrados los hace Stefanno a mano
en el Sheet, y el script o el asistente le dicen exactamente qué pestaña y qué filas.

Operaciones: `create_client`, `create_project`, `create_budget_container`,
`create_global_concept`, `create_budget_concept`, `create_provider`, `create_equipment`,
`create_material`, `create_labor`, `create_indirect`, `create_subcontract`, `create_tpu_item`,
`update_cell`.

Una operación puede llevar `tempId` para que otra posterior la referencie con `$tempId`. Al
terminar, el script escribe `<payload>-idmap.json` y `<payload>-idmap.csv` con el ID real que le
tocó a cada fila creada. Ese archivo es la entrada del siguiente payload, porque las tarjetas
necesitan el ID real del insumo en `sourceId`.
