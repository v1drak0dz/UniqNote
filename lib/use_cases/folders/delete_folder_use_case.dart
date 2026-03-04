import 'package:uniqnote/repositories/folder_repository.dart';

class DeleteFolderUseCase {
  final FolderRepository folderRepository;

  const DeleteFolderUseCase({required this.folderRepository});

  Future<void> deleteFolder(int folderId) async =>
      await folderRepository.deleteFolder(folderId);
}
