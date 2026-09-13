import Link from "next/link";
import Image from "next/image";
import { XCircle, RotateCcw } from "lucide-react";

export default function PaymentFailurePage() {
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
      }}
    >
      <div className="ambient-glow-top" />

      <div
        className="glass-card"
        style={{
          maxWidth: "520px",
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
            background: "rgba(229, 115, 115, 0.15)",
            border: "2px solid var(--error)",
            display: "flex",
            alignItems: "center",
            justifyContent: "center",
            color: "var(--error)",
            boxShadow: "0 0 24px rgba(229, 115, 115, 0.3)",
          }}
        >
          <XCircle size={36} />
        </div>

        <h1 style={{ fontSize: "26px", fontWeight: 800, color: "#fff" }}>
          Pagamento Não Concluído
        </h1>

        <p style={{ color: "var(--text-secondary)", fontSize: "15px", lineHeight: 1.6 }}>
          A transação no Mercado Pago foi cancelada ou recusada pela operadora do cartão. Nenhuma
          cobrança foi realizada na sua conta.
        </p>

        <Link
          href="/"
          className="btn btn-primary"
          style={{ width: "100%", marginTop: "10px", padding: "16px" }}
        >
          <RotateCcw size={18} />
          <span>Voltar e Tentar Novamente</span>
        </Link>
      </div>
    </main>
  );
}
