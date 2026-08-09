/**
 * Autenticación y sesión — V10-ARQUITECTURA §1 y §4. Credenciales y roles
 * en base, sin depender de terceros. next-auth@5.0.0-beta.32, fijo — nunca
 * @beta: V10-HANDOFF §5, decisión 2 de esta rebanada.
 *
 * SIN @auth/prisma-adapter, a propósito — hallazgo de esta rebanada, no
 * del stack original. El adapter espera el esquema propio de NextAuth
 * (`User`, `Account`, `Session`, `VerificationToken`), que no existe aquí
 * y que además sólo hace falta para OAuth o sesiones en base. Con
 * Credentials + JWT ninguna de las dos aplica: `authorize()` consulta
 * `usuario` directo, y la sesión vive en el token, no en una tabla.
 */
import NextAuth from "next-auth";
import Credentials from "next-auth/providers/credentials";
import bcrypt from "bcryptjs";
import { prisma } from "@/data/prisma";
import { conUsuario } from "@/data/contexto-usuario";
import type { RolAsignado } from "@/domain/_shared/permisos";

export const { handlers, signIn, signOut, auth } = NextAuth({
  session: { strategy: "jwt" },
  pages: { signIn: "/login" },
  providers: [
    Credentials({
      credentials: {
        correo: { label: "Correo", type: "email" },
        contrasena: { label: "Contraseña", type: "password" },
      },
      async authorize(credenciales) {
        const correo = credenciales?.correo as string | undefined;
        const contrasena = credenciales?.contrasena as string | undefined;
        if (!correo || !contrasena) return null;

        const usuario = await prisma.usuario.findUnique({ where: { correo } });
        if (!usuario || !usuario.activo) return null;

        const valida = await bcrypt.compare(contrasena, usuario.hash_password);
        if (!valida) return null;

        return { id: usuario.id, email: usuario.correo, name: usuario.nombre };
      },
    }),
  ],
  callbacks: {
    async jwt({ token, user }) {
      if (user?.id) {
        token.usuarioId = user.id;
        token.roles = await cargarRoles(user.id);
      }
      return token;
    },
    async session({ session, token }) {
      session.usuarioId = token.usuarioId as string;
      session.roles = token.roles as RolAsignado[];
      return session;
    },
  },
});

async function cargarRoles(usuarioId: string): Promise<RolAsignado[]> {
  // conUsuario, no conEmpresa: todavía no hay empresa activa que fijar —
  // ver V10-ESQUEMA-SQL §19.2, Corrección 4.
  return conUsuario(usuarioId, async (tx) => {
    const asignados = await tx.usuario_rol.findMany({
      where: { usuario_id: usuarioId, activo: true },
      include: { rol: true },
    });
    return asignados.map((a) => ({
      rolClave: a.rol.clave,
      empresaId: a.empresa_id,
      proyectoId: a.proyecto_id,
    }));
  });
}
