"use client";

import React, { useState, useMemo } from "react";
import {
  getWelcomeEmailHtml,
  getPurchaseConfirmationEmailHtml,
} from "@/lib/email/emailTemplates";
import {
  Mail,
  Send,
  Smartphone,
  Monitor,
  Sparkles,
  CheckCircle2,
  AlertCircle,
  Loader2,
} from "lucide-react";

export default function EmailPreviewPage() {
  const [selectedTemplate, setSelectedTemplate] = useState<"welcome" | "purchase_training" | "purchase_pass">("welcome");
  const [deviceView, setDeviceView] = useState<"desktop" | "mobile">("desktop");
  const [testEmail, setTestEmail] = useState("");
  const [isSending, setIsSending] = useState(false);
  const [feedback, setFeedback] = useState<{ type: "success" | "error"; msg: string } | null>(null);

  const previewHtml = useMemo(() => {
    if (selectedTemplate === "welcome") {
      return getWelcomeEmailHtml({
        userName: "Lucas Silveira",
        userEmail: "lucas.silveira@exemplo.com",
        appUrl: "https://manhub.app",
      });
    } else if (selectedTemplate === "purchase_training") {
      return getPurchaseConfirmationEmailHtml({
        userName: "Lucas Silveira",
        userEmail: "lucas.silveira@exemplo.com",
        itemName: "O Homem Bem-Vestido: Alfaiataria & Proporção",
        itemType: "training",
        amount: 249.90,
        paymentId: "MP-TEST-982341",
        appUrl: "https://manhub.app",
      });
    } else {
      return getPurchaseConfirmationEmailHtml({
        userName: "Lucas Silveira",
        userEmail: "lucas.silveira@exemplo.com",
        itemName: "Man Hub Pass (Acesso Ilimitado Recorrente)",
        itemType: "pass",
        amount: 49.90,
        paymentId: "SUB-TEST-554109",
        appUrl: "https://manhub.app",
      });
    }
  }, [selectedTemplate]);

  const handleSendTest = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!testEmail || !testEmail.includes("@")) {
      setFeedback({ type: "error", msg: "Digite um e-mail válido." });
      return;
    }

    setIsSending(true);
    setFeedback(null);

    try {
      const res = await fetch("/api/email/test-send", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          type: selectedTemplate,
          recipientEmail: testEmail.trim(),
          userName: "Membro Man Hub",
        }),
      });

      const data = await res.json();
      if (!res.ok || data.error) {
        throw new Error(data.error || "Falha ao disparar e-mail.");
      }

      setFeedback({
        type: "success",
        msg: `E-mail de teste enviado com sucesso para ${testEmail}! Verifique sua caixa de entrada ou spam.`,
      });
    } catch (err: any) {
      setFeedback({
        type: "error",
        msg: err?.message || "Erro ao conectar com o serviço de envio.",
      });
    } finally {
      setIsSending(false);
    }
  };

  return (
    <div
      style={{
        minHeight: "100vh",
        background: "var(--bg-main)",
        color: "var(--text-primary)",
        paddingTop: "calc(var(--header-height) + 20px)",
        paddingBottom: "60px",
        display: "flex",
        flexDirection: "column",
        alignItems: "center",
      }}
    >
      <div style={{ maxWidth: "1000px", width: "100%", padding: "0 20px" }}>
        
        {/* Header de Controle */}
        <div style={{ textAlign: "center", marginBottom: "32px" }}>
          <div
            style={{
              display: "inline-flex",
              alignItems: "center",
              gap: "8px",
              padding: "6px 14px",
              borderRadius: "50px",
              background: "rgba(0, 191, 255, 0.12)",
              border: "1px solid rgba(0, 191, 255, 0.3)",
              color: "var(--neon-primary)",
              fontSize: "12px",
              fontWeight: 700,
              textTransform: "uppercase",
              letterSpacing: "0.08em",
              marginBottom: "12px",
            }}
          >
            <Sparkles size={14} />
            Central de E-mails Transacionais
          </div>
          <h1 style={{ fontSize: "28px", fontWeight: 800, margin: "0 0 10px" }}>
            Visualizador de Presets de E-mail
          </h1>
          <p style={{ color: "var(--text-secondary)", fontSize: "15px", margin: 0 }}>
            Veja em tempo real o layout oficial de cada notificação que seu cliente receberá.
          </p>
        </div>

        {/* Barra de Ferramentas / Seletor de Templates */}
        <div
          style={{
            background: "#061224",
            border: "1px solid rgba(0, 191, 255, 0.2)",
            borderRadius: "16px",
            padding: "16px 20px",
            display: "flex",
            flexWrap: "wrap",
            gap: "16px",
            alignItems: "center",
            justifyContent: "space-between",
            marginBottom: "24px",
            boxShadow: "0 10px 30px rgba(0,0,0,0.5)",
          }}
        >
          {/* Tabs dos Templates */}
          <div style={{ display: "flex", gap: "8px", flexWrap: "wrap" }}>
            <button
              onClick={() => { setSelectedTemplate("welcome"); setFeedback(null); }}
              style={{
                display: "inline-flex",
                alignItems: "center",
                gap: "8px",
                padding: "10px 18px",
                borderRadius: "50px",
                fontSize: "13.5px",
                fontWeight: 600,
                cursor: "pointer",
                border: selectedTemplate === "welcome" ? "1px solid var(--neon-primary)" : "1px solid rgba(255,255,255,0.08)",
                background: selectedTemplate === "welcome" ? "rgba(0, 191, 255, 0.15)" : "rgba(255,255,255,0.03)",
                color: selectedTemplate === "welcome" ? "#FFFFFF" : "var(--text-secondary)",
                transition: "all 0.2s ease",
              }}
            >
              <Mail size={16} />
              1. Boas-Vindas (Novo Cadastro)
            </button>

            <button
              onClick={() => { setSelectedTemplate("purchase_training"); setFeedback(null); }}
              style={{
                display: "inline-flex",
                alignItems: "center",
                gap: "8px",
                padding: "10px 18px",
                borderRadius: "50px",
                fontSize: "13.5px",
                fontWeight: 600,
                cursor: "pointer",
                border: selectedTemplate === "purchase_training" ? "1px solid var(--neon-primary)" : "1px solid rgba(255,255,255,0.08)",
                background: selectedTemplate === "purchase_training" ? "rgba(0, 191, 255, 0.15)" : "rgba(255,255,255,0.03)",
                color: selectedTemplate === "purchase_training" ? "#FFFFFF" : "var(--text-secondary)",
                transition: "all 0.2s ease",
              }}
            >
              <CheckCircle2 size={16} />
              2. Compra de Curso Vitalício
            </button>

            <button
              onClick={() => { setSelectedTemplate("purchase_pass"); setFeedback(null); }}
              style={{
                display: "inline-flex",
                alignItems: "center",
                gap: "8px",
                padding: "10px 18px",
                borderRadius: "50px",
                fontSize: "13.5px",
                fontWeight: 600,
                cursor: "pointer",
                border: selectedTemplate === "purchase_pass" ? "1px solid var(--neon-primary)" : "1px solid rgba(255,255,255,0.08)",
                background: selectedTemplate === "purchase_pass" ? "rgba(0, 191, 255, 0.15)" : "rgba(255,255,255,0.03)",
                color: selectedTemplate === "purchase_pass" ? "#FFFFFF" : "var(--text-secondary)",
                transition: "all 0.2s ease",
              }}
            >
              <Sparkles size={16} />
              3. Assinatura Man Hub Pass
            </button>
          </div>

          {/* Toggle Dispositivo */}
          <div style={{ display: "flex", gap: "6px", background: "rgba(0,0,0,0.3)", padding: "4px", borderRadius: "50px", border: "1px solid rgba(255,255,255,0.08)" }}>
            <button
              onClick={() => setDeviceView("desktop")}
              title="Visualização Desktop"
              style={{
                display: "inline-flex",
                alignItems: "center",
                gap: "6px",
                padding: "6px 12px",
                borderRadius: "50px",
                fontSize: "12px",
                fontWeight: 600,
                border: "none",
                cursor: "pointer",
                background: deviceView === "desktop" ? "var(--neon-primary)" : "transparent",
                color: deviceView === "desktop" ? "#040D1A" : "var(--text-secondary)",
              }}
            >
              <Monitor size={14} />
              Desktop
            </button>

            <button
              onClick={() => setDeviceView("mobile")}
              title="Visualização Mobile"
              style={{
                display: "inline-flex",
                alignItems: "center",
                gap: "6px",
                padding: "6px 12px",
                borderRadius: "50px",
                fontSize: "12px",
                fontWeight: 600,
                border: "none",
                cursor: "pointer",
                background: deviceView === "mobile" ? "var(--neon-primary)" : "transparent",
                color: deviceView === "mobile" ? "#040D1A" : "var(--text-secondary)",
              }}
            >
              <Smartphone size={14} />
              Mobile
            </button>
          </div>
        </div>

        {/* Caixa de Teste de Envio Real */}
        <form
          onSubmit={handleSendTest}
          style={{
            background: "rgba(7, 20, 38, 0.6)",
            border: "1px solid rgba(0, 191, 255, 0.15)",
            borderRadius: "12px",
            padding: "16px 20px",
            display: "flex",
            flexWrap: "wrap",
            gap: "12px",
            alignItems: "center",
            justifyContent: "space-between",
            marginBottom: "24px",
          }}
        >
          <div style={{ display: "flex", alignItems: "center", gap: "10px", flex: 1, minWidth: "260px" }}>
            <Send size={18} color="var(--neon-primary)" />
            <span style={{ fontSize: "13.5px", color: "var(--text-secondary)", fontWeight: 500 }}>
              Quer receber este e-mail na sua caixa de entrada agora?
            </span>
          </div>

          <div style={{ display: "flex", gap: "10px", flexWrap: "wrap", flex: 1, justifyContent: "flex-end", minWidth: "280px" }}>
            <input
              type="email"
              placeholder="Digite seu e-mail para testar..."
              value={testEmail}
              onChange={(e) => setTestEmail(e.target.value)}
              style={{
                flex: 1,
                minWidth: "220px",
                padding: "10px 14px",
                borderRadius: "8px",
                background: "#040D1A",
                border: "1px solid rgba(255,255,255,0.15)",
                color: "#FFFFFF",
                fontSize: "13.5px",
                outline: "none",
              }}
            />
            <button
              type="submit"
              disabled={isSending}
              style={{
                display: "inline-flex",
                alignItems: "center",
                gap: "8px",
                padding: "10px 20px",
                borderRadius: "8px",
                background: "linear-gradient(135deg, var(--neon-primary) 0%, var(--royal-blue) 100%)",
                border: "none",
                color: "#FFFFFF",
                fontSize: "13.5px",
                fontWeight: 700,
                cursor: isSending ? "not-allowed" : "pointer",
                opacity: isSending ? 0.7 : 1,
              }}
            >
              {isSending ? <Loader2 size={16} className="animate-spin" /> : <Send size={15} />}
              <span>{isSending ? "Enviando..." : "Disparar Teste Real"}</span>
            </button>
          </div>
        </form>

        {/* Feedback Alert */}
        {feedback && (
          <div
            style={{
              padding: "12px 18px",
              borderRadius: "8px",
              display: "flex",
              alignItems: "center",
              gap: "10px",
              marginBottom: "20px",
              fontSize: "13.5px",
              background: feedback.type === "success" ? "rgba(76, 175, 80, 0.15)" : "rgba(239, 68, 68, 0.15)",
              border: feedback.type === "success" ? "1px solid rgba(76, 175, 80, 0.4)" : "1px solid rgba(239, 68, 68, 0.4)",
              color: feedback.type === "success" ? "#81C784" : "#F87171",
            }}
          >
            {feedback.type === "success" ? <CheckCircle2 size={18} /> : <AlertCircle size={18} />}
            <span>{feedback.msg}</span>
          </div>
        )}

        {/* Frame de Visualização */}
        <div
          style={{
            display: "flex",
            justifyContent: "center",
            width: "100%",
          }}
        >
          <div
            style={{
              width: deviceView === "desktop" ? "100%" : "400px",
              maxWidth: deviceView === "desktop" ? "680px" : "400px",
              height: "760px",
              background: "#040D1A",
              border: "1px solid rgba(0, 191, 255, 0.25)",
              borderRadius: deviceView === "desktop" ? "16px" : "36px",
              padding: deviceView === "mobile" ? "16px 8px" : "0",
              boxShadow: "0 25px 60px rgba(0,0,0,0.8), 0 0 35px rgba(0, 191, 255, 0.15)",
              overflow: "hidden",
              transition: "all 0.3s cubic-bezier(0.16, 1, 0.3, 1)",
            }}
          >
            <iframe
              title="Prévia do E-mail"
              srcDoc={previewHtml}
              style={{
                width: "100%",
                height: "100%",
                border: "none",
                borderRadius: deviceView === "desktop" ? "16px" : "28px",
                background: "#040D1A",
              }}
            />
          </div>
        </div>

      </div>
    </div>
  );
}
