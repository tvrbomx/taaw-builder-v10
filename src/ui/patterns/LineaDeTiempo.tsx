/**
 * Patrón Línea de tiempo — V10-DISENO §7. ESBOZADO, NO TERMINADO —
 * decisión explícita de la rebanada 1: se completa en la rebanada 5, con
 * la bitácora enfrente y eventos reales que mostrar. Diseñarla ahora,
 * sin datos, es diseño especulativo y lo especulativo se reescribe.
 *
 * Lo que ya se sabe, de V10-DISENO §7: "Eventos sobre un eje, agrupados
 * por día, con foto y documento adjuntos. Es la vista que cuenta la
 * historia del proyecto."
 */

export type EventoLineaDeTiempo = {
  id: string;
  fecha: Date;
  titulo: string;
};

export function LineaDeTiempo({ eventos }: { eventos: EventoLineaDeTiempo[] }) {
  return (
    <ol className="superficie-vidrio p-6 flex flex-col gap-3">
      {eventos.map((e) => (
        <li key={e.id} className="text-texto">
          <span className="text-texto-tenue text-sm">
            {e.fecha.toLocaleDateString("es-MX")}
          </span>{" "}
          — {e.titulo}
        </li>
      ))}
      {/* TODO rebanada 5: agrupación por día, fotos, adjuntos, bitácora real.
          No se construye aquí — ver el comentario de arriba. */}
    </ol>
  );
}
