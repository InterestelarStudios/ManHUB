import 'package:cloud_firestore/cloud_firestore.dart';

class OutfitPiece {
  final String id;
  final String name;
  final String category; // 'Torso / Camisa', 'Casaco / Blazer', 'Calça / Alfaiataria', 'Calçado / Sapato', 'Acessório / Relógio', 'Perfumaria'
  final String price;
  final String? brand;
  final String? imageUrl;
  final String? affiliateUrl;
  final String? color;
  final String? notes;

  const OutfitPiece({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    this.brand,
    this.imageUrl,
    this.affiliateUrl,
    this.color,
    this.notes,
  });

  double get numericPrice {
    final clean = price
        .replaceAll('R\$', '')
        .replaceAll(' ', '')
        .replaceAll('.', '')
        .replaceAll(',', '.');
    return double.tryParse(clean) ?? 0.0;
  }

  factory OutfitPiece.fromMap(Map<String, dynamic> map) {
    return OutfitPiece(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      category: map['category'] as String? ?? 'Geral',
      price: map['price']?.toString() ?? '',
      brand: map['brand'] as String?,
      imageUrl: map['imageUrl'] as String?,
      affiliateUrl: map['affiliateUrl'] as String? ?? map['link'] as String?,
      color: map['color'] as String?,
      notes: map['notes'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'price': price,
      'brand': brand,
      'imageUrl': imageUrl,
      'affiliateUrl': affiliateUrl,
      'color': color,
      'notes': notes,
    };
  }

  OutfitPiece copyWith({
    String? id,
    String? name,
    String? category,
    String? price,
    String? brand,
    String? imageUrl,
    String? affiliateUrl,
    String? color,
    String? notes,
  }) {
    return OutfitPiece(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      price: price ?? this.price,
      brand: brand ?? this.brand,
      imageUrl: imageUrl ?? this.imageUrl,
      affiliateUrl: affiliateUrl ?? this.affiliateUrl,
      color: color ?? this.color,
      notes: notes ?? this.notes,
    );
  }
}

class Outfit {
  final String id;
  final String title;
  final String description;
  final String styleCategory; // 'Smart Casual', 'Old Money', 'Casual Urbano', 'Minimalista', 'Clássico', 'Tech & Sport'
  final String occasion; // 'Trabalho / Corporativo', 'Encontro Noturno', 'Fim de Semana Casual', 'Evento Social', 'Viagem'
  final String? season; // 'Verão', 'Inverno', 'Outono', 'Primavera', 'Atemporal'
  final String imageUrl; // Foto completa e cinematográfica do outfit
  final List<OutfitPiece> pieces;
  final int likesCount;
  final String creatorName;
  final bool isFeatured;
  final DateTime createdAt;

  String get authorName => creatorName;

  double get totalPrice => pieces.fold(0.0, (acc, p) => acc + p.numericPrice);

  Outfit({
    required this.id,
    required this.title,
    required this.description,
    required this.styleCategory,
    required this.occasion,
    this.season,
    required this.imageUrl,
    this.pieces = const [],
    this.likesCount = 0,
    String? creatorName,
    String? authorName,
    this.isFeatured = false,
    DateTime? createdAt,
  })  : creatorName = authorName ?? creatorName ?? 'Man Hub Curadoria',
        createdAt = createdAt ?? DateTime.now();

  factory Outfit.fromFirestore(DocumentSnapshot doc) {
    final data = (doc.data() as Map<String, dynamic>?) ?? {};
    return Outfit.fromMap(data, doc.id);
  }

  factory Outfit.fromMap(Map<String, dynamic> map, [String? docId]) {
    DateTime parsedDate = DateTime.now();
    if (map['createdAt'] is Timestamp) {
      parsedDate = (map['createdAt'] as Timestamp).toDate();
    } else if (map['createdAt'] is String) {
      parsedDate = DateTime.tryParse(map['createdAt'] as String) ?? DateTime.now();
    }

    final rawPieces = map['pieces'];
    List<OutfitPiece> piecesList = [];
    if (rawPieces is List) {
      piecesList = rawPieces
          .map((p) => OutfitPiece.fromMap(Map<String, dynamic>.from(p as Map)))
          .toList();
    }

    return Outfit(
      id: docId ?? map['id'] as String? ?? '',
      title: map['title'] as String? ?? 'Outfit Exclusivo',
      description: map['description'] as String? ?? '',
      styleCategory: map['styleCategory'] as String? ?? 'Smart Casual',
      occasion: map['occasion'] as String? ?? 'Casual',
      season: map['season'] as String?,
      imageUrl: map['imageUrl'] as String? ?? '',
      pieces: piecesList,
      likesCount: (map['likesCount'] as num?)?.toInt() ?? 0,
      creatorName: map['creatorName'] as String? ?? map['authorName'] as String? ?? 'Man Hub IA',
      isFeatured: map['isFeatured'] as bool? ?? false,
      createdAt: parsedDate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'styleCategory': styleCategory,
      'occasion': occasion,
      'season': season,
      'imageUrl': imageUrl,
      'pieces': pieces.map((p) => p.toMap()).toList(),
      'likesCount': likesCount,
      'creatorName': creatorName,
      'isFeatured': isFeatured,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  Outfit copyWith({
    String? id,
    String? title,
    String? description,
    String? styleCategory,
    String? occasion,
    String? season,
    String? imageUrl,
    List<OutfitPiece>? pieces,
    int? likesCount,
    String? creatorName,
    bool? isFeatured,
    DateTime? createdAt,
  }) {
    return Outfit(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      styleCategory: styleCategory ?? this.styleCategory,
      occasion: occasion ?? this.occasion,
      season: season ?? this.season,
      imageUrl: imageUrl ?? this.imageUrl,
      pieces: pieces ?? this.pieces,
      likesCount: likesCount ?? this.likesCount,
      creatorName: creatorName ?? this.creatorName,
      isFeatured: isFeatured ?? this.isFeatured,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
