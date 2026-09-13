"use client";

import { useState } from "react";
import styles from "./AppExperience.module.css";
import Image from "next/image";
import { PlayCircle, Bookmark, Sparkles, CheckCircle2, ArrowRight } from "lucide-react";

interface TabExperience {
  id: string;
  tabLabel: string;
  icon: React.ReactNode;
  tag: string;
  title: string;
  description: string;
  benefits: string[];
  image: string;
  cardChip: string;
  cardTitle: string;
  cardSubtitle: string;
}

const EXPERIENCES: TabExperience[] = [
  {
    id: "stories",
    tabLabel: "Stories Interativos",
    icon: <PlayCircle size={18} />,
    tag: "Metodologia Ágil",
    title: "Aprenda no Seu Ritmo em Aulas de 30 Segundos",
    description:
      "Nada de cursos de 40 horas que você nunca termina. O Man Hub quebrou o conhecimento em micro-cards visuais de alto impacto, com imagens reais e diagramas fáceis de aplicar.",
    benefits: [
      "Retenção de conhecimento 3x superior ao formato tradicional em vídeo",
      "Perfeito para consumir no trânsito, na academia ou no intervalo do trabalho",
      "Progress bar dinâmica para você saber exatamente quanto falta para concluir",
    ],
    image:
      "https://images.unsplash.com/photo-1593032465175-481ac7f401a0?q=80&w=800&auto=format&fit=crop",
    cardChip: "Formato Stories",
    cardTitle: "Regra do Caimento de Ombros",
    cardSubtitle: "Aula 2 • Módulo Fundamentos",
  },
  {
    id: "bookmarks",
    tabLabel: "Telas Salvas & Favoritos",
    icon: <Bookmark size={18} />,
    tag: "Recurso Exclusivo",
    title: "Guarde as Melhores Dicas Direto no Seu Bolso",
    description:
      "Gostou da fórmula de um corte, da regra de comprimento da calça ou da indicação de um perfume? Salve a tela específica com um toque e abra no barbeiro ou provador.",
    benefits: [
      "Bookmark com miniatura visual exata da dica favoritada",
      "Acesso instantâneo mesmo offline para mostrar na loja de roupas",
      "Organização automática por curso, módulo e tipo de conteúdo",
    ],
    image:
      "https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?q=80&w=800&auto=format&fit=crop",
    cardChip: "Tela Salva",
    cardTitle: "Fade com Linha Retas na Barba",
    cardSubtitle: "Favoritado em Treinamento de Visagismo",
  },
  {
    id: "anamnese",
    tabLabel: "Diagnóstico Facial",
    icon: <Sparkles size={18} />,
    tag: "Inteligência Prática",
    title: "Recomendações Moldadas para a Sua Estrutura",
    description:
      "O app considera o seu formato de rosto, biotipo físico, altura e preferências de estilo para indicar as melhores escolhas para o seu perfil único.",
    benefits: [
      "Elimine a dúvida sobre quais peças e cortes combinam com seu corpo",
      "Paleta de cores recomendada baseada no seu contraste pessoal",
      "Evolução contínua conforme suas metas e rotina profissional",
    ],
    image:
      "https://images.unsplash.com/photo-1523293182086-7651a899d37f?q=80&w=800&auto=format&fit=crop",
    cardChip: "Diagnóstico Ativo",
    cardTitle: "Perfil Diamante • Silhueta Atlética",
    cardSubtitle: "38 recomendações personalizadas ativas",
  },
];

export default function AppExperience() {
  const [activeTab, setActiveTab] = useState(0);
  const current = EXPERIENCES[activeTab];

  return (
    <section id="app" className={styles.experienceSection}>
      <div className="container">
        <div className={styles.headerWrap}>
          <span className="badge-neon">Inovação em Cada Detalhe</span>
          <h2 className={styles.sectionTitle}>
            Uma Experiência Feita Para <span className="text-gradient">Homens Modernos</span>
          </h2>
          <p className={styles.sectionSubtitle}>
            Criado do zero para ser direto ao ponto, elegante e aplicável na vida real.
          </p>
        </div>

        {/* Tab Selector */}
        <div className={styles.tabsBar}>
          {EXPERIENCES.map((exp, idx) => (
            <button
              key={exp.id}
              className={`${styles.tabBtn} ${activeTab === idx ? styles.tabActive : ""}`}
              onClick={() => setActiveTab(idx)}
            >
              {exp.icon}
              <span>{exp.tabLabel}</span>
            </button>
          ))}
        </div>

        {/* Content Grid */}
        <div className={styles.tabContentGrid}>
          <div className={styles.contentLeft}>
            <span className={styles.contentTag}>{current.tag}</span>
            <h3 className={styles.contentTitle}>{current.title}</h3>
            <p className={styles.contentDesc}>{current.description}</p>

            <ul className={styles.benefitList}>
              {current.benefits.map((b, i) => (
                <li key={i} className={styles.benefitItem}>
                  <CheckCircle2 size={18} className={styles.checkIcon} />
                  <span>{b}</span>
                </li>
              ))}
            </ul>

            <div style={{ marginTop: "16px" }}>
              <a href="#download" className="btn btn-primary">
                <span>Experimentar no App</span>
                <ArrowRight size={16} />
              </a>
            </div>
          </div>

          <div className={styles.contentRight}>
            <div className={styles.previewCard}>
              <div className={styles.previewHeader}>
                <span className={styles.previewChip}>{current.cardChip}</span>
                <span style={{ fontSize: "11px", color: "var(--neon-primary)", fontWeight: 700 }}>
                  MAN HUB APP
                </span>
              </div>

              <div className={styles.previewImgWrap}>
                <Image
                  src={current.image}
                  alt={current.cardTitle}
                  width={600}
                  height={400}
                  className={styles.previewImg}
                />
              </div>

              <div>
                <h4 style={{ fontSize: "18px", fontWeight: 700, color: "#fff", marginBottom: "4px" }}>
                  {current.cardTitle}
                </h4>
                <p style={{ fontSize: "13px", color: "var(--text-secondary)" }}>
                  {current.cardSubtitle}
                </p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}
