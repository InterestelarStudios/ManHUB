import 'package:uuid/uuid.dart';
import 'content_block.dart';

class ScreenModel {
  String id;
  String title;
  List<ContentBlock> contents;

  ScreenModel({
    String? id,
    this.title = '',
    List<ContentBlock>? contents,
  })  : id = id ?? const Uuid().v4(),
        contents = contents ?? [];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'contents': contents.map((e) => e.toJson()).toList(),
    };
  }

  factory ScreenModel.fromJson(Map<String, dynamic> json) {
    var list = json['contents'] as List<dynamic>?;
    List<ContentBlock> parsedContents = [];

    if (list != null) {
      for (var item in list) {
        parsedContents.add(ContentBlock.fromJson(item as Map<String, dynamic>));
      }
    }

    return ScreenModel(
      id: json['id'] as String?,
      title: json['title'] as String? ?? '',
      contents: parsedContents,
    );
  }
}
