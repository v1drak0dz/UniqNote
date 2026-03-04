import 'package:uniqnote/services/database_service.dart';
import 'package:uniqnote/models/attachment.dart';
import 'package:uniqnote/models/note.dart';

class NotesRepository {
  Future<int> createNote(
    String title,
    String content,
    List<Attachment> attachments,
  ) async {
    final db = await DatabaseService.database;
    final noteId = await db.insert('notes', {
      'title': title,
      'content': content,
      'created_at': DateTime.now().toIso8601String(),
      'modified_at': DateTime.now().toIso8601String(),
    });

    return noteId;
  }

  Future<void> deleteNote(int noteId) async {
    final db = await DatabaseService.database;

    await db.delete('notes', where: "id = ?", whereArgs: [noteId]);
  }

  Future<void> updateNote(int noteId, String title, String content) async {
    final db = await DatabaseService.database;

    await db.update(
      'notes',
      {
        'title': title,
        'content': content,
        'modified_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [noteId],
    );
  }

  Future<List<Note>> getNotes() async {
    final db = await DatabaseService.database;

    final rows = await db.rawQuery('''
      SELECT n.*, a.id as attachment_id, a.type, a.file_path, a.name
      FROM notes n
      LEFT JOIN attachments a ON a.note_id = n.id
      ORDER BY n.is_favorite DESC, n.modified_at DESC
    ''');

    final Map<int, Note> notesMap = {};

    for (var row in rows) {
      final noteId = row['id'] as int;

      notesMap.putIfAbsent(noteId, () {
        return Note(
          id: noteId,
          title: row['title'] as String,
          content: row['content'] as String,
          createdAt: DateTime.parse(row['created_at'] as String),
          modifiedAt: DateTime.parse(row['modified_at'] as String),
          attachments: [],
          isFavorite: row['is_favorite'] as int,
          folderId: row['folder_id'] != null
              ? int.tryParse(row['folder_id'].toString())
              : null,
        );
      });

      if (row['attachment_id'] != null) {
        notesMap[noteId]!.attachments.add(
          Attachment(
            type: AttachmentType.values.firstWhere(
              (t) => t.toString().split('.').last == row['type'],
            ),
            filePath: row['file_path'] as String,
            name: row['name'] as String,
          ),
        );
      }
    }

    return notesMap.values.toList();
  }

  Future<int> moveNoteToFolder(int noteId, int? folderId) async {
    final db = await DatabaseService.database;

    return await db.update(
      'notes',
      {'folder_id': folderId},
      where: 'id = ?',
      whereArgs: [noteId],
    );
  }

  Future<int> favoriteNode(int id) async {
    final db = await DatabaseService.database;
    return await db.rawUpdate(
      '''
      UPDATE notes
         SET is_favorite = CASE is_favorite
             WHEN 1 THEN 0
             ELSE 1
         END
       WHERE id = ?
      ''',
      [id],
    );
  }
}
