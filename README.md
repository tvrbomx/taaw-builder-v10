# TAAW Builder v10

Plataforma de control de proyecto para Dravya, despacho de arquitectura que además
construye. Desarrollada por TAAW · ThArqum Architecture Workshop.

**Etapa 4 de 4 · Ejecución.** El anteproyecto y el proyecto ejecutivo (etapas 2 y 3)
cerraron el 9-ago-2026. Este repositorio contiene el primer código real: la rebanada 1,
arquitectura y sistema de diseño.

Empieza por `CLAUDE.md` — ahí están las reglas del proyecto y qué leer antes de tocar
nada.

---

## El SQL es la fuente. Prisma la consume.

**Regla que no se rompe, en ningún sentido contrario:**

1. La migración SQL se escribe a mano, tal cual está en `docs/V10-ESQUEMA-SQL.md`
   (el esquema congelado — nadie edita ese documento sin registrar la revisión).
2. Se aplica a la base con `npm run db:migrar` (`scripts/db-migrar.sh`, que corre
   cada archivo en `prisma/migrations/*/migration.sql` en orden, con `psql`).
3. Se genera `prisma/schema.prisma` con `npm run db:pull` (`prisma db pull`), nunca
   al revés.

**Nunca se edita `schema.prisma` a mano y nunca se genera SQL desde él.** Prisma no
puede expresar todas las restricciones del esquema (`CHECK`, triggers, RLS) —
si el flujo se invierte, esas restricciones se pierden en silencio y la base termina
aceptando datos que el diseño prohíbe. `schema.prisma` es un reflejo de la base, no al
revés.

Para agregar una migración nueva: se escribe el archivo `prisma/migrations/000N_nombre/
migration.sql`, se documenta en `V10-ESQUEMA-SQL.md` §19 con su razón, se aplica, y
sólo entonces se regenera `schema.prisma`.

---

## Dos roles de base de datos, nunca uno

**Hallazgo de la rebanada 1, verificado contra Postgres real:** el rol que aplica las
migraciones (dueño de las tablas) **no puede ser el mismo que usa la aplicación en
tiempo de ejecución.** El dueño de una tabla se salta el aislamiento por fila (RLS) de
`V10-ESQUEMA-SQL.md` §15 sin importar qué política exista — así que si la aplicación se
conecta como dueño, el filtro por empresa deja de existir en la base y depende
únicamente de que ningún repositorio se equivoque, exactamente lo que RLS existe para
no tener que confiar.

- **Rol administrador** (dueño de las tablas): aplica `db:migrar`, `db:pull`. No lo usa
  la aplicación.
- **Rol de aplicación** (`app_user` en desarrollo local): el que va en `DATABASE_URL`
  de `.env`. Sin `SUPERUSER`, sin ser dueño de ninguna tabla, con permisos de datos
  (`SELECT`/`INSERT`/`UPDATE`/`DELETE`) sobre el esquema — así RLS lo gobierna de
  verdad. Verificado en vivo: con este rol, una consulta sin `app.empresa_id` fijado
  devuelve cero filas, nunca datos de otra empresa.

En producción, el mini PC necesita los dos roles creados una sola vez; `db-migrar.sh`
se corre con las credenciales del administrador, nunca con las de la aplicación.

---

## Puertos

| Puerto | Para qué | Por qué éste |
|---|---|---|
| **4010** | servidor de desarrollo de Next (`npm run dev` / `npm run start`) | el 3000 lo usa Dokploy en el mini PC donde va a vivir esta app, y el 9002 lo usa la V8 en desarrollo — los dos quedan prohibidos para no chocar |
| **54329** | Postgres local de desarrollo | ya estaba en uso desde la verificación de la rebanada 1, se queda |
| **4011** | reservado, por si hace falta un segundo servicio local | ninguno todavía |

**Esto es sólo para desarrollo local.** Dentro del contenedor Docker de producción el
puerto interno de Next puede seguir siendo el que trae por omisión — no choca con nada
porque nadie más corre dentro de ese mismo contenedor. El choque sólo existe en una
máquina de desarrollo con varios proyectos corriendo a la vez, que es exactamente este
caso.

