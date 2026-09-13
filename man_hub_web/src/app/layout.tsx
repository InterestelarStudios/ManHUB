import type { Metadata, Viewport } from "next";
import { Outfit, Plus_Jakarta_Sans } from "next/font/google";
import "./globals.css";

const outfit = Outfit({
  subsets: ["latin"],
  variable: "--font-heading",
  weight: ["500", "600", "700", "800", "900"],
  display: "swap",
});

const plusJakarta = Plus_Jakarta_Sans({
  subsets: ["latin"],
  variable: "--font-body",
  weight: ["400", "500", "600", "700"],
  display: "swap",
});

export const viewport: Viewport = {
  themeColor: "#040D1A",
  width: "device-width",
  initialScale: 1,
};

export const metadata: Metadata = {
  title: "MAN HUB | O Ecossistema Definitivo de Evolução e Imagem Masculina",
  description:
    "A imagem é apenas o começo. Descubra seu visagismo facial, domine alfaiataria e caimento, encontre sua assinatura em perfumaria e desenvolva postura e presença de alto nível.",
  keywords: [
    "Man Hub",
    "estilo masculino",
    "visagismo masculino",
    "perfumaria masculina",
    "alfaiataria masculina",
    "moda masculina",
    "cuidados pessoais homem",
    "desenvolvimento pessoal masculino",
  ],
  authors: [{ name: "Interestelar Studios" }],
  icons: {
    icon: "/manhub_icon.png",
    shortcut: "/manhub_icon.png",
    apple: "/manhub_icon.png",
  },
  openGraph: {
    title: "MAN HUB | Evolução Masculina Integral",
    description:
      "Aprenda na prática com treinamentos dinâmicos em formato stories, diagnóstico de visagismo facial e consultoria de estilo e perfumaria.",
    url: "https://manhub.app",
    siteName: "MAN HUB",
    locale: "pt_BR",
    type: "website",
  },
  twitter: {
    card: "summary_large_image",
    title: "MAN HUB | A Imagem é o Começo. A Evolução é Completa.",
    description:
      "O primeiro aplicativo brasileiro dedicado à imagem, visagismo, alfaiataria e desenvolvimento integral masculino.",
  },
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html
      lang="pt-BR"
      className={`${outfit.variable} ${plusJakarta.variable}`}
      suppressHydrationWarning
    >
      <body suppressHydrationWarning>{children}</body>
    </html>
  );
}
