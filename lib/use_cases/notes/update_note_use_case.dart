import 'package:uniqnote/repositories/notes_repository.dart';

class UpdateNoteUseCase {
  final NotesRepository notesRepository;

  UpdateNoteUseCase(this.notesRepository);

  Future<void> updateNote(int noteId, String title, String content) async =>
      await notesRepository.updateNote(noteId, title, content);

  Future<void> moveNoteToFolder(int noteId, int? folderId) async =>
      await notesRepository.moveNoteToFolder(noteId, folderId);

  Future<void> favoriteNote(int noteId) async =>
      await notesRepository.favoriteNode(noteId);

  Future<void> protectNote(int noteId) async =>
      await notesRepository.protectNote(noteId);
}
