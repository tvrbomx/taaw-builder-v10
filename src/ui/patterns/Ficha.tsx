/**
 * Patrón Ficha — V10-DISENO §7. ESBOZADO, NO TERMINADO — decisión explícita
 * de la rebanada 1: la pantalla de ejemplo no ejercita una ficha real, y
 * diseñarla sin un registro real que mostrar es diseño especulativo. Se
 * completa en la rebanada que primero la necesite con datos reales delante.
 *
 * Lo que ya se sabe, de V10-DISENO §7: "La vista de un registro: encabezado
 * con lo esencial, pestañas para lo demás, acciones siempre en el mismo
 * lugar." El esqueleto de abajo respeta esa forma; el contenido no.
 */

import type { ReactNode } from "react";

export type FichaProps = {
  titulo: string;
  subtitulo?: string;
  pestañas?: { etiqueta: string; contenido: ReactNode }[];
  acciones?: ReactNode;
};

export function Ficha({ titulo, subtitulo, acciones }: FichaProps) {
  return (
    <div className="superficie-vidrio-elevada p-6">
      <header className="flex items-start justify-between">
        <div>
          <h1 className="text-xl font-semibold text-texto">{titulo}</h1>
          {subtitulo && <p className="text-texto-tenue">{subtitulo}</p>}
        </div>
        {acciones}
      </header>
      {/* TODO rebanada correspondiente: pestañas reales, con datos reales.
          No se construye aquí — ver el comentario de arriba. */}
    </div>
  );
}
