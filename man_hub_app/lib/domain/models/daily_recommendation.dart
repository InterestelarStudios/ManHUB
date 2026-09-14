import 'package:cloud_firestore/cloud_firestore.dart';

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
}
