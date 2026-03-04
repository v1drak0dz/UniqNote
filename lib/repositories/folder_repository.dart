import 'package:uniqnote/services/database_service.dart';
import 'package:uniqnote/models/folder.dart';

class FolderRepository {
  Future<List<Folder>> getFolders() async {
    final db = await DatabaseService.database;

    final result = await db.query('folders');
    return result.map((e) => Folder.fromMap(e)).toList();
  }

  Future<int> deleteFolder(int folderId) async {
    final db = await DatabaseService.database;

    return await db.delete('folders', where: 'id = ?', whereArgs: [folderId]);
  }

  Future<int> createFolder(String name, int color) async {
    final db = await DatabaseService.database;

    return await db.insert('folders', {
      'name': name,
      'color': color,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<int> updateFolderColor(int folderId, int color) async {
    final db = await DatabaseService.database;

    return await db.update(
      'folders',
      {'color': color},
      where: 'id = ?',
      whereArgs: [folderId],
    );
  }

  Future<int> renameFolder(int folderId, String newName) async {
    final db = await DatabaseService.database;

    return await db.update(
      'folders',
      {'name': newName},
      where: 'id = ?',
      whereArgs: [folderId],
    );
  }
}
