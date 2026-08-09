/**
 * Cliente Prisma, único por proceso — patrón estándar para Next.js en
 * desarrollo (evita agotar conexiones con el hot-reload).
 *
 * schema.prisma se genera con `npm run db:pull` — nunca se edita a mano.
 * Ver README.md, "Cómo se cambia el esquema".
 */
import { PrismaClient } from "@prisma/client";

const globalParaPrisma = globalThis as unknown as { prisma?: PrismaClient };

export const prisma = globalParaPrisma.prisma ?? new PrismaClient();

if (process.env.NODE_ENV !== "production") {
  globalParaPrisma.prisma = prisma;
}
