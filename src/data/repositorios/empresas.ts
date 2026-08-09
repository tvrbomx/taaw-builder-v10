/**
 * Repositorio de empresas — la tabla raíz del multiempresa. No lleva
 * empresa_id ni RLS: es la que define qué es "una empresa", no un dato
 * dentro de una. Se consulta directo, sin conEmpresa.
 */
import { prisma } from "@/data/prisma";

export type EmpresaResumen = {
  id: string;
  clave: string;
  nombreComercial: string;
};

export async function buscarEmpresaPorClave(clave: string): Promise<EmpresaResumen | null> {
  const fila = await prisma.empresa.findFirst({
    where: { clave, activo: true },
    select: { id: true, clave: true, nombre_comercial: true },
  });
  return fila ? { id: fila.id, clave: fila.clave, nombreComercial: fila.nombre_comercial } : null;
}

export async function listarEmpresasPorIds(ids: string[]): Promise<EmpresaResumen[]> {
  if (ids.length === 0) return [];
  const filas = await prisma.empresa.findMany({
    where: { id: { in: ids }, activo: true },
    select: { id: true, clave: true, nombre_comercial: true },
    orderBy: { nombre_comercial: "asc" },
  });
  return filas.map((f) => ({ id: f.id, clave: f.clave, nombreComercial: f.nombre_comercial }));
}
