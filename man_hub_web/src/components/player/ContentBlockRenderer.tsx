"use client";

import React from "react";
import Image from "next/image";
import styles from "./ContentBlockRenderer.module.css";
import { ContentBlock } from "@/lib/types/course";

/**
 * Renderiza texto com formatação básica de markdown (**bold**) e quebras de linha
 */
function FormattedText({ text, className }: { text: string; className?: string }) {
  // Dividir por quebras de linha
  const paragraphs = text.split("\n\n");

  return (
    <div className={className}>
      {paragraphs.map((p, pIdx) => {
        // Se começar com bullet ou tiver linhas com bullet
        const lines = p.split("\n");
        return (
          <div key={pIdx} style={{ marginBottom: pIdx < paragraphs.length - 1 ? "0.75rem" : 0 }}>
            {lines.map((line, lIdx) => {
              const isBullet = line.trim().startsWith("•") || line.trim().startsWith("-");
              const cleanLine = isBullet ? line.replace(/^[•-]\s*/, "") : line;

              // Parse **negrito**
              const parts = cleanLine.split(/(\*\*.*?\*\*)/g);
              const formattedContent = parts.map((part, partIdx) => {
                if (part.startsWith("**") && part.endsWith("**")) {
                  return <strong key={partIdx}>{part.slice(2, -2)}</strong>;
                }
                return part;
              });

              if (isBullet) {
                return (
                  <div key={lIdx} className={styles.bulletItem}>
                    <span className={styles.bulletDot}>•</span>
                    <span>{formattedContent}</span>
                  </div>
                );
              }

              return (
                <p key={lIdx} style={{ marginBottom: lIdx < lines.length - 1 ? "0.35rem" : 0 }}>
                  {formattedContent}
                </p>
              );
            })}
          </div>
        );
      })}
    </div>
  );
}

export default function ContentBlockRenderer({ block }: { block: ContentBlock }) {
  switch (block.type) {
    case "title":
      return (
        <div className={styles.blockContainer}>
          <h2 className={styles.titleBlock}>{block.data}</h2>
        </div>
      );

    case "title2":
      return (
        <div className={styles.blockContainer}>
          <h3 className={styles.title2Block}>{block.data}</h3>
        </div>
      );

    case "description":
      return (
        <div className={styles.blockContainer}>
          <FormattedText text={block.data} className={styles.descriptionBlock} />
        </div>
      );

    case "highlighted_description":
      return (
        <div className={styles.blockContainer}>
          <div className={styles.highlightCard}>
            <FormattedText text={block.data} className={styles.highlightText} />
          </div>
        </div>
      );

    case "image":
      if (!block.data) return null;
      return (
        <div className={styles.blockContainer}>
          <div className={styles.imageWrapper}>
            {/* Usando img direta com fallback resiliente para imagens externas irrestritas */}
            <img
              src={block.data}
              alt="Material visual da aula"
              className={styles.image}
              loading="lazy"
            />
          </div>
        </div>
      );

    case "video":
      if (!block.data) return null;
      return (
        <div className={styles.blockContainer}>
          <div className={styles.videoWrapper}>
            <video
              src={block.data}
              controls
              playsInline
              className={styles.videoElement}
            />
          </div>
        </div>
      );

    default:
      return null;
  }
}
