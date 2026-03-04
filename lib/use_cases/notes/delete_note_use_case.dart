import 'package:uniqnote/repositories/notes_repository.dart';

class DeleteNoteUseCase {
  final NotesRepository notesRepository;

  DeleteNoteUseCase(this.notesRepository);

  Future<void> deleteNote(int noteId) async {
    await notesRepository.deleteNote(noteId);
  }
}
