import styles from "./LegalLayout.module.css";
import Image from "next/image";
import Link from "next/link";
import Footer from "./Footer";
import { ArrowLeft, Shield } from "lucide-react";

interface LegalLayoutProps {
  badge: string;
  title: string;
  lastUpdated: string;
  children: React.ReactNode;
}

export default function LegalLayout({
  badge,
  title,
  lastUpdated,
  children,
}: LegalLayoutProps) {
  return (
    <div className={styles.legalPage}>
      <header className={styles.legalHeader}>
        <div className={`container ${styles.headerInner}`}>
          <Link href="/" className={styles.logoWrap}>
            <Image
              src="/manhub_icon.png"
              alt="Man Hub Logo"
              width={34}
              height={34}
              style={{ objectFit: "contain", filter: "drop-shadow(0 0 8px rgba(0, 191, 255, 0.6))" }}
            />
            <span className={styles.logoTitle}>MAN HUB</span>
          </Link>

          <Link href="/" className={styles.backBtn}>
            <ArrowLeft size={16} />
            <span>Voltar ao Início</span>
          </Link>
        </div>
      </header>

      <main className={styles.mainContent}>
        <div className="container" style={{ maxWidth: "860px" }}>
          <div className={styles.contentCard}>
            <div className={styles.docHeader}>
              <span className={styles.badge}>
                <Shield size={13} />
                {badge}
              </span>
              <h1 className={styles.docTitle}>{title}</h1>
              <p className={styles.metaText}>Última atualização: {lastUpdated} • Desenvolvido por Interestelar Studios</p>
            </div>

            <div className={styles.prose}>
              {children}
            </div>
          </div>
        </div>
      </main>

      <Footer />
    </div>
  );
}
