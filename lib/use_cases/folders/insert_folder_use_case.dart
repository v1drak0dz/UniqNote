import 'package:uniqnote/repositories/folder_repository.dart';

class InsertFolderUseCase {
  final FolderRepository folderRepository;

  const InsertFolderUseCase(this.folderRepository);

  Future<void> createFolder(String name, int color) async =>
      await folderRepository.createFolder(name, color);
}
