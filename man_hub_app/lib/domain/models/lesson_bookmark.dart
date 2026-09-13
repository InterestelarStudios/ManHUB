import 'package:cloud_firestore/cloud_firestore.dart';
import 'screen_model.dart';
import 'content_block.dart';

class LessonBookmark {
  final String id; // formato: ${trainingId}_${sessionId}_${screenId}
  final String trainingId;
  final String trainingTitle;
  final String? category;
  final String moduleId;
  final String moduleTitle;
  final String sessionId;
  final String sessionTitle;
  final String? sessionSubtitle;
  final String screenId;
  final int screenIndex;
  final String screenTitle;
  final String? screenPreviewText;
  final String? screenImageUrl;
  final String? coverImageUrl;
  final DateTime createdAt;

  LessonBookmark({
    required this.id,
    required this.trainingId,
    required this.trainingTitle,
    this.category,
    required this.moduleId,
    required this.moduleTitle,
    required this.sessionId,
    required this.sessionTitle,
    this.sessionSubtitle,
    required this.screenId,
    this.screenIndex = 0,
    required this.screenTitle,
    this.screenPreviewText,
    this.screenImageUrl,
    this.coverImageUrl,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  static String extractPreviewText(ScreenModel screen) {
    for (final block in screen.contents) {
      if (block is HighlightedDescriptionBlock && block.text.trim().isNotEmpty) {
        return block.text.trim();
      }
      if (block is DescriptionBlock && block.text.trim().isNotEmpty) {
        return block.text.trim();
      }
    }
    for (final block in screen.contents) {
      if (block is Title2Block && block.text.trim().isNotEmpty) {
        return block.text.trim();
      }
      if (block is TitleBlock && block.text.trim().isNotEmpty) {
        return block.text.trim();
      }
    }
    return '';
  }

  static String? extractImageUrl(ScreenModel screen) {
    for (final block in screen.contents) {
      if (block is ImageBlock && block.imageUrl.trim().isNotEmpty) {
        return block.imageUrl.trim();
      }
    }
    return null;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'trainingId': trainingId,
      'trainingTitle': trainingTitle,
      'category': category,
      'moduleId': moduleId,
      'moduleTitle': moduleTitle,
      'sessionId': sessionId,
      'sessionTitle': sessionTitle,
      'sessionSubtitle': sessionSubtitle,
      'screenId': screenId,
      'screenIndex': screenIndex,
      'screenTitle': screenTitle,
      'screenPreviewText': screenPreviewText,
      'screenImageUrl': screenImageUrl,
      'coverImageUrl': coverImageUrl,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory LessonBookmark.fromMap(Map<String, dynamic> map, String docId) {
    DateTime parsedCreatedAt = DateTime.now();
    final rawDate = map['createdAt'];
    if (rawDate is Timestamp) {
      parsedCreatedAt = rawDate.toDate();
    } else if (rawDate is String) {
      parsedCreatedAt = DateTime.tryParse(rawDate) ?? DateTime.now();
    }

    return LessonBookmark(
      id: docId.isNotEmpty ? docId : (map['id'] as String? ?? ''),
      trainingId: map['trainingId'] as String? ?? '',
      trainingTitle: map['trainingTitle'] as String? ?? '',
      category: map['category'] as String?,
      moduleId: map['moduleId'] as String? ?? '',
      moduleTitle: map['moduleTitle'] as String? ?? '',
      sessionId: map['sessionId'] as String? ?? '',
      sessionTitle: map['sessionTitle'] as String? ?? '',
      sessionSubtitle: map['sessionSubtitle'] as String?,
      screenId: map['screenId'] as String? ?? '',
      screenIndex: (map['screenIndex'] as num?)?.toInt() ?? 0,
      screenTitle: map['screenTitle'] as String? ?? 'Tela Salva',
      screenPreviewText: map['screenPreviewText'] as String?,
      screenImageUrl: map['screenImageUrl'] as String?,
      coverImageUrl: map['coverImageUrl'] as String?,
      createdAt: parsedCreatedAt,
    );
  }
}
