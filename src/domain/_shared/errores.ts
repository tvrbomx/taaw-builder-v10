/**
 * Errores de dominio — V10-API §6. Nunca cadenas de texto sueltas.
 * Toda Server Action y todo Route Handler devuelve ResultadoOperacion<T>.
 */

export type ErrorDominio = {
  tipo: string;
  mensaje: string;
  campo?: string;
};

export type ResultadoOperacion<T> =
  | { ok: true; datos: T }
  | { ok: false; error: ErrorDominio };

export function ok<T>(datos: T): ResultadoOperacion<T> {
  return { ok: true, datos };
}

export function error(tipo: string, mensaje: string, campo?: string): ResultadoOperacion<never> {
  return { ok: false, error: { tipo, mensaje, campo } };
}

// Tipos de dominio conocidos — se amplía por rebanada, nunca se reemplaza por string.
export const ERRORES = {
  SIN_SESION: "SinSesion",
  SIN_PERMISO: "SinPermiso",
  CLAVE_DUPLICADA: "ClaveDuplicada",
  GASTO_SIN_CONCEPTO: "GastoSinConcepto",
  AVANCE_SIN_CARTA_ENTREGA: "AvanceSinCartaEntrega",
  AUTORREVISION_EXCEDE_TOPE: "AutorrevisionExcedeTope",
  EMPRESA_ACTIVA_NO_RESUELTA: "EmpresaActivaNoResuelta",
} as const;
