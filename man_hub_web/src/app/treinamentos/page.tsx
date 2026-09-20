"use client";

import React, { useState, useMemo } from "react";
import Link from "next/link";
import styles from "./Marketplace.module.css";
import { useTrainings } from "@/lib/hooks/useTrainings";
import { useAuth } from "@/lib/context/AuthContext";
import { useProgress } from "@/lib/context/ProgressContext";
import CheckoutModal from "@/components/CheckoutModal";
import {
  Search,
  Sparkles,
  Layers,
  Clock,
  BookOpen,
  CheckCircle2,
  Play,
  Lock,
  ArrowRight,
  X,
  Compass,
  Crown,
} from "lucide-react";

const STANDARD_CATEGORIES = [
  "Todos",
  "Jornada",
  "Estilo",
  "Visagismo",
  "Perfumes",
  "Skincare",
  "Corpo",
  "Comunicação",
];

export default function MarketplacePage() {
  const { trainings, loading } = useTrainings();
  const { hasAccessToTraining, isSubscribed } = useAuth();
  const { getProgress } = useProgress();

  const [selectedCategory, setSelectedCategory] = useState("Todos");
  const [searchQuery, setSearchQuery] = useState("");
  const [isCheckoutOpen, setIsCheckoutOpen] = useState(false);

  // Computa todas as categorias disponíveis
  const allCategories = useMemo(() => {
    const set = new Set<string>(STANDARD_CATEGORIES);
    trainings.forEach((t) => {
      if (t.category && t.category.trim()) {
        set.add(t.category.trim());
      }
      if (Array.isArray(t.categories)) {
        t.categories.forEach((c) => {
          if (c && c.trim()) set.add(c.trim());
        });
      }
    });
    return Array.from(set);
  }, [trainings]);

  // Filtra por categoria e busca
  const filteredTrainings = useMemo(() => {
    return trainings.filter((t) => {
      // 1. Filtro por Categoria
      const sel = selectedCategory.toUpperCase();
      let matchesCategory = sel === "TODOS";

      if (!matchesCategory) {
        if ((t.category || "").toUpperCase() === sel) {
          matchesCategory = true;
        } else if (
          Array.isArray(t.categories) &&
          t.categories.some((c) => c.toUpperCase() === sel)
        ) {
          matchesCategory = true;
        } else {
          // Fallback semântico inteligente
          const text = `${t.title} ${t.subtitle || ""} ${t.description || ""}`.toLowerCase();
          if (sel === "PERFUMES" && (text.includes("perfum") || text.includes("olfat"))) {
            matchesCategory = true;
          } else if (
            sel === "ESTILO" &&
            (text.includes("vestido") ||
              text.includes("estilo") ||
              text.includes("roupa") ||
              text.includes("alfaiataria"))
          ) {
            matchesCategory = true;
          } else if (
            sel === "VISAGISMO" &&
            (text.includes("visagismo") ||
              text.includes("rosto") ||
              text.includes("barba") ||
              text.includes("cabelo"))
          ) {
            matchesCategory = true;
          } else if (sel === "SKINCARE" && (text.includes("pele") || text.includes("skincare"))) {
            matchesCategory = true;
          } else if (sel === "JORNADA" && (text.includes("jornada") || text.includes("valor"))) {
            matchesCategory = true;
          } else if (
            sel === "CORPO" &&
            (text.includes("corpo") || text.includes("postura") || text.includes("treino"))
          ) {
            matchesCategory = true;
          } else if (
            sel === "COMUNICAÇÃO" &&
            (text.includes("comunicação") || text.includes("voz") || text.includes("oratória"))
          ) {
            matchesCategory = true;
          }
        }
      }

      if (!matchesCategory) return false;

      // 2. Filtro por Busca de Texto
      if (searchQuery.trim()) {
        const q = searchQuery.toLowerCase();
        const haystack = `${t.title} ${t.subtitle || ""} ${t.description || ""} ${
          t.whatYouWillLearn || ""
        }`.toLowerCase();
        return haystack.includes(q);
      }

      return true;
    });
  }, [trainings, selectedCategory, searchQuery]);

  return (
    <div className={styles.container}>
      {/* Hero Header */}
      <section className={styles.hero}>
        <div className={styles.badge}>
          <Sparkles size={14} />
          <span>Academia Man Hub • Catálogo Oficial</span>
        </div>

        <h1 className={styles.title}>
          Treinamentos & <span className={styles.titleHighlight}>Especializações</span>
        </h1>

        <p className={styles.subtitle}>
          Aulas dinâmicas e imersivas em formato de Stories, pensadas para o homem contemporâneo
          que busca autoridade, estilo magnético e evolução consistente.
        </p>
      </section>

      {/* Controls Bar: Busca e Categorias */}
      <section className={styles.controlsSection}>
        {/* Search Input */}
        <div className={styles.searchBox}>
          <Search size={18} className={styles.searchIcon} />
          <input
            type="text"
            placeholder="Buscar por título, assunto, especialidade..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            className={styles.searchInput}
          />
          {searchQuery && (
            <button
              onClick={() => setSearchQuery("")}
              className={styles.clearSearchBtn}
              aria-label="Limpar busca"
            >
              <X size={16} />
            </button>
          )}
        </div>

        {/* Categories Bar */}
        <div className={styles.categoriesWrapper}>
          {allCategories.map((cat) => {
            const isActive = selectedCategory.toLowerCase() === cat.toLowerCase();
            return (
              <button
                key={cat}
                className={`${styles.categoryBtn} ${isActive ? styles.active : ""}`}
                onClick={() => setSelectedCategory(cat)}
              >
                <span>{cat}</span>
              </button>
            );
          })}
        </div>
      </section>

      {/* Main Grid */}
      <main className={styles.contentSection}>
        <div className={styles.resultsHeader}>
          <span>
            Exibindo <strong>{filteredTrainings.length}</strong>{" "}
            {filteredTrainings.length === 1 ? "treinamento" : "treinamentos"}
          </span>
          {selectedCategory !== "Todos" && (
            <button
              onClick={() => setSelectedCategory("Todos")}
              style={{
                background: "transparent",
                border: "none",
                color: "var(--neon-primary)",
                fontSize: "12px",
                cursor: "pointer",
                fontWeight: 600,
              }}
            >
              Limpar filtro de categoria
            </button>
          )}
        </div>

        {filteredTrainings.length === 0 ? (
          <div className={styles.emptyState}>
            <div className={styles.emptyIcon}>
              <Compass size={28} />
            </div>
            <h3 className={styles.emptyTitle}>Nenhum treinamento encontrado</h3>
            <p className={styles.emptyText}>
              Não encontramos cursos para os critérios selecionados. Tente buscar por outros termos
              ou resetar os filtros.
            </p>
            <button
              className={styles.resetBtn}
              onClick={() => {
                setSelectedCategory("Todos");
                setSearchQuery("");
              }}
            >
              Ver Todos os Treinamentos
            </button>
          </div>
        ) : (
          <div className={styles.coursesGrid}>
            {filteredTrainings.map((course) => {
              const hasAccess = hasAccessToTraining(course.id);
              const progress = getProgress(course.id);
              const totalSessions = course.modules.reduce(
                (acc, m) => acc + m.sessions.length,
                0
              );
              const completedCount = progress?.completedSessionIds?.length || 0;
              const percent =
                totalSessions > 0
                  ? Math.min(100, Math.round((completedCount / totalSessions) * 100))
                  : 0;

              return (
                <Link
                  key={course.id}
                  href={`/treinamentos/${course.id}`}
                  className={styles.courseCard}
                >
                  <div className={styles.cardImageWrapper}>
                    {course.coverImageUrl ? (
                      <img
                        src={course.coverImageUrl}
                        alt={course.title}
                        className={styles.cardImage}
                      />
                    ) : (
                      <div
                        style={{
                          width: "100%",
                          height: "100%",
                          background: "#040D1A",
                          display: "flex",
                          alignItems: "center",
                          justifyContent: "center",
                        }}
                      >
                        <Compass size={32} style={{ color: "var(--neon-primary)" }} />
                      </div>
                    )}

                    <span className={styles.categoryTagOverlay}>
                      {course.category || "Especialização"}
                    </span>

                    {percent === 100 && (
                      <span className={styles.completedBadgeOverlay}>
                        <CheckCircle2 size={12} /> Concluído
                      </span>
                    )}
                  </div>

                  <div className={styles.cardBody}>
                    <h3 className={styles.cardTitle}>{course.title}</h3>
                    <p className={styles.cardDescription}>{course.description}</p>

                    <div className={styles.cardMeta}>
                      {course.duration && (
                        <div className={styles.cardMetaItem}>
                          <Clock size={14} style={{ color: "var(--neon-primary)" }} />
                          <span>{course.duration}</span>
                        </div>
                      )}
                      <div className={styles.cardMetaItem}>
                        <Layers size={14} style={{ color: "var(--neon-primary)" }} />
                        <span>{course.modules.length} Módulos</span>
                      </div>
                      <div className={styles.cardMetaItem}>
                        <BookOpen size={14} style={{ color: "var(--neon-primary)" }} />
                        <span>{totalSessions} Aulas</span>
                      </div>
                    </div>

                    {completedCount > 0 && (
                      <div className={styles.cardProgressBox}>
                        <div className={styles.cardProgressHeader}>
                          <span className={styles.cardProgressText}>
                            {completedCount}/{totalSessions} aulas
                          </span>
                          <span className={styles.cardProgressPercent}>{percent}%</span>
                        </div>
                        <div className={styles.progressBarTrack}>
                          <div
                            className={styles.progressBarFill}
                            style={{ width: `${percent}%` }}
                          />
                        </div>
                      </div>
                    )}

                    <div className={styles.cardFooter}>
                      {hasAccess ? (
                        <span className={styles.accessBadgeUnlocked}>
                          <CheckCircle2 size={12} /> Acesso Liberado
                        </span>
                      ) : (
                        <div className={styles.priceContainer}>
                          <span className={styles.priceValue}>
                            R$ {(course.price ?? 97.0).toFixed(2).replace(".", ",")}
                          </span>
                          <span className={styles.accessBadgeTrial}>
                            <Play size={10} /> 1º Módulo Grátis
                          </span>
                        </div>
                      )}

                      <span className={styles.cardActionLink}>
                        <span>{hasAccess ? "Acessar" : "Ver Detalhes"}</span>
                        <ArrowRight size={14} />
                      </span>
                    </div>
                  </div>
                </Link>
              );
            })}
          </div>
        )}

        {/* Pass Banner Promotion */}
        {!isSubscribed && (
          <section className={styles.passBanner}>
            <div className={styles.passBannerLeft}>
              <div className={styles.passBadge}>
                <Crown size={13} />
                <span>Man Hub Pass • Acesso Ilimitado</span>
              </div>
              <h2 className={styles.passTitle}>
                Desbloqueie todos os treinamentos em uma só assinatura
              </h2>
              <p className={styles.passText}>
                Com o <strong>Man Hub Pass</strong>, você tem acesso completo a todos os cursos
                existentes e a todas as novidades adicionadas semanalmente à plataforma. Cancele
                quando quiser sem taxas ocultas.
              </p>
            </div>

            <button
              className={styles.passBtn}
              onClick={() => setIsCheckoutOpen(true)}
            >
              <Sparkles size={17} />
              <span>Assinar com Man Hub Pass</span>
            </button>
          </section>
        )}
      </main>

      {/* Checkout Modal */}
      <CheckoutModal
        isOpen={isCheckoutOpen}
        onClose={() => setIsCheckoutOpen(false)}
        defaultPlan="pass"
      />
    </div>
  );
}
