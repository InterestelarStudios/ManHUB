"use client";

import { useState } from "react";
import { Trash2, AlertCircle, CheckCircle2, Loader2, ArrowRight } from "lucide-react";

export default function AccountDeletionForm() {
  const [email, setEmail] = useState("");
  const [reason, setReason] = useState("");
  const [confirmed, setConfirmed] = useState(false);
  const [loading, setLoading] = useState(false);
  const [protocol, setProtocol] = useState<string | null>(null);
  const [errorMessage, setErrorMessage] = useState<string | null>(null);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!email || !email.includes("@")) {
      setErrorMessage("Por favor, informe um endereço de e-mail válido.");
      return;
    }
    if (!confirmed) {
      setErrorMessage("Você precisa marcar a caixa confirmando que está ciente da exclusão definitiva.");
      return;
    }

    setLoading(true);
    setErrorMessage(null);

    try {
      const res = await fetch("/api/account-deletion", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ email, reason }),
      });

      const data = await res.json();
      if (!res.ok) {
        throw new Error(data.error || "Erro ao registrar solicitação.");
      }

      setProtocol(data.protocol || `DEL-${Date.now().toString(36).toUpperCase()}`);
    } catch (err: any) {
      setErrorMessage(err.message || "Ocorreu um erro ao enviar sua solicitação.");
    } finally {
      setLoading(false);
    }
  };

  if (protocol) {
    return (
      <div style={{
        background: "rgba(129, 199, 132, 0.08)",
        border: "1px solid rgba(129, 199, 132, 0.3)",
        borderRadius: "14px",
        padding: "32px",
        textAlign: "center",
        margin: "24px 0"
      }}>
        <div style={{
          width: "56px",
          height: "56px",
          borderRadius: "50%",
          background: "rgba(129, 199, 132, 0.2)",
          color: "var(--success)",
          display: "flex",
          alignItems: "center",
          justifyContent: "center",
          margin: "0 auto 16px"
        }}>
          <CheckCircle2 size={32} />
        </div>
        <h3 style={{ color: "#FFFFFF", fontSize: "20px", marginBottom: "8px" }}>
          Solicitação de Exclusão Registrada!
        </h3>
        <p style={{ color: "var(--text-secondary)", fontSize: "14.5px", marginBottom: "16px" }}>
          Sua solicitação para a conta vinculada ao e-mail <strong>{email}</strong> foi recebida com sucesso.
        </p>
        <div style={{
          display: "inline-block",
          background: "rgba(4, 13, 26, 0.7)",
          border: "1px dashed var(--card-border)",
          padding: "10px 20px",
          borderRadius: "8px",
          marginBottom: "16px"
        }}>
          <span style={{ fontSize: "12px", color: "var(--text-muted)", display: "block" }}>Protocolo de Atendimento:</span>
          <span style={{ fontSize: "18px", fontWeight: 700, color: "var(--neon-primary)", letterSpacing: "0.08em" }}>
            {protocol}
          </span>
        </div>
        <p style={{ color: "var(--text-muted)", fontSize: "13px", margin: 0 }}>
          O processo de desativação e exclusão é processado em até 5 dias úteis. Um e-mail de confirmação será enviado quando a remoção for concluída.
        </p>
      </div>
    );
  }

  return (
    <form onSubmit={handleSubmit} style={{
      background: "rgba(7, 20, 38, 0.7)",
      border: "1px solid var(--card-border)",
      borderRadius: "14px",
      padding: "28px",
      margin: "24px 0"
    }}>
      <h3 style={{
        fontSize: "18px",
        color: "#FFFFFF",
        marginBottom: "16px",
        display: "flex",
        alignItems: "center",
        gap: "10px"
      }}>
        <Trash2 size={20} color="var(--error)" />
        Formulário Web de Solicitação de Exclusão
      </h3>

      <p style={{ fontSize: "14px", color: "var(--text-secondary)", marginBottom: "20px" }}>
        Caso não tenha mais acesso ao aplicativo instalado, preencha o e-mail cadastrado no MAN HUB para solicitar a exclusão de todos os seus dados:
      </p>

      {errorMessage && (
        <div style={{
          background: "rgba(229, 115, 115, 0.12)",
          border: "1px solid rgba(229, 115, 115, 0.35)",
          color: "var(--error)",
          borderRadius: "8px",
          padding: "12px 16px",
          fontSize: "13.5px",
          display: "flex",
          alignItems: "center",
          gap: "10px",
          marginBottom: "18px"
        }}>
          <AlertCircle size={18} style={{ flexShrink: 0 }} />
          <span>{errorMessage}</span>
        </div>
      )}

      <div style={{ marginBottom: "18px" }}>
        <label style={{ display: "block", fontSize: "13.5px", color: "var(--text-primary)", fontWeight: 600, marginBottom: "8px" }}>
          E-mail cadastrado no MAN HUB *
        </label>
        <input
          type="email"
          required
          placeholder="exemplo@email.com"
          value={email}
          onChange={(e) => setEmail(e.target.value)}
          style={{
            width: "100%",
            padding: "12px 16px",
            background: "rgba(4, 13, 26, 0.8)",
            border: "1px solid var(--card-border)",
            borderRadius: "8px",
            color: "#FFFFFF",
            fontSize: "14.5px",
            outline: "none"
          }}
        />
      </div>

      <div style={{ marginBottom: "18px" }}>
        <label style={{ display: "block", fontSize: "13.5px", color: "var(--text-primary)", fontWeight: 600, marginBottom: "8px" }}>
          Motivo da exclusão (opcional)
        </label>
        <textarea
          rows={3}
          placeholder="Conte-nos o motivo ou deixe em branco se preferir..."
          value={reason}
          onChange={(e) => setReason(e.target.value)}
          style={{
            width: "100%",
            padding: "12px 16px",
            background: "rgba(4, 13, 26, 0.8)",
            border: "1px solid var(--card-border)",
            borderRadius: "8px",
            color: "#FFFFFF",
            fontSize: "14.5px",
            outline: "none",
            resize: "vertical"
          }}
        />
      </div>

      <div style={{ marginBottom: "22px" }}>
        <label style={{
          display: "flex",
          alignItems: "flex-start",
          gap: "10px",
          cursor: "pointer",
          fontSize: "13.5px",
          color: "var(--text-secondary)"
        }}>
          <input
            type="checkbox"
            checked={confirmed}
            onChange={(e) => setConfirmed(e.target.checked)}
            style={{ marginTop: "3px", accentColor: "var(--error)", width: "16px", height: "16px" }}
          />
          <span>
            Estou ciente de que esta ação é <strong>irreversível</strong>. Meu acesso a cursos, progresso, looks e histórico será permanentemente excluído.
          </span>
        </label>
      </div>

      <button
        type="submit"
        disabled={loading}
        style={{
          display: "inline-flex",
          alignItems: "center",
          gap: "8px",
          background: "linear-gradient(135deg, #E57373 0%, #D32F2F 100%)",
          color: "#FFFFFF",
          border: "none",
          padding: "12px 24px",
          borderRadius: "8px",
          fontWeight: 600,
          fontSize: "14px",
          cursor: loading ? "not-allowed" : "pointer",
          opacity: loading ? 0.7 : 1,
          boxShadow: "0 4px 15px rgba(211, 47, 47, 0.3)"
        }}
      >
        {loading ? (
          <>
            <Loader2 size={16} className="spinner" />
            <span>Processando solicitação...</span>
          </>
        ) : (
          <>
            <Trash2 size={16} />
            <span>Confirmar Solicitação de Exclusão</span>
          </>
        )}
      </button>
    </form>
  );
}
