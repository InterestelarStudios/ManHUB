"use client";

import React, { useState, useRef, useEffect } from "react";
import Link from "next/link";
import { usePathname } from "next/navigation";
import styles from "./UserMenu.module.css";
import { useAuth } from "@/lib/context/AuthContext";
import { ChevronDown, BookOpen, LogOut, ShieldCheck, Sparkles, User } from "lucide-react";

export default function UserMenu() {
  const pathname = usePathname();
  const { user, profile, logout, isSubscribed } = useAuth();
  const [isOpen, setIsOpen] = useState(false);
  const menuRef = useRef<HTMLDivElement>(null);

  const isContaActive = pathname?.startsWith("/conta");

  // Close dropdown on outside click
  useEffect(() => {
    const handleClickOutside = (e: MouseEvent) => {
      if (menuRef.current && !menuRef.current.contains(e.target as Node)) {
        setIsOpen(false);
      }
    };
    document.addEventListener("mousedown", handleClickOutside);
    return () => document.removeEventListener("mousedown", handleClickOutside);
  }, []);

  if (!user) return null;

  const displayName = profile?.name || user.displayName || user.email?.split("@")[0] || "Membro";
  const firstName = displayName.split(" ")[0];
  const initial = firstName.charAt(0).toUpperCase();

  const memberStatus = isSubscribed
    ? "Membro Pass"
    : profile?.unlockedTrainingIds && profile.unlockedTrainingIds.length > 0
    ? "Aluno Oficial"
    : "Membro";

  return (
    <div className={styles.container} ref={menuRef}>
      <button
        className={`${styles.triggerBtn} ${isContaActive ? styles.activeTrigger : ""}`}
        onClick={() => setIsOpen(!isOpen)}
        aria-label="Menu do usuário"
      >
        {profile?.profileImageUrl ? (
          <img
            src={profile.profileImageUrl}
            alt={displayName}
            className={styles.avatar}
          />
        ) : (
          <div className={styles.avatarFallback}>{initial}</div>
        )}

        <span className={styles.userName}>{firstName}</span>
        <ChevronDown size={14} className={`${styles.chevron} ${isOpen ? styles.open : ""}`} />
      </button>

      {isOpen && (
        <div className={styles.dropdown}>
          <div className={styles.userInfoRow}>
            <span className={styles.fullName}>{displayName}</span>
            <span className={styles.userEmail}>{user.email}</span>
            <div className={styles.memberBadge}>
              <Sparkles size={11} />
              <span>{memberStatus}</span>
            </div>
          </div>

          <Link
            href="/conta"
            className={styles.menuItem}
            onClick={() => setIsOpen(false)}
          >
            <User size={16} />
            <span>Minha Conta</span>
          </Link>

          <Link
            href="/treinamentos"
            className={styles.menuItem}
            onClick={() => setIsOpen(false)}
          >
            <BookOpen size={16} />
            <span>Meus Treinamentos</span>
          </Link>

          <div className={styles.menuDivider} />

          <button
            className={`${styles.menuItem} ${styles.logoutItem}`}
            onClick={async () => {
              setIsOpen(false);
              await logout();
            }}
          >
            <LogOut size={16} />
            <span>Sair da Conta</span>
          </button>
        </div>
      )}
    </div>
  );
}
