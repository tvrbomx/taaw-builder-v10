/**
 * Fija app.usuario_id en la transacción — habilita la política
 * p_usuario_rol_autoconsulta — V10-ESQUEMA-SQL §19.2, Corrección 4.
 * Sólo para leer los roles del propio usuario, ANTES de saber en qué
 * empresa va a pararse: ahí todavía no hay app.empresa_id que fijar.
 * Ninguna escritura queda cubierta por esta política — sigue exigiendo
 * app.empresa_id, como conEmpresa().
 */
import { prisma } from "./prisma";
import type { PrismaClient } from "@prisma/client";

type ClienteTransaccion = Omit<
  PrismaClient,
  "$connect" | "$disconnect" | "$on" | "$transaction" | "$use" | "$extends"
>;

export async function conUsuario<T>(
  usuarioId: string,
  operacion: (tx: ClienteTransaccion) => Promise<T>
): Promise<T> {
  return prisma.$transaction(async (tx) => {
    await tx.$executeRaw`select set_config('app.usuario_id', ${usuarioId}, true)`;
    return operacion(tx);
  }) as Promise<T>;
}
