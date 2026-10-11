"use client";

import { useState } from "react";
import styles from "./CtaBanner.module.css";
import Image from "next/image";
import { Apple, Check, Sparkles, Send, CheckCircle2 } from "lucide-react";
import { db } from "@/lib/firebase";
import { collection, addDoc, serverTimestamp } from "firebase/firestore";

export default function CtaBanner() {
  const [email, setEmail] = useState("");
  const [submitted, setSubmitted] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (email.trim().length > 3) {
      setSubmitted(true);
      try {
        await addDoc(collection(db, "waitlist"), {
          email: email.trim(),
          createdAt: serverTimestamp(),
          source: "landing_page_vip",
        });
      } catch (err) {
        console.warn("Erro ao salvar lead no Firestore:", err);
      }
    }
  };

  return (
    <section id="download" className={styles.bannerSection}>
      <div className="container">
        <div className={styles.bannerCard}>
          <Image
            src="/manhub_icon.png"
            alt="Man Hub Logo"
            width={64}
            height={64}
            style={{
              objectFit: "contain",
              filter: "drop-shadow(0 0 16px rgba(0, 191, 255, 0.7))",
            }}
          />

          <span className="badge-neon">
            <Sparkles size={13} />
            Aplicativo Oficial Disponível na Google Play
          </span>

          <h2 className={styles.bannerTitle}>
            Baixe o <span className="text-gradient">MAN HUB na Google Play</span> <br />
            ou acesse diretamente pelo navegador.
          </h2>

          <p className={styles.bannerSubtitle}>
            O aplicativo oficial já está disponível para Android na Google Play Store! A versão iOS (App Store) está em fase de homologação. Baixe agora ou cadastre seu e-mail para receber novidades e avisos VIP.
          </p>

          {/* Interactive Waitlist Form */}
          <div className={styles.waitlistWrap}>
            {!submitted ? (
              <form onSubmit={handleSubmit} className={styles.waitlistForm}>
                <input
                  type="email"
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  placeholder="Digite seu melhor e-mail..."
                  required
                  className={styles.emailInput}
                />
                <button type="submit" className={styles.waitlistBtn}>
                  <Send size={15} />
                  <span>Entrar na Lista VIP</span>
                </button>
              </form>
            ) : (
              <div className={styles.successAlert}>
                <CheckCircle2 size={20} color="var(--success)" />
                <span>
                  Inscrição confirmada! Você receberá novidades e avisos VIP.
                </span>
              </div>
            )}
          </div>

          {/* Store Buttons */}
          <div className={styles.buttonGroup}>
            <a
              href="https://play.google.com/store/apps/details?id=com.interestelar.manhub"
              target="_blank"
              rel="noopener noreferrer"
              className={styles.storeBadgeBtn}
              style={{ textDecoration: "none" }}
            >
              <svg width="22" height="22" viewBox="0 0 24 24" fill="currentColor">
                <path
                  d="M3.609 1.814L13.792 12 3.61 22.186a1.99 1.99 0 0 1-.61-.91V2.724c0-.336.075-.658.21-.91z"
                  fill="#00BFFF"
                />
                <path
                  d="M17.183 8.61L14.73 11.063 4.548.877c.41-.35 1-.456 1.573-.133l11.062 7.866z"
                  fill="#33CCFF"
                />
                <path
                  d="M17.183 15.39L6.12 23.256c-.573.323-1.163.217-1.572-.133L14.73 12.937l2.453 2.453z"
                  fill="#005F9E"
                />
                <path
                  d="M21.39 12l-4.207 2.42-2.453-2.42 2.453-2.42L21.39 12c.813.468.813 1.232 0 1.7z"
                  fill="#E5A93C"
                />
              </svg>
              <div className={styles.storeBadgeText}>
                <span className={styles.storeBadgeSmall}>Disponível no</span>
                <span className={styles.storeBadgeName}>Google Play</span>
              </div>
            </a>

            <div className={styles.storeBadgeBtn} style={{ opacity: 0.85 }}>
              <Apple size={24} />
              <div className={styles.storeBadgeText}>
                <span className={styles.storeBadgeSmall}>Em breve na</span>
                <span className={styles.storeBadgeName}>App Store</span>
              </div>
            </div>
          </div>

          <div className={styles.assuranceRow}>
            <div className={styles.assuranceItem}>
              <Check size={16} color="var(--neon-primary)" />
              <span>Acesso Imediato aos Treinamentos na Web</span>
            </div>
            <div className={styles.assuranceItem}>
              <Check size={16} color="var(--neon-primary)" />
              <span>Notificação imediata no e-mail</span>
            </div>
            <div className={styles.assuranceItem}>
              <Check size={16} color="var(--neon-primary)" />
              <span>Zero Spam</span>
            </div>
            <div className={styles.assuranceItem}>
              <Check size={16} color="var(--neon-primary)" />
              <span>Condições especiais para membros VIP</span>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}
