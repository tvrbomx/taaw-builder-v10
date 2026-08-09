"use client";

/**
 * Alterna data-theme en <html> y lo guarda en localStorage — layout.tsx
 * lee ese mismo valor antes de pintar para no parpadear. V10-DISENO §6.
 */
import { useEffect, useState } from "react";

type Tema = "claro" | "oscuro";

function temaActual(): Tema {
  if (typeof document === "undefined") return "claro";
  const explicito = document.documentElement.getAttribute("data-theme");
  if (explicito === "dark") return "oscuro";
  if (explicito === "light") return "claro";
  // Sin preferencia guardada todavía — el tema visible lo decide
  // prefers-color-scheme (tokens.css), y el botón tiene que coincidir
  // con lo que la persona ya está viendo, no con "claro" a ciegas.
  return window.matchMedia("(prefers-color-scheme: dark)").matches ? "oscuro" : "claro";
}

export function ThemeToggle() {
  const [tema, setTema] = useState<Tema>("claro");

  useEffect(() => {
    setTema(temaActual());
  }, []);

  function alternar() {
    const siguiente: Tema = tema === "claro" ? "oscuro" : "claro";
    document.documentElement.setAttribute("data-theme", siguiente === "oscuro" ? "dark" : "light");
    localStorage.setItem("taaw-tema", siguiente);
    setTema(siguiente);
  }

  return (
    <button
      type="button"
      onClick={alternar}
      aria-label={tema === "claro" ? "Cambiar a tema oscuro" : "Cambiar a tema claro"}
      className="superficie-vidrio px-3 py-2 text-sm text-texto hover:bg-vidrio-elevado transition-colors"
    >
      {tema === "claro" ? "Oscuro" : "Claro"}
    </button>
  );
}
