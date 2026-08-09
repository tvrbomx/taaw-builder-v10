# TAAW V10 · ARQUITECTURA

**R01 · 7-ago-2026 · documento 2 de [[V10-PLAN-DE-TRABAJO-R02]]**

Define **el terreno nivelado**: todo lo que si no existe antes de la primera función,
después rompe la aplicación al intentar agregarlo. Es la rebanada 1.

---

## 1. Decisiones de fondo

| Decisión | Elección | Por qué |
|---|---|---|
| Framework | **Next.js 15 + TypeScript** | Se conserva. El equipo ya lo conoce, las 60 pantallas de la V8 sirven de referencia visual, y Dokploy lo despliega con Nixpacks sin configuración |
| Base de datos | **PostgreSQL** | Lo único que da integridad referencial real. Es lo que Sheets no puede hacer y lo que quebró a la V8 |
| Acceso a datos | **Prisma** | Migraciones versionadas y tipos generados del esquema. El esquema se congela y el compilador lo vigila |
| Autenticación | **Auth.js** con credenciales y roles en base | Gratuito, en el propio servidor, sin depender de terceros |
| Documentos PDF | **@react-pdf/renderer** | Ya se usa en la V8 y funciona |
| Archivos y fotos | **Volumen local del servidor** | Costo cero. Respaldo junto con la base |
| Despliegue | **Dokploy en el mini PC** | Ver §7 |

**Lo que se descarta y por qué:** Google Sheets como base de datos. No puede rechazar un
dato inválido, no tiene llaves foráneas, no tiene transacciones. Los 877 conceptos con
40 formatos de ID son consecuencia directa de eso.

### 1.1 Versiones exactas — rebanada 1 · 9-ago-2026

Todo `package.json` fija versión exacta, nunca rango ni `@latest`. Cada desviación de
"la última disponible" tiene una razón verificada contra el registro real de npm o
contra un `npm install` real, no una preferencia.

| Paquete | Versión fija | Por qué |
|---|---|---|
| Node | **22** | LTS activo al momento de arrancar la rebanada |
| Next.js | **15.5.23** | Aprobado en 15. `create-next-app@latest` instaló 16.3.0 — corregido de vuelta a la última 15.x estable, no a la última disponible |
| React / react-dom | **19.2.8** | La que trae Next 15.5.23 como peer |
| TypeScript | **5.9.3**, no 7 | `create-next-app` resolvió `^5`; la 7.0.2 (dos mayores de salto) no tiene señal de compatibilidad verificada con las herramientas de Next 15.5.23 |
| Prisma / @prisma/client | **6.19.3**, no 7 | Al fijarse, `@auth/prisma-adapter@2.11.3` sólo declaraba soporte de peer hasta `@prisma/client >=6`, no `>=7` — verificado con `npm view`. El adapter se quitó después (ver abajo); revisar si sigue habiendo razón para no subir a 7 cuando se necesite |
| Tailwind CSS | **4.3.3** | Lee variables CSS de `tokens.css`, nunca al revés — V10-DISENO |
| next-auth (Auth.js) | **5.0.0-beta.32**, versión fija, nunca `@beta` flotante | Auth.js v5 sigue en beta en el registro; se fija el número exacto para que nunca se mueva solo — un `@beta` sin número puede cambiar de versión en cualquier `npm install` |
| eslint | **9.39.5**, no 10 | `eslint-config-next@15.5.23` declara peer `eslint: ^7\|\|^8\|\|^9` — un `npm install` real con eslint 10 dio ERESOLVE |
| zod | **4.4.3** | `@hookform/resolvers@5.7.1` declara soporte de Zod 4 |
| react-hook-form | **7.85.0** | validación `onBlur`, nunca `onSubmit` — V10-DISENO §7 |
| date-fns | **4.4.0** | agregada por instrucción explícita: el proyecto entero son fechas (cronograma, semanas, cortes de cobranza, vigencias) y no había biblioteca para manejarlas — la fecha nativa a pelo es "justo donde se cometen errores que nadie nota hasta que la cobranza cae en la semana equivocada" |
| idb | **8.0.3** | cola offline sobre IndexedDB — V10-PANTALLAS-Y-ROLES §5 |
| ulid | **3.0.2** | formato universal de llave primaria del esquema |
| sharp | **0.35.3** | procesamiento de fotos de bitácora |
| @react-pdf/renderer | **4.6.0** | ya se usaba en la V8 y funciona |
| bcryptjs | **3.0.3** | **no estaba en la lista aprobada originalmente** — se agregó al escribir `services/auth/auth.ts`: hacía falta verificar contraseña contra `usuario.hash_password` y no había ninguna biblioteca de hashing en el stack |
| vitest | **4.1.10** | pruebas mínimas — V10-ARQUITECTURA §9 |

