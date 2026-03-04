import 'package:uniqnote/models/attachment.dart';
import 'package:uniqnote/repositories/attachments_repository.dart';

class UpdateAttachmentsUseCase {
  final AttachmentsRepository attachmentsRepository;

  UpdateAttachmentsUseCase(this.attachmentsRepository);

  Future<void> updateAttachments(
    int noteId,
    List<Attachment> attachments,
  ) async {
    await attachmentsRepository.deleteFromNote(noteId);

    for (var attachment in attachments) {
      await attachmentsRepository.createAttachment(attachment, noteId);
    }
  }
}
