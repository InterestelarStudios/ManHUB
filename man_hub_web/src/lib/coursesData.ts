import { Training, PlayableSessionContext } from "./types/course";
import cursoVestimenta from "@/data/courses/curso_o_homem_bem_vestido.json";
import cursoPeleCabeloBarba from "@/data/courses/curso_pele_cabelo_barba.json";
import cursoPerfumaria from "@/data/courses/curso_perfumaria_masculina.json";

export const COURSES: Training[] = [
  {
    ...(cursoVestimenta as unknown as Training),
    category: (cursoVestimenta as any).category || "Estilo",
    categories: (cursoVestimenta as any).categories || ["Estilo", "Jornada"],
    price: (cursoVestimenta as any).price && (cursoVestimenta as any).price > 0 ? (cursoVestimenta as any).price : 249.9,
  },
  {
    ...(cursoPeleCabeloBarba as unknown as Training),
    category: (cursoPeleCabeloBarba as any).category || "Visagismo",
    categories: (cursoPeleCabeloBarba as any).categories || ["Visagismo", "Skincare"],
    price: (cursoPeleCabeloBarba as any).price && (cursoPeleCabeloBarba as any).price > 0 ? (cursoPeleCabeloBarba as any).price : 79.9,
  },
  {
    ...(cursoPerfumaria as unknown as Training),
    category: (cursoPerfumaria as any).category || "Perfumes",
    categories: (cursoPerfumaria as any).categories || ["Perfumes", "Estilo"],
    price: (cursoPerfumaria as any).price && (cursoPerfumaria as any).price > 0 ? (cursoPerfumaria as any).price : 159.9,
  },
];

export function getAllCourses(): Training[] {
  return COURSES;
}

export function getCourseById(id: string): Training | undefined {
  return COURSES.find((c) => c.id === id);
}

export function getPlayableSession(
  trainingId: string,
  sessionId: string
): PlayableSessionContext | null {
  const training = getCourseById(trainingId);
  if (!training) return null;

  // Flatten all sessions to calculate global index, previous and next
  interface FlatItem {
    module: Training["modules"][0];
    moduleIndex: number;
    session: Training["modules"][0]["sessions"][0];
    sessionIndex: number;
  }

  const flatPlaylist: FlatItem[] = [];
  training.modules.forEach((mod, mIdx) => {
    mod.sessions.forEach((sess, sIdx) => {
      flatPlaylist.push({
        module: mod,
        moduleIndex: mIdx,
        session: sess,
        sessionIndex: sIdx,
      });
    });
  });

  const currentIndex = flatPlaylist.findIndex(
    (item) => item.session.id === sessionId
  );

  if (currentIndex === -1) return null;

  const currentItem = flatPlaylist[currentIndex];
  const prevItem = currentIndex > 0 ? flatPlaylist[currentIndex - 1] : undefined;
  const nextItem =
    currentIndex < flatPlaylist.length - 1
      ? flatPlaylist[currentIndex + 1]
      : undefined;

  return {
    training,
    module: currentItem.module,
    moduleIndex: currentItem.moduleIndex,
    session: currentItem.session,
    sessionIndex: currentItem.sessionIndex,
    totalSessionsInCourse: flatPlaylist.length,
    currentGlobalIndex: currentIndex,
    prevSession: prevItem
      ? {
          trainingId: training.id,
          sessionId: prevItem.session.id,
          title: prevItem.session.title,
        }
      : undefined,
    nextSession: nextItem
      ? {
          trainingId: training.id,
          sessionId: nextItem.session.id,
          title: nextItem.session.title,
          isLocked: nextItem.moduleIndex > 0, // Module 0 (first module) is free preview
        }
      : undefined,
  };
}
