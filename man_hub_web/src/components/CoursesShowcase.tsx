"use client";

import { useState, useEffect } from "react";
import styles from "./CoursesShowcase.module.css";
import Image from "next/image";
import Link from "next/link";
import { Clock, Layers, ArrowRight, PlayCircle, Sparkles } from "lucide-react";
import { db } from "@/lib/firebase";
import { collection, onSnapshot } from "firebase/firestore";

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
  price?: number;
}

const DEFAULT_COURSES: Course[] = [
  {
    id: "e0ee6636-cea6-4f59-8242-6b7270f8254d",
    category: "Estilo & Presença",
    title: "O Homem Bem-Vestido",
    subtitle: "Alfaiataria, Proporção e Caimento",
    description:
      "Aprenda a ciência visual da vestimenta masculina. Descubra como acertar caimentos, equilibrar silhuetas e montar um guarda-roupa versátil de alta autoridade.",
    duration: "5 horas",
    modulesCount: 11,
    imageUrl:
      "https://images.unsplash.com/photo-1593032465175-481ac7f401a0?q=80&w=800&auto=format&fit=crop",
    price: 249.9,
    topics: [
      "Caimento exato de ombros, mangas e barras",
      "Equilíbrio de proporção e silhueta em 'V'",
      "Decodificação dos dress codes oficiais",
      "Montagem de guarda-roupa funcional e atemporal",
    ],
  },
  {
    id: "f47a8291-3c1e-49fb-9de8-18e329ba4182",
    category: "Autocuidado & Imagem",
    title: "Cuidados com Pele, Cabelo e Barba",
    subtitle: "Harmonia Facial e Autocuidado de Alto Padrão",
    description:
      "O guia definitivo para transformar o seu visual. Saiba qual corte e barba alinham com a estrutura óssea do seu rosto e estabeleça uma rotina prática.",
    duration: "4.5 horas",
    modulesCount: 13,
    imageUrl:
      "https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?q=80&w=800&auto=format&fit=crop",
    price: 79.9,
    topics: [
      "Mapeamento geométrico e proporções faciais",
      "Harmonia de corte de cabelo e barba na mandíbula",
      "Rotina de skincare masculina em 3 passos",
      "Controle de oleosidade e prevenção de foliculite",
    ],
  },
  {
    id: "a7e14d9b-83c6-4e5a-bb44-67290f11ac38",
    category: "Presença & Assinatura",
    title: "Perfumaria Masculina e Assinatura Olfativa",
    subtitle: "A Arte do Perfume e Assinatura Olfativa",
    description:
      "Aprenda a decifrar a pirâmide olfativa e escolha fragrâncias marcantes com fixação prolongada para trabalho, calor, noites e momentos decisivos.",
    duration: "3.5 horas",
    modulesCount: 12,
    imageUrl:
      "https://images.unsplash.com/photo-1523293182086-7651a899d37f?q=80&w=800&auto=format&fit=crop",
    price: 159.9,
    topics: [
      "Pirâmide olfativa (saída, coração e fundo)",
      "Seleção de perfumes para calor vs. noites frias",
      "Pontos estratégicos de aplicação e projeção",
      "Notas e referências validadas por especialistas",
    ],
  },
];

interface CoursesShowcaseProps {
  onBuyCourse?: (courseId: string, courseTitle: string) => void;
}

export default function CoursesShowcase({ onBuyCourse }: CoursesShowcaseProps) {
  const [courses, setCourses] = useState<Course[]>(DEFAULT_COURSES);

  useEffect(() => {
    try {
      const unsubscribe = onSnapshot(
        collection(db, "trainings"),
        (snapshot) => {
          if (!snapshot.empty) {
            const list: Course[] = snapshot.docs.map((docSnap) => {
              const data = docSnap.data();

              let topics: string[] = [];
              if (data.whatYouWillLearn && typeof data.whatYouWillLearn === "string") {
                topics = data.whatYouWillLearn
                  .split("\n")
                  .map((s: string) => s.replace(/^[•\-\*]\s*/, "").trim())
                  .filter(Boolean)
                  .slice(0, 4);
              }

              if (topics.length === 0 && Array.isArray(data.modules)) {
                topics = data.modules
                  .map((m: any) => (m.title ? String(m.title).trim() : ""))
                  .filter(Boolean)
                  .slice(0, 4);
              }

              if (topics.length === 0) {
                topics = [
                  "Aulas imersivas em formato stories",
                  "Material didático objetivo e prático",
                  "Acesso vitalício e atualizações",
                ];
              }

              const coverImg =
                data.coverImageUrl ||
                data.imageUrl ||
                "https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?q=80&w=800&auto=format&fit=crop";

              const modulesCount = Array.isArray(data.modules)
                ? data.modules.length
                : typeof data.modulesCount === "number"
                ? data.modulesCount
                : 10;

              return {
                id: docSnap.id,
                title: data.title || "Treinamento Oficial",
                subtitle: data.subtitle || "",
                category: data.category || "Desenvolvimento Masculino",
                description:
                  data.description ||
                  "Treinamento prático e imersivo em formato stories para acelerar sua evolução.",
                duration: data.duration || "4 horas",
                modulesCount,
                imageUrl: coverImg,
                topics,
                price: typeof data.price === "number" ? data.price : 97,
              };
            });

            // Ordena mantendo consistência de exibição
            setCourses(list);
          }
        },
        (error) => {
          console.warn("Aviso ao sincronizar treinamentos do Firestore:", error);
        }
      );

      return () => unsubscribe();
    } catch (err) {
      console.warn("Erro ao configurar listener do Firestore:", err);
    }
  }, []);

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
          {courses.map((course) => (
            <Link
              key={course.id}
              href={`/treinamentos/${course.id}`}
              className={styles.courseCardLink}
              title={`Ver detalhes do treinamento: ${course.title}`}
            >
              <div className={styles.courseCard}>
                <div className={styles.cardImageWrap}>
                  <Image
                    src={course.imageUrl}
                    alt={course.title}
                    width={600}
                    height={400}
                    className={styles.cardImage}
                    unoptimized={!course.imageUrl.includes("images.unsplash.com")}
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
                      <span>Stories</span>
                    </div>
                  </div>

                  <h3 className={styles.courseTitle}>{course.title}</h3>
                  <p className={styles.courseDesc}>{course.description}</p>

                  <ul className={styles.topicsList}>
                    {course.topics.slice(0, 2).map((topic, idx) => (
                      <li key={idx} className={styles.topicItem}>
                        <span className={styles.topicDot} />
                        <span>{topic}</span>
                      </li>
                    ))}
                  </ul>

                  <div className={styles.cardFooter}>
                    <span className={styles.interactiveTag}>
                      {course.price
                        ? `R$ ${course.price.toFixed(2).replace(".", ",")} vitalício`
                        : "Acesso Vitalício"}
                    </span>
                    <span className={styles.openCourseBtn}>
                      <span>Ver Aulas & Detalhes</span>
                      <ArrowRight size={14} />
                    </span>
                  </div>
                </div>
              </div>
            </Link>
          ))}
        </div>

        {/* Botão Ver Todos os Treinamentos */}
        <div className={styles.viewAllWrap}>
          <Link href="/treinamentos" className={styles.viewAllBtn}>
            <Sparkles size={18} />
            <span>Ver Todos os Treinamentos</span>
            <ArrowRight size={18} />
          </Link>
        </div>
      </div>
    </section>
  );
}

