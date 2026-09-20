"use client";

import React, { useState, useEffect, useCallback, useRef } from "react";
import { useRouter } from "next/navigation";
import styles from "./StoryPlayer.module.css";
import { PlayableSessionContext } from "@/lib/types/course";
import ContentBlockRenderer from "./ContentBlockRenderer";
import CourseSidebar from "./CourseSidebar";
import { useAuth } from "@/lib/context/AuthContext";
import { useProgress } from "@/lib/context/ProgressContext";
import {
  X,
  Menu,
  Bookmark,
  ChevronLeft,
  ChevronRight,
  Maximize2,
  Minimize2,
  CheckCircle2,
  ArrowRight,
  RotateCcw,
  Lock,
} from "lucide-react";

interface StoryPlayerProps {
  sessionContext: PlayableSessionContext;
  onOpenCheckout?: (trainingId: string, trainingTitle: string) => void;
}

export default function StoryPlayer({
  sessionContext,
  onOpenCheckout,
}: StoryPlayerProps) {
  const router = useRouter();
  const { hasAccessToTraining } = useAuth();
  const { saveCurrentPosition, markSessionCompleted } = useProgress();
  const { training, module, session, nextSession, prevSession } = sessionContext;
  const userHasAccess = hasAccessToTraining(training.id);
  const isNextLocked = nextSession ? (nextSession.isLocked && !userHasAccess) : false;

  const [currentScreenIndex, setCurrentScreenIndex] = useState(0);
  const [isSessionFinished, setIsSessionFinished] = useState(false);
  const [isSidebarOpen, setIsSidebarOpen] = useState(false);
  const [isBookmarked, setIsBookmarked] = useState(false);
  const [isFullscreen, setIsFullscreen] = useState(false);

  const contentRef = useRef<HTMLDivElement>(null);
  const totalScreens = session.screens.length;
  const currentScreen = session.screens[currentScreenIndex];

  // Scroll to top on screen change
  useEffect(() => {
    if (contentRef.current) {
      contentRef.current.scrollTop = 0;
    }
  }, [currentScreenIndex]);

  // Load bookmark status from localStorage
  useEffect(() => {
    try {
      const saved = localStorage.getItem(`bookmark_${session.id}`);
      setIsBookmarked(!!saved);
    } catch {
      // ignore
    }
  }, [session.id]);

  const toggleBookmark = () => {
    try {
      if (isBookmarked) {
        localStorage.removeItem(`bookmark_${session.id}`);
        setIsBookmarked(false);
      } else {
        localStorage.setItem(`bookmark_${session.id}`, "true");
        setIsBookmarked(true);
      }
    } catch {
      // ignore
    }
  };

  // Salva posição ao entrar na aula
  useEffect(() => {
    saveCurrentPosition({
      trainingId: training.id,
      trainingTitle: training.title,
      moduleIndex: sessionContext.moduleIndex,
      sessionId: session.id,
      sessionTitle: session.title,
      screenIndex: currentScreenIndex,
    });
  }, [training.id, session.id]);

  const handleNextScreen = useCallback(() => {
    if (isSessionFinished) return;

    if (currentScreenIndex < totalScreens - 1) {
      const nextIdx = currentScreenIndex + 1;
      setCurrentScreenIndex(nextIdx);
      saveCurrentPosition({
        trainingId: training.id,
        trainingTitle: training.title,
        moduleIndex: sessionContext.moduleIndex,
        sessionId: session.id,
        sessionTitle: session.title,
        screenIndex: nextIdx,
      });
    } else {
      setIsSessionFinished(true);
      markSessionCompleted({
        trainingId: training.id,
        trainingTitle: training.title,
        sessionId: session.id,
        moduleIndex: sessionContext.moduleIndex,
      });
    }
  }, [
    currentScreenIndex,
    totalScreens,
    isSessionFinished,
    saveCurrentPosition,
    markSessionCompleted,
    training.id,
    training.title,
    sessionContext.moduleIndex,
    session.id,
    session.title,
  ]);

  const handlePrevScreen = useCallback(() => {
    if (isSessionFinished) {
      setIsSessionFinished(false);
      return;
    }

    if (currentScreenIndex > 0) {
      const prevIdx = currentScreenIndex - 1;
      setCurrentScreenIndex(prevIdx);
      saveCurrentPosition({
        trainingId: training.id,
        trainingTitle: training.title,
        moduleIndex: sessionContext.moduleIndex,
        sessionId: session.id,
        sessionTitle: session.title,
        screenIndex: prevIdx,
      });
    } else if (prevSession) {
      router.push(`/treinamentos/${training.id}/aula/${prevSession.sessionId}`);
    }
  }, [
    currentScreenIndex,
    isSessionFinished,
    prevSession,
    router,
    training.id,
    training.title,
    sessionContext.moduleIndex,
    session.id,
    session.title,
    saveCurrentPosition,
  ]);

  // Keyboard navigation
  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if (isSidebarOpen) return;

      if (e.key === "ArrowRight" || e.key === " ") {
        e.preventDefault();
        handleNextScreen();
      } else if (e.key === "ArrowLeft") {
        e.preventDefault();
        handlePrevScreen();
      } else if (e.key === "Escape") {
        router.push(`/treinamentos/${training.id}`);
      }
    };

    window.addEventListener("keydown", handleKeyDown);
    return () => window.removeEventListener("keydown", handleKeyDown);
  }, [handleNextScreen, handlePrevScreen, isSidebarOpen, router, training.id]);

  // Fullscreen toggle
  const toggleFullscreen = () => {
    if (!document.fullscreenElement) {
      document.documentElement.requestFullscreen().then(() => setIsFullscreen(true)).catch(() => {});
    } else {
      document.exitFullscreen().then(() => setIsFullscreen(false)).catch(() => {});
    }
  };

  const handleNextSessionClick = () => {
    if (!nextSession) {
      router.push(`/treinamentos/${training.id}`);
      return;
    }

    if (isNextLocked) {
      if (onOpenCheckout) {
        onOpenCheckout(training.id, training.title);
      }
      return;
    }

    router.push(`/treinamentos/${training.id}/aula/${nextSession.sessionId}`);
  };

  return (
    <div className={styles.wrapper}>
      <div className={styles.ambientGlow} />

      {/* Side Arrow Navigation (Desktop) */}
      <button
        className={`${styles.sideArrow} ${styles.sideArrowLeft}`}
        onClick={handlePrevScreen}
        disabled={currentScreenIndex === 0 && !prevSession}
        aria-label="Tela anterior"
      >
        <ChevronLeft size={24} />
      </button>

      <button
        className={`${styles.sideArrow} ${styles.sideArrowRight}`}
        onClick={handleNextScreen}
        aria-label="Próxima tela"
      >
        <ChevronRight size={24} />
      </button>

      {/* Main Card */}
      <div className={styles.playerCard}>
        {/* Header */}
        <header className={styles.playerHeader}>
          {/* Progress Bars Segments */}
          <div className={styles.progressSegments}>
            {session.screens.map((_, idx) => {
              let fillPercent = 0;
              if (idx < currentScreenIndex || isSessionFinished) {
                fillPercent = 100;
              } else if (idx === currentScreenIndex) {
                fillPercent = 100;
              }

              return (
                <div key={idx} className={styles.segmentTrack}>
                  <div
                    className={styles.segmentFill}
                    style={{ width: `${fillPercent}%` }}
                  />
                </div>
              );
            })}
          </div>

          {/* Meta Row */}
          <div className={styles.metaRow}>
            <div className={styles.headerLeft}>
              <button
                className={styles.menuBtn}
                onClick={() => setIsSidebarOpen(true)}
                title="Ver índice de aulas"
              >
                <Menu size={16} />
              </button>

              <div className={styles.lessonTitles}>
                <span className={styles.lessonModuleTag}>{module.title}</span>
                <span className={styles.lessonMainTitle} title={session.title}>
                  {session.title}
                </span>
              </div>
            </div>

            <div className={styles.headerRight}>
              <button
                className={`${styles.headerIconBtn} ${
                  isBookmarked ? styles.active : ""
                }`}
                onClick={toggleBookmark}
                title={isBookmarked ? "Salvo nos favoritos" : "Salvar aula"}
              >
                <Bookmark size={17} />
              </button>

              <button
                className={styles.headerIconBtn}
                onClick={toggleFullscreen}
                title="Tela cheia"
              >
                {isFullscreen ? <Minimize2 size={17} /> : <Maximize2 size={17} />}
              </button>

              <button
                className={styles.headerIconBtn}
                onClick={() => router.push(`/treinamentos/${training.id}`)}
                title="Fechar aula"
              >
                <X size={18} />
              </button>
            </div>
          </div>
        </header>

        {/* Content Area or Finished Screen */}
        {!isSessionFinished && currentScreen ? (
          <>
            {/* Click / Touch Zones */}
            <div className={styles.touchZones}>
              <div
                className={styles.zoneLeft}
                onClick={handlePrevScreen}
                title="Toque para voltar"
              />
              <div
                className={styles.zoneRight}
                onClick={handleNextScreen}
                title="Toque para avançar"
              />
            </div>

            {/* Content Container */}
            <main
              ref={contentRef}
              key={currentScreen.id}
              className={`${styles.contentArea} ${styles.screenTransition}`}
            >
              {currentScreen.contents.map((block) => (
                <ContentBlockRenderer key={block.id} block={block} />
              ))}
            </main>
          </>
        ) : (
          <div className={styles.finishedContainer}>
            <div className={styles.trophyCircle}>
              <CheckCircle2 size={36} />
            </div>
            <h2 className={styles.finishedTitle}>Aula Concluída!</h2>
            <p className={styles.finishedSubtitle}>
              Excelente progresso. Você deu mais um passo na sua jornada de evolução.
            </p>

            <div className={styles.finishedActions}>
              {nextSession ? (
                <button
                  className={styles.primaryActionBtn}
                  style={{ justifyContent: "center", padding: "0.75rem 1.25rem" }}
                  onClick={handleNextSessionClick}
                >
                  {isNextLocked ? (
                    <>
                      <Lock size={16} /> Desbloquear Próxima Aula
                    </>
                  ) : (
                    <>
                      Próxima Aula <ArrowRight size={16} />
                    </>
                  )}
                </button>
              ) : (
                <button
                  className={styles.primaryActionBtn}
                  style={{ justifyContent: "center", padding: "0.75rem 1.25rem" }}
                  onClick={() => router.push(`/treinamentos/${training.id}`)}
                >
                  Ver Grade do Treinamento
                </button>
              )}

              <button
                className={styles.restartBtn}
                onClick={() => {
                  setCurrentScreenIndex(0);
                  setIsSessionFinished(false);
                }}
              >
                <RotateCcw size={14} style={{ display: "inline", marginRight: "6px" }} />
                Revisar Esta Aula
              </button>
            </div>
          </div>
        )}

        {/* Footer */}
        <footer className={styles.playerFooter}>
          <span className={styles.screenCounter}>
            {isSessionFinished
              ? "CONCLUÍDO"
              : `${currentScreenIndex + 1} / ${totalScreens}`}
          </span>

          <div className={styles.footerActions}>
            <button
              className={styles.navActionBtn}
              onClick={handlePrevScreen}
              disabled={currentScreenIndex === 0 && !prevSession}
            >
              <ChevronLeft size={16} /> Anterior
            </button>

            <button
              className={styles.navActionBtn}
              onClick={handleNextScreen}
            >
              {currentScreenIndex === totalScreens - 1 && !isSessionFinished
                ? "Concluir"
                : "Avançar"}{" "}
              <ChevronRight size={16} />
            </button>
          </div>
        </footer>
      </div>

      {/* Syllabus Sidebar */}
      <CourseSidebar
        isOpen={isSidebarOpen}
        onClose={() => setIsSidebarOpen(false)}
        training={training}
        currentSessionId={session.id}
        hasFullAccess={userHasAccess}
        onLockedClick={() => {
          setIsSidebarOpen(false);
          if (onOpenCheckout) {
            onOpenCheckout(training.id, training.title);
          }
        }}
      />
    </div>
  );
}
