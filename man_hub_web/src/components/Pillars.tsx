import styles from "./Pillars.module.css";
import { Sparkles, Shield, Trophy, Users, CheckCircle2 } from "lucide-react";

interface PillarItem {
  number: string;
  icon: React.ReactNode;
  title: string;
  description: string;
  highlights: string[];
}

const PILLARS: PillarItem[] = [
  {
    number: "01",
    icon: <Sparkles size={26} />,
    title: "Transformando sua Imagem",
    description:
      "A sua imagem é seu cartão de visitas imediato. Alinhe proporções corporais, corte, estilo e caimento para transmitir autoridade, elegância e respeito instantâneo.",
    highlights: [
      "Construção de uma identidade visual marcante e de alta liderança",
      "Domínio de caimento, proporções da silhueta e paleta de cores",
      "Cuidado estético, harmonia facial e higiene pessoal estratégica",
      "Do casual refinado ao traje formal sem cometer erros básicos",
    ],
  },
  {
    number: "02",
    icon: <Shield size={26} />,
    title: "Ensinando a Ser um Homem de Valor",
    description:
      "Princípios inegociáveis, palavra sustentada e caráter forjado na disciplina. Um homem de alto valor governa a si mesmo antes de liderar qualquer outra pessoa.",
    highlights: [
      "Maturidade emocional, integridade inabalável e firmeza moral",
      "Autodomínio sobre impulsos e superação definitiva da procrastinação",
      "Clareza de propósito, determinação e foco brutal em objetivos",
      "Construção de patrimônio, respeito familiar e legado duradouro",
    ],
  },
  {
    number: "03",
    icon: <Trophy size={26} />,
    title: "Presença de Alto Nível",
    description:
      "Magnetismo natural e respeito sem precisar forçar a barra. Domine a linguagem corporal, postura firme e comunicação verbal que comandam qualquer ambiente.",
    highlights: [
      "Linguagem corporal de autoridade, tônus firme e contato visual",
      "Comunicação assertiva, voz ressonante e dicção clara",
      "Autoconfiança inabalável em negociações e situações de pressão",
      "Inteligência social para transitar com elegância em mesas de topo",
    ],
  },
  {
    number: "04",
    icon: <Users size={26} />,
    title: "Esteja Entre os Lobos Grandes",
    description:
      "Você é a média dos homens que tolera ao seu redor. Rompa com a mediocridade, cerque-se de homens que exigem o seu melhor e construa um círculo forte.",
    highlights: [
      "Mentalidade de matilha: homens fortes que puxam homens para cima",
      "Rompimento definitivo com amizades tóxicas e ambientes acomodados",
      "Acesso a networking qualificado, negócios e parcerias estratégicas",
      "Conexão diária com uma irmandade que busca excelência contínua",
    ],
  },
];

export default function Pillars() {
  return (
    <section id="pilares" className={styles.pillarsSection}>
      <div className="container">
        <div className={styles.headerWrap}>
          <span className="badge-neon">Academia Masculina</span>
          <h2 className={styles.sectionTitle}>
            Os 4 Pilares da Nova <span className="text-gradient">Presença Masculina</span>
          </h2>
          <p className={styles.sectionSubtitle}>
            Um método estruturado de evolução integral: transforme sua imagem, forje seus princípios
            e desenvolva a mentalidade dos homens que estão no topo.
          </p>
        </div>

        <div className={styles.grid}>
          {PILLARS.map((pillar) => (
            <div key={pillar.number} className={styles.pillarCard}>
              <div className={styles.cardTop}>
                <div className={styles.iconBox}>{pillar.icon}</div>
                <span className={styles.pillarNumber}>{pillar.number}</span>
              </div>

              <h3 className={styles.pillarTitle}>{pillar.title}</h3>
              <p className={styles.pillarDesc}>{pillar.description}</p>

              <ul className={styles.featuresList}>
                {pillar.highlights.map((item, idx) => (
                  <li key={idx} className={styles.featureItem}>
                    <CheckCircle2 size={16} className={styles.featureCheck} />
                    <span>{item}</span>
                  </li>
                ))}
              </ul>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}
