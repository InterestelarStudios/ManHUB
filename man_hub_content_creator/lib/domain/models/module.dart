import 'package:uuid/uuid.dart';
import 'session.dart';

class Module {
  String id;
  String title;
  List<Session> sessions;

  Module({
    String? id,
    this.title = '',
    List<Session>? sessions,
  })  : id = id ?? const Uuid().v4(),
        sessions = sessions ?? [];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'sessions': sessions.map((e) => e.toJson()).toList(),
    };
  }

  factory Module.fromJson(Map<String, dynamic> json) {
    var list = json['sessions'] as List<dynamic>?;
    List<Session> parsedSessions = [];

    if (list != null) {
      for (var item in list) {
        parsedSessions.add(Session.fromJson(item as Map<String, dynamic>));
      }
    }

    return Module(
      id: json['id'] as String?,
      title: json['title'] as String? ?? '',
      sessions: parsedSessions,
    );
  }
}