**`@auth/prisma-adapter` — agregado y luego quitado, el mismo día.** Se instaló
siguiendo el patrón usual de Auth.js con Prisma, y se quitó al notar que espera el
esquema propio de NextAuth (`User`, `Account`, `Session`, `VerificationToken`), que no
existe en esta base — el esquema usa `usuario`, sin esas otras tres tablas — y que
además es innecesario: con Credentials y sesión JWT no hay cuenta OAuth que enlazar ni
sesión que guardar en base. `npm uninstall @auth/prisma-adapter` corrido el mismo día
que se instaló. Con el adapter fuera, la razón original para fijar Prisma en 6 (arriba)
ya no aplica — queda anotado para revisar cuando haga falta subir a Prisma 7.

---

## 2. Estructura de carpetas

```
src/
  app/                    rutas y pantallas
    (auth)/               login, recuperación
    (app)/                aplicación autenticada
      [empresa]/          todo cuelga de una empresa
  domain/                 el corazón. No sabe de Next ni de Prisma
    catalogo/             insumos, conceptos, tarjetas
    proyecto/             proyecto, cliente, folios
    presupuesto/
    obra/                 bitácora, requisiciones, entregas
    programa/             cronograma, flujo, control
    dinero/               movimientos, abonos, cobranza
    _shared/              tipos, errores, invariantes
  data/                   repositorios. Lo único que habla con Prisma
  services/              orquestación entre dominios
  ui/
    tokens/               colores, tipografía, espacios, radios
    components/           componentes sin lógica de negocio
    patterns/             tabla, formulario, ficha, línea de tiempo
  documents/              plantillas PDF
  lib/                    utilidades puras
prisma/
  schema.prisma
  migrations/             versionadas, nunca editadas a mano
```

**Regla de dependencia:** `app` → `services` → `domain` → `data`.
Nunca al revés. Una pantalla jamás llama a Prisma directo.

Esa regla es la que permite cambiar de base de datos o de framework sin reescribir las
reglas de negocio. Y es la que faltaba en la V8, donde una pantalla hablaba con Sheets.

---

## 3. Multiempresa

Regla invariante 9: **todo dato pertenece a una empresa.**

```
grupo_empresa          el corporativo. No opera
  └── empresa          Dravya · TAAW · (mantenimiento, futura)
        └── proyecto
              └── todo lo demás
```

**Implementación:**

- Toda tabla de negocio lleva `empresa_id` **obligatorio**, con llave foránea
- La sesión carga la empresa activa; el repositorio filtra por ella **siempre**, sin
  que la pantalla tenga que acordarse
- Un usuario puede pertenecer a varias empresas con roles distintos
- Cada empresa tiene su logotipo, datos fiscales, correos, disclaimers y plantillas
  de documento

**Por qué desde el día uno:** meterlo después obliga a tocar todas las tablas, todas las
consultas y todos los documentos. Es el clásico cambio que rompe una aplicación entera.

---

## 4. Roles y permisos

El permiso va **por rol, no por persona**. Y **un usuario puede tener varios roles a la
vez** — es obligatorio, porque tres personas cubren ocho funciones.

| Rol | Alcance |
|---|---|
| **Administrador de la aplicación** | Configura la aplicación y las empresas. Da de alta usuarios y asigna roles. Único que toca integraciones y respaldos |
| Dirección | Lee todo. Aprueba etapas documentales |
| Coordinación de proyectos | Aprueba requisiciones. Edita presupuesto y programa |
| Administración de finanzas | Marca pagos. Edita movimientos y proveedores |
| Residencia | Edita programa y avance. Levanta requisiciones |
| Supervisión | Levanta y valida requisiciones. Registra bitácora |
| **Validador de documentos** | Único que mueve un documento de `S3` a `A5`. No edita nada más |
| Consulta | Sólo lectura. Es un modo de visualización, no un puesto |

**Implementación:** `usuario` ↔ `usuario_rol` ↔ `rol`, con `empresa_id`. Un mismo usuario
puede ser residencia en un proyecto y supervisión en otro. Los roles se definen en tabla,
no en código: agregar uno no debe requerir un despliegue.

**No existe, ni ahora ni después, un rol `CLIENTE`. Decisión de Stefanno, 9-ago-2026, no
un olvido.** El cliente recibe documentos — folio, PDF, correo — y nunca entra a la
aplicación. Se deja escrito aquí para que dentro de un año nadie lo agregue pensando que
faltó: es exactamente lo que ya decía `V10-CONCEPTO-ParaQueEsLaApp-R02` §3 — *"Cliente ·
Recibe documentos. No entra a la app"* — sólo que ahí vivía como dato de una tabla y no
como regla explícita de la capa de roles.

---

## 5. Sistema de diseño

**Va en la rebanada 1 y no después.** En la V9, meter temas cuando la aplicación ya
existía rompió lo que funcionaba, porque los colores estaban escritos dentro de cada
pantalla.

Lo técnico que aplica aquí:

- Todo color, tamaño, espacio, radio y sombra vive en **un solo archivo de tokens**.
  Ninguna pantalla escribe un color literal
