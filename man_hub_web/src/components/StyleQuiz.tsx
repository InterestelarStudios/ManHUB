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
    title: "1. Qual é a sua prioridade máxima de evolução hoje?",
    options: [
      {
        key: "A",
        label: "Elevar minha autoridade e presença profissional em reuniões e negócios",
        track: "Alfaiataria & Postura",
      },
      {
        key: "B",
        label: "Descobrir o corte de cabelo e formato de barba exatos para meu rosto",
        track: "Visagismo Facial",
      },
      {
        key: "C",
        label: "Encontrar meu perfume de assinatura e aprender a fixar por 12 horas",
        track: "Perfumaria de Nicho",
      },
      {
        key: "D",
        label: "Montar um guarda-roupa inteligente e parar de gastar dinheiro à toa",
        track: "Guarda-Roupa Cápsula",
      },
    ],
  },
  {
    id: 2,
    title: "2. Como você descreveria a estrutura do seu rosto?",
    options: [
      {
        key: "A",
        label: "Mandíbula bem definida e linhas angulares (Quadrado / Retangular)",
        track: "Harmonia Angular",
      },
      {
        key: "B",
        label: "Maçãs do rosto largas e queixo afilado (Diamante)",
        track: "Equilíbrio Lateral",
      },
      {
        key: "C",
        label: "Proporções equilibradas e contorno suave (Oval)",
        track: "Versatilidade Clássica",
      },
      {
        key: "D",
        label: "Linhas suaves com largura e comprimento similares (Redondo)",
        track: "Alongamento Vertical",
      },
    ],
  },
  {
    id: 3,
    title: "3. Qual estética melhor traduz a sua rotina?",
    options: [
      {
        key: "A",
        label: "Smart Casual moderno: blazer desestruturado, camisas de linho e alfaiataria",
        track: "Elegância Contemporânea",
      },
      {
        key: "B",
        label: "Minimalista atemporal: paleta neutra (preto, off-white, marinho e grafite)",
        track: "Minimalismo Sóbrio",
      },
      {
        key: "C",
        label: "Clássico formal: costumes bem cortados, sapatos de couro e gravatas sóbrias",
        track: "Autoridade Tradicional",
      },
      {
        key: "D",
        label: "Urbano refinado: jeans nobre, camisetas de gramatura alta e sneakers premium",
        track: "Casual High-End",
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
                    <span className={styles.diagLabel}>Foco Imediato</span>
                    <span className={styles.diagValue}>{answers[0] || "Alfaiataria & Imagem"}</span>
                  </div>

                  <div className={styles.diagItem}>
                    <span className={styles.diagLabel}>Harmonia Facial</span>
                    <span className={styles.diagValue}>{answers[1] || "Alinhamento de Mandíbula"}</span>
                  </div>

                  <div className={styles.diagItem}>
                    <span className={styles.diagLabel}>Estilo Recomendado</span>
                    <span className={styles.diagValue}>{answers[2] || "Elegância Smart"}</span>
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
