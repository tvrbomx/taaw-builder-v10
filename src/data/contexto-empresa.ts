/**
 * Fija app.empresa_id en la transacción — la segunda barrera de aislamiento
 * de V10-ESQUEMA-SQL §15. El repositorio la usa siempre; la pantalla nunca
 * se entera de que existe.
 *
 * Si un repositorio olvida llamar esto, la política de fila de Postgres
 * no deja pasar ninguna fila — falla ruidoso (cero resultados), no
 * silencioso (datos de otra empresa mezclados).
 */
import { prisma } from "./prisma";
import type { Prisma, PrismaClient } from "@prisma/client";

type ClienteTransaccion = Omit<
  PrismaClient,
  "$connect" | "$disconnect" | "$on" | "$transaction" | "$use" | "$extends"
>;

export async function conEmpresa<T>(
  empresaId: string,
  operacion: (tx: ClienteTransaccion) => Promise<T>
): Promise<T> {
  return prisma.$transaction(async (tx) => {
    await tx.$executeRaw`select set_config('app.empresa_id', ${empresaId}, true)`;
    return operacion(tx);
  }) as Promise<T>;
}

export type { Prisma };
