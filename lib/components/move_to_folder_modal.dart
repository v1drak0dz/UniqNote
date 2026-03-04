import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:uniqnote/models/folder.dart';
import 'package:uniqnote/models/note.dart';
import 'package:uniqnote/repositories/notes_repository.dart';
import 'package:uniqnote/use_cases/notes/update_note_use_case.dart';

class MoveToFolderModal extends StatelessWidget {
  final List<Folder> folders;
  final VoidCallback loadAll;
  final Note note;

  const MoveToFolderModal({
    super.key,
    required this.folders,
    required this.loadAll,
    required this.note,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: Text(tr("no_folder")),
            leading: const Icon(Icons.folder_off),
            onTap: () async {
              Navigator.pop(context);
              await UpdateNoteUseCase(
                NotesRepository(),
              ).moveNoteToFolder(note.id, null);
              loadAll();
            },
          ),

          ...folders.map((folder) {
            return ListTile(
              leading: const Icon(Icons.folder),
              title: Text(folder.name),
              onTap: () async {
                Navigator.pop(context);
                await UpdateNoteUseCase(
                  NotesRepository(),
                ).moveNoteToFolder(note.id, folder.id);
                loadAll();
              },
            );
          }),
        ],
      ),
    );
  }
}
