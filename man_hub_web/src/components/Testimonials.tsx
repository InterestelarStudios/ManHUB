import styles from "./Testimonials.module.css";
import { Star } from "lucide-react";

interface Testimonial {
  name: string;
  role: string;
  initials: string;
  quote: string;
}

const TESTIMONIALS: Testimonial[] = [
  {
    name: "Rodrigo Alencar",
    role: "Diretor Comercial, 36 anos",
    initials: "RA",
    quote:
      "“Antes eu gastava milhares de reais em camisas e blazers que pareciam desajeitados em mim. O módulo de alfaiataria e a regra do acrômio mudaram meu posicionamento em reuniões com clientes. O respeito imediato é perceptível.”",
  },
  {
    name: "Lucas Menezes",
    role: "Fundador de Tech & Empreendedor, 31 anos",
    initials: "LM",
    quote:
      "“A análise de visagismo me tirou do mesmo corte que eu usava há 10 anos. Pela primeira vez o barbeiro entendeu exatamente o que fazer. O formato em stories rápidos é viciante para quem tem a agenda corrida.”",
  },
  {
    name: "Eduardo Siqueira",
    role: "Advogado Tributarista, 42 anos",
    initials: "ES",
    quote:
      "“O Guia de Perfumaria é fora de série. Parei de comprar perfumes por impulso e hoje tenho 3 assinaturas bem definidas para calor, reuniões e eventos noturnos. Recomendo para qualquer homem que busca elegância.”",
  },
];

export default function Testimonials() {
  return (
    <section id="depoimentos" className={styles.testimonialsSection}>
      <div className="container">
        <div className={styles.headerWrap}>
          <span className="badge-neon">Transformações Reais</span>
          <h2 className={styles.sectionTitle}>
            O Que Dizem Quem Já <span className="text-gradient">Elevou o Padrão</span>
          </h2>
          <p className={styles.sectionSubtitle}>
            Resultados tangíveis na imagem, na postura profissional e no respeito diário.
          </p>
        </div>

        <div className={styles.grid}>
          {TESTIMONIALS.map((t, idx) => (
            <div key={idx} className={styles.card}>
              <div className={styles.starsRow}>
                {[...Array(5)].map((_, s) => (
                  <Star key={s} size={18} fill="#E5A93C" color="#E5A93C" />
                ))}
              </div>

              <p className={styles.quoteText}>{t.quote}</p>

              <div className={styles.authorRow}>
                <div className={styles.avatarCircle}>{t.initials}</div>
                <div className={styles.authorInfo}>
                  <span className={styles.authorName}>{t.name}</span>
                  <span className={styles.authorRole}>{t.role}</span>
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}
