import 'package:uuid/uuid.dart';
import 'screen_model.dart';

class Session {
  String id;
  String title;
  String subtitle;
  List<ScreenModel> screens;

  Session({
    String? id,
    this.title = '',
    this.subtitle = '',
    List<ScreenModel>? screens,
  })  : id = id ?? const Uuid().v4(),
        screens = screens ?? [];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'screens': screens.map((e) => e.toJson()).toList(),
    };
  }

  factory Session.fromJson(Map<String, dynamic> json) {
    var list = json['screens'] as List<dynamic>?;
    List<ScreenModel> parsedScreens = [];

    if (list != null) {
      for (var item in list) {
        parsedScreens.add(ScreenModel.fromJson(item as Map<String, dynamic>));
      }
    }

    return Session(
      id: json['id'] as String?,
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      screens: parsedScreens,
    );
  }
}
