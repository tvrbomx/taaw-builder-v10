"use client";

/**
 * Patrón Formulario — V10-DISENO §7. Completo, per rebanada 1.
 * "Etiqueta arriba, campo abajo, ayuda al lado. Validación al salir del
 *  campo, nunca al enviar. Los errores se explican, no se anuncian."
 *
 * Envoltura delgada sobre react-hook-form + zod: el layout y el momento
 * de validación son el patrón; los campos concretos los define cada
 * pantalla.
 */

import { zodResolver } from "@hookform/resolvers/zod";
import {
  useForm,
  FormProvider,
  useFormContext,
  type FieldValues,
  type Resolver,
  type SubmitHandler,
  type DefaultValues,
} from "react-hook-form";
import type { ReactNode } from "react";
import type { ZodType } from "zod";
import type { ErrorDominio } from "@/domain/_shared/errores";

export type FormularioProps<T extends FieldValues> = {
  esquema: ZodType<T, T>;
  valoresIniciales: DefaultValues<T>;
  alEnviar: SubmitHandler<T>;
  errorServidor?: ErrorDominio | null;
  children: ReactNode;
  textoEnviar?: string;
};

export function Formulario<T extends FieldValues>({
  esquema,
  valoresIniciales,
  alEnviar,
  errorServidor,
  children,
  textoEnviar = "Guardar",
}: FormularioProps<T>) {
  const metodos = useForm<T>({
    resolver: zodResolver(esquema) as unknown as Resolver<T>,
    defaultValues: valoresIniciales,
    mode: "onBlur", // validación al salir del campo, nunca al enviar
  });

  return (
    <FormProvider {...metodos}>
      <form
        onSubmit={metodos.handleSubmit(alEnviar)}
        className="superficie-vidrio p-8 flex flex-col gap-6"
        noValidate
      >
        {children}

        {errorServidor && (
          <p role="alert" className="text-negativo texto-secundario">
            {errorServidor.mensaje}
          </p>
        )}

        <button
          type="submit"
          disabled={metodos.formState.isSubmitting}
          className="self-start rounded-[var(--radio)] bg-acento text-texto-inverso px-4 py-2.5 disabled:opacity-50 transition-opacity"
        >
          {metodos.formState.isSubmitting ? "Guardando…" : textoEnviar}
        </button>
      </form>
    </FormProvider>
  );
}

export function Campo({
  nombre,
  etiqueta,
  ayuda,
  tipo = "text",
}: {
  nombre: string;
  etiqueta: string;
  ayuda?: string;
  tipo?: string;
}) {
  const {
    register,
    formState: { errors },
  } = useFormContext();
  const error = errors[nombre];

  return (
    <div className="flex flex-col gap-2">
      <label htmlFor={nombre} className="etiqueta">
        {etiqueta}
      </label>
      <input
        id={nombre}
        type={tipo}
        {...register(nombre)}
        aria-invalid={!!error}
        aria-describedby={ayuda ? `${nombre}-ayuda` : undefined}
        className="rounded-[var(--radio-chico)] border border-vidrio-borde bg-vidrio-elevado px-3 py-2.5 text-texto outline-none focus:border-acento transition-colors"
      />
      {/* el error se explica, no se anuncia — V10-DISENO §8 */}
      {error && (
        <p className="text-negativo texto-secundario">{String(error.message)}</p>
      )}
      {!error && ayuda && (
        <p id={`${nombre}-ayuda`} className="texto-secundario">
          {ayuda}
        </p>
      )}
    </div>
  );
}
