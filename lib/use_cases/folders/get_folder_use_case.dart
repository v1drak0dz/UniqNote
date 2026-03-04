import 'package:uniqnote/models/folder.dart';
import 'package:uniqnote/repositories/folder_repository.dart';

class GetFolderUseCase {
  final FolderRepository folderRepository;

  GetFolderUseCase(this.folderRepository);

  Future<List<Folder>> getFolders() async {
    return await folderRepository.getFolders();
  }
}
