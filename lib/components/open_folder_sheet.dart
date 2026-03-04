import 'package:flutter/material.dart';
import 'package:uniqnote/components/notes_grid.dart';
import 'package:uniqnote/models/folder.dart';
import 'package:uniqnote/models/note.dart';

class OpenFolderSheet extends StatelessWidget {
  final Folder folder;
  final List<Note> folderNotes;
  final void Function(Note note) openNote;
  final VoidCallback loadAll;
  final void Function(Note note) openMoveToFolderModal;

  const OpenFolderSheet({
    super.key,
    required this.folder,
    required this.folderNotes,
    required this.openNote,
    required this.loadAll,
    required this.openMoveToFolderModal,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          physics: NeverScrollableScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Text(
                folder.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              NotesGrid(
                notes: folderNotes,
                openNote: openNote,
                loadAll: loadAll,
                openMoveToFolder: openMoveToFolderModal,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
