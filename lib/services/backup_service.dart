import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class BackupService {
  static Future<void> autoBackup() async {
    final dbPath = await getDatabasesPath();
    final sourcePath = join(dbPath, 'notes.db');

    final dir = await getApplicationDocumentsDirectory();

    final backupPath = join(dir.path, "notes_backup.db");

    final file = File(sourcePath);

    if (await file.exists()) {
      await file.copy(backupPath);
    }
  }
}
