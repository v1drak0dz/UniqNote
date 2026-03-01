import 'package:uniqnote/models/attachment.dart';

class Note {
  final int id;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime modifiedAt;
  final int isFavorite;
  final int? folderId;
  final List<Attachment> attachments;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.modifiedAt,
    this.isFavorite = 0,
    this.attachments = const [],
    this.folderId,
  });
}
