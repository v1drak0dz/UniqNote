import 'package:uniqnote/models/attachment.dart';
import 'package:uniqnote/repositories/attachments_repository.dart';

class InsertAttachmentsUseCase {
  final AttachmentsRepository attachmentsRepository;

  InsertAttachmentsUseCase(this.attachmentsRepository);

  Future<void> insertAttachments(
    List<Attachment> attachments,
    int noteId,
  ) async {
    for (var attachment in attachments) {
      attachmentsRepository.createAttachment(attachment, noteId);
    }
  }
}
