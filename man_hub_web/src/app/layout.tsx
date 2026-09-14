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
  title: "MAN HUB | Academia de Desenvolvimento Masculino",
  description:
    "A imagem é o começo. A evolução é completa. A sua Academia de Desenvolvimento Masculino: transforme sua imagem, forje sua postura de homem de valor e construa uma presença de alto nível.",
  keywords: [
    "Man Hub",
    "academia de desenvolvimento masculino",
    "desenvolvimento masculino",
    "homem de valor",
    "presença masculina",
    "estilo masculino",
    "imagem masculina",
    "postura e liderança",
  ],
  authors: [{ name: "Interestelar Studios" }],
  icons: {
    icon: "/manhub_icon.png",
    shortcut: "/manhub_icon.png",
    apple: "/manhub_icon.png",
  },
  openGraph: {
    title: "MAN HUB | Academia de Desenvolvimento Masculino",
    description:
      "Aprenda na prática com treinamentos dinâmicos em formato stories, transformação de imagem, princípios de homem de valor e presença de alto nível.",
    url: "https://manhub.app",
    siteName: "MAN HUB",
    locale: "pt_BR",
    type: "website",
  },
  twitter: {
    card: "summary_large_image",
    title: "MAN HUB | A Imagem é o Começo. A Evolução é Completa.",
    description:
      "A sua Academia de Desenvolvimento Masculino: transformação de imagem, postura de homem de valor e presença de alto nível.",
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
