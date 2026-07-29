import 'package:uuid/uuid.dart';

sealed class ContentBlock {
  String id;
  String type;

  ContentBlock({String? id, required this.type}) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson();

  factory ContentBlock.fromJson(Map<String, dynamic> json) {
    switch (json['type']) {
      case 'title':
        return TitleBlock(id: json['id'], text: json['data'] ?? '');
      case 'title2':
        return Title2Block(id: json['id'], text: json['data'] ?? '');
      case 'description':
        return DescriptionBlock(id: json['id'], text: json['data'] ?? '');
      case 'highlighted_description':
        return HighlightedDescriptionBlock(id: json['id'], text: json['data'] ?? '');
      case 'image':
        return ImageBlock(id: json['id'], imageUrl: json['data'] ?? '');
      case 'video':
        return VideoBlock(id: json['id'], videoUrl: json['data'] ?? '');
      default:
        throw Exception('Unknown block type: ${json['type']}');
    }
  }
}

class TitleBlock extends ContentBlock {
  String text;
  TitleBlock({String? id, this.text = ''}) : super(id: id, type: 'title');

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'data': text,
      };
}

class Title2Block extends ContentBlock {
  String text;
  Title2Block({String? id, this.text = ''}) : super(id: id, type: 'title2');

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'data': text,
      };
}

class DescriptionBlock extends ContentBlock {
  String text;
  DescriptionBlock({String? id, this.text = ''}) : super(id: id, type: 'description');

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'data': text,
      };
}

class HighlightedDescriptionBlock extends ContentBlock {
  String text;
  HighlightedDescriptionBlock({String? id, this.text = ''}) : super(id: id, type: 'highlighted_description');

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'data': text,
      };
}

class ImageBlock extends ContentBlock {
  String imageUrl;
  ImageBlock({String? id, this.imageUrl = ''}) : super(id: id, type: 'image');

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'data': imageUrl,
      };
}

class VideoBlock extends ContentBlock {
  String videoUrl;
  VideoBlock({String? id, this.videoUrl = ''}) : super(id: id, type: 'video');

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'data': videoUrl,
      };
}
