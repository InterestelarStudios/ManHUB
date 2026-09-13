import styles from "./Pillars.module.css";
import { Scissors, Shirt, Sparkles, Compass, CheckCircle2 } from "lucide-react";

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
    icon: <Scissors size={26} />,
    title: "Visagismo Facial & Autocuidado",
    description:
      "Descubra a geometria do seu rosto e elimine a dúvida ao sentar na cadeira do barbeiro. Saiba exatamente qual corte e formato de barba realçam sua estrutura óssea.",
    highlights: [
      "Identificação do formato facial (Diamante, Quadrado, Oval, etc.)",
      "Projeção e alinhamento de barba para formato de mandíbula",
      "Skincare masculino minimalista de 3 passos sem complicação",
      "Tratamento de pele, poros e prevenção de oleosidade",
    ],
  },
  {
    number: "02",
    icon: <Shirt size={26} />,
    title: "Alfaiataria, Caimento & Silhueta",
    description:
      "A roupa mais cara do mundo parece barata se o caimento estiver errado. Aprenda a regra do acrômio, linhas verticais e a teoria das cores para qualquer ocasião.",
    highlights: [
      "Acrômio, caimento de ombro e silhueta em 'V'",
      "Decodificação dos 5 dress codes (do casual ao Black Tie)",
      "Cores neutras, contrastes e guarda-roupa cápsula",
      "Guia prático de tecidos nobres e longevidade das peças",
    ],
  },
  {
    number: "03",
    icon: <Sparkles size={26} />,
    title: "Perfumaria de Assinatura & Niche",
    description:
      "O perfume é sua impressão digital invisível. Entenda a pirâmide olfativa, notas de saída a fundo e descubra fragrâncias com projeção e fixação de até 12 horas.",
    highlights: [
      "Pirâmide olfativa completa e famílias aromáticas",
      "Seleção ideal para clima tropical, frio, trabalho e encontros",
      "Pontos de pulsação e técnicas de aplicação para máxima fixação",
      "Biblioteca olfativa com notas e referências do Fragrantica",
    ],
  },
  {
    number: "04",
    icon: <Compass size={26} />,
    title: "Postura, Presença & Mentalidade",
    description:
      "A transformação que começa no espelho ganha força na sua atitude diária. Desenvolva autoconfiança inabalável, comunicação assertiva e respeito onde você pisar.",
    highlights: [
      "Linguagem corporal de autoridade natural e contato visual",
      "Comunicação firme, voz ressonante e dicção clara",
      "Disciplina, rotina de treino e condicionamento físico",
      "Filosofia de homens ajudando homens a evoluírem",
    ],
  },
];

export default function Pillars() {
  return (
    <section id="pilares" className={styles.pillarsSection}>
      <div className="container">
        <div className={styles.headerWrap}>
          <span className="badge-neon">Fundamentos Inabaláveis</span>
          <h2 className={styles.sectionTitle}>
            Os 4 Pilares da Nova <span className="text-gradient">Presença Masculina</span>
          </h2>
          <p className={styles.sectionSubtitle}>
            Desenvolvido por especialistas em imagem, alfaiataria e comportamento para entregar um método
            estruturado de evolução integral, sem teorias vazias.
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
