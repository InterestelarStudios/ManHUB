"use client";

import { usePathname } from "next/navigation";
import Header from "@/components/Header";

export default function GlobalNavbar() {
  const pathname = usePathname();

  // Story player de tela cheia não exibe a barra global para não sobrepor as barras do story
  const isStoryPlayer = pathname?.includes("/aula/");

  if (isStoryPlayer) return null;

  return <Header />;
}