---

## Arranque local, desde cero

Asume que no instalaste nada de esto antes.

```bash
# 1. Dependencias
npm install

# 2. Variables de entorno — DATABASE_URL aquí es la de la APLICACIÓN
#    (rol restringido, sujeto a RLS), no la del administrador.
cp .env.example .env
# Edita .env: DATABASE_URL y AUTH_SECRET (openssl rand -base64 32)

# 3. Postgres — cualquier Postgres 16+ sirve. Si no tienes uno a mano
#    localmente, la forma más simple sin Docker ni sudo es un Postgres
#    embebido (el que se usó para verificar esta rebanada):
#      npm install --no-save embedded-postgres
#      node -e "const {default:EmbeddedPostgres}=await import('embedded-postgres'); ..."
#    o cualquier Postgres 16+ que ya tengas corriendo en el puerto 54329.

# 4. Migraciones — CON EL ROL ADMINISTRADOR, no el de la app (ver
#    "Dos roles de base de datos" arriba). Ejemplo con un superusuario
#    local de nombre "taaw":
DATABASE_URL="postgresql://taaw:taaw@127.0.0.1:54329/postgres?schema=public" npm run db:migrar
DATABASE_URL="postgresql://taaw:taaw@127.0.0.1:54329/postgres?schema=public" npm run db:pull
npm run db:generar

# 5. Crear el rol restringido de la aplicación (una sola vez por base) —
#    con el rol administrador:
psql "postgresql://taaw:taaw@127.0.0.1:54329/postgres" -c "
  create role app_user with login password 'app_user';
  grant usage on schema public to app_user;
  grant select, insert, update, delete on all tables in schema public to app_user;
  grant usage, select on all sequences in schema public to app_user;
  alter default privileges in schema public grant select, insert, update, delete on tables to app_user;
"
# Ese es el rol que va en el DATABASE_URL de .env (paso 2).

# 6. Datos de prueba — tres empresas ficticias, un usuario, unos
#    proyectos. NO son datos de Dravya ni de F-19. Con el rol
#    administrador (RLS bloquearía la escritura cruzada entre empresas):
DATABASE_URL="postgresql://taaw:taaw@127.0.0.1:54329/postgres?schema=public" npm run db:sembrar

# 7. Arrancar
npm run dev
# → http://localhost:4010/login
```

**Para entrar:** correo `prueba@taaw.local`, contraseña `Prueba1234!` — los imprime
también `npm run db:sembrar` al terminar. Ese usuario tiene rol en tres empresas de
prueba (`PRUEBA1` con 2 proyectos, `PRUEBA2` con 1, `PRUEBA3` sin ninguno, para ver el
estado vacío) — entra por `/`, que las lista.

## Scripts

| Comando | Qué hace |
|---|---|
| `npm run dev` | servidor de desarrollo, puerto 4010 |
| `npm run build` | build de producción |
| `npm run start` | servidor de producción, puerto 4010 |
| `npm run lint` | ESLint |
| `npm run test` | Vitest |
| `npm run db:migrar` | aplica `prisma/migrations/*/migration.sql` en orden — rol administrador |
| `npm run db:pull` | regenera `schema.prisma` desde la base real — rol administrador |
| `npm run db:generar` | regenera el cliente de Prisma |
| `npm run db:sembrar` | siembra datos de PRUEBA para verificar login y aislamiento — rol administrador |

## Estructura

```
src/
  app/          rutas de Next — nunca llama a Prisma directo
  services/     casos de uso — autoriza, orquesta, valida
  domain/       tipos y reglas de negocio, sin dependencias externas
  data/         Prisma, repositorios, aislamiento por empresa (RLS)
  ui/
    tokens/     variables CSS del sistema de diseño — ningún color literal fuera de aquí
    patterns/   Tabla y Formulario completos; Ficha y LineaDeTiempo, bosquejo
docs/           el anteproyecto y el proyecto ejecutivo — la fuente de verdad
prisma/
  migrations/   SQL de mano, versionado
  schema.prisma generado, no editado
```

Regla de dependencia (`CLAUDE.md`): `app → services → domain → data`, nunca al revés.
