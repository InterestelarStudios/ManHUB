"use client";

import { useState, useEffect } from "react";
import styles from "./Header.module.css";
import Image from "next/image";
import { Sparkles, Menu, X } from "lucide-react";

export default function Header() {
  const [scrolled, setScrolled] = useState(false);
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);

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
        <a href="#" className={styles.logo}>
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
        </a>

        <nav className={styles.nav}>
          <a href="#app" className={styles.navLink}>O App</a>
          <a href="#pilares" className={styles.navLink}>Pilares</a>
          <a href="#treinamentos" className={styles.navLink}>Treinamentos</a>
          <a href="#diagnostico" className={styles.navLink}>Diagnóstico</a>
          <a href="#depoimentos" className={styles.navLink}>Depoimentos</a>
          <a href="#faq" className={styles.navLink}>FAQ</a>
        </nav>

        <div className={styles.headerAction}>
          <a href="#download" className={styles.ctaBtn}>
            <Sparkles size={15} />
            <span>Lista VIP • Em Breve</span>
          </a>

          <button
            className={styles.mobileMenuBtn}
            onClick={() => setMobileMenuOpen(!mobileMenuOpen)}
            aria-label="Abrir menu de navegação"
          >
            {mobileMenuOpen ? <X size={24} /> : <Menu size={24} />}
          </button>
        </div>
      </div>

      {mobileMenuOpen && (
        <div className={`${styles.mobileNav} ${styles.mobileOpen}`}>
          <a
            href="#app"
            className={styles.navLink}
            onClick={() => setMobileMenuOpen(false)}
          >
            O App
          </a>
          <a
            href="#pilares"
            className={styles.navLink}
            onClick={() => setMobileMenuOpen(false)}
          >
            Pilares
          </a>
          <a
            href="#treinamentos"
            className={styles.navLink}
            onClick={() => setMobileMenuOpen(false)}
          >
            Treinamentos
          </a>
          <a
            href="#diagnostico"
            className={styles.navLink}
            onClick={() => setMobileMenuOpen(false)}
          >
            Diagnóstico
          </a>
          <a
            href="#depoimentos"
            className={styles.navLink}
            onClick={() => setMobileMenuOpen(false)}
          >
            Depoimentos
          </a>
          <a
            href="#faq"
            className={styles.navLink}
            onClick={() => setMobileMenuOpen(false)}
          >
            FAQ
          </a>
          <a
            href="#download"
            className={styles.ctaBtn}
            onClick={() => setMobileMenuOpen(false)}
            style={{ textAlign: "center", justifyContent: "center" }}
          >
            <Sparkles size={16} />
            <span>Garantir Acesso VIP • Em Breve</span>
          </a>
        </div>
      )}
    </header>
  );
}
