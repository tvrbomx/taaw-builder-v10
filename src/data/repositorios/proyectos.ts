/**
 * Repositorio de proyectos — la única capa que habla con Prisma para esta
 * entidad. Filtra por empresa siempre; ninguna pantalla se entera de cómo.
 * V10-ARQUITECTURA §2: app → services → domain → data, nunca al revés.
 */
import { conEmpresa } from "@/data/contexto-empresa";

export type ProyectoResumen = {
  id: string;
  clave: string;
  nombre: string;
  etapaBim: string;
};

export async function listarProyectos(empresaId: string): Promise<ProyectoResumen[]> {
  return conEmpresa(empresaId, async (tx) => {
    const filas = await tx.proyecto.findMany({
      where: { activo: true },
      orderBy: { creado_en: "desc" },
      select: { id: true, clave: true, nombre: true, etapa_bim: true },
    });
    return filas.map((f) => ({
      id: f.id,
      clave: f.clave,
      nombre: f.nombre,
      etapaBim: f.etapa_bim,
    }));
  });
}
