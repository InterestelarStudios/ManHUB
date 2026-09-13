import styles from "./CoursesShowcase.module.css";
import Image from "next/image";
import { Clock, Layers, ArrowRight, PlayCircle } from "lucide-react";

interface Course {
  id: string;
  category: string;
  title: string;
  subtitle: string;
  description: string;
  duration: string;
  modulesCount: number;
  imageUrl: string;
  topics: string[];
}

const COURSES: Course[] = [
  {
    id: "homem-bem-vestido",
    category: "Estilo & Alfaiataria",
    title: "O Homem Bem-Vestido",
    subtitle: "Alfaiataria, Proporção e Caimento",
    description:
      "Aprenda a ciência visual da vestimenta masculina. Descubra como acertar caimentos, equilibrar silhuetas e montar um guarda-roupa versátil de alta autoridade.",
    duration: "5 horas",
    modulesCount: 6,
    imageUrl:
      "https://images.unsplash.com/photo-1593032465175-481ac7f401a0?q=80&w=800&auto=format&fit=crop",
    topics: [
      "Caimento exato de ombros, mangas e barras",
      "Equilíbrio de proporção e silhueta em 'V'",
      "Decodificação dos 5 dress codes oficiais",
      "Montagem de guarda-roupa cápsula funcional",
    ],
  },
  {
    id: "pele-cabelo-barba",
    category: "Visagismo Facial",
    title: "Pele, Cabelo & Barba",
    subtitle: "Visagismo e Autocuidado de Alto Padrão",
    description:
      "O guia definitivo para transformar o seu visual facial. Saiba qual corte e barba alinham com a estrutura óssea do seu rosto e estabeleça um skincare prático.",
    duration: "4.5 horas",
    modulesCount: 5,
    imageUrl:
      "https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?q=80&w=800&auto=format&fit=crop",
    topics: [
      "Mapeamento geométrico do formato facial",
      "Harmonia de corte de cabelo e barba na mandíbula",
      "Rotina de skincare masculina em 3 passos",
      "Controle de oleosidade e prevenção de foliculite",
    ],
  },
  {
    id: "perfumaria-masculina",
    category: "Perfumaria & Assinatura",
    title: "Guia de Perfumaria Masculina",
    subtitle: "A Arte do Perfume e Assinatura Olfativa",
    description:
      "Aprenda a decifrar a pirâmide olfativa e escolha fragrâncias marcantes com fixação prolongada para trabalho, calor, noites e momentos decisivos.",
    duration: "4 horas",
    modulesCount: 6,
    imageUrl:
      "https://images.unsplash.com/photo-1523293182086-7651a899d37f?q=80&w=800&auto=format&fit=crop",
    topics: [
      "Pirâmide olfativa (saída, coração e fundo)",
      "Seleção de perfumes para calor vs. noites frias",
      "Pontos estratégicos de aplicação e projeção",
      "Notas e referências validadas pelo Fragrantica",
    ],
  },
];

interface CoursesShowcaseProps {
  onBuyCourse?: (courseId: string, courseTitle: string) => void;
}

export default function CoursesShowcase({ onBuyCourse }: CoursesShowcaseProps) {
  return (
    <section id="treinamentos" className={styles.coursesSection}>
      <div className="ambient-glow-pill" style={{ top: "30%", right: "-10%" }} />

      <div className="container">
        <div className={styles.headerWrap}>
          <span className="badge-gold">Trilhas Oficiais</span>
          <h2 className={styles.sectionTitle}>
            Treinamentos em <span className="text-gradient">Formato Stories</span>
          </h2>
          <p className={styles.sectionSubtitle}>
            Aulas dinâmicas, visuais e com alta retenção. Nada de vídeos longos e cansativos: absorva
            conhecimento de alto impacto em cards objetivos e salve suas telas favoritas.
          </p>
        </div>

        <div className={styles.coursesGrid}>
          {COURSES.map((course) => (
            <div key={course.id} className={styles.courseCard}>
              <div className={styles.cardImageWrap}>
                <Image
                  src={course.imageUrl}
                  alt={course.title}
                  width={600}
                  height={400}
                  className={styles.cardImage}
                />
                <div className={styles.cardOverlay} />
                <span className={styles.categoryBadge}>{course.category}</span>
              </div>

              <div className={styles.cardBody}>
                <div className={styles.metaRow}>
                  <div className={styles.metaItem}>
                    <Clock size={14} color="var(--neon-primary)" />
                    <span>{course.duration}</span>
                  </div>
                  <div className={styles.metaItem}>
                    <Layers size={14} color="var(--neon-primary)" />
                    <span>{course.modulesCount} Módulos</span>
                  </div>
                  <div className={styles.metaItem}>
                    <PlayCircle size={14} color="var(--gold-accent)" />
                    <span>Em Stories</span>
                  </div>
                </div>

                <h3 className={styles.courseTitle}>{course.title}</h3>
                <p className={styles.courseDesc}>{course.description}</p>

                <ul className={styles.topicsList}>
                  {course.topics.map((topic, idx) => (
                    <li key={idx} className={styles.topicItem}>
                      <span className={styles.topicDot} />
                      <span>{topic}</span>
                    </li>
                  ))}
                </ul>

                <div className={styles.cardFooter}>
                  <span className={styles.interactiveTag}>R$ 97,00 vitalício</span>
                  <button
                    onClick={() => onBuyCourse?.(course.id, course.title)}
                    className={styles.openCourseBtn}
                    style={{ background: "transparent", border: "none" }}
                  >
                    <span>Comprar Curso</span>
                    <ArrowRight size={14} />
                  </button>
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}
