"use client";

/**
 * Fondo atmosférico por módulo — V10-DISENO §3. Hoy son degradados de
 * marcador de posición (--fondo-modulo-* en tokens.css); cuando lleguen
 * las imágenes generadas por IA, entran ahí mismo, sin tocar este
 * componente ni la pantalla que lo usa.
 *
 * "Carga diferida": aquí no hay imagen que diferir todavía (es CSS), pero
 * el componente ya está listo para volverse <Image loading="lazy"> el
 * día que --fondo-modulo-* sea una url() en vez de un degradado.
 *
 * Preferencia: localStorage "taaw-fondo" = "apagado" desactiva la capa
 * atmosférica y deja sólo el fondo liso del tema — mismo patrón que
 * ThemeToggle.
 */
import { useEffect, useState } from "react";

export type Modulo = "proyectos" | "catalogo" | "obra" | "dinero" | "junta";

export function FondoModulo({ modulo }: { modulo: Modulo }) {
  const [activo, setActivo] = useState(true);

  useEffect(() => {
    setActivo(localStorage.getItem("taaw-fondo") !== "apagado");
  }, []);

  if (!activo) return null;

  return (
    <div
      aria-hidden
      className="fixed inset-0 -z-10 bg-cover bg-center transition-opacity duration-500"
      style={{ backgroundImage: `var(--fondo-modulo-${modulo})` }}
    />
  );
}

export function FondoToggle() {
  const [activo, setActivo] = useState(true);

  useEffect(() => {
    setActivo(localStorage.getItem("taaw-fondo") !== "apagado");
  }, []);

  function alternar() {
    const siguiente = !activo;
    localStorage.setItem("taaw-fondo", siguiente ? "activo" : "apagado");
    setActivo(siguiente);
    // El fondo se lee al montar — un cambio de preferencia se ve reflejado
    // recargando, igual que cualquier otra preferencia de la aplicación.
    window.location.reload();
  }

  return (
    <button
      type="button"
      onClick={alternar}
      aria-label={activo ? "Desactivar fondo atmosférico" : "Activar fondo atmosférico"}
      className="superficie-vidrio px-3 py-2 text-sm text-texto hover:bg-vidrio-elevado transition-colors"
    >
      {activo ? "Fondo liso" : "Fondo atmosférico"}
    </button>
  );
}
