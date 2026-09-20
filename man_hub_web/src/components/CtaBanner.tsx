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

          <span className="badge-gold">
            <Sparkles size={13} />
            Aplicativo Mobile em Homologação
          </span>

          <h2 className={styles.bannerTitle}>
            Seja um dos primeiros a experimentar o <br />
            <span className="text-gradient">MAN HUB nas lojas oficiais.</span>
          </h2>

          <p className={styles.bannerSubtitle}>
            O aplicativo está em fase final de homologação e testes fechados. Cadastre seu e-mail para
            receber o convite VIP e ser notificado no instante em que estiver liberado para download.
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
                  Inscrição confirmada! Você será avisado no instante em que o app for lançado.
                </span>
              </div>
            )}
          </div>

          {/* Store Buttons with 'Em Breve' */}
          <div className={styles.buttonGroup}>
            <div className={styles.storeBadgeBtn}>
              <Apple size={24} />
              <div className={styles.storeBadgeText}>
                <span className={styles.storeBadgeSmall}>Em breve na</span>
                <span className={styles.storeBadgeName}>App Store</span>
              </div>
            </div>

            <div className={styles.storeBadgeBtn}>
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
                <span className={styles.storeBadgeSmall}>Em breve no</span>
                <span className={styles.storeBadgeName}>Google Play</span>
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
