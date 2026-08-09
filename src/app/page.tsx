import { redirect } from "next/navigation";
import Link from "next/link";
import { auth } from "@/services/auth/auth";
import { listarEmpresasPorIds } from "@/data/repositorios/empresas";

export default async function Home() {
  const sesion = await auth();
  if (!sesion) redirect("/login");

  const empresaIds = [...new Set(sesion.roles.map((r) => r.empresaId))];
  const empresas = await listarEmpresasPorIds(empresaIds);

  return (
    <div className="flex flex-col flex-1 items-center justify-center gap-8 p-8">
      <h1 className="titulo-pantalla text-texto">TAAW Builder</h1>

      {empresas.length === 0 ? (
        <p className="texto-secundario">No tienes ninguna empresa asignada.</p>
      ) : (
        <ul className="flex flex-col gap-3 w-full max-w-sm">
          {empresas.map((e) => (
            <li key={e.id}>
              <Link
                href={`/${e.clave}`}
                className="superficie-vidrio block px-4 py-3 text-texto hover:bg-vidrio-elevado transition-colors"
              >
                {e.nombreComercial}
              </Link>
            </li>
          ))}
        </ul>
      )}
    </div>
  );
}
