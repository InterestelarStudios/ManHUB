"use client";

import React, { createContext, useContext, useEffect, useState } from "react";
import {
  collection,
  doc,
  onSnapshot,
  setDoc,
  serverTimestamp,
  arrayUnion,
  Timestamp,
} from "firebase/firestore";
import { db } from "@/lib/firebase";
import { useAuth } from "./AuthContext";
import { UserProgress, ProgressContextType } from "@/lib/types/progress";

const ProgressContext = createContext<ProgressContextType | undefined>(undefined);

export function ProgressProvider({ children }: { children: React.ReactNode }) {
  const { user } = useAuth();
  const [progressMap, setProgressMap] = useState<Record<string, UserProgress>>({});
  const [loading, setLoading] = useState(true);

  // Escuta em tempo real a subcoleção users/{uid}/progress
  useEffect(() => {
    if (!user) {
      // Carrega fallback do localStorage para visitantes
      try {
        const saved = localStorage.getItem("manhub_guest_progress");
        if (saved) {
          setProgressMap(JSON.parse(saved));
        } else {
          setProgressMap({});
        }
      } catch {
        setProgressMap({});
      }
      setLoading(false);
      return;
    }

    setLoading(true);
    const progressRef = collection(db, "users", user.uid, "progress");

    const unsubscribe = onSnapshot(
      progressRef,
      (snapshot) => {
        const newMap: Record<string, UserProgress> = {};

        snapshot.docs.forEach((docSnap) => {
          const data = docSnap.data();
          let parsedDate = new Date();
          if (data.updatedAt instanceof Timestamp) {
            parsedDate = data.updatedAt.toDate();
          }

          newMap[docSnap.id] = {
            trainingId: docSnap.id,
            trainingTitle: data.trainingTitle || "",
            lastModuleIndex: typeof data.lastModuleIndex === "number" ? data.lastModuleIndex : 0,
            lastSessionId: data.lastSessionId || "",
            lastSessionTitle: data.lastSessionTitle || "",
            lastScreenIndex: typeof data.lastScreenIndex === "number" ? data.lastScreenIndex : 0,
            completedSessionIds: Array.isArray(data.completedSessionIds)
              ? data.completedSessionIds
              : [],
            completedModuleIndices: Array.isArray(data.completedModuleIndices)
              ? data.completedModuleIndices
              : [],
            updatedAt: parsedDate,
          };
        });

        setProgressMap(newMap);
        setLoading(false);
      },
      (error) => {
        console.error("Erro ao sincronizar progresso:", error);
        setLoading(false);
      }
    );

    return () => unsubscribe();
  }, [user]);

  const getProgress = (trainingId: string): UserProgress | undefined => {
    return progressMap[trainingId];
  };

  const isSessionCompleted = (trainingId: string, sessionId: string): boolean => {
    const p = progressMap[trainingId];
    return p ? p.completedSessionIds.includes(sessionId) : false;
  };

  const saveCurrentPosition = async ({
    trainingId,
    trainingTitle,
    moduleIndex,
    sessionId,
    sessionTitle,
    screenIndex,
  }: {
    trainingId: string;
    trainingTitle: string;
    moduleIndex: number;
    sessionId: string;
    sessionTitle: string;
    screenIndex: number;
  }) => {
    // Atualização otimista local
    setProgressMap((prev) => {
      const existing = prev[trainingId];
      const updated: UserProgress = {
        trainingId,
        trainingTitle: trainingTitle || existing?.trainingTitle || "",
        lastModuleIndex: moduleIndex,
        lastSessionId: sessionId,
        lastSessionTitle: sessionTitle || existing?.lastSessionTitle || "",
        lastScreenIndex: screenIndex,
        completedSessionIds: existing?.completedSessionIds || [],
        completedModuleIndices: existing?.completedModuleIndices || [],
        updatedAt: new Date(),
      };
      const updatedMap = { ...prev, [trainingId]: updated };

      if (!user) {
        try {
          localStorage.setItem("manhub_guest_progress", JSON.stringify(updatedMap));
        } catch {}
      }

      return updatedMap;
    });

    if (user) {
      try {
        const docRef = doc(db, "users", user.uid, "progress", trainingId);
        await setDoc(
          docRef,
          {
            trainingId,
            trainingTitle,
            lastModuleIndex: moduleIndex,
            lastSessionId: sessionId,
            lastSessionTitle: sessionTitle,
            lastScreenIndex: screenIndex,
            updatedAt: serverTimestamp(),
          },
          { merge: true }
        );
      } catch (err) {
        console.error("Erro ao salvar posição da aula:", err);
      }
    }
  };

  const markSessionCompleted = async ({
    trainingId,
    trainingTitle,
    sessionId,
    moduleIndex,
    isModuleFullyCompleted = false,
  }: {
    trainingId: string;
    trainingTitle: string;
    sessionId: string;
    moduleIndex: number;
    isModuleFullyCompleted?: boolean;
  }) => {
    // Atualização otimista local
    setProgressMap((prev) => {
      const existing = prev[trainingId];
      const currentCompleted = existing ? [...existing.completedSessionIds] : [];
      if (!currentCompleted.includes(sessionId)) {
        currentCompleted.push(sessionId);
      }

      const currentCompletedModules = existing ? [...existing.completedModuleIndices] : [];
      if (isModuleFullyCompleted && !currentCompletedModules.includes(moduleIndex)) {
        currentCompletedModules.push(moduleIndex);
      }

      const updated: UserProgress = {
        trainingId,
        trainingTitle: trainingTitle || existing?.trainingTitle || "",
        lastModuleIndex: moduleIndex,
        lastSessionId: sessionId,
        lastSessionTitle: existing?.lastSessionTitle || "",
        lastScreenIndex: existing?.lastScreenIndex || 0,
        completedSessionIds: currentCompleted,
        completedModuleIndices: currentCompletedModules,
        updatedAt: new Date(),
      };

      const updatedMap = { ...prev, [trainingId]: updated };

      if (!user) {
        try {
          localStorage.setItem("manhub_guest_progress", JSON.stringify(updatedMap));
        } catch {}
      }

      return updatedMap;
    });

    if (user) {
      try {
        const docRef = doc(db, "users", user.uid, "progress", trainingId);
        await setDoc(
          docRef,
          {
            trainingId,
            trainingTitle,
            lastModuleIndex: moduleIndex,
            lastSessionId: sessionId,
            completedSessionIds: arrayUnion(sessionId),
            ...(isModuleFullyCompleted ? { completedModuleIndices: arrayUnion(moduleIndex) } : {}),
            updatedAt: serverTimestamp(),
          },
          { merge: true }
        );
      } catch (err) {
        console.error("Erro ao marcar aula como concluída:", err);
      }
    }
  };

  return (
    <ProgressContext.Provider
      value={{
        progressMap,
        loading,
        getProgress,
        isSessionCompleted,
        saveCurrentPosition,
        markSessionCompleted,
      }}
    >
      {children}
    </ProgressContext.Provider>
  );
}

export function useProgress(): ProgressContextType {
  const context = useContext(ProgressContext);
  if (!context) {
    throw new Error("useProgress deve ser utilizado dentro de um ProgressProvider");
  }
  return context;
}
