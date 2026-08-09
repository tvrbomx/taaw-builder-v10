import { describe, expect, it } from "vitest";
import { puede, puedeEnEmpresa, type RolAsignado } from "./permisos";

const EMPRESA_A = "empresa-a";
const EMPRESA_B = "empresa-b";
const PROYECTO_1 = "proyecto-1";

describe("puede", () => {
  it("permite cuando el rol aplica a toda la empresa (proyectoId nulo)", () => {
    const roles: RolAsignado[] = [
      { rolClave: "direccion", empresaId: EMPRESA_A, proyectoId: null },
    ];
    expect(puede(roles, "ver", EMPRESA_A, PROYECTO_1)).toBe(true);
  });

  it("no permite un rol de otra empresa, aunque el proyectoId coincida", () => {
    const roles: RolAsignado[] = [
      { rolClave: "administrador_aplicacion", empresaId: EMPRESA_B, proyectoId: null },
    ];
    expect(puede(roles, "ver", EMPRESA_A, PROYECTO_1)).toBe(false);
  });

  it("no permite una acción que el rol no tiene, aunque empresa y proyecto coincidan", () => {
    const roles: RolAsignado[] = [
      { rolClave: "consulta", empresaId: EMPRESA_A, proyectoId: PROYECTO_1 },
    ];
    expect(puede(roles, "editar", EMPRESA_A, PROYECTO_1)).toBe(false);
  });

  it("es la unión de varios roles, no el máximo de uno solo", () => {
    const roles: RolAsignado[] = [
      { rolClave: "consulta", empresaId: EMPRESA_A, proyectoId: PROYECTO_1 },
      { rolClave: "coordinacion_proyectos", empresaId: EMPRESA_A, proyectoId: PROYECTO_1 },
    ];
    expect(puede(roles, "editar", EMPRESA_A, PROYECTO_1)).toBe(true);
  });
});

describe("puedeEnEmpresa", () => {
  it("ignora el proyectoId — sirve para pantallas fuera de un proyecto", () => {
    const roles: RolAsignado[] = [
      { rolClave: "consulta", empresaId: EMPRESA_A, proyectoId: PROYECTO_1 },
    ];
    expect(puedeEnEmpresa(roles, "ver", EMPRESA_A)).toBe(true);
  });

  it("no permite nada si el usuario no tiene ningún rol en esa empresa", () => {
    const roles: RolAsignado[] = [
      { rolClave: "administrador_aplicacion", empresaId: EMPRESA_B, proyectoId: null },
    ];
    expect(puedeEnEmpresa(roles, "ver", EMPRESA_A)).toBe(false);
  });
});
