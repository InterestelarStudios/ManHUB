"use client";

import React, { useState, useEffect } from "react";
import styles from "./CheckoutModal.module.css";
import {
  X,
  ShieldCheck,
  ArrowRight,
  Loader2,
  Sparkles,
  User as UserIcon,
  CheckCircle,
  LogIn,
} from "lucide-react";
import { db } from "@/lib/firebase";
import { collection, onSnapshot } from "firebase/firestore";
import { useAuth } from "@/lib/context/AuthContext";
import AuthModal from "@/components/auth/AuthModal";

interface CheckoutModalProps {
  isOpen: boolean;
  onClose: () => void;
  defaultPlan?: "pass" | "training";
  defaultTrainingId?: string;
  defaultTrainingTitle?: string;
  defaultPrice?: number;
}

interface ModalTraining {
  id: string;
  title: string;
  price: number;
}

const DEFAULT_TRAININGS: ModalTraining[] = [
  { id: "e0ee6636-cea6-4f59-8242-6b7270f8254d", title: "O Homem Bem-Vestido", price: 249.9 },
  { id: "f47a8291-3c1e-49fb-9de8-18e329ba4182", title: "Cuidados com Pele, Cabelo e Barba", price: 79.9 },
  { id: "a7e14d9b-83c6-4e5a-bb44-67290f11ac38", title: "Perfumaria Masculina e Assinatura Olfativa", price: 159.9 },
];