- Modo claro y oscuro desde el primer día, mismo juego de tokens con dos valores
- Tamaño de fuente ajustable por el usuario sin que se rompa el diseño
- Se diseñan primero los cuatro patrones que se repiten —**tabla, formulario, ficha y
  línea de tiempo**— y de ahí salen las pantallas

**La dirección visual, la paleta, la tipografía y la filosofía de interfaz viven en su
propio documento: [[V10-DISENO]].** Aquí sólo queda la regla de que el tema es
configuración, no código.

---

## 6. Manejo de errores

**La enfermedad de la V8, con nombre y apellido.** El reporte del propio agente lo dice:
quedan **26 capturas de error silenciosas** en cronograma, pagos, destajos, bitácora y
programa vivo. Un `catch` que no hace nada convierte un fallo en un dato perdido sin aviso.

De ahí salió el bug que borraba filas del Sheet.

**Reglas:**

1. **Prohibido el `catch` silencioso.** Todo error se registra y se propaga o se muestra
2. Los errores de negocio son tipos del dominio, no cadenas de texto
3. Toda escritura de varios registros va en **transacción**. Si algo falla, no se guarda nada
4. La interfaz siempre distingue tres estados: cargando · vacío · error
5. Nada de valores por omisión que oculten un fallo. Si no hay dato, se dice que no hay dato

---

## 7. Plataforma y despliegue

**El mini PC con Dokploy resuelve la condición de costo cero mejor que cualquier servicio
en línea.**

| | |
|---|---|
| Servidor | Mini PC propio, con Dokploy |
| Base de datos | Postgres como servicio de Dokploy, en el mismo servidor |
| Ventaja | No se suspende por inactividad · Respaldo local · Sin límite de filas · Sin costo mensual |
| Si se apaga | No es crítico: hay forma de encenderlo. La app no guarda nada en el dispositivo del usuario, todo vive en la base |
| Acceso | Desde cualquier dispositivo con navegador. Nada se instala |
| Acceso remoto | Túnel o dominio dinámico, como ya se está usando |

**Sobre el respaldo.** El mini PC es el servidor, no el respaldo. Un respaldo que vive en
la misma máquina que la base no es respaldo: si falla el disco, se pierden los dos.

Esquema mínimo, sin costo:

1. **Volcado diario automático** de Postgres a un directorio del propio servidor —
   protege contra el error humano, que es el caso más frecuente
2. **Copia semanal fuera de la máquina** — disco externo, otra computadora de la oficina,
   o el almacenamiento personal que ya se paga. Protege contra falla de hardware
3. **El repositorio de código no es respaldo de datos.** Son cosas distintas

### Todo lo propuesto es gratuito

| Pieza | Licencia |
|---|---|
| Next.js · React · TypeScript | Código abierto, sin costo |
| PostgreSQL | Código abierto, sin costo |
| Prisma | Código abierto, sin costo |
| Auth.js | Código abierto, sin costo |
| @react-pdf/renderer | Código abierto, sin costo |
| Dokploy | Código abierto, en servidor propio, sin costo |

**Cero mensualidades.** El único costo es la luz del mini PC.

Detalle y plan de migración de los 877 conceptos en [[V10-PLATAFORMA-Y-MIGRACION]].

---

## 8. Migraciones

- El esquema **se congela** al cerrar [[V10-ESQUEMA-SQL]]
- Todo cambio posterior es una **migración nueva**, nunca una edición del esquema anterior
- Las migraciones se versionan en el repositorio y corren solas en el despliegue
- **Nunca** se edita la base a mano en producción

---

## 9. Pruebas mínimas

No se busca cobertura total. Se cubre lo que si falla en silencio cuesta dinero:

1. Cálculo de la tarjeta de precio unitario y su cascada
2. Sumas del presupuesto por módulo y partida
3. Máquina de estados de la requisición: transiciones válidas e inválidas
4. Abonos contra compromiso: que nunca rebasen el saldo
5. Aislamiento entre empresas: que una nunca vea datos de otra

---

## 10. Lo que se rescata de la V8

| Se rescata | Se descarta |
|---|---|
| Las 60 pantallas como referencia de qué hace falta | Todo el acceso a datos vía Sheets |
| Las plantillas PDF con `@react-pdf/renderer` | Las 26 capturas silenciosas de error |
| La fórmula canónica de precio unitario | Los 40 formatos de identificador |
| El diagnóstico de la base — dice qué **no** repetir | El módulo eléctrico: pasa a satélite y se rehace |

---

## 11. Qué falta confirmar

| # | Pendiente | De quién |
|---|---|---|
| 1 | Paleta y tipografía definitivas, tomadas del hub informativo | Stefanno |
| 2 | Empresas del grupo y cuál es la principal | Stefanno |
| 3 | Nombre de la aplicación y del repositorio nuevo | Stefanno |
| 4 | Ruta de respaldo automático de la base | Stefanno |

---

*Documento 2 de 8. El siguiente es [[V10-MODELO-DOMINIO]].*
