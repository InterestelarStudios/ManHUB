"use client";

import { useState, useEffect } from "react";
import { collection, onSnapshot } from "firebase/firestore";
import { db } from "@/lib/firebase";
import { Training } from "@/lib/types/course";
import { getAllCourses } from "@/lib/coursesData";

export function useTrainings() {
  const [trainings, setTrainings] = useState<Training[]>(getAllCourses());
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    try {
      const trainingsRef = collection(db, "trainings");

      const unsubscribe = onSnapshot(
        trainingsRef,
        (snapshot) => {
          if (!snapshot.empty) {
            const firestoreTrainings: Training[] = snapshot.docs.map((docSnap) => {
              const data = docSnap.data();
              let parsedPrice = 97.0;
              if (typeof data.price === "number" && data.price > 0) {
                parsedPrice = data.price;
              } else if (data.price) {
                const num = Number(data.price);
                if (!isNaN(num) && num > 0) parsedPrice = num;
              }

              return {
                id: data.id || docSnap.id,
                title: data.title || "",
                subtitle: data.subtitle || "",
                description: data.description || "",
                category: data.category || "Geral",
                categories: Array.isArray(data.categories) ? data.categories : [],
                price: parsedPrice,
                whatYouWillLearn: data.whatYouWillLearn || "",
                duration: data.duration || "",
                coverImageUrl: data.coverImageUrl || "",
                requirements: data.requirements || "",
                updatedAt: data.updatedAt || "",
                modules: Array.isArray(data.modules) ? data.modules : [],
              };
            });

            // Mescla os treinamentos locais como base caso algum não esteja no Firestore ainda
            const localCourses = getAllCourses();
            const firestoreIds = new Set(firestoreTrainings.map((t) => t.id));
            const merged = [
              ...firestoreTrainings,
              ...localCourses.filter((loc) => !firestoreIds.has(loc.id)),
            ];

            setTrainings(merged);
          } else {
            // Se o Firestore não tiver documentos de cursos cadastrados, usa os locais
            setTrainings(getAllCourses());
          }
          setLoading(false);
        },
        (err) => {
          console.warn("Aviso: Falha ao carregar treinamentos do Firestore, utilizando fallback:", err);
          setTrainings(getAllCourses());
          setLoading(false);
        }
      );

      return () => unsubscribe();
    } catch (err: any) {
      console.warn("Erro ao configurar listener do Firestore para treinamentos:", err);
      setTrainings(getAllCourses());
      setLoading(false);
    }
  }, []);

  return { trainings, loading, error };
}
