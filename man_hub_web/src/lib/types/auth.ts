import { User } from "firebase/auth";

export interface UserProfile {
  uid: string;
  name: string;
  email: string;
  profileImageUrl?: string | null;
  memberType: string; // ex: 'Membro Vitalício', 'Visitante', 'Assinante'
  isSubscribed: boolean;
  subscriptionExpiresAt?: Date | null;
  unlockedTrainingIds: string[];
  createdAt?: Date | null;
  phone?: string;
}

export interface AuthContextType {
  user: User | null;
  profile: UserProfile | null;
  loading: boolean;
  isLoggedIn: boolean;
  isSubscribed: boolean;
  hasAccessToTraining: (trainingId: string) => boolean;
  loginWithEmail: (email: string, password: string) => Promise<void>;
  registerWithEmail: (name: string, email: string, password: string) => Promise<void>;
  loginWithGoogle: () => Promise<void>;
  sendPasswordReset: (email: string) => Promise<void>;
  logout: () => Promise<void>;
}
