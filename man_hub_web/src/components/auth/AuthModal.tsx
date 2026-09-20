"use client";

import React, { useState } from "react";
import styles from "./AuthModal.module.css";
import { useAuth } from "@/lib/context/AuthContext";
import { X, Eye, EyeOff, Loader2, AlertCircle, CheckCircle, Sparkles } from "lucide-react";

interface AuthModalProps {
  isOpen: boolean;
  onClose: () => void;
  defaultMode?: "login" | "register";
}

export default function AuthModal({
  isOpen,
  onClose,
  defaultMode = "login",
}: AuthModalProps) {
  const { loginWithEmail, registerWithEmail, loginWithGoogle, sendPasswordReset } = useAuth();

  const [mode, setMode] = useState<"login" | "register" | "forgot">(defaultMode);
  const [name, setName] = useState("");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [showPassword, setShowPassword] = useState(false);
  const [loading, setLoading] = useState(false);
  const [errorMsg, setErrorMsg] = useState("");
  const [successMsg, setSuccessMsg] = useState("");

  if (!isOpen) return null;

  const resetMessages = () => {
    setErrorMsg("");
    setSuccessMsg("");
  };

  const parseFirebaseError = (err: any): string => {
    const code = err?.code || "";
    switch (code) {
      case "auth/user-not-found":
      case "auth/wrong-password":
      case "auth/invalid-credential":
        return "E-mail ou senha incorretos. Verifique suas credenciais.";
      case "auth/email-already-in-use":
        return "Este e-mail já está cadastrado. Alterne para a aba 'Entrar'.";
      case "auth/weak-password":
        return "A senha deve conter no mínimo 6 caracteres.";
      case "auth/invalid-email":
        return "Por favor, digite um e-mail válido.";
      case "auth/popup-closed-by-user":
        return "A janela de login com o Google foi fechada antes de concluir.";
      case "auth/too-many-requests":
        return "Muitas tentativas sem sucesso. Tente novamente mais tarde.";
      default:
        return err?.message || "Ocorreu um erro ao processar. Tente novamente.";
    }
  };

  const handleGoogleLogin = async () => {
    resetMessages();
    setLoading(true);
    try {
      await loginWithGoogle();
      onClose();
    } catch (err) {
      setErrorMsg(parseFirebaseError(err));
    } finally {
      setLoading(false);
    }
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    resetMessages();
    setLoading(true);

    try {
      if (mode === "login") {
        await loginWithEmail(email, password);
        onClose();
      } else if (mode === "register") {
        if (!name.trim()) {
          throw new Error("Por favor, informe seu nome completo.");
        }
        await registerWithEmail(name, email, password);
        onClose();
      } else if (mode === "forgot") {
        if (!email.trim()) {
          throw new Error("Digite seu e-mail para receber as instruções.");
        }
        await sendPasswordReset(email);
        setSuccessMsg("E-mail de redefinição enviado! Verifique sua caixa de entrada.");
      }
    } catch (err: any) {
      setErrorMsg(parseFirebaseError(err));
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className={styles.overlay} onClick={onClose}>
      <div className={styles.modal} onClick={(e) => e.stopPropagation()}>
        <button className={styles.closeBtn} onClick={onClose} aria-label="Fechar">
          <X size={18} />
        </button>

        {/* Header */}
        <div className={styles.header}>
          <div className={styles.logoBadge}>
            <Sparkles size={12} />
            <span>Man Hub ID</span>
          </div>

          <h2 className={styles.title}>
            {mode === "login"
              ? "Acesse Sua Conta"
              : mode === "register"
              ? "Crie Sua Conta"
              : "Recuperar Senha"}
          </h2>
          <p className={styles.subtitle}>
            {mode === "login"
              ? "Continue sua jornada de evolução pessoal"
              : mode === "register"
              ? "Comece agora a forjar o homem de valor"
              : "Digite seu e-mail para redefinir o acesso"}
          </p>
        </div>

        {/* Tabs for Login / Register */}
        {mode !== "forgot" ? (
          <div className={styles.tabs}>
            <button
              className={`${styles.tab} ${mode === "login" ? styles.active : ""}`}
              onClick={() => {
                setMode("login");
                resetMessages();
              }}
            >
              Entrar
            </button>
            <button
              className={`${styles.tab} ${mode === "register" ? styles.active : ""}`}
              onClick={() => {
                setMode("register");
                resetMessages();
              }}
            >
              Criar Conta
            </button>
          </div>
        ) : null}

        {/* Google Sign-in */}
        {mode !== "forgot" && (
          <>
            <button
              type="button"
              className={styles.googleBtn}
              onClick={handleGoogleLogin}
              disabled={loading}
            >
              <svg className={styles.googleIcon} viewBox="0 0 24 24">
                <path
                  fill="#4285F4"
                  d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"
                />
                <path
                  fill="#34A853"
                  d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"
                />
                <path
                  fill="#FBBC05"
                  d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.06H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.94l2.85-2.22.81-.63z"
                />
                <path
                  fill="#EA4335"
                  d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.06l3.66 2.84c.87-2.6 3.3-4.52 6.16-4.52z"
                />
              </svg>
              <span>Continuar com o Google</span>
            </button>

            <div className={styles.divider}>
              <div className={styles.dividerLine} />
              <span>ou com seu e-mail</span>
              <div className={styles.dividerLine} />
            </div>
          </>
        )}

        {/* Email & Password Form */}
        <form onSubmit={handleSubmit} className={styles.form}>
          {errorMsg && (
            <div className={styles.errorBanner}>
              <AlertCircle size={16} style={{ flexShrink: 0 }} />
              <span>{errorMsg}</span>
            </div>
          )}

          {successMsg && (
            <div className={styles.successBanner}>
              <CheckCircle size={16} style={{ flexShrink: 0 }} />
              <span>{successMsg}</span>
            </div>
          )}

          {mode === "register" && (
            <div className={styles.inputGroup}>
              <label className={styles.label}>Nome Completo</label>
              <div className={styles.inputWrapper}>
                <input
                  type="text"
                  placeholder="Ex: Carlos Silva"
                  value={name}
                  onChange={(e) => setName(e.target.value)}
                  className={styles.input}
                  required
                />
              </div>
            </div>
          )}

          <div className={styles.inputGroup}>
            <label className={styles.label}>E-mail</label>
            <div className={styles.inputWrapper}>
              <input
                type="email"
                placeholder="seuemail@exemplo.com"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                className={styles.input}
                required
              />
            </div>
          </div>

          {mode !== "forgot" && (
            <div className={styles.inputGroup}>
              <label className={styles.label}>Senha</label>
              <div className={styles.inputWrapper}>
                <input
                  type={showPassword ? "text" : "password"}
                  placeholder="••••••••"
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  className={styles.input}
                  required
                />
                <button
                  type="button"
                  className={styles.togglePasswordBtn}
                  onClick={() => setShowPassword(!showPassword)}
                >
                  {showPassword ? <EyeOff size={16} /> : <Eye size={16} />}
                </button>
              </div>
            </div>
          )}

          {mode === "login" && (
            <button
              type="button"
              className={styles.forgotPasswordLink}
              onClick={() => {
                setMode("forgot");
                resetMessages();
              }}
            >
              Esqueceu sua senha?
            </button>
          )}

          <button
            type="submit"
            className={styles.submitBtn}
            disabled={loading}
          >
            {loading ? (
              <>
                <Loader2 size={18} className={styles.spinner} />
                <span>Processando...</span>
              </>
            ) : mode === "login" ? (
              "Acessar Conta"
            ) : mode === "register" ? (
              "Criar Minha Conta"
            ) : (
              "Enviar Instruções"
            )}
          </button>

          {mode === "forgot" && (
            <button
              type="button"
              className={styles.forgotPasswordLink}
              style={{ alignSelf: "center", marginTop: "0.5rem" }}
              onClick={() => {
                setMode("login");
                resetMessages();
              }}
            >
              Voltar para o login
            </button>
          )}
        </form>
      </div>
    </div>
  );
}
