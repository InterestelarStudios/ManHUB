export interface UserProgress {
  trainingId: string;
  trainingTitle: string;
  lastModuleIndex: number;
  lastSessionId: string;
  lastSessionTitle: string;
  lastScreenIndex: number;
  completedSessionIds: string[];
  completedModuleIndices: number[];
  updatedAt: Date;
}

export interface ProgressContextType {
  progressMap: Record<string, UserProgress>;
  loading: boolean;
  getProgress: (trainingId: string) => UserProgress | undefined;
  isSessionCompleted: (trainingId: string, sessionId: string) => boolean;
  saveCurrentPosition: (params: {
    trainingId: string;
    trainingTitle: string;
    moduleIndex: number;
    sessionId: string;
    sessionTitle: string;
    screenIndex: number;
  }) => Promise<void>;
  markSessionCompleted: (params: {
    trainingId: string;
    trainingTitle: string;
    sessionId: string;
    moduleIndex: number;
    isModuleFullyCompleted?: boolean;
  }) => Promise<void>;
}
