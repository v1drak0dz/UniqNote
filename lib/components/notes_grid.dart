import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:uniqnote/models/attachment.dart';
import 'package:uniqnote/models/note.dart';
import 'package:uniqnote/repositories/notes_repository.dart';
import 'package:uniqnote/use_cases/notes/delete_note_use_case.dart';
import 'package:uniqnote/use_cases/notes/update_note_use_case.dart';

class NotesGrid extends StatelessWidget {
  final List<Note> notes;
  final void Function(Note note) openNote;
  final VoidCallback loadAll;
  final void Function(Note note) openMoveToFolder;

  const NotesGrid({
    super.key,
    required this.notes,
    required this.openNote,
    required this.loadAll,
    required this.openMoveToFolder,
  });

  @override
  Widget build(BuildContext context) {
    return MasonryGridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      itemCount: notes.length,
      itemBuilder: (_, i) {
        final note = notes[i];
        final date = note.modifiedAt;

        return GestureDetector(
          onTap: () => openNote(note),
          onLongPress: () {
            showModalBottomSheet(
              context: context,
              builder: (modalContext) {
                return SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: Icon(Icons.favorite, color: Colors.pink),
                        title: note.isFavorite == 1
                            ? Text(tr("unfavorite"))
                            : Text(tr("favorite")),
                        onTap: () async {
                          Navigator.pop(modalContext);
                          await UpdateNoteUseCase(
                            NotesRepository(),
                          ).favoriteNote(note.id);
                          loadAll();
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.delete, color: Colors.red),
                        title: Text(tr("delete")),
                        onTap: () async {
                          Navigator.pop(modalContext);
                          await DeleteNoteUseCase(
                            NotesRepository(),
                          ).deleteNote(note.id);
                          loadAll();
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.folder, color: Colors.amber),
                        title: Text(tr("move_to_folder")),
                        onTap: () async {
                          Navigator.pop(modalContext);
                          openMoveToFolder(note);
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          },
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          note.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      note.isFavorite ==
                              1 //&& note.folderId != null
                          ? Icon(Icons.favorite, color: Colors.pink, size: 16.0)
                          : Text(""),
                    ],
                  ),

                  const SizedBox(height: 4),
                  Text(
                    "${date.day}/${date.month}/${date.year}",
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 4,
                    children: note.attachments.map((att) {
                      switch (att.type) {
                        case AttachmentType.image:
                          return const Icon(Icons.image, size: 16);
                        case AttachmentType.audio:
                          return const Icon(Icons.audiotrack, size: 16);
                        case AttachmentType.file:
                          return const Icon(Icons.attach_file, size: 16);
                        case AttachmentType.video:
                          return const Icon(Icons.videocam, size: 16);
                      }
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
