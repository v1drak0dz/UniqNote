enum AttachmentType { image, audio, file, video }

class Attachment {
  final AttachmentType type;
  final String filePath;

  Attachment({required this.type, required this.filePath});
}
