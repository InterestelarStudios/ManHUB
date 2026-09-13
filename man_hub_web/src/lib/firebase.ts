import { initializeApp, getApps, getApp, FirebaseApp } from "firebase/app";
import { getAnalytics, isSupported, Analytics } from "firebase/analytics";
import { getFirestore, Firestore } from "firebase/firestore";
import { getAuth, Auth } from "firebase/auth";

const firebaseConfig = {
  apiKey: "AIzaSyBTMx6HSuRO1VXRA1zLMVw5wGI8fB-CExo",
  authDomain: "man-hub-c0bef.firebaseapp.com",
  projectId: "man-hub-c0bef",
  storageBucket: "man-hub-c0bef.firebasestorage.app",
  messagingSenderId: "495141513520",
  appId: "1:495141513520:web:cfdb6fc7c55d825a5340f5",
  measurementId: "G-NVE9L2CQBD",
};

// Inicialização segura com suporte a singleton para SSR no Next.js
export const app: FirebaseApp =
  getApps().length > 0 ? getApp() : initializeApp(firebaseConfig);

export const auth: Auth = getAuth(app);
export const db: Firestore = getFirestore(app);

// Analytics seguro inicializado apenas no ambiente do cliente (browser)
let analytics: Analytics | null = null;
if (typeof window !== "undefined") {
  isSupported().then((supported) => {
    if (supported) {
      analytics = getAnalytics(app);
    }
  });
}

export { analytics };
export default app;
