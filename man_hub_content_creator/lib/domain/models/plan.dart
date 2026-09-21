import 'package:cloud_firestore/cloud_firestore.dart';

class Plan {
  final String id;
  final String name;
  final String description;
  final double price;
  final String currency;
  final String billingPeriod; // 'monthly', 'annual', 'lifetime'
  final List<String> features;
  final bool active;
  final DateTime? updatedAt;

  const Plan({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.currency = 'BRL',
    this.billingPeriod = 'monthly',
    this.features = const [],
    this.active = true,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'currency': currency,
      'billingPeriod': billingPeriod,
      'features': features,
      'active': active,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  factory Plan.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final priceVal = data['price'];
    double parsedPrice = 49.90;
    if (priceVal is num) {
      parsedPrice = priceVal.toDouble();
    } else if (priceVal != null) {
      final n = double.tryParse(priceVal.toString().replaceAll(',', '.'));
      if (n != null) parsedPrice = n;
    }

    final rawFeatures = data['features'];
    List<String> parsedFeatures = [];
    if (rawFeatures is List) {
      parsedFeatures = rawFeatures.map((e) => e.toString()).toList();
    }

    DateTime? parsedUpdatedAt;
    final rawUpdatedAt = data['updatedAt'];
    if (rawUpdatedAt is Timestamp) {
      parsedUpdatedAt = rawUpdatedAt.toDate();
    }

    return Plan(
      id: doc.id,
      name: data['name']?.toString() ?? 'Man Hub Pass',
      description: data['description']?.toString() ??
          'Acesso Ilimitado a Todos os Treinamentos',
      price: parsedPrice,
      currency: data['currency']?.toString() ?? 'BRL',
      billingPeriod: data['billingPeriod']?.toString() ?? 'monthly',
      features: parsedFeatures,
      active: data['active'] is bool ? data['active'] as bool : true,
      updatedAt: parsedUpdatedAt,
    );
  }

  Plan copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? currency,
    String? billingPeriod,
    List<String>? features,
    bool? active,
    DateTime? updatedAt,
  }) {
    return Plan(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      billingPeriod: billingPeriod ?? this.billingPeriod,
      features: features ?? this.features,
      active: active ?? this.active,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
