import 'package:sqflite/sqflite.dart';
import 'package:sqflite_migration_service/sqflite_migration_service.dart'
    as mig;
import 'package:path/path.dart';

import 'package:uniqnote/models/attachment.dart';
import 'package:uniqnote/models/note.dart';
import 'package:uniqnote/models/folder.dart';

class DBHelper {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();

    final migrationService = mig.DatabaseMigrationService();

    await migrationService.runMigration(
      _db,
      migrationFiles: [
        '1_create_notes_table.sql',
        '2_create_attachments_table.sql',
        '3_add_is_favorite_to_notes.sql',
        '4_add_name_to_attachments.sql',
        '5_create_folders_add_to_notes.sql',
      ],
    );

    return _db!;
  }

  static Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'notes.db');

    return await openDatabase(path, version: 2);
  }

  static Future<int> insertFolder(String name) async {
    final db = await database;

    return await db.insert('folders', {
      'name': name,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  static Future<List<Folder>> getFolders() async {
    final db = await database;

    final result = await db.query('folders');

    return result.map((e) => Folder.fromMap(e)).toList();
  }

  static Future<void> moveNoteToFolder(int noteId, int? folderId) async {
    final db = await database;

    await db.update(
      'notes',
      {'folder_id': folderId},
      where: 'id = ?',
      whereArgs: [noteId],
    );
  }

  static Future<int> insertNote(
    String title,
    String content,
    List<Attachment> attachments,
  ) async {
    final db = await database;
    final noteId = await db.insert('notes', {
      'title': title,
      'content': content,
      'created_at': DateTime.now().toIso8601String(),
      'modified_at': DateTime.now().toIso8601String(),
    });

    for (var attachment in attachments) {
      await db.insert('attachments', {
        'note_id': noteId,
        'type': attachment.type.toString().split('.').last,
        'file_path': attachment.filePath,
        'name': attachment.name,
      });
    }

    return noteId;
  }

  static Future<List<Note>> getNotesWithAttachments() async {
    final db = await database;
    final notesRaw = await db.query(
      'notes',
      orderBy: 'is_favorite DESC, modified_at DESC',
    );

    List<Note> notes = [];

    for (var noteMap in notesRaw) {
      final attachmentsRaw = await db.query(
        'attachments',
        where: 'note_id = ?',
        whereArgs: [noteMap['id']],
      );

      final attachments = attachmentsRaw.map((att) {
        return Attachment(
          type: AttachmentType.values.firstWhere(
            (t) => t.toString().split('.').last == att['type'],
          ),
          filePath: att['file_path'] as String,
          name: att['name'] as String,
        );
      }).toList();

      notes.add(
        Note(
          id: noteMap['id'] as int,
          title: noteMap['title'] as String,
          content: noteMap['content'] as String,
          createdAt: DateTime.parse(noteMap['created_at'] as String),
          modifiedAt: DateTime.parse(noteMap['modified_at'] as String),
          attachments: attachments,
          isFavorite: noteMap['is_favorite'] as int,
          folderId: noteMap['folder_id'] as int?,
        ),
      );
    }

    return notes;
  }

  /// Atualizar nota e substituir anexos
  static Future<int> updateNote(
    int id,
    String title,
    String content,
    List<Attachment> attachments,
  ) async {
    final db = await database;
    final result = await db.update(
      'notes',
      {
        'title': title,
        'content': content,
        'modified_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );

    await db.delete('attachments', where: 'note_id = ?', whereArgs: [id]);
    for (var attachment in attachments) {
      await db.insert('attachments', {
        'note_id': id,
        'type': attachment.type.toString().split('.').last,
        'file_path': attachment.filePath,
        'name': attachment.name,
      });
    }

    return result;
  }

  static Future<int> deleteNote(int id) async {
    final db = await database;
    await db.delete('attachments', where: 'note_id = ?', whereArgs: [id]);
    return await db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }

  static Future<int> favoriteNode(int id) async {
    final db = await database;
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
