import 'package:uuid/uuid.dart';
import 'module.dart';

class Training {
  String id;
  String title;
  String? subtitle;
  String? description;
  String? whatYouWillLearn;
  String? duration;
  String? coverImageUrl;
  String? requirements;
  String? updatedAt;
  List<Module> modules;
  String? category;
  List<String> categories;
  double? price;

  Training({
    String? id,
    this.title = '',
    this.subtitle,
    this.description,
    this.whatYouWillLearn,
    this.duration,
    this.coverImageUrl,
    this.requirements,
    this.updatedAt,
    List<Module>? modules,
    this.category,
    List<String>? categories,
    this.price,
  })  : id = id ?? const Uuid().v4(),
        modules = modules ?? [],
        categories = categories ?? [];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      if (subtitle != null && subtitle!.isNotEmpty) 'subtitle': subtitle,
      if (description != null && description!.isNotEmpty) 'description': description,
      if (whatYouWillLearn != null && whatYouWillLearn!.isNotEmpty) 'whatYouWillLearn': whatYouWillLearn,
      if (duration != null && duration!.isNotEmpty) 'duration': duration,
      if (coverImageUrl != null && coverImageUrl!.isNotEmpty) 'coverImageUrl': coverImageUrl,
      if (requirements != null && requirements!.isNotEmpty) 'requirements': requirements,
      if (updatedAt != null && updatedAt!.isNotEmpty) 'updatedAt': updatedAt,
      'modules': modules.map((e) => e.toJson()).toList(),
      if (category != null && category!.isNotEmpty) 'category': category,
      if (categories.isNotEmpty) 'categories': categories,
      if (price != null) 'price': price,
    };
  }

  factory Training.fromJson(Map<String, dynamic> json) {
    var list = json['modules'] as List<dynamic>?;
    List<Module> parsedModules = [];

    if (list != null) {
      for (var item in list) {
        parsedModules.add(Module.fromJson(item as Map<String, dynamic>));
      }
    }

    final cat = json['category'] as String?;
    final rawCats = json['categories'] as List<dynamic>?;
    final parsedCats = rawCats != null
        ? rawCats.map((e) => e.toString()).toList()
        : (cat != null && cat.isNotEmpty ? [cat] : <String>[]);

    return Training(
      id: json['id'] as String?,
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String?,
      description: json['description'] as String?,
      whatYouWillLearn: json['whatYouWillLearn'] as String?,
      duration: json['duration'] as String?,
      coverImageUrl: json['coverImageUrl'] as String?,
      requirements: json['requirements'] as String?,
      updatedAt: json['updatedAt'] as String?,
      modules: parsedModules,
      category: cat,
      categories: parsedCats,
      price: (json['price'] as num?)?.toDouble(),
    );
  }
}
