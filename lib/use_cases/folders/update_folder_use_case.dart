import 'package:uniqnote/repositories/folder_repository.dart';

class UpdateFolderUseCase {
  final FolderRepository folderRepository;

  const UpdateFolderUseCase(this.folderRepository);

  Future<int> updateFolderColor(int folderId, int color) async =>
      await folderRepository.updateFolderColor(folderId, color);

  Future<int> renameFolder(int folderId, String newName) async =>
      await folderRepository.renameFolder(folderId, newName);

  Future<int> protectFolder(int folderId) async =>
      await folderRepository.protectFolder(folderId);
}
