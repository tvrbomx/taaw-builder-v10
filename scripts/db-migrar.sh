#!/usr/bin/env bash
# Aplica las migraciones SQL, en orden, a la base indicada por DATABASE_URL.
# No genera SQL desde schema.prisma. No usa `prisma migrate` — ver README §"El SQL es la fuente".
set -euo pipefail

if [ -z "${DATABASE_URL:-}" ]; then
  echo "DATABASE_URL no está definida. Cárgala desde .env antes de correr esto." >&2
  exit 1
fi

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/prisma/migrations"

for migracion in "$DIR"/*/migration.sql; do
  echo "Aplicando: $migracion"
  psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f "$migracion"
done

echo "Listo. Ahora corre: npm run db:pull && npm run db:generar"
