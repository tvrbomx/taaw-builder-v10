# SATÉLITE · CÁLCULO ELÉCTRICO · CONCEPTUALIZACIÓN

**R01 · 7-ago-2026 · aplicación independiente que consume el núcleo de [[V10-PLAN-DE-TRABAJO-R02]]**

Sale de la V10 por decisión de Stefanno. Son cálculos de ingeniería con normativa propia
y ritmo propio; meterlos dentro de la plataforma la vuelve pesada sin hacerla mejor.

---

## 1. Qué hace

**Lo que hoy hace un arquitecto cuando desarrolla el plano eléctrico de un proyecto
ejecutivo**, y que hoy se resuelve con hojas de Excel heredadas.

El ejercicio real, tal como se hace:

1. Se colocan **todas las salidas** que va a tener el inmueble
2. Se **agrupan en circuitos**, según criterio y experiencia
3. De ahí sale el **calibre de cable**, el **interruptor termomagnético** y el **tablero**
4. Se balancean las fases según el servicio de CFE contratado

La app hace ese recorrido: se arma un circuito, se le van metiendo salidas, y ella
**sugiere calibre, protección y tablero** conforme se llena.

---

## 2. Alcance por tipo de proyecto

Cada tipo trae su propia capa de complejidad:

| Tipo | Nota |
|---|---|
| **Doméstico** | El caso base. Con el que se arranca |
| Comercial | Cargas continuas, horarios, alumbrado de emergencia |
| Industrial | Motores, factor de potencia, arranques |
| Gobierno | Requisitos de licitación y verificación reforzada |

**Servicio de CFE:** de monofásico a trifásico. El tipo de servicio cambia el balanceo
y la selección de protecciones.

---

## 3. Los catálogos que necesita

Igual que la V10, esto son bases de datos distintas para componentes distintos:

| Catálogo | Contenido |
|---|---|
| **Salidas** | Aparatos que se conectan a un enchufe o van conectados directo. Con su carga en watts y su factor de demanda |
| **Cables** | Calibre, tipo de aislamiento, capacidad de conducción, caída de tensión |
| **Interruptores termomagnéticos** | Tipo, capacidad, número de polos, curva |
| **Tableros** | Número de espacios, tipo de montaje, barras |
| **Canalizaciones** | Tubería, charolas, capacidad de relleno |

---

## 4. Estructura eléctrica que debe modelar

```
ACOMETIDA CFE  (monofásica · bifásica · trifásica)
      ↓
INTERRUPTOR PRINCIPAL
      ↓
TABLERO PRINCIPAL
      ↓
SUBTABLEROS  (uno o varios)
      ↓
CIRCUITOS
      ↓
SALIDAS
```

Debe permitir varios subtableros colgando de un interruptor principal.

---

## 5. Cálculos

- Carga por salida y carga total por circuito
- Balanceo de fases
- Caída de tensión por circuito y por alimentador
- Selección de calibre
- Selección de protección
- Dimensionamiento de tablero y de acometida
- Cuadro de cargas completo

---

## 6. Normativa

**Pendiente de recuperar.** En una versión anterior se alimentó a la IA con documentación
normativa para que los cálculos cumplieran con lo que pide la **unidad verificadora en
México**. Se desconoce si esa documentación sobrevive.

**Primera tarea del anteproyecto de este satélite:** buscar esa normativa en el repositorio
de la V8 y en el histórico de los agentes. Si no aparece, se reconstruye.

A esa base normativa se le suma el **estándar BIM de Dravya**, para que el resultado sea
una norma interna estricta de cómo se calculan cargas en el despacho.

---

## 7. Qué consume de la V10

No duplica nada. Lee del núcleo:

`cliente` · `proyecto` · `colaborador` · `proveedor` · `insumo` · `concepto`

**Y devuelve al núcleo:** las cantidades calculadas —salidas, metros de cable, piezas de
protección— entran como volúmenes al presupuesto. Ese es el punto de unión y la razón de
que sea satélite y no aplicación suelta.

---

## 8. Documentos que emite

- Cuadro de cargas
- Memoria de cálculo eléctrico
- Diagrama unifilar
- Lista de materiales eléctricos para el presupuesto

---

## 9. Pendientes

| # | Pendiente |
|---|---|
| 1 | Recuperar la normativa de unidad verificadora usada en versiones anteriores |
| 2 | Revisar el código del módulo eléctrico de la V8 y decidir qué se rescata |
| 3 | Definir el catálogo base de salidas para proyecto doméstico |
| 4 | Decidir si el diagrama unifilar se dibuja o sólo se tabula |

---

*Satélite 1 de la navaja suiza. No se desarrolla hasta que la V10 tenga su núcleo en pie.*
