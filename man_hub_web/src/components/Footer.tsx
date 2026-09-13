import styles from "./Footer.module.css";
import Image from "next/image";

export default function Footer() {
  return (
    <footer className={styles.footer}>
      <div className="container">
        <div className={styles.topGrid}>
          {/* Brand Info */}
          <div className={styles.brandCol}>
            <div className={styles.logo}>
              <Image
                src="/manhub_icon.png"
                alt="Man Hub Logo"
                width={36}
                height={36}
                style={{ objectFit: "contain", filter: "drop-shadow(0 0 10px rgba(0, 191, 255, 0.6))" }}
              />
              <span className={styles.logoTitle}>MAN HUB</span>
            </div>
            <p className={styles.brandDesc}>
              A imagem é apenas o começo. O primeiro hub integrado dedicado à evolução masculina,
              visagismo, alfaiataria, perfumaria de nicho e autoconfiança de alto padrão.
            </p>
            <div style={{ marginTop: "4px" }}>
              <span className="badge-gold" style={{ fontSize: "10.5px" }}>
                Lançamento em Breve na App Store & Google Play
              </span>
            </div>
          </div>

          {/* Column 1: Trilhas */}
          <div>
            <h4 className={styles.colTitle}>Treinamentos</h4>
            <ul className={styles.linksList}>
              <li className={styles.linkItem}>
                <a href="#treinamentos">O Homem Bem-Vestido</a>
              </li>
              <li className={styles.linkItem}>
                <a href="#treinamentos">Pele, Cabelo & Barba</a>
              </li>
              <li className={styles.linkItem}>
                <a href="#treinamentos">Perfumaria Masculina</a>
              </li>
              <li className={styles.linkItem}>
                <a href="#pilares">Postura & Linguagem Corporal</a>
              </li>
            </ul>
          </div>

          {/* Column 2: Recursos */}
          <div>
            <h4 className={styles.colTitle}>Recursos</h4>
            <ul className={styles.linksList}>
              <li className={styles.linkItem}>
                <a href="#diagnostico">Diagnóstico Facial & Estilo</a>
              </li>
              <li className={styles.linkItem}>
                <a href="#app">Formato Stories Interativo</a>
              </li>
              <li className={styles.linkItem}>
                <a href="#app">Telas Salvas & Favoritos</a>
              </li>
              <li className={styles.linkItem}>
                <a href="#download">Download iOS & Android</a>
              </li>
            </ul>
          </div>

          {/* Column 3: Institucional */}
          <div>
            <h4 className={styles.colTitle}>Institucional</h4>
            <ul className={styles.linksList}>
              <li className={styles.linkItem}>
                <a href="#pilares">Metodologia</a>
              </li>
              <li className={styles.linkItem}>
                <a href="#depoimentos">Depoimentos</a>
              </li>
              <li className={styles.linkItem}>
                <a href="#faq">Perguntas Frequentes</a>
              </li>
              <li className={styles.linkItem}>
                <a href="mailto:contato@manhub.app">Suporte & Contato</a>
              </li>
            </ul>
          </div>
        </div>

        {/* Bottom Bar */}
        <div className={styles.bottomBar}>
          <span className={styles.copyright}>
            © 2026 MAN HUB. Todos os direitos reservados. Uma marca Interestelar Studios.
          </span>

          <div className={styles.legalLinks}>
            <a href="#" className={styles.legalLink}>
              Termos de Uso
            </a>
            <a href="#" className={styles.legalLink}>
              Política de Privacidade
            </a>
            <a href="#" className={styles.legalLink}>
              Segurança de Dados
            </a>
          </div>
        </div>
      </div>
    </footer>
  );
}
