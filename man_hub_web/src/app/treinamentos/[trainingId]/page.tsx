"use client";

import React, { useState, useEffect } from "react";
import Link from "next/link";
import { useParams, useRouter } from "next/navigation";
import styles from "./CourseDetail.module.css";
import { getCourseById } from "@/lib/coursesData";
import { useTrainings } from "@/lib/hooks/useTrainings";
import CheckoutModal from "@/components/CheckoutModal";
import { useAuth } from "@/lib/context/AuthContext";
import { useProgress } from "@/lib/context/ProgressContext";
import { trackViewContent } from "@/lib/tracking/pixel";
import {
  Clock,
  Layers,
  BookOpen,
  CheckCircle,
  Play,
  Lock,
  Sparkles,
  CheckCircle2,
} from "lucide-react";

export default function CourseDetailPage() {
  const params = useParams();
  const router = useRouter();
  const { hasAccessToTraining, isSubscribed } = useAuth();
  const { getProgress, isSessionCompleted } = useProgress();
  const { trainings } = useTrainings();
  const trainingId = params?.trainingId as string;

  const [isCheckoutOpen, setIsCheckoutOpen] = useState(false);

  const course =
    trainings.find((c) => c.id === trainingId) || getCourseById(trainingId);
  const userHasAccess = course ? hasAccessToTraining(course.id) : false;
  const userProgress = course ? getProgress(course.id) : undefined;
  const totalSessions = course
    ? course.modules.reduce((acc, m) => acc + m.sessions.length, 0)
    : 0;
  const completedCount = userProgress?.completedSessionIds?.length || 0;
  const progressPercentage =
    totalSessions > 0
      ? Math.min(100, Math.round((completedCount / totalSessions) * 100))
      : 0;

  useEffect(() => {
    if (course) {
      trackViewContent({
        id: course.id,
        name: course.title,
        price: course.price,
        category: course.category,
      });
    }
  }, [course]);

  if (!course) {
    return (
      <div className={styles.container}>
        <div style={{ textAlign: "center", padding: "5rem 1.5rem" }}>
          <h2 style={{ fontSize: "1.75rem", marginBottom: "1rem" }}>Treinamento não encontrado</h2>
          <p style={{ color: "var(--text-secondary)", marginBottom: "1.5rem" }}>
            O treinamento que você tentou acessar não está disponível.
          </p>
          <Link href="/treinamentos" className={styles.startFreeBtn}>
            Explorar Treinamentos
          </Link>
        </div>
      </div>
    );
  }

  // First session of the first module (free trial)
  const firstSession = course.modules[0]?.sessions[0];

  // What you will learn items
  const learningPoints = course.whatYouWillLearn
    ? course.whatYouWillLearn.split("\n").filter((p) => p.trim().length > 0)
    : [];

  const handleOpenCheckout = () => {
    setIsCheckoutOpen(true);
  };

  return (
    <div className={styles.container}>
      {/* Hero Section */}
      <section className={styles.hero}>
        <div className={styles.heroContent}>
          <div className={styles.categoryTag}>
            <Sparkles size={13} />
            <span>Academia Man Hub</span>
          </div>

          <h1 className={styles.title}>{course.title}</h1>
          <p className={styles.subtitle}>{course.subtitle}</p>
          <p className={styles.description}>{course.description}</p>

          <div className={styles.metaRow}>
            {course.duration && (
              <div className={styles.metaItem}>
                <Clock size={16} className={styles.metaIcon} />
                <span>{course.duration} de conteúdo</span>
              </div>
            )}
            <div className={styles.metaItem}>
              <Layers size={16} className={styles.metaIcon} />
              <span>{course.modules.length} Módulos</span>
            </div>
            <div className={styles.metaItem}>
              <BookOpen size={16} className={styles.metaIcon} />
              <span>
                {course.modules.reduce((acc, m) => acc + m.sessions.length, 0)} Aulas em Stories
              </span>
            </div>
          </div>

          <div className={styles.ctaGroup}>
            {course && (
              <Link
                href={`/treinamentos/${course.id}/aula/${
                  userProgress?.lastSessionId || firstSession?.id || ""
                }`}
                className={styles.startFreeBtn}
              >
                {completedCount === 0 ? (
                  <>
                    <Play size={18} />{" "}
                    {userHasAccess ? "Iniciar Treinamento" : "Iniciar Primeira Aula Grátis"}
                  </>
                ) : completedCount === totalSessions ? (
                  <>
                    <CheckCircle2 size={18} /> Rever Treinamento (100% Concluído)
                  </>
                ) : (
                  <>
                    <Play size={18} /> Continuar De Onde Parou ({progressPercentage}%)
                  </>
                )}
              </Link>
            )}

            {userHasAccess ? (
              <div
                className={styles.buyBtn}
                style={{
                  cursor: "default",
                  background: "rgba(0, 191, 255, 0.15)",
                  borderColor: "var(--neon-primary)",
                  color: "#FFFFFF",
                }}
              >
                <CheckCircle2 size={16} style={{ color: "var(--neon-primary)" }} />
                <span>Acesso Liberado (Aluno Oficial)</span>
              </div>
            ) : (
              <button className={styles.buyBtn} onClick={handleOpenCheckout}>
                <Lock size={16} /> Desbloquear Treinamento • R${" "}
                {(course.price ?? 97.0).toFixed(2).replace(".", ",")}
              </button>
            )}
          </div>
        </div>

        {course.coverImageUrl && (
          <div className={styles.coverWrapper}>
            <img
              src={course.coverImageUrl}
              alt={course.title}
              className={styles.coverImage}
            />
          </div>
        )}
      </section>

      {/* Main Content: Learning Points + Syllabus */}
      <main className={styles.mainContent}>
        {/* Left: What You Will Learn */}
        <aside className={styles.learningCard}>
          <h2 className={styles.sectionTitle}>
            <Sparkles size={18} style={{ color: "var(--neon-primary)" }} /> O Que Você Irá Dominar
          </h2>

          <div className={styles.learningList}>
            {learningPoints.map((point, idx) => {
              const cleanText = point.replace(/^[•-]\s*/, "");
              return (
                <div key={idx} className={styles.learningItem}>
                  <CheckCircle size={16} className={styles.checkIcon} />
                  <span>{cleanText}</span>
                </div>
              );
            })}
          </div>
        </aside>

        {/* Right: Modules & Sessions Syllabus */}
        <section className={styles.syllabusSection}>
          <div className={styles.syllabusHeaderRow}>
            <h2 className={styles.sectionTitle} style={{ marginBottom: 0 }}>
              <BookOpen size={18} style={{ color: "var(--neon-primary)" }} /> Grade do Treinamento
            </h2>
            {completedCount > 0 && (
              <span className={styles.progressCounterBadge}>
                <CheckCircle2 size={13} style={{ color: "var(--success)" }} />
                {completedCount}/{totalSessions} Concluídas ({progressPercentage}%)
              </span>
            )}
          </div>

          {completedCount > 0 && (
            <div className={styles.progressBarWrapper}>
              <div
                className={styles.progressBarFill}
                style={{ width: `${progressPercentage}%` }}
              />
            </div>
          )}

          {course.modules.map((module, mIdx) => {
            const isModuleUnlocked = mIdx === 0 || userHasAccess;

            return (
              <div key={module.id} className={styles.moduleCard}>
                <div className={styles.moduleHeader}>
                  <div className={styles.moduleHeaderLeft}>
                    <span className={styles.moduleBadge}>MÓDULO {mIdx + 1}</span>
                    <h3 className={styles.moduleCardTitle}>{module.title}</h3>
                  </div>
                  {isModuleUnlocked ? (
                    <span className={styles.freeTag}>
                      {userHasAccess ? "Acesso Liberado" : "Degustação Aberta"}
                    </span>
                  ) : (
                    <Lock size={15} style={{ color: "var(--text-muted)" }} />
                  )}
                </div>

                <div className={styles.sessionsList}>
                  {module.sessions.map((session, sIdx) => {
                    const isCompleted = isSessionCompleted(course.id, session.id);

                    if (!isModuleUnlocked) {
                      return (
                        <div
                          key={session.id}
                          className={`${styles.sessionRow} ${styles.locked}`}
                          onClick={handleOpenCheckout}
                          title="Clique para desbloquear este módulo"
                        >
                          <div className={styles.sessionLeft}>
                            <Lock size={15} className={styles.sessionIcon} style={{ color: "var(--text-muted)" }} />
                            <div className={styles.sessionText}>
                              <span className={styles.sessionTitle}>
                                {sIdx + 1}. {session.title}
                              </span>
                              {session.subtitle && (
                                <span className={styles.sessionSubtitle}>
                                  {session.subtitle}
                                </span>
                              )}
                            </div>
                          </div>

                          <div className={styles.sessionRight}>
                            <span className={styles.screensBadge}>
                              {session.screens.length} telas
                            </span>
                            <Lock size={14} style={{ color: "var(--text-muted)" }} />
                          </div>
                        </div>
                      );
                    }

                    return (
                      <Link
                        key={session.id}
                        href={`/treinamentos/${course.id}/aula/${session.id}`}
                        className={`${styles.sessionRow} ${
                          isCompleted ? styles.sessionCompleted : ""
                        }`}
                      >
                        <div className={styles.sessionLeft}>
                          {isCompleted ? (
                            <CheckCircle2
                              size={16}
                              className={`${styles.sessionIcon} ${styles.completedIcon}`}
                            />
                          ) : (
                            <Play size={15} className={styles.sessionIcon} />
                          )}
                          <div className={styles.sessionText}>
                            <span className={styles.sessionTitle}>
                              {sIdx + 1}. {session.title}
                            </span>
                            {session.subtitle && (
                              <span className={styles.sessionSubtitle}>
                                {session.subtitle}
                              </span>
                            )}
                          </div>
                        </div>

                        <div className={styles.sessionRight}>
                          {isCompleted ? (
                            <span className={styles.completedTag}>
                              <CheckCircle2 size={11} /> Concluída
                            </span>
                          ) : (
                            <span className={styles.freeTag}>Assistir</span>
                          )}
                          <span className={styles.screensBadge}>
                            {session.screens.length} telas
                          </span>
                        </div>
                      </Link>
                    );
                  })}
                </div>
              </div>
            );
          })}
        </section>
      </main>

      {/* Checkout Modal */}
      <CheckoutModal
        isOpen={isCheckoutOpen}
        onClose={() => setIsCheckoutOpen(false)}
        defaultPlan="training"
        defaultTrainingId={course.id}
        defaultTrainingTitle={course.title}
        defaultPrice={course.price}
      />
    </div>
  );
}
