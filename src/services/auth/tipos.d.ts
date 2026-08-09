import type { RolAsignado } from "@/domain/_shared/permisos";

declare module "next-auth" {
  interface Session {
    usuarioId: string;
    roles: RolAsignado[];
  }
}

declare module "next-auth/jwt" {
  interface JWT {
    usuarioId: string;
    roles: RolAsignado[];
  }
}
