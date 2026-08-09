/**
 * Servicio de la pantalla de ejemplo — V10-ARQUITECTURA §2: app llama
 * services, services llama domain y data. La pantalla nunca ve Prisma
 * ni sabe cómo se resuelve el permiso.
 */
import { auth } from "@/services/auth/auth";
import { buscarEmpresaPorClave } from "@/data/repositorios/empresas";
import { listarProyectos, type ProyectoResumen } from "@/data/repositorios/proyectos";
import { puedeEnEmpresa } from "@/domain/_shared/permisos";
import { ok, error, ERRORES } from "@/domain/_shared/errores";
import type { ResultadoOperacion } from "@/domain/_shared/errores";

export type ListaProyectos = {
  empresa: { id: string; nombreComercial: string };
  proyectos: ProyectoResumen[];
};

export async function obtenerListaProyectos(
  claveEmpresa: string
): Promise<ResultadoOperacion<ListaProyectos>> {
  const sesion = await auth();
  if (!sesion) {
    return error(ERRORES.SIN_SESION, "No hay sesión activa.");
  }

  const empresa = await buscarEmpresaPorClave(claveEmpresa);
  if (!empresa) {
    return error(ERRORES.EMPRESA_ACTIVA_NO_RESUELTA, "La empresa no existe o está inactiva.");
  }

  if (!puedeEnEmpresa(sesion.roles, "ver", empresa.id)) {
    return error(ERRORES.SIN_PERMISO, "No tienes permiso para ver los proyectos de esta empresa.");
  }

  const proyectos = await listarProyectos(empresa.id);
  return ok({ empresa: { id: empresa.id, nombreComercial: empresa.nombreComercial }, proyectos });
}
