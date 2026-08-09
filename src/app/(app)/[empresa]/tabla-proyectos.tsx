"use client";

/**
 * Envoltura cliente de Tabla — un Server Component no puede pasarle
 * funciones (render, idDeFila) a un Client Component como props, sólo
 * datos serializables. Este componente recibe los datos y define las
 * columnas del lado del cliente.
 */
import { Tabla, type ColumnaTabla } from "@/ui/patterns/Tabla";
import type { ProyectoResumen } from "@/data/repositorios/proyectos";

const COLUMNAS: ColumnaTabla<ProyectoResumen>[] = [
  {
    clave: "clave",
    encabezado: "Clave",
    // claves, folios y códigos van en mono, siempre — V10-DISENO §5
    render: (p) => <span className="texto-mono">{p.clave}</span>,
    ordenable: true,
    valorOrden: (p) => p.clave,
  },
  {
    clave: "nombre",
    encabezado: "Proyecto",
    render: (p) => p.nombre,
    ordenable: true,
    valorOrden: (p) => p.nombre,
  },
  { clave: "etapaBim", encabezado: "Etapa BIM", render: (p) => p.etapaBim },
];

export function TablaProyectos({
  proyectos,
  estado,
  mensajeVacio,
  mensajeError,
}: {
  proyectos: ProyectoResumen[];
  estado: "vacio" | "listo" | "error";
  mensajeVacio?: string;
  mensajeError?: string;
}) {
  return (
    <Tabla<ProyectoResumen>
      columnas={COLUMNAS}
      filas={proyectos}
      idDeFila={(p) => p.id}
      estado={estado}
      mensajeVacio={mensajeVacio}
      mensajeError={mensajeError}
    />
  );
}
