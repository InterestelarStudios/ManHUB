"use client";

import React, { useState } from "react";
import Link from "next/link";
import { useParams } from "next/navigation";
import { getPlayableSession } from "@/lib/coursesData";
import StoryPlayer from "@/components/player/StoryPlayer";
import CheckoutModal from "@/components/CheckoutModal";
import { ArrowLeft } from "lucide-react";

export default function LessonStoryPlayerPage() {
  const params = useParams();
  const trainingId = params?.trainingId as string;
  const sessionId = params?.sessionId as string;

  const [isCheckoutOpen, setIsCheckoutOpen] = useState(false);
  const [selectedTrainingInfo, setSelectedTrainingInfo] = useState<{
    id: string;
    title: string;
  }>({ id: "", title: "" });

  const sessionContext = getPlayableSession(trainingId, sessionId);

  if (!sessionContext) {
    return (
      <div
        style={{
          minHeight: "100vh",
          backgroundColor: "#040D1A",
          color: "#E0E6EE",
          display: "flex",
          flexDirection: "column",
          alignItems: "center",
          justifyContent: "center",
          padding: "2rem",
          textAlign: "center",
        }}
      >
        <h2 style={{ fontSize: "1.75rem", marginBottom: "1rem" }}>Aula não encontrada</h2>
        <p style={{ color: "#8A9AAB", marginBottom: "2rem", maxWidth: "420px" }}>
          Não conseguimos localizar o conteúdo desta aula ou ela foi movida.
        </p>
        <Link
          href={`/treinamentos/${trainingId}`}
          style={{
            display: "inline-flex",
            alignItems: "center",
            gap: "0.5rem",
            backgroundColor: "#00BFFF",
            color: "#040D1A",
            padding: "0.75rem 1.5rem",
            borderRadius: "8px",
            fontWeight: 700,
            textDecoration: "none",
          }}
        >
          <ArrowLeft size={16} /> Voltar ao Treinamento
        </Link>
      </div>
    );
  }

  const handleOpenCheckout = (tId: string, tTitle: string) => {
    setSelectedTrainingInfo({ id: tId, title: tTitle });
    setIsCheckoutOpen(true);
  };

  return (
    <>
      <StoryPlayer
        sessionContext={sessionContext}
        onOpenCheckout={handleOpenCheckout}
      />

      <CheckoutModal
        isOpen={isCheckoutOpen}
        onClose={() => setIsCheckoutOpen(false)}
        defaultPlan="training"
        defaultTrainingId={selectedTrainingInfo.id || trainingId}
        defaultTrainingTitle={selectedTrainingInfo.title || sessionContext.training.title}
      />
    </>
  );
}
