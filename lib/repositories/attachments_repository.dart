import 'package:uniqnote/services/database_service.dart';
import 'package:uniqnote/models/attachment.dart';

class AttachmentsRepository {
  Future<void> createAttachment(Attachment attachment, int noteId) async {
    final db = await DatabaseService.database;
    await db.insert('attachments', {
      'note_id': noteId,
      'type': attachment.type.toString().split('.').last,
      'file_path': attachment.filePath,
      'name': attachment.name,
    });
  }

  Future<void> deleteAttachment(int attachmentId) async {
    final db = await DatabaseService.database;
    await db.delete('attachments', where: 'id = ?', whereArgs: [attachmentId]);
  }

  Future<void> deleteFromNote(int noteId) async {
    final db = await DatabaseService.database;
    await db.delete('attachments', where: 'note_id = ?', whereArgs: [noteId]);
  }
}
