import 'package:cloud_firestore/cloud_firestore.dart';

class Haircut {
  final String id;
  final String title;
  final String description;
  final List<String> imageUrls;
  final List<String> faceShapes;
  final String hairType;
  final String recommendedStylingProduct;
  final List<String> tags;
  final DateTime createdAt;
  final String creatorName;

  const Haircut({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrls,
    required this.faceShapes,
    required this.hairType,
    required this.recommendedStylingProduct,
    required this.tags,
    required this.createdAt,
    this.creatorName = 'Man Hub Curadoria',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrls': imageUrls,
      'faceShapes': faceShapes,
      'hairType': hairType,
      'recommendedStylingProduct': recommendedStylingProduct,
      'tags': tags,
      'createdAt': Timestamp.fromDate(createdAt),
      'creatorName': creatorName,
    };
  }

  factory Haircut.fromMap(Map<String, dynamic> map, String docId) {
    DateTime parsedDate = DateTime.now();
    final rawDate = map['createdAt'];
    if (rawDate is Timestamp) {
      parsedDate = rawDate.toDate();
    } else if (rawDate is String) {
      parsedDate = DateTime.tryParse(rawDate) ?? DateTime.now();
    }

    final rawImages = map['imageUrls'];
    List<String> imagesList = [];
    if (rawImages is List) {
      imagesList = rawImages.map((e) => e.toString()).toList();
    } else if (map['imageUrl'] != null && map['imageUrl'].toString().isNotEmpty) {
      imagesList = [map['imageUrl'].toString()];
    }

    final rawFaces = map['faceShapes'];
    List<String> facesList = [];
    if (rawFaces is List) {
      facesList = rawFaces.map((e) => e.toString()).toList();
    } else if (map['faceShape'] != null && map['faceShape'].toString().isNotEmpty) {
      facesList = [map['faceShape'].toString()];
    }

    final rawTags = map['tags'];
    List<String> tagsList = [];
    if (rawTags is List) {
      tagsList = rawTags.map((e) => e.toString()).toList();
    }

    return Haircut(
      id: docId.isNotEmpty ? docId : (map['id'] as String? ?? ''),
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      imageUrls: imagesList,
      faceShapes: facesList,
      hairType: map['hairType'] as String? ?? 'Liso',
      recommendedStylingProduct:
          map['recommendedStylingProduct'] as String? ?? '',
      tags: tagsList,
      createdAt: parsedDate,
      creatorName: map['creatorName'] as String? ?? 'Man Hub Curadoria',
    );
  }
}
