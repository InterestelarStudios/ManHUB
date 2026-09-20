import styles from "./Footer.module.css";
import Image from "next/image";
import Link from "next/link";

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
              A imagem é apenas o começo. A sua Academia de Desenvolvimento Masculino:
              transformação de imagem, princípios de homem de valor e presença de alto nível.
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
                <Link href="/treinamentos">Catálogo de Treinamentos</Link>
              </li>
              <li className={styles.linkItem}>
                <Link href="/treinamentos/e0ee6636-cea6-4f59-8242-6b7270f8254d">O Homem Bem-Vestido</Link>
              </li>
              <li className={styles.linkItem}>
                <Link href="/treinamentos/f47a8291-3c1e-49fb-9de8-18e329ba4182">Pele, Cabelo & Barba</Link>
              </li>
              <li className={styles.linkItem}>
                <Link href="/treinamentos/a7e14d9b-83c6-4e5a-bb44-67290f11ac38">Perfumaria Masculina</Link>
              </li>
            </ul>
          </div>

          {/* Column 2: Recursos */}
          <div>
            <h4 className={styles.colTitle}>Recursos</h4>
            <ul className={styles.linksList}>
              <li className={styles.linkItem}>
                <Link href="/#diagnostico">Diagnóstico Facial & Estilo</Link>
              </li>
              <li className={styles.linkItem}>
                <Link href="/#app">Formato Stories Interativo</Link>
              </li>
              <li className={styles.linkItem}>
                <Link href="/conta">Área do Usuário & Progresso</Link>
              </li>
              <li className={styles.linkItem}>
                <Link href="/#download">Download iOS & Android</Link>
              </li>
            </ul>
          </div>

          {/* Column 3: Institucional */}
          <div>
            <h4 className={styles.colTitle}>Institucional</h4>
            <ul className={styles.linksList}>
              <li className={styles.linkItem}>
                <Link href="/#pilares">Metodologia</Link>
              </li>
              <li className={styles.linkItem}>
                <Link href="/#depoimentos">Depoimentos</Link>
              </li>
              <li className={styles.linkItem}>
                <Link href="/#faq">Perguntas Frequentes</Link>
              </li>
              <li className={styles.linkItem}>
                <a href="mailto:support@interestelar.studio">Suporte & Contato</a>
              </li>
              <li className={styles.linkItem}>
                <Link href="/exclusao-de-conta">Exclusão de Conta</Link>
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
            <Link href="/termos-de-uso" className={styles.legalLink}>
              Termos de Uso
            </Link>
            <Link href="/politica-de-privacidade" className={styles.legalLink}>
              Política de Privacidade
            </Link>
            <Link href="/exclusao-de-conta" className={styles.legalLink}>
              Exclusão de Dados & Conta
            </Link>
          </div>
        </div>
      </div>
    </footer>
  );
}
