"use client";

import { useState, useEffect } from "react";
import Link from "next/link";
import { usePathname } from "next/navigation";
import styles from "./Header.module.css";
import Image from "next/image";
import { Sparkles, Menu, X, User } from "lucide-react";
import { useAuth } from "@/lib/context/AuthContext";
import UserMenu from "@/components/auth/UserMenu";
import AuthModal from "@/components/auth/AuthModal";

interface HeaderProps {
  onOpenCheckout?: () => void;
}

export default function Header({ onOpenCheckout }: HeaderProps) {
  const pathname = usePathname();
  const { isLoggedIn } = useAuth();
  const [scrolled, setScrolled] = useState(false);
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);
  const [isAuthModalOpen, setIsAuthModalOpen] = useState(false);

  const isHome = pathname === "/";
  const isTrainings = pathname?.startsWith("/treinamentos");

  useEffect(() => {
    const handleScroll = () => {
      setScrolled(window.scrollY > 20);
    };
    window.addEventListener("scroll", handleScroll);
    return () => window.removeEventListener("scroll", handleScroll);
  }, []);

  return (
    <header className={`${styles.header} ${scrolled ? styles.scrolled : ""}`}>
      <div className={`container ${styles.inner}`}>
        <Link href="/" className={styles.logo}>
          <Image
            src="/manhub_icon.png"
            alt="Man Hub Logo"
            width={38}
            height={38}
            priority
            style={{ objectFit: "contain", filter: "drop-shadow(0 0 10px rgba(0, 191, 255, 0.6))" }}
          />
          <div className={styles.logoText}>
            <span className={styles.logoTitle}>MAN HUB</span>
            <span className={styles.logoSubtitle}>Evolução Masculina</span>
          </div>
        </Link>

        <nav className={styles.nav}>
          <Link
            href="/"
            className={`${styles.navLink} ${isHome ? styles.activeNavLink : ""}`}
          >
            {isHome && <span className={styles.activeDot} />}
            Início
          </Link>
          <Link
            href="/treinamentos"
            className={`${styles.navLink} ${isTrainings ? styles.activeNavLink : ""}`}
          >
            {isTrainings && <span className={styles.activeDot} />}
            Treinamentos
          </Link>
          <Link href="/#app" className={styles.navLink}>O App</Link>
          <Link href="/#pilares" className={styles.navLink}>Pilares</Link>
          <Link href="/#depoimentos" className={styles.navLink}>Depoimentos</Link>
          <Link href="/#faq" className={styles.navLink}>FAQ</Link>
        </nav>

        <div className={styles.headerAction}>
          {isLoggedIn ? (
            <UserMenu />
          ) : (
            <>
              <button
                onClick={() => setIsAuthModalOpen(true)}
                className={styles.loginBtn}
              >
                <User size={15} />
                <span>Entrar</span>
              </button>

              <button
                onClick={() => setIsAuthModalOpen(true)}
                className={styles.ctaBtn}
              >
                <Sparkles size={15} />
                <span>Iniciar Jornada</span>
              </button>
            </>
          )}

          <button
            className={styles.mobileMenuBtn}
            onClick={() => setMobileMenuOpen(!mobileMenuOpen)}
            aria-label="Abrir menu de navegação"
          >
            {mobileMenuOpen ? <X size={24} /> : <Menu size={24} />}
          </button>
        </div>
      </div>

      <AuthModal
        isOpen={isAuthModalOpen}
        onClose={() => setIsAuthModalOpen(false)}
      />

      {mobileMenuOpen && (
        <div className={`${styles.mobileNav} ${styles.mobileOpen}`}>
          <Link
            href="/"
            className={`${styles.mobileNavLink} ${isHome ? styles.activeMobileNavLink : ""}`}
            onClick={() => setMobileMenuOpen(false)}
          >
            <span>Início</span>
            {isHome && <span className={styles.mobileActiveDot} />}
          </Link>
          <Link
            href="/treinamentos"
            className={`${styles.mobileNavLink} ${isTrainings ? styles.activeMobileNavLink : ""}`}
            onClick={() => setMobileMenuOpen(false)}
          >
            <span>Treinamentos</span>
            {isTrainings && <span className={styles.mobileActiveDot} />}
          </Link>
          <Link
            href="/#app"
            className={styles.mobileNavLink}
            onClick={() => setMobileMenuOpen(false)}
          >
            <span>O App</span>
          </Link>
          <Link
            href="/#pilares"
            className={styles.mobileNavLink}
            onClick={() => setMobileMenuOpen(false)}
          >
            <span>Pilares</span>
          </Link>
          <Link
            href="/#diagnostico"
            className={styles.mobileNavLink}
            onClick={() => setMobileMenuOpen(false)}
          >
            <span>Diagnóstico</span>
          </Link>
          <Link
            href="/#depoimentos"
            className={styles.mobileNavLink}
            onClick={() => setMobileMenuOpen(false)}
          >
            <span>Depoimentos</span>
          </Link>
          <Link
            href="/#faq"
            className={styles.mobileNavLink}
            onClick={() => setMobileMenuOpen(false)}
          >
            <span>FAQ</span>
          </Link>
          <Link
            href="/treinamentos"
            className={styles.ctaBtn}
            onClick={() => setMobileMenuOpen(false)}
            style={{ textAlign: "center", justifyContent: "center" }}
          >
            <Sparkles size={16} />
            <span>Começar Agora • Treinamentos</span>
          </Link>
        </div>
      )}
    </header>
  );
}
