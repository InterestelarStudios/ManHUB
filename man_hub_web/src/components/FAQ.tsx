"use client";

import { useState } from "react";
import styles from "./FAQ.module.css";
import { ChevronDown } from "lucide-react";

interface FAQItem {
  question: string;
  answer: string;
}

const FAQS: FAQItem[] = [
  {
    question: "O Man Hub é indicado para quem não entende absolutamente nada de moda?",
    answer:
      "Sim, perfeitamente. O Man Hub não é sobre tendências passageiras de passarelas ou futilidades. É sobre a lógica prática e atemporal da proporção visual masculina: cortes de cabelo que valorizam seu rosto, camisas com o caimento certo no ombro, perfumes que fixam de verdade e postura de confiança.",
  },
  {
    question: "Preciso gastar muito dinheiro em roupas caras para aplicar o método?",
    answer:
      "Pelo contrário. Uma das principais vantagens do Man Hub é ensinar você a parar de gastar dinheiro à toa com roupas erradas. Você aprenderá a reconhecer caimentos impecáveis e tecidos duráveis até mesmo em marcas acessíveis, montando um guarda-roupa cápsula inteligente com poucas peças altamente combináveis.",
  },
  {
    question: "O aplicativo já está liberado para download nas lojas?",
    answer:
      "A plataforma web do Man Hub já está totalmente ativa com os treinamentos oficiais em formato Stories liberados. O aplicativo mobile nativo está em fase final de homologação técnica e revisão nas lojas Google Play e App Store. Você já pode criar sua conta e evoluir diretamente pelo navegador!",
  },
  {
    question: "Como funcionam os treinamentos em formato Stories?",
    answer:
      "Criamos uma metodologia visual pioneira inspirada no consumo ágil de stories: cada aula é dividida em cards visuais com ilustrações, fotos reais e explicações diretas de 20 a 40 segundos. Você absorve conhecimento em pausas no trabalho ou no trajeto sem precisar assistir a vídeos longos e monótonos.",
  },
  {
    question: "Posso favoritar telas e dicas específicas para consultar na hora das compras ou no barbeiro?",
    answer:
      "Com certeza! O app conta com o recurso exclusivo de 'Telas Salvas & Favoritos'. Enquanto assiste a qualquer aula, você pode tocar no ícone de marcador para salvar aquela tela específica (seja a foto de um corte, a fórmula do ombro ou a indicação de um perfume) e abri-la instantaneamente no seu perfil.",
  },
  {
    question: "O Man Hub tem relação com conteúdos de 'guru' ou masculinidade tóxica?",
    answer:
      "Não, repudiamos veementemente qualquer conteúdo tóxico, extremista ou de promessas milagrosas. O Man Hub é construído sob o lema 'Homens ajudando homens a evoluírem': focado em disciplina, respeito, elegância, maturidade e autocuidado genuíno.",
  },
];

export default function FAQ() {
  const [openIndex, setOpenIndex] = useState<number | null>(0);

  const toggle = (idx: number) => {
    setOpenIndex(openIndex === idx ? null : idx);
  };

  return (
    <section id="faq" className={styles.faqSection}>
      <div className="container">
        <div className={styles.headerWrap}>
          <span className="badge-neon">Esclarecimentos</span>
          <h2 className={styles.sectionTitle}>
            Perguntas <span className="text-gradient">Frequentes</span>
          </h2>
          <p className={styles.sectionSubtitle}>
            Tudo o que você precisa saber para iniciar sua jornada de evolução sem hesitação.
          </p>
        </div>

        <div className={styles.accordionWrap}>
          {FAQS.map((faq, idx) => {
            const isOpen = openIndex === idx;
            return (
              <div
                key={idx}
                className={`${styles.accordionItem} ${isOpen ? styles.itemActive : ""}`}
              >
                <button className={styles.accordionTrigger} onClick={() => toggle(idx)}>
                  <span>{faq.question}</span>
                  <ChevronDown
                    size={20}
                    className={`${styles.chevronIcon} ${isOpen ? styles.chevronOpen : ""}`}
                  />
                </button>

                {isOpen && (
                  <div className={styles.accordionContent}>
                    <p>{faq.answer}</p>
                  </div>
                )}
              </div>
            );
          })}
        </div>
      </div>
    </section>
  );
}
