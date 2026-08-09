"use client";

/**
 * Patrón Tabla — V10-DISENO §7. Completo, per rebanada 1.
 * "Densa pero legible, con columnas fijas, orden, filtro, y una fila que
 *  puede expandirse sin abrir otra pantalla."
 */

import { Fragment, useMemo, useState, type ReactNode } from "react";

export type ColumnaTabla<T> = {
  clave: string;
  encabezado: string;
  render: (fila: T) => ReactNode;
  ordenable?: boolean;
  valorOrden?: (fila: T) => string | number | Date;
  alineacion?: "izquierda" | "derecha";
};

export type TablaProps<T> = {
  columnas: ColumnaTabla<T>[];
  filas: T[];
  idDeFila: (fila: T) => string;
  filtro?: (fila: T, texto: string) => boolean;
  contenidoExpandido?: (fila: T) => ReactNode;
  estado: "cargando" | "vacio" | "listo" | "error";
  tituloVacio?: string;
  mensajeVacio?: string;
  mensajeError?: string;
};

function EstadoDecorado({
  tono,
  icono,
  titulo,
  mensaje,
  rol,
}: {
  tono: "tenue" | "negativo";
  icono: ReactNode;
  titulo: string;
  mensaje: string;
  rol: "status" | "alert";
}) {
  return (
    <div
      role={rol}
      className={
        "superficie-vidrio flex flex-col items-center gap-3 px-8 py-12 text-center " +
        (tono === "negativo" ? "text-negativo" : "text-texto-tenue")
      }
    >
      {icono}
      <p className="titulo-seccion text-texto">{titulo}</p>
      <p className="texto-secundario max-w-sm">{mensaje}</p>
    </div>
  );
}

const ICONO_CARGANDO = (
  <svg
    className="h-8 w-8 animate-spin text-acento"
    viewBox="0 0 24 24"
    fill="none"
    aria-hidden
  >
    <circle cx="12" cy="12" r="9" stroke="currentColor" strokeOpacity="0.25" strokeWidth="2.5" />
    <path d="M21 12a9 9 0 0 0-9-9" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" />
  </svg>
);

const ICONO_VACIO = (
  <svg className="h-8 w-8 text-texto-tenue" viewBox="0 0 24 24" fill="none" aria-hidden>
    <rect x="3.5" y="6" width="17" height="14" rx="2" stroke="currentColor" strokeWidth="1.6" />
    <path d="M3.5 10.5h17" stroke="currentColor" strokeWidth="1.6" />
    <path d="M8 15.5h4" stroke="currentColor" strokeWidth="1.6" strokeLinecap="round" />
  </svg>
);

const ICONO_ERROR = (
  <svg className="h-8 w-8 text-negativo" viewBox="0 0 24 24" fill="none" aria-hidden>
    <path
      d="M12 3.5 21 19H3L12 3.5Z"
      stroke="currentColor"
      strokeWidth="1.6"
      strokeLinejoin="round"
    />
    <path d="M12 10v4" stroke="currentColor" strokeWidth="1.6" strokeLinecap="round" />
    <circle cx="12" cy="16.7" r="0.9" fill="currentColor" />
  </svg>
);

