"use client";

import { useState } from "react";
import styles from "./StyleQuiz.module.css";
import { Sparkles, CheckCircle2, ArrowRight, RotateCcw } from "lucide-react";

interface Question {
  id: number;
  title: string;
  options: { label: string; key: string; track: string }[];
}

const QUESTIONS: Question[] = [
  {
    id: 1,
    title: "1. O que mais tem travado a sua evolução hoje?",
    options: [
      {
        key: "A",
        label: "Sinto que minha imagem atual não transmite o respeito, a liderança e a maturidade que possuo.",
        track: "Transformação de Imagem",
      },
      {
        key: "B",
        label: "Dificuldade com consistência, autodomínio e clareza de princípios para agir como um homem de valor.",
        track: "Homem de Valor & Disciplina",
      },
      {
        key: "C",
        label: "Postura tímida, insegurança ao falar ou falta de presença marcante em ambientes exigentes.",
        track: "Presença & Postura Magnética",
      },
      {
        key: "D",
        label: "Estar rodeado de companhias acomodadas que não têm ambição e puxam meus padrões para baixo.",
        track: "Ambiente de Alta Performance",
      },
    ],
  },
  {
    id: 2,
    title: "2. Em qual ambiente você mais precisa impor respeito e autoridade natural?",
    options: [
      {
        key: "A",
        label: "Em reuniões profissionais, negociações estratégicas e fechamento de negócios.",
        track: "Autoridade em Negócios",
      },
      {
        key: "B",
        label: "Em eventos sociais e encontros onde a primeira impressão define o jogo.",
        track: "Magnetismo Social & Conquista",
      },
      {
        key: "C",
        label: "Diante de si mesmo: vencendo a preguiça, construindo foco e sustentando sua palavra.",
        track: "Autodomínio & Firmeza",
      },
      {
        key: "D",
        label: "Na liderança da sua equipe, família ou círculo de confiança como uma referência inabalável.",
        track: "Liderança de Princípios",
      },
    ],
  },
  {
    id: 3,
    title: "3. Qual é o seu objetivo principal nos próximos 6 meses?",
    options: [
      {
        key: "A",
        label: "Passar por um upgrade completo de imagem, porte físico e elegância masculina.",
        track: "Upgrade Completo de Imagem",
      },
      {
        key: "B",
        label: "Forjar uma rotina inegociável de disciplina, condicionamento e produtividade diária.",
        track: "Forja de Hábitos de Elite",
      },
      {
        key: "C",
        label: "Elevar minha comunicação não-verbal, poder de oratória e influência entre pessoas de alto nível.",
        track: "Comunicação de Alto Nível",
      },
      {
        key: "D",
        label: "Romper definitivamente com a mediocridade e caminhar entre os grandes lobos.",
        track: "Mentalidade de Matilha",
      },
    ],
  },
];

export default function StyleQuiz() {
  const [currentStep, setCurrentStep] = useState(0);
  const [answers, setAnswers] = useState<string[]>([]);
  const isFinished = currentStep >= QUESTIONS.length;

  const handleSelectOption = (track: string) => {
    setAnswers([...answers, track]);
    setCurrentStep(currentStep + 1);
  };

  const handleRestart = () => {
    setAnswers([]);
    setCurrentStep(0);
  };

  return (
    <section id="diagnostico" className={styles.quizSection}>
      <div className="container">
        <div className={styles.quizContainer}>
          <div className={styles.headerWrap}>
            <span className="badge-neon">
              <Sparkles size={13} />
              Diagnóstico Instantâneo
            </span>
            <h2 className={styles.sectionTitle}>
              Descubra seu <span className="text-gradient">Primeiro Ponto de Evolução</span>
            </h2>
            <p className={styles.sectionSubtitle}>
              Responda a 3 perguntas rápidas para receber uma prévia de recomendação personalizada do método Man Hub.
            </p>
          </div>

          <div className={styles.quizCard}>
            {!isFinished ? (
              <>
                <div className={styles.progressBarTrack}>
                  <div
                    className={styles.progressBarFill}
                    style={{ width: `${((currentStep + 1) / QUESTIONS.length) * 100}%` }}
                  />
                </div>

                <div className={styles.stepIndicator}>
                  Etapa {currentStep + 1} de {QUESTIONS.length}
                </div>

                <h3 className={styles.questionTitle}>{QUESTIONS[currentStep].title}</h3>

                <div className={styles.optionsGrid}>
                  {QUESTIONS[currentStep].options.map((opt) => (
                    <button
                      key={opt.key}
                      className={styles.optionBtn}
                      onClick={() => handleSelectOption(opt.track)}
                    >
                      <span className={styles.optionKey}>{opt.key}</span>
                      <span>{opt.label}</span>
                    </button>
                  ))}
                </div>
              </>
            ) : (
              <div className={styles.resultContent}>
                <div className={styles.resultIconBadge}>
                  <CheckCircle2 size={36} />
                </div>

                <h3 className={styles.resultTitle}>Pré-Diagnóstico Pronto</h3>
                <p className={styles.resultSubtitle}>
                  Com base nas suas respostas, nossa metodologia identificou os pilares essenciais para destravar sua presença:
                </p>

                <div className={styles.diagnosisBox}>
                  <div className={styles.diagItem}>
                    <span className={styles.diagLabel}>Pilar Estratégico</span>
                    <span className={styles.diagValue}>{answers[0] || "Transformação de Imagem"}</span>
                  </div>

                  <div className={styles.diagItem}>
                    <span className={styles.diagLabel}>Área de Domínio</span>
                    <span className={styles.diagValue}>{answers[1] || "Autoridade em Negócios"}</span>
                  </div>

                  <div className={styles.diagItem}>
                    <span className={styles.diagLabel}>Próximo Nível</span>
                    <span className={styles.diagValue}>{answers[2] || "Upgrade Completo de Imagem"}</span>
                  </div>
                </div>

                <a href="#download" className="btn btn-primary" style={{ padding: "16px 36px" }}>
                  <span>Desbloquear Análise Completa no App</span>
                  <ArrowRight size={18} />
                </a>

                <button className={styles.restartBtn} onClick={handleRestart}>
                  <span style={{ display: "inline-flex", alignItems: "center", gap: "6px" }}>
                    <RotateCcw size={13} />
                    Refazer teste
                  </span>
                </button>
              </div>
            )}
          </div>
        </div>
      </div>
    </section>
  );
}
