import Link from "next/link";
import Image from "next/image";
import { CheckCircle2, ArrowRight } from "lucide-react";

export default function PaymentSuccessPage() {
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
          Seu acesso já foi liberado no ecossistema <strong>Man Hub</strong>. Se você realizou a compra
          pelo smartphone, basta retornar ao aplicativo — seu treinamento ou assinatura já está
          desbloqueado em tempo real!
        </p>

        <div
          style={{
            padding: "14px 20px",
            background: "rgba(0, 191, 255, 0.08)",
            border: "1px solid rgba(0, 191, 255, 0.2)",
            borderRadius: "var(--radius-md)",
            fontSize: "13px",
            color: "var(--neon-light)",
            width: "100%",
          }}
        >
          Enviamos os detalhes do pedido e o comprovante para o seu e-mail cadastrado.
        </div>

        <Link
          href="/"
          className="btn btn-primary"
          style={{ width: "100%", marginTop: "10px", padding: "16px" }}
        >
          <span>Retornar ao Início</span>
          <ArrowRight size={18} />
        </Link>
      </div>
    </main>
  );
}
