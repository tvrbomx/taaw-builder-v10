/**
 * Permiso por pantalla y por acción — V10-PANTALLAS-Y-ROLES §8.
 * Un usuario con varios roles tiene la UNIÓN de lo que cada rol permite
 * en el proyecto donde ese rol aplica — nunca un máximo global.
 */

export type Accion = "ver" | "editar" | "aprobar";

export type RolAsignado = {
  rolClave: string;
  empresaId: string; // usuario_rol.empresa_id nunca es nulo — todo rol vive en una empresa
  proyectoId: string | null; // null = aplica a toda la empresa
};

// Alcance mínimo de la pantalla de ejemplo — V10-ARQUITECTURA §4.
// Se amplía por pantalla en cada rebanada, nunca se centraliza en un
// switch gigante: cada pantalla declara lo suyo.
const PERMISOS_PROYECTOS: Record<string, Accion[]> = {
  administrador_aplicacion: ["ver", "editar", "aprobar"],
  direccion: ["ver", "aprobar"],
  coordinacion_proyectos: ["ver", "editar"],
  consulta: ["ver"],
};

export function puede(
  roles: RolAsignado[],
  accion: Accion,
  empresaId: string,
  proyectoId: string
): boolean {
  return roles.some((r) => {
    if (r.empresaId !== empresaId) return false;
    if (r.proyectoId !== null && r.proyectoId !== proyectoId) return false;
    const permitidas = PERMISOS_PROYECTOS[r.rolClave] ?? [];
    return permitidas.includes(accion);
  });
}

// Acceso a nivel empresa, sin un proyecto concreto — pantallas como la
// lista de proyectos, que no viven dentro de un proyecto todavía.
export function puedeEnEmpresa(
  roles: RolAsignado[],
  accion: Accion,
  empresaId: string
): boolean {
  return roles.some((r) => {
    if (r.empresaId !== empresaId) return false;
    const permitidas = PERMISOS_PROYECTOS[r.rolClave] ?? [];
    return permitidas.includes(accion);
  });
}