export default function CheckoutModal({
  isOpen,
  onClose,
  defaultPlan = "pass",
  defaultTrainingId,
  defaultTrainingTitle,
  defaultPrice,
}: CheckoutModalProps) {
  const { user, profile } = useAuth();
  const [planType, setPlanType] = useState<"pass" | "training">(defaultPlan);
  const [selectedTraining, setSelectedTraining] = useState(
    defaultTrainingId || "e0ee6636-cea6-4f59-8242-6b7270f8254d"
  );
  const [trainingsList, setTrainingsList] = useState<ModalTraining[]>(DEFAULT_TRAININGS);
  const [loading, setLoading] = useState(false);
  const [errorMsg, setErrorMsg] = useState("");
  const [isAuthModalOpen, setIsAuthModalOpen] = useState(false);

  useEffect(() => {
    try {
      const unsub = onSnapshot(collection(db, "trainings"), (snapshot) => {
        if (!snapshot.empty) {
          const list: ModalTraining[] = snapshot.docs.map((docSnap) => {
            const data = docSnap.data();
            let parsed = 97.0;
            if (typeof data.price === "number" && data.price > 0) {
              parsed = data.price;
            } else if (data.price) {
              const n = Number(data.price);
              if (!isNaN(n) && n > 0) parsed = n;
            }
            return {
              id: docSnap.id,
              title: data.title || "Treinamento Oficial",
              price: parsed,
            };
          });
          setTrainingsList(list);
        }
      });
      return () => unsub();
    } catch (err) {
      console.warn("Aviso ao buscar treinamentos para Checkout:", err);
    }
  }, []);

  useEffect(() => {
    if (defaultPlan) setPlanType(defaultPlan);
    if (defaultTrainingId) setSelectedTraining(defaultTrainingId);
  }, [defaultPlan, defaultTrainingId]);

  if (!isOpen) return null;

  const selectedTrainingObj = trainingsList.find((t) => t.id === selectedTraining);
  const currentPrice =
    planType === "pass"
      ? 49.9
      : selectedTrainingObj?.price ?? defaultPrice ?? 97.0;
  const currentTitle =
    planType === "pass"
      ? "Man Hub Pass - Todos os Cursos"
      : selectedTrainingObj?.title ||
        defaultTrainingTitle ||
        "Treinamento Man Hub";

  const handleCheckout = async (e: React.FormEvent) => {
    e.preventDefault();

    if (!user) {
      setIsAuthModalOpen(true);
      return;
    }

    setLoading(true);
    setErrorMsg("");

    const userName = profile?.name || user.displayName || user.email?.split("@")[0] || "Membro";
    const userEmail = user.email || "";

    try {
      const res = await fetch("/api/payments/create-preference", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          userId: user.uid,
          userName: userName,
          userEmail: userEmail,
          itemType: planType,
          itemId: planType === "pass" ? "man_hub_pass" : selectedTraining,
          title: currentTitle,
          description:
            planType === "pass"
              ? "Assinatura Man Hub Pass - Acesso Ilimitado"
              : `Acesso Vitalício: ${currentTitle}`,
          price: currentPrice,
        }),
      });

      const data = await res.json();
      if (!res.ok || !data.initPoint) {
        throw new Error(data.error || "Falha ao gerar link de pagamento.");
      }

      // Redireciona para o checkout oficial do Mercado Pago
      window.location.href = data.initPoint;
    } catch (err: any) {
      console.error(err);
      setErrorMsg(err?.message || "Erro ao conectar com o Mercado Pago. Tente novamente.");
      setLoading(false);
    }
  };

  return (
    <>
      <div className={styles.modalOverlay} onClick={onClose}>
        <div className={styles.modalCard} onClick={(e) => e.stopPropagation()}>
          <button className={styles.closeBtn} onClick={onClose} aria-label="Fechar modal">
            <X size={18} />
          </button>

          <div className={styles.modalHeader}>
            <span className="badge-gold">
              <Sparkles size={12} />
              Pagamento Seguro via Mercado Pago
            </span>
            <h2 className={styles.modalTitle}>Adquirir Acesso Man Hub</h2>
            <p className={styles.modalSubtitle}>
              Pague via <strong>Pix com liberação imediata</strong> ou{" "}
              <strong>cartão de crédito em até 12x</strong>.
            </p>
          </div>

          {/* Plan Selection */}
          <div className={styles.planOptions}>
            <div
              className={`${styles.planOption} ${planType === "pass" ? styles.planOptionActive : ""}`}
              onClick={() => setPlanType("pass")}
            >
              <div className={styles.planInfo}>
                <span className={styles.planName}>Man Hub Pass (Acesso Ilimitado)</span>
                <span className={styles.planDesc}>
                  Acesse todos os 3 cursos atuais e lançamentos futuros
                </span>
              </div>
              <span className={styles.planPrice}>R$ 49,90/mês</span>
            </div>

            <div
              className={`${styles.planOption} ${planType === "training" ? styles.planOptionActive : ""}`}
              onClick={() => setPlanType("training")}
            >
              <div className={styles.planInfo}>
                <span className={styles.planName}>Treinamento Individual (Vitalício)</span>
                <span className={styles.planDesc}>
                  Acesso para sempre ao curso escolhido sem mensalidades
                </span>
              </div>
              <span className={styles.planPrice}>
                R$ {(selectedTrainingObj?.price ?? defaultPrice ?? 97.0).toFixed(2).replace(".", ",")}
              </span>
            </div>
          </div>

          {planType === "training" && (
            <div className={styles.formGroup}>
              <label className={styles.label}>Escolha o Treinamento:</label>
              <select
                className={styles.input}
                value={selectedTraining}
                onChange={(e) => setSelectedTraining(e.target.value)}
              >
                {trainingsList.map((t) => (
                  <option key={t.id} value={t.id}>
                    {t.title} - R$ {t.price.toFixed(2).replace(".", ",")}
                  </option>
                ))}
              </select>
            </div>
          )}

          {/* Conta Vinculada ou Prompt de Login */}
          {user ? (
            <div className={styles.connectedAccountCard}>
              <div className={styles.accountIconCircle}>
                <UserIcon size={18} />
              </div>
              <div className={styles.accountDetails}>
                <span className={styles.accountLabel}>Compra Vinculada à Sua Conta</span>
                <span className={styles.accountName}>
                  {profile?.name || user.displayName || "Membro"}
                </span>
                <span className={styles.accountEmail}>{user.email}</span>
              </div>
              <div className={styles.accountBadgeVerified}>
                <CheckCircle size={14} />
                <span>Autenticado</span>
              </div>
            </div>
          ) : (
            <div className={styles.loginPromptBox}>
              <p className={styles.loginPromptText}>
                Para vincular suas compras à sua conta e acessar seus cursos em qualquer dispositivo,
                entre ou cadastre-se primeiro.
              </p>
              <button
                type="button"
                className="btn btn-primary"
                onClick={() => setIsAuthModalOpen(true)}
                style={{ padding: "10px 20px", fontSize: "14px", gap: "6px" }}
              >
                <LogIn size={16} />
                <span>Entrar ou Criar Conta</span>
              </button>
            </div>
          )}

          {errorMsg && (
            <div style={{ color: "var(--error)", fontSize: "13px", textAlign: "center" }}>
              {errorMsg}
            </div>
          )}

          <form onSubmit={handleCheckout}>
            <button
              type="submit"
              disabled={loading || !user}
              className="btn btn-primary"
              style={{
                width: "100%",
                padding: "16px",
                fontSize: "15px",
                marginTop: "6px",
                opacity: !user ? 0.5 : 1,
                cursor: !user ? "not-allowed" : "pointer",
              }}
            >
              {loading ? (
                <>
                  <Loader2 size={18} className="animate-spin" />
                  <span>Conectando ao Mercado Pago...</span>
                </>
              ) : (
                <>
                  <span>
                    Pagar R$ {currentPrice.toFixed(2).replace(".", ",")} no Mercado Pago
                  </span>
                  <ArrowRight size={18} />
                </>
              )}
            </button>
          </form>

          <div className={styles.securityNote}>
            <ShieldCheck size={16} color="var(--neon-primary)" />
            <span>Transação criptografada com garantia incondicional de 7 dias.</span>
          </div>
        </div>
      </div>

      <AuthModal
        isOpen={isAuthModalOpen}
        onClose={() => setIsAuthModalOpen(false)}
      />
    </>
  );
}
