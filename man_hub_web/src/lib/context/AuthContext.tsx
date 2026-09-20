"use client";

import React, { createContext, useContext, useEffect, useState } from "react";
import {
  User,
  signInWithEmailAndPassword,
  createUserWithEmailAndPassword,
  signInWithPopup,
  GoogleAuthProvider,
  sendPasswordResetEmail,
  signOut,
  updateProfile,
  onAuthStateChanged,
} from "firebase/auth";
import {
  doc,
  setDoc,
  onSnapshot,
  serverTimestamp,
  Timestamp,
} from "firebase/firestore";
import { auth, db } from "@/lib/firebase";
import { AuthContextType, UserProfile } from "@/lib/types/auth";
import { trackCompleteRegistration } from "@/lib/tracking/pixel";

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [user, setUser] = useState<User | null>(null);
  const [profile, setProfile] = useState<UserProfile | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    let unsubscribeSnapshot: (() => void) | null = null;

    const unsubscribeAuth = onAuthStateChanged(auth, async (currentUser) => {
      setUser(currentUser);

      if (unsubscribeSnapshot) {
        unsubscribeSnapshot();
        unsubscribeSnapshot = null;
      }

      if (currentUser) {
        const userRef = doc(db, "users", currentUser.uid);

        unsubscribeSnapshot = onSnapshot(
          userRef,
          async (docSnap) => {
            if (docSnap.exists()) {
              const data = docSnap.data();

              let parsedCreatedAt: Date | null = null;
              if (data.createdAt instanceof Timestamp) {
                parsedCreatedAt = data.createdAt.toDate();
              }

              let parsedSubExpiry: Date | null = null;
              if (data.subscriptionExpiresAt instanceof Timestamp) {
                parsedSubExpiry = data.subscriptionExpiresAt.toDate();
              }

              const userProfile: UserProfile = {
                uid: currentUser.uid,
                name: data.name || currentUser.displayName || "Membro",
                email: data.email || currentUser.email || "",
                profileImageUrl: data.profileImageUrl || currentUser.photoURL || null,
                memberType: data.memberType || "Visitante",
                isSubscribed: !!data.isSubscribed,
                subscriptionExpiresAt: parsedSubExpiry,
                unlockedTrainingIds: Array.isArray(data.unlockedTrainingIds)
                  ? data.unlockedTrainingIds
                  : [],
                createdAt: parsedCreatedAt,
                phone: data.phone || undefined,
              };

              // Se tiver foto no Google mas não tiver no documento, sincroniza
              if (!data.profileImageUrl && currentUser.photoURL) {
                try {
                  await setDoc(userRef, { profileImageUrl: currentUser.photoURL }, { merge: true });
                } catch {
                  // ignore
                }
              }

              setProfile(userProfile);
              setLoading(false);
            } else {
              // Primeiro login: cria o documento do usuário
              const newProfile: UserProfile = {
                uid: currentUser.uid,
                name: currentUser.displayName || currentUser.email?.split("@")[0] || "Membro",
                email: currentUser.email || "",
                profileImageUrl: currentUser.photoURL || null,
                memberType: "Visitante",
                isSubscribed: false,
                unlockedTrainingIds: [],
                createdAt: new Date(),
              };

              try {
                await setDoc(userRef, {
                  uid: newProfile.uid,
                  name: newProfile.name,
                  email: newProfile.email,
                  profileImageUrl: newProfile.profileImageUrl,
                  memberType: newProfile.memberType,
                  isSubscribed: newProfile.isSubscribed,
                  unlockedTrainingIds: newProfile.unlockedTrainingIds,
                  createdAt: serverTimestamp(),
                  updatedAt: serverTimestamp(),
                });
              } catch (e) {
                console.error("Erro ao registrar novo perfil no Firestore:", e);
              }

              // Dispara e-mail de boas-vindas no primeiro login
              try {
                if (newProfile.email) {
                  fetch("/api/auth/welcome", {
                    method: "POST",
                    headers: { "Content-Type": "application/json" },
                    body: JSON.stringify({
                      userName: newProfile.name,
                      userEmail: newProfile.email,
                    }),
                  }).catch((e) => console.warn("[Auth] Erro não-bloqueante ao disparar boas-vindas:", e));
                }
              } catch (_) {}

              // Rastreamento de conversão de cadastro
              trackCompleteRegistration("google");

              setProfile(newProfile);
              setLoading(false);
            }
          },
          (error) => {
            console.error("Erro ao sincronizar perfil do usuário:", error);
            setLoading(false);
          }
        );
      } else {
        setProfile(null);
        setLoading(false);
      }
    });

    return () => {
      unsubscribeAuth();
      if (unsubscribeSnapshot) {
        unsubscribeSnapshot();
      }
    };
  }, []);

  const loginWithEmail = async (email: string, password: string) => {
    await signInWithEmailAndPassword(auth, email.trim(), password);
  };

  const registerWithEmail = async (name: string, email: string, password: string) => {
    const cred = await createUserWithEmailAndPassword(auth, email.trim(), password);
    if (cred.user) {
      await updateProfile(cred.user, { displayName: name.trim() });
      const userRef = doc(db, "users", cred.user.uid);
      await setDoc(userRef, {
        uid: cred.user.uid,
        name: name.trim(),
        email: email.trim(),
        memberType: "Visitante",
        isSubscribed: false,
        unlockedTrainingIds: [],
        createdAt: serverTimestamp(),
        updatedAt: serverTimestamp(),
      });

      // Dispara e-mail de boas-vindas de forma não-bloqueante
      try {
        fetch("/api/auth/welcome", {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({
            userName: name.trim(),
            userEmail: email.trim(),
          }),
        }).catch((e) => console.warn("[Auth] Erro não-bloqueante ao disparar boas-vindas:", e));
      } catch (_) {}

      // Rastreamento de conversão de cadastro
      trackCompleteRegistration("email");
    }
  };

  const loginWithGoogle = async () => {
    const provider = new GoogleAuthProvider();
    provider.setCustomParameters({ prompt: "select_account" });
    await signInWithPopup(auth, provider);
  };

  const sendPasswordReset = async (email: string) => {
    await sendPasswordResetEmail(auth, email.trim());
  };

  const logout = async () => {
    await signOut(auth);
  };

  const isSubscribed = Boolean(
    profile?.isSubscribed &&
      (!profile.subscriptionExpiresAt || profile.subscriptionExpiresAt > new Date())
  );

  const hasAccessToTraining = (trainingId: string): boolean => {
    if (isSubscribed) return true;
    if (profile?.unlockedTrainingIds?.includes(trainingId)) return true;
    return false;
  };

  return (
    <AuthContext.Provider
      value={{
        user,
        profile,
        loading,
        isLoggedIn: !!user,
        isSubscribed,
        hasAccessToTraining,
        loginWithEmail,
        registerWithEmail,
        loginWithGoogle,
        sendPasswordReset,
        logout,
      }}
    >
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth(): AuthContextType {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error("useAuth deve ser utilizado dentro de um AuthProvider");
  }
  return context;
}
