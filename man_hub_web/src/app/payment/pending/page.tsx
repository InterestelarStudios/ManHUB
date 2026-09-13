import Link from "next/link";
import Image from "next/image";
import { Clock, ArrowRight } from "lucide-react";

export default function PaymentPendingPage() {
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
            background: "rgba(229, 169, 60, 0.15)",
            border: "2px solid var(--gold-accent)",
            display: "flex",
            alignItems: "center",
            justifyContent: "center",
            color: "var(--gold-accent)",
            boxShadow: "0 0 24px rgba(229, 169, 60, 0.3)",
          }}
        >
          <Clock size={36} />
        </div>

        <h1 style={{ fontSize: "26px", fontWeight: 800, color: "#fff" }}>
          Pagamento em Processamento
        </h1>

        <p style={{ color: "var(--text-secondary)", fontSize: "15px", lineHeight: 1.6 }}>
          Seu pagamento via Pix ou Boleto foi gerado e está aguardando compensação bancária. Assim
          que o Mercado Pago confirmar a liquidação, seu acesso será liberado automaticamente.
        </p>

        <Link
          href="/"
          className="btn btn-primary"
          style={{ width: "100%", marginTop: "10px", padding: "16px" }}
        >
          <span>Voltar para o Início</span>
          <ArrowRight size={18} />
        </Link>
      </div>
    </main>
  );
}
