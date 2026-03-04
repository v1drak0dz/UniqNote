import 'package:uniqnote/models/attachment.dart';
import 'package:uniqnote/repositories/notes_repository.dart';

class InsertNoteUseCase {
  final NotesRepository notesRepository;

  InsertNoteUseCase(this.notesRepository);

  Future<int> insertNote(
    String title,
    String content,
    List<Attachment> attachments,
  ) async {
    final noteId = notesRepository.createNote(title, content, attachments);

    return noteId;
  }
}
