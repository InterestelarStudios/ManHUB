"use client";

import React, { useEffect, Suspense } from "react";
import { useSearchParams } from "next/navigation";
import Link from "next/link";
import Image from "next/image";
import { CheckCircle2, ArrowRight } from "lucide-react";
import { trackPurchase } from "@/lib/tracking/pixel";

function PaymentSuccessContent() {
  const searchParams = useSearchParams();
  const paymentId = searchParams.get("payment_id") || searchParams.get("collection_id") || "order_" + Date.now();

  useEffect(() => {
    trackPurchase({
      id: paymentId,
      name: "Assinatura / Treinamento Man Hub",
      price: 49.90,
      currency: "BRL",
    });
  }, [paymentId]);

  return (
    <main
      style={{
        minHeight: "100vh",
        display: "flex",
        alignItems: "center",
        justifyContent: "center",
        padding: "24px",
        background: "var(--bg-main)",
        position: "relative",
        overflow: "hidden",
      }}
    >
      <div className="ambient-glow-top" />

      <div
        className="glass-card"
        style={{
          maxWidth: "540px",
          width: "100%",
          padding: "48px 32px",
          textAlign: "center",
          display: "flex",
          flexDirection: "column",
          alignItems: "center",
          gap: "20px",
          position: "relative",
          zIndex: 10,
        }}
      >
        <Image
          src="/manhub_icon.png"
          alt="Man Hub Logo"
          width={60}
          height={60}
          style={{ objectFit: "contain", filter: "drop-shadow(0 0 14px rgba(0, 191, 255, 0.7))" }}
        />

        <div
          style={{
            width: "68px",
            height: "68px",
            borderRadius: "50%",
            background: "rgba(129, 199, 132, 0.15)",
            border: "2px solid var(--success)",
            display: "flex",
            alignItems: "center",
            justifyContent: "center",
            color: "var(--success)",
            boxShadow: "0 0 24px rgba(129, 199, 132, 0.3)",
          }}
        >
          <CheckCircle2 size={36} />
        </div>

        <span className="badge-gold">Transação Aprovada</span>

        <h1 style={{ fontSize: "28px", fontWeight: 800, color: "#fff", lineHeight: 1.2 }}>
          Pagamento Confirmado!
        </h1>

        <p style={{ color: "var(--text-secondary)", fontSize: "15px", lineHeight: 1.6 }}>
          Seu acesso já foi liberado no ecossistema <strong>Man Hub</strong>! O conteúdo adquirido está
          vinculado diretamente ao seu e-mail de compra para consumo imediato no aplicativo.
        </p>

        <div
          style={{
            padding: "18px 20px",
            background: "rgba(0, 191, 255, 0.08)",
            border: "1px solid rgba(0, 191, 255, 0.25)",
            borderRadius: "var(--radius-md)",
            fontSize: "13px",
            color: "var(--text-primary)",
            width: "100%",
            textAlign: "left",
            display: "flex",
            flexDirection: "column",
            gap: "8px",
          }}
        >
          <strong style={{ color: "var(--neon-light)", fontSize: "14px" }}>
            Passos para começar agora mesmo:
          </strong>
          <div style={{ color: "var(--text-secondary)", fontSize: "13px", lineHeight: 1.5 }}>
            1. Abra o aplicativo <strong>Man Hub</strong> no seu celular.<br />
            2. Faça login ou crie sua conta utilizando o <strong>mesmo e-mail</strong> desta compra.<br />
            3. Pronto! Seus treinamentos e o <strong>Man Hub Pass</strong> estarão liberados automaticamente.
          </div>
        </div>

        <div style={{ display: "flex", flexDirection: "column", width: "100%", gap: "10px", marginTop: "10px" }}>
          <a
            href="https://play.google.com/store/apps/details?id=com.interestelar.manhub"
            target="_blank"
            rel="noopener noreferrer"
            className="btn btn-primary"
            style={{ width: "100%", padding: "16px", justifyContent: "center" }}
          >
            <span>Baixar / Abrir na Google Play</span>
            <ArrowRight size={18} />
          </a>

          <Link
            href="/"
            className="btn btn-secondary"
            style={{ width: "100%", padding: "14px", justifyContent: "center" }}
          >
            <span>Retornar ao Site</span>
          </Link>
        </div>
      </div>
    </main>
  );
}

export default function PaymentSuccessPage() {
  return (
    <Suspense fallback={<div style={{ minHeight: "100vh", background: "var(--bg-main)" }} />}>
      <PaymentSuccessContent />
    </Suspense>
  );
}
