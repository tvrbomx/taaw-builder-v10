#!/usr/bin/env node
/**
 * Datos de PRUEBA para verificar el login y el aislamiento por empresa —
 * NO son datos reales de Dravya ni de F-19. Tres empresas ficticias, un
 * usuario, y proyectos suficientes para comprobar que ninguna empresa ve
 * los datos de otra.
 *
 * Correr con DATABASE_URL del rol ADMINISTRADOR (dueño de las tablas),
 * nunca con el de la aplicación: RLS bloquearía la escritura cruzada
 * entre empresas — ver README "Dos roles de base de datos".
 */
import { PrismaClient } from "@prisma/client";
import { ulid } from "ulid";
import bcrypt from "bcryptjs";

const prisma = new PrismaClient();

const CORREO = "prueba@taaw.local";
const CONTRASENA = "Prueba1234!";

async function main() {
  const yaExiste = await prisma.usuario.findUnique({ where: { correo: CORREO } });
  if (yaExiste) {
    console.log(`Ya existe ${CORREO} — no se vuelve a sembrar. Bórralo a mano si quieres repetir.`);
    return;
  }

  const idUsuario = ulid();
  const idGrupo = ulid();
  const idEmpresa1 = ulid();
  const idEmpresa2 = ulid();
  const idEmpresa3 = ulid();
  const idCliente1 = ulid();
  const idCliente2 = ulid();

  const hash = await bcrypt.hash(CONTRASENA, 10);

  await prisma.$transaction(async (tx) => {
    await tx.usuario.create({
      data: { id: idUsuario, correo: CORREO, nombre: "Usuario de Prueba", hash_password: hash },
    });

    await tx.grupo_empresa.create({ data: { id: idGrupo, nombre: "Grupo de Prueba" } });

    await tx.empresa.create({
      data: { id: idEmpresa1, grupo_empresa_id: idGrupo, clave: "PRUEBA1", nombre_comercial: "Empresa de Prueba Uno" },
    });
    await tx.empresa.create({
      data: { id: idEmpresa2, grupo_empresa_id: idGrupo, clave: "PRUEBA2", nombre_comercial: "Empresa de Prueba Dos" },
    });
    await tx.empresa.create({
      data: { id: idEmpresa3, grupo_empresa_id: idGrupo, clave: "PRUEBA3", nombre_comercial: "Empresa de Prueba Tres (vacía)" },
    });

    await tx.cliente.create({
      data: { id: idCliente1, empresa_id: idEmpresa1, creado_por: idUsuario, actualizado_por: idUsuario, clave: "CLI1", nombre: "Cliente de Prueba Uno" },
    });
    await tx.cliente.create({
      data: { id: idCliente2, empresa_id: idEmpresa2, creado_por: idUsuario, actualizado_por: idUsuario, clave: "CLI2", nombre: "Cliente de Prueba Dos" },
    });

    const rolAdmin = await tx.rol.upsert({
      where: { clave: "administrador_aplicacion" },
      update: {},
      create: { id: ulid(), clave: "administrador_aplicacion", nombre: "Administrador de la aplicación" },
    });
    const rolDireccion = await tx.rol.upsert({
      where: { clave: "direccion" },
      update: {},
      create: { id: ulid(), clave: "direccion", nombre: "Dirección" },
    });
    const rolConsulta = await tx.rol.upsert({
      where: { clave: "consulta" },
      update: {},
      create: { id: ulid(), clave: "consulta", nombre: "Consulta" },
    });

    await tx.usuario_rol.create({
      data: { id: ulid(), empresa_id: idEmpresa1, usuario_id: idUsuario, rol_id: rolAdmin.id, proyecto_id: null },
    });
    await tx.usuario_rol.create({
      data: { id: ulid(), empresa_id: idEmpresa2, usuario_id: idUsuario, rol_id: rolDireccion.id, proyecto_id: null },
    });
    await tx.usuario_rol.create({
      data: { id: ulid(), empresa_id: idEmpresa3, usuario_id: idUsuario, rol_id: rolConsulta.id, proyecto_id: null },
    });

    await tx.proyecto.create({
      data: { id: ulid(), empresa_id: idEmpresa1, creado_por: idUsuario, actualizado_por: idUsuario, clave: "ALB1", nombre: "Casa Alba (prueba)", cliente_id: idCliente1, etapa_bim: "AP" },
    });
    await tx.proyecto.create({
      data: { id: ulid(), empresa_id: idEmpresa1, creado_por: idUsuario, actualizado_por: idUsuario, clave: "ALB2", nombre: "Bodega Alba (prueba)", cliente_id: idCliente1, etapa_bim: "PE" },
    });
    await tx.proyecto.create({
      data: { id: ulid(), empresa_id: idEmpresa2, creado_por: idUsuario, actualizado_por: idUsuario, clave: "TOR1", nombre: "Torre Norte (prueba)", cliente_id: idCliente2, etapa_bim: "OB" },
    });
  });

  console.log("Sembrado listo.");
  console.log(`Correo: ${CORREO}  Contraseña: ${CONTRASENA}`);
  console.log("Empresa 1: /PRUEBA1 — 2 proyectos (ALB1, ALB2)");
  console.log("Empresa 2: /PRUEBA2 — 1 proyecto (TOR1)");
  console.log("Empresa 3: /PRUEBA3 — 0 proyectos, para probar el estado vacío");
}

main()
  .catch((e) => {
    console.error(e);
    process.exitCode = 1;
  })
  .finally(() => prisma.$disconnect());
