# TAAW BUILDER V10 · DISEÑO E INTERFAZ

**R01 · 7-ago-2026 · documento de diseño de [[V10-PLAN-DE-TRABAJO-R02]]**

Dirección visual, filosofía de interfaz y sistema de tokens.
Lo técnico de cómo se implementa vive en [[V10-ARQUITECTURA]].

---

## 1. La referencia

**Notis · Smart AI Workspace**, en Behance. Estética *Frutiger Aero* aplicada a una
herramienta de trabajo moderna.

Lo que hay que tomar de ahí:

- **Fondos con presencia.** Imágenes amplias, atmosféricas, con profundidad —
  no rellenos planos
- **Vidrio.** Paneles translúcidos con desenfoque que dejan ver el fondo a través
- **Brillo suave.** Reflejos y luz sobre las superficies, sin caer en el plástico
- **Profundidad real.** Capas que flotan sobre el fondo, sombras difusas, sensación
  de espacio
- **Optimismo.** Es una estética luminosa, generosa, que da gusto usar

**El contenido pasa por encima del fondo, no lo tapa.** Esa es la idea central:
el fondo respira, los paneles de vidrio lo dejan ver, y la información vive encima.

---

## 2. La tensión que hay que resolver

Frutiger Aero clásico es acuático: azules, verdes, agua, cielo.
La marca de Dravya es cálida: hueso y cafés.

**Aero cálido. Aprobado por Stefanno el 9-ago-2026.** Se conserva toda la estructura
—vidrio, profundidad, brillo, fondos atmosféricos— pero la temperatura es la de la
marca: hueso y cafés. Fondos de luz cálida, piedra, madera, arena, atardecer. Vidrio
ámbar en vez de vidrio azul.

Así la aplicación y el hub informativo se sienten de la misma casa, y la marca no se
diluye en una moda. La alternativa —aero frío clásico, reservando hueso y café sólo para
el hub— queda descartada.

---

## 3. Fondos generados

Los fondos se producen con IA y se guardan como recursos del sistema de diseño.
**No son decoración: son parte del tema.**

Reglas:

- Un fondo por **módulo**, no por pantalla. Que se reconozca dónde estás por la atmósfera
- Muy poco contraste interno. Un fondo que compite con el contenido está mal
- Versión clara y versión oscura de cada uno
- Formato comprimido y con carga diferida. Un fondo bonito que hace lenta la app es un
  fondo malo
- Se pueden desactivar desde preferencias, para quien prefiera fondo liso

### Guía para generarlos

```
Fondo abstracto atmosférico para interfaz de software profesional.
Paleta cálida: hueso, arena, café claro, ámbar tenue.
Luz suave difusa, profundidad, sensación de espacio abierto.
Formas orgánicas muy sutiles, sin objetos reconocibles.
Contraste interno bajo — debe servir de fondo para texto encima.
Estilo Frutiger Aero contemporáneo: limpio, luminoso, translúcido.
Sin texto, sin logotipos, sin figuras humanas.
Relación 16:9, alta resolución.
```

Variantes por módulo cambiando la temperatura y el motivo: catálogo más neutro,
obra más terroso, dinero más ámbar, junta más luminoso.

---

## 4. Tokens

Todo vive en un solo archivo. Ninguna pantalla escribe un color literal.

### Superficie y vidrio

- `fondo-imagen` — el fondo atmosférico del módulo
- `vidrio` — panel translúcido con desenfoque. Es la superficie principal
- `vidrio-elevado` — para lo que flota encima: menús, diálogos
- `vidrio-borde` — el filo luminoso que le da el brillo característico

### Texto

- `texto` · `texto-tenue` · `texto-inverso`

### Acento y estado

- `acento` · `acento-tenue`
- `positivo` · `atencion` · `negativo` — **sólo para estados reales, nunca para decorar**

### Forma

- Radios generosos. El aero es redondo, no anguloso
- Sombras difusas y amplias, nunca duras
- Espaciado abundante. La interfaz respira

---

## 5. Tipografía

| Uso | Tipo |
|---|---|
| Títulos de sección | Display con carácter, tamaño grande y confiado |
| Cuerpo | Sans limpia, 16 a 18 px, interlineado generoso |
| Claves, folios y códigos | Monoespaciada. Siempre |
| Números de dinero | Tabular, para que las columnas alineen |

La jerarquía la marca **el tamaño y el aire**, no las cajas ni los colores.
Tamaño ajustable por el usuario sin que se rompa nada.

---

## 6. Modo claro y oscuro

Los dos desde el primer día, con el mismo juego de tokens y dos valores.

En oscuro el vidrio se vuelve más denso y el fondo baja de luminosidad, pero **no se
convierte en negro plano**: conserva la temperatura. Un oscuro frío rompería la marca.

Si un componente se ve mal en oscuro, el componente está mal, no el tema.

---

## 7. Los cuatro patrones

Se diseñan antes que cualquier pantalla. Toda la aplicación sale de estos cuatro:

**Tabla.** Es el patrón más usado. Densa pero legible, con columnas fijas, orden,
filtro, y una fila que puede expandirse sin abrir otra pantalla.

**Formulario.** Etiqueta arriba, campo abajo, ayuda al lado. Validación al salir del
campo, nunca al enviar. Los errores se explican, no se anuncian.

**Ficha.** La vista de un registro: encabezado con lo esencial, pestañas para lo demás,
acciones siempre en el mismo lugar.

**Línea de tiempo.** La bitácora y el cronograma se apoyan en ella. Eventos sobre un eje,
agrupados por día, con foto y documento adjuntos. Es la vista que cuenta la historia
del proyecto.

---

## 8. Filosofía de interfaz

**Un dato se captura una vez.** Si el usuario ya lo escribió, la aplicación no se lo
vuelve a pedir. Ese es el criterio de valor de toda la plataforma y también el de la
interfaz.

**El error se explica, no se anuncia.** "No se pudo guardar" no sirve. "El concepto
ALB08211 ya existe en este presupuesto" sí.

**Nada se pierde en silencio.** Si algo falló, se ve. Si algo está incompleto, se marca.

**El cliente nunca ve lo interno.** Costo directo, utilidad y proveedores no aparecen en
ninguna vista que se pueda imprimir para el cliente. Es regla de diseño, no de permisos.

**La densidad se gana.** Una pantalla puede ser densa si el patrón es conocido. Un
formulario nuevo, no.

---

## 9. Homologación con el hub informativo

El hub de Dravya y la aplicación deben sentirse de la misma casa: misma temperatura,
misma tipografía, mismo trato del espacio.

**La diferencia es el propósito.** El hub es editorial y contemplativo: se lee.
La aplicación es instrumental: se opera. El hub puede darse el lujo de una portada a
pantalla completa; la app no.

Cuando se apruebe la dirección de este documento, el hub se ajusta para alinearse.

---

## 10. Pendientes

| # | Pendiente |
|---|---|
| 1 | Aprobar *aero cálido* contra *aero frío* |
| 2 | Elegir las dos familias tipográficas |
| 3 | Generar el juego de fondos por módulo, claro y oscuro |
| 4 | Definir el logotipo de TAAW Builder y su relación con el de Dravya |

---

*Documento de diseño. Se aplica en la rebanada 1 de [[V10-PLAN-DE-TRABAJO-R02]].*
