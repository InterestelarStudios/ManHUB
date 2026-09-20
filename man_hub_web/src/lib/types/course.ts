export type ContentBlockType =
  | "title"
  | "title2"
  | "description"
  | "highlighted_description"
  | "image"
  | "video";

export interface ContentBlock {
  id: string;
  type: ContentBlockType | string;
  data: string;
}

export interface ScreenModel {
  id: string;
  title: string;
  contents: ContentBlock[];
}

export interface Session {
  id: string;
  title: string;
  subtitle?: string;
  screens: ScreenModel[];
}

export interface Module {
  id: string;
  title: string;
  sessions: Session[];
}

export interface Training {
  id: string;
  title: string;
  subtitle: string;
  description: string;
  category?: string;
  categories?: string[];
  price?: number;
  whatYouWillLearn?: string;
  duration?: string;
  coverImageUrl?: string;
  requirements?: string;
  updatedAt?: string;
  modules: Module[];
}

export interface PlayableSessionContext {
  training: Training;
  module: Module;
  moduleIndex: number;
  session: Session;
  sessionIndex: number;
  totalSessionsInCourse: number;
  currentGlobalIndex: number;
  prevSession?: {
    trainingId: string;
    sessionId: string;
    title: string;
  };
  nextSession?: {
    trainingId: string;
    sessionId: string;
    title: string;
    isLocked: boolean;
  };
}
