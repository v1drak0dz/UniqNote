enum AttachmentType { image, audio, file, video }

class Attachment {
  final AttachmentType type;
  final String filePath;
  final String name;

  Attachment({required this.type, required this.filePath, required this.name});
}
