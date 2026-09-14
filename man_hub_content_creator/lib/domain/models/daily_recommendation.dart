import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class DailyRecommendation {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String trainingId;
  final String trainingTitle;
  final String sessionId;
  final String sessionTitle;
  final String? moduleId;
  final bool isActive;
  final String createdAt;
  final String? updatedAt;

  const DailyRecommendation({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.trainingId,
    required this.trainingTitle,
    required this.sessionId,
    required this.sessionTitle,
    this.moduleId,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  });

  factory DailyRecommendation.create({
    required String title,
    required String description,
    required String imageUrl,
    required String trainingId,
    required String trainingTitle,
    required String sessionId,
    required String sessionTitle,
    String? moduleId,
    bool isActive = true,
  }) {
    final now = DateTime.now().toIso8601String();
    return DailyRecommendation(
      id: const Uuid().v4(),
      title: title.trim(),
      description: description.trim(),
      imageUrl: imageUrl.trim(),
      trainingId: trainingId.trim(),
      trainingTitle: trainingTitle.trim(),
      sessionId: sessionId.trim(),
      sessionTitle: sessionTitle.trim(),
      moduleId: moduleId?.trim(),
      isActive: isActive,
      createdAt: now,
      updatedAt: now,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'trainingId': trainingId,
      'trainingTitle': trainingTitle,
      'sessionId': sessionId,
      'sessionTitle': sessionTitle,
      if (moduleId != null && moduleId!.isNotEmpty) 'moduleId': moduleId,
      'isActive': isActive,
      'createdAt': createdAt,
      if (updatedAt != null && updatedAt!.isNotEmpty) 'updatedAt': updatedAt,
    };
  }

  factory DailyRecommendation.fromMap(Map<String, dynamic> map, [String? docId]) {
    return DailyRecommendation(
      id: (docId != null && docId.isNotEmpty)
          ? docId
          : (map['id'] as String? ?? ''),
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      imageUrl: map['imageUrl'] as String? ?? '',
      trainingId: map['trainingId'] as String? ?? '',
      trainingTitle: map['trainingTitle'] as String? ?? '',
      sessionId: map['sessionId'] as String? ?? '',
      sessionTitle: map['sessionTitle'] as String? ?? '',
      moduleId: map['moduleId'] as String?,
      isActive: map['isActive'] as bool? ?? true,
      createdAt: map['createdAt'] as String? ?? DateTime.now().toIso8601String(),
      updatedAt: map['updatedAt'] as String?,
    );
  }

  factory DailyRecommendation.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return DailyRecommendation.fromMap(data, doc.id);
  }

  DailyRecommendation copyWith({
    String? id,
    String? title,
    String? description,
    String? imageUrl,
    String? trainingId,
    String? trainingTitle,
    String? sessionId,
    String? sessionTitle,
    String? moduleId,
    bool? isActive,
    String? createdAt,
    String? updatedAt,
  }) {
    return DailyRecommendation(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      trainingId: trainingId ?? this.trainingId,
      trainingTitle: trainingTitle ?? this.trainingTitle,
      sessionId: sessionId ?? this.sessionId,
      sessionTitle: sessionTitle ?? this.sessionTitle,
      moduleId: moduleId ?? this.moduleId,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
