import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String name;
  final String? description;
  final String category;
  final double? price;
  final double? originalPrice;
  final String imageUrl;
  final String? affiliateUrl;
  final String? coupon;
  final String? brand;
  final String? reason;
  final List<String> tags;
  final bool isFeatured;
  final DateTime? createdAt;

  Product({
    required this.id,
    required this.name,
    this.description,
    required this.category,
    this.price,
    this.originalPrice,
    required this.imageUrl,
    this.affiliateUrl,
    this.coupon,
    this.brand,
    this.reason,
    this.tags = const [],
    this.isFeatured = false,
    this.createdAt,
  });

  factory Product.fromFirestore(DocumentSnapshot doc) {
    final data = (doc.data() as Map<String, dynamic>?) ?? {};
    return Product.fromJson(data, doc.id);
  }

  factory Product.fromJson(Map<String, dynamic> json, [String? docId]) {
    DateTime? parsedCreatedAt;
    if (json['createdAt'] is Timestamp) {
      parsedCreatedAt = (json['createdAt'] as Timestamp).toDate();
    } else if (json['createdAt'] is String) {
      parsedCreatedAt = DateTime.tryParse(json['createdAt']);
    }

    return Product(
      id: docId ?? json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      category: json['category'] ?? 'Outros',
      price: (json['price'] != null) ? (json['price'] as num).toDouble() : null,
      originalPrice: (json['originalPrice'] != null) ? (json['originalPrice'] as num).toDouble() : null,
      imageUrl: json['imageUrl'] ?? '',
      affiliateUrl: json['affiliateUrl'] ?? json['link'],
      coupon: json['coupon'],
      brand: json['brand'],
      reason: json['reason'],
      tags: json['tags'] != null ? List<String>.from(json['tags']) : const [],
      isFeatured: json['isFeatured'] ?? false,
      createdAt: parsedCreatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'price': price,
      'originalPrice': originalPrice,
      'imageUrl': imageUrl,
      'affiliateUrl': affiliateUrl,
      'coupon': coupon,
      'brand': brand,
      'reason': reason,
      'tags': tags,
      'isFeatured': isFeatured,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    };
  }

  String get formattedPrice {
    if (price == null) return 'Sob Consulta';
    return 'R\$ ${price!.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  String? get formattedOriginalPrice {
    if (originalPrice == null) return null;
    return 'R\$ ${originalPrice!.toStringAsFixed(2).replaceAll('.', ',')}';
  }
}
