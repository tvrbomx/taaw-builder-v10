"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { z } from "zod";
import { Formulario, Campo } from "@/ui/patterns/Formulario";
import type { ErrorDominio } from "@/domain/_shared/errores";
import { iniciarSesion } from "./accion";

const esquema = z.object({
  correo: z.email("Correo inválido."),
  contrasena: z.string().min(1, "La contraseña es obligatoria."),
});

type DatosLogin = z.infer<typeof esquema>;

export default function PaginaLogin() {
  const router = useRouter();
  const [errorServidor, setErrorServidor] = useState<ErrorDominio | null>(null);

  async function alEnviar(datos: DatosLogin) {
    setErrorServidor(null);
    const resultado = await iniciarSesion(datos);
    if (!resultado.ok) {
      setErrorServidor(resultado.error);
      return;
    }
    router.push("/");
    router.refresh();
  }

  return (
    <div className="flex flex-1 items-center justify-center p-8">
      <div className="w-full max-w-sm flex flex-col gap-8">
        <h1 className="titulo-pantalla text-texto text-center">TAAW Builder</h1>
        <Formulario<DatosLogin>
          esquema={esquema}
          valoresIniciales={{ correo: "", contrasena: "" }}
          alEnviar={alEnviar}
          errorServidor={errorServidor}
          textoEnviar="Entrar"
        >
          <Campo nombre="correo" etiqueta="Correo" tipo="email" />
          <Campo nombre="contrasena" etiqueta="Contraseña" tipo="password" />
        </Formulario>
      </div>
    </div>
  );
}
