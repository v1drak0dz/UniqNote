import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:uniqnote/repositories/folder_repository.dart';
import 'package:uniqnote/use_cases/folders/update_folder_use_case.dart';

class RenameFolderModal extends StatelessWidget {
  final VoidCallback loadAll;
  final TextEditingController controller;
  final int folderId;

  const RenameFolderModal({
    super.key,
    required this.loadAll,
    required this.controller,
    required this.folderId,
  });

  @override
  Widget build(BuildContext build) {
    return AlertDialog(
      title: Text(tr("rename_folder")),
      content: TextField(
        controller: controller,
        autofocus: true,
        decoration: InputDecoration(hintText: tr("folder_name")),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(build);
            loadAll();
          },
          child: Text(tr("cancel")),
        ),
        ElevatedButton(
          onPressed: () async {
            final newName = controller.text.trim();

            if (newName.isEmpty) return;

            Navigator.pop(build);
            await UpdateFolderUseCase(
              FolderRepository(),
            ).renameFolder(folderId, newName);

            loadAll();
          },
          child: Text(tr("rename")),
        ),
      ],
    );
  }
}
