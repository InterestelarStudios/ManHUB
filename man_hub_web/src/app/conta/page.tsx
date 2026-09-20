"use client";

import React, { useState, useEffect } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import styles from "./Conta.module.css";
import { useAuth } from "@/lib/context/AuthContext";
import { useProgress } from "@/lib/context/ProgressContext";
import { getAllCourses } from "@/lib/coursesData";
import { db } from "@/lib/firebase";
import { doc, setDoc, serverTimestamp } from "firebase/firestore";
import AuthModal from "@/components/auth/AuthModal";
import CheckoutModal from "@/components/CheckoutModal";
import {
  User,
  BookOpen,
  Shield,
  LogOut,
  Play,
  Lock,
  CheckCircle2,
  AlertCircle,
  Loader2,
  Sparkles,
  Layers,
  Clock,
  KeyRound,
  Save,
} from "lucide-react";

export default function ContaPage() {
  const router = useRouter();
  const { user, profile, loading, isSubscribed, hasAccessToTraining, sendPasswordReset, logout } =
    useAuth();
  const { getProgress } = useProgress();

  const [activeTab, setActiveTab] = useState<"courses" | "profile" | "security">("courses");
  const [name, setName] = useState("");
  const [phone, setPhone] = useState("");
  const [savingProfile, setSavingProfile] = useState(false);
  const [profileMsg, setProfileMsg] = useState<{ type: "success" | "error"; text: string } | null>(
    null
  );

  const [resetSent, setResetSent] = useState(false);
  const [resetLoading, setResetLoading] = useState(false);
  const [resetError, setResetError] = useState("");

  const [isAuthModalOpen, setIsAuthModalOpen] = useState(false);
  const [isCheckoutOpen, setIsCheckoutOpen] = useState(false);
  const [selectedTrainingId, setSelectedTrainingId] = useState<string | undefined>();
  const [selectedTrainingTitle, setSelectedTrainingTitle] = useState<string | undefined>();

  const courses = getAllCourses();

  useEffect(() => {
    if (profile) {
      setName(profile.name || "");
      setPhone(profile.phone || "");
    } else if (user) {
      setName(user.displayName || "");
    }
  }, [profile, user]);

  if (loading) {
    return (
      <div
        className={styles.container}
        style={{ display: "flex", alignItems: "center", justifyContent: "center" }}
      >
        <div style={{ textAlign: "center" }}>
          <Loader2 size={32} className="animate-spin" style={{ color: "var(--neon-primary)" }} />
          <p style={{ marginTop: "1rem", color: "var(--text-secondary)" }}>Carregando sua conta...</p>
        </div>
      </div>
    );
  }

  if (!user) {
    return (
      <div className={styles.container}>
        <div style={{ textAlign: "center", padding: "5rem 1.5rem" }}>
          <div
            style={{
              width: "64px",
              height: "64px",
              borderRadius: "50%",
              background: "rgba(0, 191, 255, 0.15)",
              color: "var(--neon-primary)",
              display: "flex",
              alignItems: "center",
              justifyContent: "center",
              margin: "0 auto 1.5rem",
            }}
          >
            <User size={30} />
          </div>
          <h2 style={{ fontSize: "1.75rem", marginBottom: "0.5rem", color: "#FFFFFF" }}>
            Acesso à Conta
          </h2>
          <p style={{ color: "var(--text-secondary)", marginBottom: "2rem", maxWidth: "420px", margin: "0 auto 2rem" }}>
            Você precisa estar conectado para visualizar seus treinamentos, dados e segurança.
          </p>
          <button
            onClick={() => setIsAuthModalOpen(true)}
            className="btn btn-primary"
            style={{ padding: "12px 28px", fontSize: "15px" }}
          >
            Entrar ou Criar Conta
          </button>
        </div>

        <AuthModal
          isOpen={isAuthModalOpen}
          onClose={() => setIsAuthModalOpen(false)}
        />
      </div>
    );
  }

  const displayName = profile?.name || user.displayName || user.email?.split("@")[0] || "Membro";
  const initial = displayName.charAt(0).toUpperCase();

  const memberStatus = isSubscribed
    ? "Membro Pass (Acesso Ilimitado)"
    : profile?.unlockedTrainingIds && profile.unlockedTrainingIds.length > 0
    ? "Aluno Oficial"
    : "Visitante";

  const handleSaveProfile = async (e: React.FormEvent) => {
    e.preventDefault();
    setProfileMsg(null);
    setSavingProfile(true);

    try {
      const userRef = doc(db, "users", user.uid);
      await setDoc(
        userRef,
        {
          name: name.trim(),
          phone: phone.trim(),
          updatedAt: serverTimestamp(),
        },
        { merge: true }
      );
      setProfileMsg({ type: "success", text: "Dados atualizados com sucesso!" });
    } catch (err: any) {
      console.error(err);
      setProfileMsg({ type: "error", text: "Falha ao salvar dados. Tente novamente." });
    } finally {
      setSavingProfile(false);
    }
  };

  const handlePasswordReset = async () => {
    if (!user.email) return;
    setResetLoading(true);
    setResetError("");
    setResetSent(false);

    try {
      await sendPasswordReset(user.email);
      setResetSent(true);
    } catch (err: any) {
      setResetError("Não foi possível enviar o e-mail de redefinição.");
    } finally {
      setResetLoading(false);
    }
  };

  const handleBuyTraining = (tId: string, tTitle: string) => {
    setSelectedTrainingId(tId);
    setSelectedTrainingTitle(tTitle);
    setIsCheckoutOpen(true);
  };

  return (
    <div className={styles.container}>
      {/* Profile Hero Header */}
      <section className={styles.profileHero}>
        <div className={styles.heroCard}>
          <div className={styles.userProfileLeft}>
            {profile?.profileImageUrl ? (
              <img src={profile.profileImageUrl} alt={displayName} className={styles.avatar} />
            ) : (
              <div className={styles.avatarFallback}>{initial}</div>
            )}

            <div className={styles.userInfo}>
              <h1 className={styles.userName}>{displayName}</h1>
              <p className={styles.userEmail}>{user.email}</p>
              <div className={styles.badgesRow}>
                <span
                  className={`${styles.statusBadge} ${
                    isSubscribed
                      ? styles.statusBadgePass
                      : profile?.unlockedTrainingIds && profile.unlockedTrainingIds.length > 0
                      ? styles.statusBadgeOfficial
                      : styles.statusBadgeVisitor
                  }`}
                >
                  <Sparkles size={12} />
                  <span>{memberStatus}</span>
                </span>
              </div>
            </div>
          </div>

          <button
            className={styles.logoutBtn}
            onClick={async () => {
              await logout();
              router.push("/");
            }}
          >
            <LogOut size={16} />
            <span>Sair da Conta</span>
          </button>
        </div>
      </section>

      {/* Tabs Bar */}
      <div className={styles.tabsContainer}>
        <button
          className={`${styles.tabBtn} ${activeTab === "courses" ? styles.active : ""}`}
          onClick={() => setActiveTab("courses")}
        >
          <BookOpen size={17} />
          <span>Meus Treinamentos</span>
        </button>

        <button
          className={`${styles.tabBtn} ${activeTab === "profile" ? styles.active : ""}`}
          onClick={() => setActiveTab("profile")}
        >
          <User size={17} />
          <span>Dados Pessoais</span>
        </button>

        <button
          className={`${styles.tabBtn} ${activeTab === "security" ? styles.active : ""}`}
          onClick={() => setActiveTab("security")}
        >
          <Shield size={17} />
          <span>Segurança & Senha</span>
        </button>
      </div>

      {/* Tab 1: Meus Treinamentos */}
      {activeTab === "courses" && (
        <section className={styles.tabContent}>
          <div className={styles.coursesGrid}>
            {courses.map((course) => {
              const hasAccess = hasAccessToTraining(course.id);
              const firstSession = course.modules[0]?.sessions[0];
              const progress = getProgress(course.id);
              const totalSessions = course.modules.reduce(
                (acc, m) => acc + m.sessions.length,
                0
              );
              const completedCount = progress?.completedSessionIds?.length || 0;
              const percent =
                totalSessions > 0
                  ? Math.min(100, Math.round((completedCount / totalSessions) * 100))
                  : 0;
              const resumeSessionId = progress?.lastSessionId || firstSession?.id;

              return (
                <div key={course.id} className={styles.courseCard}>
                  {course.coverImageUrl && (
                    <div className={styles.cardImageWrapper}>
                      <img
                        src={course.coverImageUrl}
                        alt={course.title}
                        className={styles.cardImage}
                      />
                      {percent === 100 && (
                        <span className={styles.completedBadgeOverlay}>
                          <CheckCircle2 size={12} /> Concluído
                        </span>
                      )}
                    </div>
                  )}

                  <div className={styles.cardBody}>
                    <h3 className={styles.cardTitle}>{course.title}</h3>

                    <div className={styles.cardMeta}>
                      <div className={styles.cardMetaItem}>
                        <Layers size={14} color="var(--neon-primary)" />
                        <span>{course.modules.length} Módulos</span>
                      </div>
                      {course.duration && (
                        <div className={styles.cardMetaItem}>
                          <Clock size={14} color="var(--neon-primary)" />
                          <span>{course.duration}</span>
                        </div>
                      )}
                    </div>

                    {completedCount > 0 && (
                      <div className={styles.courseProgressBox}>
                        <div className={styles.courseProgressHeader}>
                          <span className={styles.courseProgressText}>
                            {completedCount} de {totalSessions} aulas concluídas
                          </span>
                          <span className={styles.courseProgressPercent}>{percent}%</span>
                        </div>
                        <div className={styles.progressBarTrack}>
                          <div
                            className={styles.progressBarFill}
                            style={{ width: `${percent}%` }}
                          />
                        </div>
                      </div>
                    )}

                    {hasAccess ? (
                      resumeSessionId && (
                        <Link
                          href={`/treinamentos/${course.id}/aula/${resumeSessionId}`}
                          className={styles.playBtn}
                        >
                          {percent === 100 ? (
                            <>
                              <CheckCircle2 size={16} /> Rever Treinamento
                            </>
                          ) : completedCount > 0 ? (
                            <>
                              <Play size={16} /> Continuar De Onde Parou
                            </>
                          ) : (
                            <>
                              <Play size={16} /> Iniciar Treinamento
                            </>
                          )}
                        </Link>
                      )
                    ) : (
                      <button
                        className={styles.lockedNotice}
                        onClick={() => handleBuyTraining(course.id, course.title)}
                      >
                        <Lock size={15} />
                        <span>Desbloquear Curso Completo</span>
                      </button>
                    )}
                  </div>
                </div>
              );
            })}
          </div>
        </section>
      )}

      {/* Tab 2: Dados Pessoais */}
      {activeTab === "profile" && (
        <section className={styles.tabContent}>
          <div className={styles.formCard}>
            <h2 className={styles.formTitle}>Dados Cadastrais</h2>
            <p className={styles.formSubtitle}>
              Atualize as informações associadas à sua conta Man Hub.
            </p>

            <form onSubmit={handleSaveProfile} className={styles.form}>
              {profileMsg && (
                <div
                  className={`${styles.statusMessage} ${
                    profileMsg.type === "success" ? styles.successMsg : styles.errorMsg
                  }`}
                >
                  {profileMsg.type === "success" ? <CheckCircle2 size={16} /> : <AlertCircle size={16} />}
                  <span>{profileMsg.text}</span>
                </div>
              )}

              <div className={styles.formGroup}>
                <label className={styles.label}>Nome Completo</label>
                <input
                  type="text"
                  value={name}
                  onChange={(e) => setName(e.target.value)}
                  className={styles.input}
                  required
                />
              </div>

              <div className={styles.formGroup}>
                <label className={styles.label}>E-mail (Login Principal)</label>
                <input
                  type="email"
                  value={user.email || ""}
                  disabled
                  className={styles.input}
                />
                <span style={{ fontSize: "11px", color: "var(--text-muted)", marginTop: "3px" }}>
                  O e-mail é vinculado ao seu provedor de acesso e não pode ser alterado diretamente.
                </span>
              </div>

              <div className={styles.formGroup}>
                <label className={styles.label}>Telefone / WhatsApp</label>
                <input
                  type="tel"
                  placeholder="(11) 99999-9999"
                  value={phone}
                  onChange={(e) => setPhone(e.target.value)}
                  className={styles.input}
                />
              </div>

              <button type="submit" disabled={savingProfile} className={styles.saveBtn}>
                {savingProfile ? (
                  <>
                    <Loader2 size={16} className="animate-spin" />
                    <span>Salvando...</span>
                  </>
                ) : (
                  <>
                    <Save size={16} />
                    <span>Salvar Alterações</span>
                  </>
                )}
              </button>
            </form>
          </div>
        </section>
      )}

      {/* Tab 3: Segurança & Senha */}
      {activeTab === "security" && (
        <section className={styles.tabContent}>
          <div className={styles.formCard}>
            <h2 className={styles.formTitle}>Segurança da Conta</h2>
            <p className={styles.formSubtitle}>
              Gerencie a redefinição de senha e proteja o acesso à sua jornada.
            </p>

            <div style={{ display: "flex", flexDirection: "column", gap: "1.25rem" }}>
              {resetSent && (
                <div className={`${styles.statusMessage} ${styles.successMsg}`}>
                  <CheckCircle2 size={16} />
                  <span>
                    E-mail oficial de redefinição enviado para <strong>{user.email}</strong>.
                    Verifique sua caixa de entrada e spam.
                  </span>
                </div>
              )}

              {resetError && (
                <div className={`${styles.statusMessage} ${styles.errorMsg}`}>
                  <AlertCircle size={16} />
                  <span>{resetError}</span>
                </div>
              )}

              <div
                style={{
                  background: "rgba(4, 13, 26, 0.7)",
                  border: "1px solid rgba(255, 255, 255, 0.08)",
                  borderRadius: "var(--radius-sm)",
                  padding: "1.25rem",
                  display: "flex",
                  alignItems: "center",
                  justifyContent: "space-between",
                  gap: "1rem",
                }}
              >
                <div>
                  <h4 style={{ color: "#FFFFFF", fontSize: "0.95rem", fontWeight: 700 }}>
                    Redefinir Senha de Acesso
                  </h4>
                  <p style={{ color: "var(--text-secondary)", fontSize: "0.825rem", marginTop: "2px" }}>
                    Enviaremos um link seguro para o seu e-mail cadastrado.
                  </p>
                </div>

                <button
                  type="button"
                  onClick={handlePasswordReset}
                  disabled={resetLoading || resetSent}
                  className="btn btn-secondary"
                  style={{
                    padding: "8px 16px",
                    fontSize: "13px",
                    display: "inline-flex",
                    alignItems: "center",
                    gap: "6px",
                    flexShrink: 0,
                  }}
                >
                  {resetLoading ? (
                    <Loader2 size={14} className="animate-spin" />
                  ) : (
                    <KeyRound size={14} />
                  )}
                  <span>{resetSent ? "Enviado" : "Enviar Link"}</span>
                </button>
              </div>
            </div>
          </div>
        </section>
      )}

      {/* Checkout Modal if user clicks on locked training */}
      <CheckoutModal
        isOpen={isCheckoutOpen}
        onClose={() => setIsCheckoutOpen(false)}
        defaultPlan="training"
        defaultTrainingId={selectedTrainingId}
        defaultTrainingTitle={selectedTrainingTitle}
      />
    </div>
  );
}
