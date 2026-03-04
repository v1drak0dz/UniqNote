import 'package:uniqnote/repositories/attachments_repository.dart';

class DeleteAttachmentsUseCase {
  final AttachmentsRepository attachmentsRepository;

  DeleteAttachmentsUseCase(this.attachmentsRepository);

  Future<void> deleteAttachmentsFromNote(int noteId) async {
    await attachmentsRepository.deleteFromNote(noteId);
  }
}
