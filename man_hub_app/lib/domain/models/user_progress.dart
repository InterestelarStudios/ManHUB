import 'package:cloud_firestore/cloud_firestore.dart';

class UserProgress {
  final String trainingId;
  final String trainingTitle;
  final int lastModuleIndex;
  final String lastSessionId;
  final String lastSessionTitle;
  final int lastScreenIndex;
  final List<String> completedSessionIds;
  final List<int> completedModuleIndices;
  final DateTime updatedAt;

  UserProgress({
    required this.trainingId,
    required this.trainingTitle,
    this.lastModuleIndex = 0,
    required this.lastSessionId,
    this.lastSessionTitle = '',
    this.lastScreenIndex = 0,
    this.completedSessionIds = const [],
    this.completedModuleIndices = const [],
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();

  bool isSessionCompleted(String sessionId) => completedSessionIds.contains(sessionId);
  bool isModuleCompleted(int moduleIndex) => completedModuleIndices.contains(moduleIndex);

  double getCompletionPercentage(int totalSessions) {
    if (totalSessions <= 0) return 0.0;
    final completedCount = completedSessionIds.length;
    return (completedCount / totalSessions).clamp(0.0, 1.0);
  }

  Map<String, dynamic> toMap() {
    return {
      'trainingId': trainingId,
      'trainingTitle': trainingTitle,
      'lastModuleIndex': lastModuleIndex,
      'lastSessionId': lastSessionId,
      'lastSessionTitle': lastSessionTitle,
      'lastScreenIndex': lastScreenIndex,
      'completedSessionIds': completedSessionIds,
      'completedModuleIndices': completedModuleIndices,
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory UserProgress.fromMap(Map<String, dynamic> map, String trainingId) {
    DateTime parsedUpdatedAt = DateTime.now();
    final rawDate = map['updatedAt'];
    if (rawDate is Timestamp) {
      parsedUpdatedAt = rawDate.toDate();
    } else if (rawDate is String) {
      parsedUpdatedAt = DateTime.tryParse(rawDate) ?? DateTime.now();
    }

    final rawSessions = map['completedSessionIds'];
    List<String> sessions = [];
    if (rawSessions is List) {
      sessions = rawSessions.map((e) => e.toString()).toList();
    }

    final rawModules = map['completedModuleIndices'];
    List<int> modules = [];
    if (rawModules is List) {
      modules = rawModules.map((e) => (e as num).toInt()).toList();
    }

    return UserProgress(
      trainingId: trainingId,
      trainingTitle: map['trainingTitle'] as String? ?? '',
      lastModuleIndex: (map['lastModuleIndex'] as num?)?.toInt() ?? 0,
      lastSessionId: map['lastSessionId'] as String? ?? '',
      lastSessionTitle: map['lastSessionTitle'] as String? ?? '',
      lastScreenIndex: (map['lastScreenIndex'] as num?)?.toInt() ?? 0,
      completedSessionIds: sessions,
      completedModuleIndices: modules,
      updatedAt: parsedUpdatedAt,
    );
  }

  UserProgress copyWith({
    String? trainingId,
    String? trainingTitle,
    int? lastModuleIndex,
    String? lastSessionId,
    String? lastSessionTitle,
    int? lastScreenIndex,
    List<String>? completedSessionIds,
    List<int>? completedModuleIndices,
    DateTime? updatedAt,
  }) {
    return UserProgress(
      trainingId: trainingId ?? this.trainingId,
      trainingTitle: trainingTitle ?? this.trainingTitle,
      lastModuleIndex: lastModuleIndex ?? this.lastModuleIndex,
      lastSessionId: lastSessionId ?? this.lastSessionId,
      lastSessionTitle: lastSessionTitle ?? this.lastSessionTitle,
      lastScreenIndex: lastScreenIndex ?? this.lastScreenIndex,
      completedSessionIds: completedSessionIds ?? this.completedSessionIds,
      completedModuleIndices: completedModuleIndices ?? this.completedModuleIndices,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
