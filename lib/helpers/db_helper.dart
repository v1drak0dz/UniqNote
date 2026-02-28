import 'package:sqflite/sqflite.dart';
import 'package:sqflite_migration_service/sqflite_migration_service.dart'
    as mig;
import 'package:path/path.dart';

import 'package:uniqnote/models/attachment.dart';
import 'package:uniqnote/models/note.dart';

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
      ],
    );

    return _db!;
  }

  static Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'notes.db');

    return await openDatabase(path, version: 2);
  }

  /// Inserir nota com anexos
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
      });
    }

    return noteId;
  }

  static Future<List<Note>> getNotesWithAttachments() async {
    final db = await database;
    final notesRaw = await db.query('notes', orderBy: 'modified_at DESC');

    List<Note> notes = [];

    for (var noteMap in notesRaw) {
      // Buscar anexos da nota
      final attachmentsRaw = await db.query(
        'attachments',
        where: 'note_id = ?',
        whereArgs: [noteMap['id']],
      );

      // Converter cada anexo em objeto Attachment
      final attachments = attachmentsRaw.map((att) {
        return Attachment(
          type: AttachmentType.values.firstWhere(
            (t) => t.toString().split('.').last == att['type'],
          ),
          filePath: att['file_path'] as String,
        );
      }).toList();

      // Montar objeto Note
      notes.add(
        Note(
          id: noteMap['id'] as int,
          title: noteMap['title'] as String,
          content: noteMap['content'] as String,
          createdAt: DateTime.parse(noteMap['created_at'] as String),
          modifiedAt: DateTime.parse(noteMap['modified_at'] as String),
          attachments: attachments,
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

    // Remove anexos antigos e insere os novos
    await db.delete('attachments', where: 'note_id = ?', whereArgs: [id]);
    for (var attachment in attachments) {
      await db.insert('attachments', {
        'note_id': id,
        'type': attachment.type.toString().split('.').last,
        'file_path': attachment.filePath,
      });
    }

    return result;
  }

  /// Deletar nota e anexos vinculados
  static Future<int> deleteNote(int id) async {
    final db = await database;
    // Deletar anexos primeiro (ON DELETE CASCADE também cobre isso)
    await db.delete('attachments', where: 'note_id = ?', whereArgs: [id]);
    return await db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }
}
