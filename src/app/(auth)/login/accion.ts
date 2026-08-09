"use server";

/**
 * Server Action de inicio de sesión — V10-API §2. redirect:false para
 * poder devolver ResultadoOperacion en vez de dejar que next-auth
 * redirija por su cuenta; el cliente navega tras recibir ok:true.
 */
import { AuthError } from "next-auth";
import { signIn } from "@/services/auth/auth";
import { ok, error, ERRORES } from "@/domain/_shared/errores";
import type { ResultadoOperacion } from "@/domain/_shared/errores";

export async function iniciarSesion(datos: {
  correo: string;
  contrasena: string;
}): Promise<ResultadoOperacion<null>> {
  try {
    await signIn("credentials", {
      correo: datos.correo,
      contrasena: datos.contrasena,
      redirect: false,
    });
    return ok(null);
  } catch (e) {
    if (e instanceof AuthError) {
      return error(ERRORES.SIN_PERMISO, "Correo o contraseña incorrectos.");
    }
    throw e; // nunca catch silencioso — CLAUDE.md
  }
}
