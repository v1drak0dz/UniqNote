import 'package:uniqnote/models/note.dart';
import 'package:uniqnote/repositories/notes_repository.dart';

class GetNoteUseCase {
  final NotesRepository notesRepository;

  GetNoteUseCase(this.notesRepository);

  Future<List<Note>> getNotes() async {
    return await notesRepository.getNotes();
  }
}
