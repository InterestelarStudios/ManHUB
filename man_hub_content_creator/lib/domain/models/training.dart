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
  })  : id = id ?? const Uuid().v4(),
        modules = modules ?? [];

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
    );
  }
}
