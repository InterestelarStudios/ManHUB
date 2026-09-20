"use client";

import React from "react";
import Link from "next/link";
import styles from "./CourseSidebar.module.css";
import { Training } from "@/lib/types/course";
import { useProgress } from "@/lib/context/ProgressContext";
import { X, Play, Lock, CheckCircle2 } from "lucide-react";

interface CourseSidebarProps {
  isOpen: boolean;
  onClose: () => void;
  training: Training;
  currentSessionId: string;
  hasFullAccess?: boolean;
  onLockedClick?: (sessionTitle: string) => void;
}

export default function CourseSidebar({
  isOpen,
  onClose,
  training,
  currentSessionId,
  hasFullAccess = false,
  onLockedClick,
}: CourseSidebarProps) {
  const { isSessionCompleted } = useProgress();

  return (
    <>
      <div
        className={`${styles.overlay} ${isOpen ? styles.open : ""}`}
        onClick={onClose}
      />

      <aside className={`${styles.sidebar} ${isOpen ? styles.open : ""}`}>
        <div className={styles.sidebarHeader}>
          <div className={styles.courseInfo}>
            <span className={styles.courseTag}>Treinamento</span>
            <h3 className={styles.courseTitle} title={training.title}>
              {training.title}
            </h3>
          </div>
          <button
            className={styles.closeBtn}
            onClick={onClose}
            aria-label="Fechar índice do curso"
          >
            <X size={20} />
          </button>
        </div>

        <div className={styles.modulesList}>
          {training.modules.map((module, mIdx) => {
            const isModuleFree = mIdx === 0 || hasFullAccess;

            return (
              <div key={module.id} className={styles.moduleGroup}>
                <div className={styles.moduleHeader}>
                  <span className={styles.moduleIndexBadge}>M{mIdx + 1}</span>
                  <span className={styles.moduleTitle}>{module.title}</span>
                </div>

                <div className={styles.sessionsList}>
                  {module.sessions.map((session, sIdx) => {
                    const isActive = session.id === currentSessionId;
                    const isLocked = !isModuleFree;
                    const isCompleted = isSessionCompleted(training.id, session.id);

                    if (isLocked) {
                      return (
                        <div
                          key={session.id}
                          className={`${styles.sessionItem} ${styles.locked}`}
                          onClick={() => {
                            if (onLockedClick) {
                              onLockedClick(session.title);
                            }
                          }}
                        >
                          <div className={styles.sessionLeft}>
                            <Lock size={15} className={styles.lockIcon} />
                            <div className={styles.sessionTitles}>
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
                            <Lock size={14} className={styles.lockIcon} />
                          </div>
                        </div>
                      );
                    }

                    return (
                      <Link
                        key={session.id}
                        href={`/treinamentos/${training.id}/aula/${session.id}`}
                        className={`${styles.sessionItem} ${
                          isActive ? styles.active : ""
                        } ${isCompleted ? styles.completed : ""}`}
                        onClick={onClose}
                      >
                        <div className={styles.sessionLeft}>
                          {isActive ? (
                            <Play size={15} className={styles.sessionIcon} />
                          ) : isCompleted ? (
                            <CheckCircle2
                              size={15}
                              className={`${styles.sessionIcon} ${styles.completedIcon}`}
                            />
                          ) : (
                            <Play
                              size={14}
                              className={styles.sessionIcon}
                              style={{ opacity: 0.5 }}
                            />
                          )}
                          <div className={styles.sessionTitles}>
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
                              <CheckCircle2 size={10} /> Concluída
                            </span>
                          ) : isModuleFree && mIdx === 0 ? (
                            <span className={styles.freeTag}>Grátis</span>
                          ) : null}
                        </div>
                      </Link>
                    );
                  })}
                </div>
              </div>
            );
          })}
        </div>
      </aside>
    </>
  );
}
