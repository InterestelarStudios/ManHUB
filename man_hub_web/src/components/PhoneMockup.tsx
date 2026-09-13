"use client";

import { useState, useEffect } from "react";
import styles from "./PhoneMockup.module.css";
import Image from "next/image";
import { Bookmark, Sparkles, Volume2, Home, BookOpen, User, Scissors, Shirt } from "lucide-react";

interface SlideData {
  id: string;
  courseTitle: string;
  badge: string;
  title: string;
  text: string;
  imageUrl: string;
}

const SLIDES: SlideData[] = [
  {
    id: "visagismo",
    courseTitle: "Pele, Cabelo & Barba",
    badge: "Visagismo Facial",
    title: "Formato de Rosto Diamante",
    text: "Maçãs do rosto proeminentes exigem cortes com volume lateral e textura no topo, equilibrados com barba de linhas retas na mandíbula.",
    imageUrl: "https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?q=80&w=800&auto=format&fit=crop",
  },
  {
    id: "estilo",
    courseTitle: "O Homem Bem-Vestido",
    badge: "Caimento Perfeito",
    title: "A Regra de Ouro do Ombro",
    text: "A costura da camisa ou paletó deve repousar com precisão cirúrgica sobre o osso do ombro (acrômio), desenhando a clássica proporção em 'V'.",
    imageUrl: "https://images.unsplash.com/photo-1593032465175-481ac7f401a0?q=80&w=800&auto=format&fit=crop",
  },
  {
    id: "perfumes",
    courseTitle: "Perfumaria Masculina",
    badge: "Pirâmide Olfativa",
    title: "Notas de Fundo & Assinatura",
    text: "O âmbar, cedro atlas e vetiver são responsáveis pela fixação de até 12 horas e criam sua verdadeira aura de autoridade e magnetismo.",
    imageUrl: "https://images.unsplash.com/photo-1523293182086-7651a899d37f?q=80&w=800&auto=format&fit=crop",
  },
];

export default function PhoneMockup() {
  const [currentSlide, setCurrentSlide] = useState(0);
  const [bookmarkedSlides, setBookmarkedSlides] = useState<Record<number, boolean>>({ 0: true });

  useEffect(() => {
    const timer = setInterval(() => {
      setCurrentSlide((prev) => (prev + 1) % SLIDES.length);
    }, 5500);
    return () => clearInterval(timer);
  }, []);

  const slide = SLIDES[currentSlide];
  const isBookmarked = !!bookmarkedSlides[currentSlide];

  const handleNext = () => {
    setCurrentSlide((prev) => (prev + 1) % SLIDES.length);
  };

  const handlePrev = () => {
    setCurrentSlide((prev) => (prev - 1 + SLIDES.length) % SLIDES.length);
  };

  const toggleBookmark = (e: React.MouseEvent) => {
    e.stopPropagation();
    setBookmarkedSlides((prev) => ({
      ...prev,
      [currentSlide]: !prev[currentSlide],
    }));
  };

  return (
    <div className={styles.mockupContainer}>
      {/* Floating Badge 1 - AI Visagism */}
      <div className={styles.floatingBadge1}>
        <div
          className={styles.badgeIconCircle}
          style={{ background: "rgba(0, 191, 255, 0.2)", color: "var(--neon-primary)" }}
        >
          <Sparkles size={16} />
        </div>
        <div className={styles.badgeText}>
          <span className={styles.badgeLabel}>IA Visagismo</span>
          <span className={styles.badgeVal}>Análise Facial 3D</span>
        </div>
      </div>

      {/* Floating Badge 2 - Saved Lessons */}
      <div className={styles.floatingBadge2}>
        <div
          className={styles.badgeIconCircle}
          style={{ background: "rgba(229, 169, 60, 0.2)", color: "var(--gold-accent)" }}
        >
          <Bookmark size={16} />
        </div>
        <div className={styles.badgeText}>
          <span className={styles.badgeLabel}>Telas Salvas</span>
          <span className={styles.badgeVal}>Dicas Favoritadas</span>
        </div>
      </div>

      {/* Smartphone Device Frame */}
      <div className={styles.phoneFrame}>
        {/* Dynamic Island / Header Bar */}
        <div className={styles.phoneHeaderBar}>
          <div className={styles.cameraLens} />
          <div className={styles.speakerMesh} />
        </div>

        {/* Screen Content */}
        <div className={styles.phoneScreen}>
          {/* Story Progress Indicators */}
          <div className={styles.storyBars}>
            {SLIDES.map((_, idx) => (
              <div
                key={idx}
                className={styles.barTrack}
                onClick={() => setCurrentSlide(idx)}
              >
                <div
                  className={styles.barFill}
                  style={{
                    width: idx === currentSlide ? "100%" : idx < currentSlide ? "100%" : "0%",
                  }}
                />
              </div>
            ))}
          </div>

          {/* Top Bar inside App */}
          <div className={styles.appTopBar}>
            <div className={styles.appBrand}>
              <Image
                src="/manhub_icon.png"
                alt="Man Hub"
                width={22}
                height={22}
                style={{ objectFit: "contain", filter: "drop-shadow(0 0 6px rgba(0, 191, 255, 0.7))" }}
              />
              <span className={styles.appCourseTitle}>{slide.courseTitle}</span>
            </div>

            <div className={styles.appActions}>
              <button
                className={`${styles.iconBtn} ${isBookmarked ? styles.bookmarked : ""}`}
                onClick={toggleBookmark}
                title={isBookmarked ? "Remover tela dos favoritos" : "Salvar tela nos favoritos"}
              >
                <Bookmark size={14} fill={isBookmarked ? "currentColor" : "none"} />
              </button>
              <div className={styles.iconBtn}>
                <Volume2 size={14} />
              </div>
            </div>
          </div>

          {/* Touch navigation zones */}
          <div className={styles.touchLeft} onClick={handlePrev} />
          <div className={styles.touchRight} onClick={handleNext} />

          {/* Slide Visual Content */}
          <div className={styles.slideContent}>
            <div
              className={styles.slideBackground}
              style={{ backgroundImage: `url(${slide.imageUrl})` }}
            />
            <div className={styles.slideGradientOverlay} />

            <div className={styles.slideCard}>
              <span className={styles.slideBadge}>{slide.badge}</span>
              <h3 className={styles.slideTitle}>{slide.title}</h3>
              <p className={styles.slideText}>{slide.text}</p>
            </div>
          </div>

          {/* Bottom App Navigation */}
          <div className={styles.bottomNav}>
            <div className={`${styles.navItem} ${styles.navActive}`}>
              <Home size={18} />
              <span>Início</span>
            </div>
            <div className={styles.navItem}>
              <BookOpen size={18} />
              <span>Treinos</span>
            </div>
            <div className={styles.navItem}>
              <Scissors size={18} />
              <span>Visagismo</span>
            </div>
            <div className={styles.navItem}>
              <Shirt size={18} />
              <span>Looks</span>
            </div>
            <div className={styles.navItem}>
              <User size={18} />
              <span>Perfil</span>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