export function Tabla<T>({
  columnas,
  filas,
  idDeFila,
  filtro,
  contenidoExpandido,
  estado,
  tituloVacio = "Sin datos todavía",
  mensajeVacio = "Cuando haya algo que mostrar aquí, aparece solo.",
  mensajeError = "No se pudo cargar la información.",
}: TablaProps<T>) {
  const [ordenPor, setOrdenPor] = useState<string | null>(null);
  const [ordenAsc, setOrdenAsc] = useState(true);
  const [textoFiltro, setTextoFiltro] = useState("");
  const [expandida, setExpandida] = useState<string | null>(null);

  const filasFiltradas = useMemo(() => {
    let resultado = filas;
    if (filtro && textoFiltro.trim()) {
      resultado = resultado.filter((f) => filtro(f, textoFiltro.trim()));
    }
    if (ordenPor) {
      const columna = columnas.find((c) => c.clave === ordenPor);
      if (columna?.valorOrden) {
        resultado = [...resultado].sort((a, b) => {
          const va = columna.valorOrden!(a);
          const vb = columna.valorOrden!(b);
          const cmp = va < vb ? -1 : va > vb ? 1 : 0;
          return ordenAsc ? cmp : -cmp;
        });
      }
    }
    return resultado;
  }, [filas, filtro, textoFiltro, ordenPor, ordenAsc, columnas]);

  function alternarOrden(clave: string) {
    if (ordenPor === clave) {
      setOrdenAsc((v) => !v);
    } else {
      setOrdenPor(clave);
      setOrdenAsc(true);
    }
  }

  if (estado === "cargando") {
    return (
      <EstadoDecorado
        tono="tenue"
        rol="status"
        icono={ICONO_CARGANDO}
        titulo="Cargando…"
        mensaje="Un momento."
      />
    );
  }

  if (estado === "error") {
    return (
      <EstadoDecorado
        tono="negativo"
        rol="alert"
        icono={ICONO_ERROR}
        titulo="Algo no salió bien"
        mensaje={mensajeError}
      />
    );
  }

  if (estado === "vacio" || filas.length === 0) {
    return (
      <EstadoDecorado
        tono="tenue"
        rol="status"
        icono={ICONO_VACIO}
        titulo={tituloVacio}
        mensaje={mensajeVacio}
      />
    );
  }

  return (
    <div className="superficie-vidrio overflow-hidden">
      {filtro && (
        <div className="p-3 border-b border-vidrio-borde">
          <input
            type="text"
            value={textoFiltro}
            onChange={(e) => setTextoFiltro(e.target.value)}
            placeholder="Filtrar…"
            className="w-full bg-transparent outline-none text-texto placeholder:text-texto-tenue"
          />
        </div>
      )}
      {/* Contenedor con alto acotado: es lo que hace que el encabezado
          "sticky" tenga sentido — sin un alto que exceder, nunca se
          desplaza y el encabezado fijo no se distingue del normal. */}
      <div className="max-h-[28rem] overflow-y-auto">
        <table className="w-full text-left">
          <thead className="sticky top-0 z-10 bg-vidrio-elevado backdrop-blur-[var(--vidrio-blur)]">
            <tr>
              {columnas.map((c) => (
                <th
                  key={c.clave}
                  className={
                    "etiqueta px-4 py-3 select-none " +
                    (c.alineacion === "derecha" ? "text-right" : "text-left")
                  }
                >
                  {c.ordenable ? (
                    <button
                      type="button"
                      onClick={() => alternarOrden(c.clave)}
                      className={
                        "flex items-center gap-1 " +
                        (c.alineacion === "derecha" ? "ml-auto" : "")
                      }
                    >
                      {c.encabezado}
                      {ordenPor === c.clave ? (ordenAsc ? " ↑" : " ↓") : ""}
                    </button>
                  ) : (
                    c.encabezado
                  )}
                </th>
              ))}
            </tr>
          </thead>
          <tbody>
            {filasFiltradas.map((fila) => {
              const id = idDeFila(fila);
              const abierta = expandida === id;
              return (
                <Fragment key={id}>
                  <tr
                    onClick={() => contenidoExpandido && setExpandida(abierta ? null : id)}
                    className={
                      "border-t border-vidrio-borde" +
                      (contenidoExpandido ? " cursor-pointer hover:bg-vidrio-elevado" : "")
                    }
                  >
                    {columnas.map((c) => (
                      <td
                        key={c.clave}
                        className={
                          "px-4 py-3 text-texto " +
                          (c.alineacion === "derecha" ? "text-right cifras-tabulares" : "text-left")
                        }
                      >
                        {c.render(fila)}
                      </td>
                    ))}
                  </tr>
                  {abierta && contenidoExpandido && (
                    <tr key={id + "-expandida"}>
                      <td colSpan={columnas.length} className="px-4 py-3 bg-vidrio-elevado">
                        {contenidoExpandido(fila)}
                      </td>
                    </tr>
                  )}
                </Fragment>
              );
            })}
          </tbody>
        </table>
      </div>
    </div>
  );
}
