"use client";

import { usePathname } from "next/navigation";
import Footer from "@/components/Footer";

export default function GlobalFooter() {
  const pathname = usePathname();

  const isStoryPlayer = pathname?.includes("/aula/");
  const isLegal =
    pathname === "/politica-de-privacidade" ||
    pathname === "/termos-de-uso" ||
    pathname === "/exclusao-de-conta";

  if (isStoryPlayer || isLegal) return null;

  return <Footer />;
}
