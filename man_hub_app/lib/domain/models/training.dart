import 'package:uuid/uuid.dart';
import 'module.dart';

class Training {
  String id;
  String title;
  List<Module> modules;

  Training({
    String? id,
    this.title = '',
    List<Module>? modules,
  })  : id = id ?? const Uuid().v4(),
        modules = modules ?? [];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
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
      modules: parsedModules,
    );
  }
}
