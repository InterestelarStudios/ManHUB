import styles from "./LegalLayout.module.css";
import { Shield } from "lucide-react";

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
    </div>
  );
}
