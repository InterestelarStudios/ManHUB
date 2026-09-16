"use client";

import { useState, useEffect } from "react";
import styles from "./CheckoutModal.module.css";
import { X, ShieldCheck, ArrowRight, Loader2, Sparkles } from "lucide-react";
import { db } from "@/lib/firebase";
import { collection, onSnapshot } from "firebase/firestore";

interface CheckoutModalProps {
  isOpen: boolean;
  onClose: () => void;
  defaultPlan?: "pass" | "training";
  defaultTrainingId?: string;
  defaultTrainingTitle?: string;
}

interface ModalTraining {
  id: string;
  title: string;
  price: number;
}

const DEFAULT_TRAININGS: ModalTraining[] = [
  { id: "e0ee6636-cea6-4f59-8242-6b7270f8254d", title: "O Homem Bem-Vestido", price: 97.0 },
  { id: "f47a8291-3c1e-49fb-9de8-18e329ba4182", title: "Cuidados com Pele, Cabelo e Barba", price: 97.0 },
  { id: "a7e14d9b-83c6-4e5a-bb44-67290f11ac38", title: "Perfumaria Masculina e Assinatura Olfativa", price: 97.0 },
];

export default function CheckoutModal({
  isOpen,
  onClose,
  defaultPlan = "pass",
  defaultTrainingId,
  defaultTrainingTitle,
}: CheckoutModalProps) {
  const [planType, setPlanType] = useState<"pass" | "training">(defaultPlan);
  const [selectedTraining, setSelectedTraining] = useState(
    defaultTrainingId || "e0ee6636-cea6-4f59-8242-6b7270f8254d"
  );
  const [trainingsList, setTrainingsList] = useState<ModalTraining[]>(DEFAULT_TRAININGS);
  const [name, setName] = useState("");
  const [email, setEmail] = useState("");
  const [loading, setLoading] = useState(false);
  const [errorMsg, setErrorMsg] = useState("");

  useEffect(() => {
    try {
      const unsub = onSnapshot(collection(db, "trainings"), (snapshot) => {
        if (!snapshot.empty) {
          const list: ModalTraining[] = snapshot.docs.map((docSnap) => {
            const data = docSnap.data();
            return {
              id: docSnap.id,
              title: data.title || "Treinamento Oficial",
              price: typeof data.price === "number" ? data.price : 97.0,
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

  const currentPrice = planType === "pass" ? 49.9 : 97.0;
  const currentTitle =
    planType === "pass"
      ? "Man Hub Pass - Todos os Cursos"
      : trainingsList.find((t) => t.id === selectedTraining)?.title || defaultTrainingTitle || "Treinamento Man Hub";

  const handleCheckout = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!email || !name) {
      setErrorMsg("Preencha seu nome e e-mail.");
      return;
    }

    setLoading(true);
    setErrorMsg("");

    const normalizedEmail = email.trim().toLowerCase();
    const cleanName = name.trim();

    try {
      const res = await fetch("/api/payments/create-preference", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          userId: `web_${Date.now()}`,
          userName: cleanName,
          userEmail: normalizedEmail,
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
            Pague via <strong>Pix com liberação imediata</strong> ou <strong>cartão de crédito em até 12x</strong>.
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
              <span className={styles.planDesc}>Acesse todos os 3 cursos atuais e lançamentos futuros</span>
            </div>
            <span className={styles.planPrice}>R$ 49,90/mês</span>
          </div>

          <div
            className={`${styles.planOption} ${planType === "training" ? styles.planOptionActive : ""}`}
            onClick={() => setPlanType("training")}
          >
            <div className={styles.planInfo}>
              <span className={styles.planName}>Treinamento Individual (Vitalício)</span>
              <span className={styles.planDesc}>Acesso para sempre ao curso escolhido sem mensalidades</span>
            </div>
            <span className={styles.planPrice}>R$ 97,00</span>
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

        <form onSubmit={handleCheckout} style={{ display: "flex", flexDirection: "column", gap: "16px" }}>
          <div className={styles.formGroup}>
            <label className={styles.label}>Seu Nome Completo:</label>
            <input
              type="text"
              required
              value={name}
              onChange={(e) => setName(e.target.value)}
              placeholder="Ex: Carlos Eduardo"
              className={styles.input}
            />
          </div>

          <div className={styles.formGroup}>
            <label className={styles.label}>Seu Melhor E-mail (o mesmo do App):</label>
            <input
              type="email"
              required
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              placeholder="Ex: seuemail@exemplo.com"
              className={styles.input}
            />
            <span style={{ color: "var(--neon-light)", fontSize: "11px", marginTop: "4px", opacity: 0.9 }}>
              * Seus treinamentos serão liberados automaticamente neste e-mail ao entrar no app.
            </span>
          </div>

          {errorMsg && (
            <div style={{ color: "var(--error)", fontSize: "13px", textAlign: "center" }}>
              {errorMsg}
            </div>
          )}

          <button
            type="submit"
            disabled={loading}
            className="btn btn-primary"
            style={{ width: "100%", padding: "16px", fontSize: "15px", marginTop: "6px" }}
          >
            {loading ? (
              <>
                <Loader2 size={18} className="animate-spin" />
                <span>Conectando ao Mercado Pago...</span>
              </>
            ) : (
              <>
                <span>Pagar R$ {currentPrice.toFixed(2).replace(".", ",")} no Mercado Pago</span>
                <ArrowRight size={18} />
              </>
            )}
          </button>
        </form>

        <div className={styles.securityNote}>
          <ShieldCheck size={16} color="var(--success)" />
          <span>Ambiente 100% Criptografado & Protegido pelo Mercado Pago</span>
        </div>
      </div>
    </div>
  );
}
