import { redirect } from "next/navigation";
import Link from "next/link";
import { obtenerListaProyectos } from "@/services/proyectos/obtener-lista-proyectos";
import { ERRORES } from "@/domain/_shared/errores";
import { ThemeToggle } from "@/ui/patterns/ThemeToggle";
import { FondoModulo, FondoToggle } from "@/ui/patterns/FondoModulo";
import { TablaProyectos } from "./tabla-proyectos";

export default async function PaginaProyectos({
  params,
}: {
  params: Promise<{ empresa: string }>;
}) {
  const { empresa: claveEmpresa } = await params;
  const resultado = await obtenerListaProyectos(claveEmpresa);

  if (!resultado.ok && resultado.error.tipo === ERRORES.SIN_SESION) {
    redirect("/login");
  }

  return (
    <>
      <FondoModulo modulo="proyectos" />
      <div className="flex flex-col flex-1 gap-8 p-8 max-w-3xl mx-auto w-full">
        <header className="flex items-center justify-between gap-4">
          <div className="flex flex-col gap-1">
            <Link href="/" className="etiqueta hover:text-texto w-fit">
              ← Mis empresas
            </Link>
            <h1 className="titulo-pantalla text-texto">
              {resultado.ok ? resultado.datos.empresa.nombreComercial : "Proyectos"}
            </h1>
          </div>
          <div className="flex items-center gap-2">
            <FondoToggle />
            <ThemeToggle />
          </div>
        </header>

        {!resultado.ok ? (
          <TablaProyectos proyectos={[]} estado="error" mensajeError={resultado.error.mensaje} />
        ) : (
          <TablaProyectos
            proyectos={resultado.datos.proyectos}
            estado={resultado.datos.proyectos.length === 0 ? "vacio" : "listo"}
            mensajeVacio="Esta empresa todavía no tiene proyectos activos."
          />
        )}
      </div>
    </>
  );
}
