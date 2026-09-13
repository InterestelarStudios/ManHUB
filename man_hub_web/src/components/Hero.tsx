import styles from "./Hero.module.css";
import PhoneMockup from "./PhoneMockup";
import { ArrowRight, Sparkles, Star, ShieldCheck, Apple } from "lucide-react";

export default function Hero() {
  return (
    <section className={styles.hero}>
      <div className="ambient-glow-top" />

      <div className={`container ${styles.heroContent}`}>
        {/* Left Column: Value Proposition & CTAs */}
        <div className={styles.heroLeft}>
          <div className={styles.badgeWrap}>
            <span className="badge-gold">
              <Sparkles size={13} />
              Lançamento Oficial em Breve
            </span>
            <span className="badge-neon">
              Acesso Antecipado
            </span>
          </div>

          <h1 className={styles.heroTitle}>
            A imagem é o começo. <br />
            <span className="text-gradient">A evolução é completa.</span>
          </h1>

          <p className={styles.heroSubtitle}>
            O primeiro hub inteligente que une <strong>visagismo facial</strong>,
            <strong> alfaiataria de caimento perfeito</strong>, <strong>perfumaria de nicho</strong> e
            desenvolvimento pessoal prático em treinamentos imersivos.
          </p>

          <div className={styles.heroCtas}>
            <a href="#download" className="btn btn-primary">
              <span>Garantir Acesso Antecipado</span>
              <ArrowRight size={18} />
            </a>

            <a href="#pilares" className="btn btn-secondary">
              <span>Explorar os 4 Pilares</span>
            </a>
          </div>

          <div className={styles.appBadges}>
            <a href="#download" className={styles.storeBtn}>
              <Apple size={22} />
              <div className={styles.storeText}>
                <span className={styles.storeSmall}>Em breve na</span>
                <span className={styles.storeName}>App Store</span>
              </div>
            </a>

            <a href="#download" className={styles.storeBtn}>
              <div style={{ display: "flex", alignItems: "center" }}>
                {/* Google Play SVG icon */}
                <svg width="20" height="20" viewBox="0 0 24 24" fill="currentColor">
                  <path d="M3.609 1.814L13.792 12 3.61 22.186a1.99 1.99 0 0 1-.61-.91V2.724c0-.336.075-.658.21-.91z" fill="#00BFFF"/>
                  <path d="M17.183 8.61L14.73 11.063 4.548.877c.41-.35 1-.456 1.573-.133l11.062 7.866z" fill="#33CCFF"/>
                  <path d="M17.183 15.39L6.12 23.256c-.573.323-1.163.217-1.572-.133L14.73 12.937l2.453 2.453z" fill="#005F9E"/>
                  <path d="M21.39 12l-4.207 2.42-2.453-2.42 2.453-2.42L21.39 12c.813.468.813 1.232 0 1.7z" fill="#E5A93C"/>
                </svg>
              </div>
              <div className={styles.storeText}>
                <span className={styles.storeSmall}>Em breve no</span>
                <span className={styles.storeName}>Google Play</span>
              </div>
            </a>
          </div>

          {/* Social Proof & Quantitative Proof */}
          <div className={styles.metricsBar}>
            <div className={styles.metricItem}>
              <span className={styles.metricNum}>+15.000</span>
              <span className={styles.metricLabel}>Homens evoluindo sua presença e estilo</span>
            </div>

            <div className={styles.metricItem}>
              <span className={styles.metricNum} style={{ display: "flex", alignItems: "center", gap: "6px" }}>
                4.9 <Star size={20} fill="#E5A93C" color="#E5A93C" />
              </span>
              <span className={styles.metricLabel}>Avaliação média com alto índice de satisfação</span>
            </div>

            <div className={styles.metricItem}>
              <span className={styles.metricNum} style={{ display: "flex", alignItems: "center", gap: "6px" }}>
                100% <ShieldCheck size={20} color="var(--neon-primary)" />
              </span>
              <span className={styles.metricLabel}>Conteúdo prático, sem fórmulas mágicas</span>
            </div>
          </div>
        </div>

        {/* Right Column: Interactive Phone Mockup */}
        <div className={styles.heroRight}>
          <PhoneMockup />
        </div>
      </div>
    </section>
  );
}
