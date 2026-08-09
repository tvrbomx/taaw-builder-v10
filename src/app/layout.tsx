import type { Metadata } from "next";
import { Fraunces, Inter, JetBrains_Mono } from "next/font/google";
import "./globals.css";

// V10-DISENO §5, resuelto 9-ago-2026: Fraunces (display), Inter (cuerpo),
// JetBrains Mono (claves, folios, montos). next/font las sirve sin
// parpadeo y sin petición externa en cada carga.
const fraunces = Fraunces({
  subsets: ["latin"],
  variable: "--font-fraunces",
  axes: ["opsz", "SOFT", "WONK"],
});
const inter = Inter({ subsets: ["latin"], variable: "--font-inter" });
const jetbrainsMono = JetBrains_Mono({ subsets: ["latin"], variable: "--font-jetbrains-mono" });

export const metadata: Metadata = {
  title: "TAAW Builder v10",
  description: "Plataforma de control de proyecto — Dravya",
};

// Se fija el tema ANTES de pintar, para que no haya parpadeo del tema
// por omisión mientras React hidrata — V10-DISENO §6.
const SCRIPT_TEMA = `
(function () {
  try {
    var guardado = localStorage.getItem('taaw-tema');
    if (guardado === 'claro' || guardado === 'oscuro') {
      document.documentElement.setAttribute('data-theme', guardado === 'oscuro' ? 'dark' : 'light');
    }
  } catch (e) {}
})();
`;

export default function RootLayout({ children }: LayoutProps<"/">) {
  return (
    // suppressHydrationWarning: SCRIPT_TEMA cambia data-theme entre el HTML
    // que manda el servidor y lo que hay antes de pintar, a propósito — es
    // el mismo trato que documenta React para este patrón.
    <html
      lang="es"
      className={`h-full antialiased ${fraunces.variable} ${inter.variable} ${jetbrainsMono.variable}`}
      suppressHydrationWarning
    >
      <head>
        <script dangerouslySetInnerHTML={{ __html: SCRIPT_TEMA }} />
      </head>
      <body className="min-h-full flex flex-col">{children}</body>
    </html>
  );
}
