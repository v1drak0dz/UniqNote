import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:uniqnote/cross_cutting/consts/themes.dart';
import 'package:uniqnote/cross_cutting/utils.dart';
import 'package:uniqnote/models/attachment.dart';
import 'package:uniqnote/models/note.dart';
import 'package:uniqnote/repositories/notes_repository.dart';
import 'package:uniqnote/services/password_service.dart';
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

  Future<bool> showPasswordDialog(
    BuildContext context,
    String id,
    Function(String) onCheck,
  ) async {
    final controller = TextEditingController();
    bool isValid = false;

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Digite a senha"),
        content: TextField(
          controller: controller,
          obscureText: true,
          decoration: const InputDecoration(hintText: "Senha"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () async {
              isValid = await onCheck(controller.text);
              if (isValid) {
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Senha incorreta")),
                );
              }
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );

    return isValid;
  }

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
        final contentLimited = generatePreview(note.content, limit: 300);
        final countedAttachments = note.attachments
            .fold<Map<AttachmentType, int>>({}, (map, att) {
              map[att.type] = (map[att.type] ?? 0) + 1;
              return map;
            });

        return GestureDetector(
          onTap: () async {
            if (note.isProtected == 1) {
              bool biometricUnlocked = await PasswordService()
                  .requestBiometricUnlock();

              if (biometricUnlocked) {
                openNote(note);
              } else {
                bool unlocked = await showPasswordDialog(
                  context,
                  note.id.toString(),
                  (input) => PasswordService().checkPassword(
                    note.id.toString(),
                    input,
                  ),
                );

                if (unlocked) {
                  openNote(note);
                }
              }
            } else {
              openNote(note);
            }
          },

          onLongPress: () {
            showModalBottomSheet(
              context: context,
              builder: (modalContext) {
                return SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: const Icon(
                          Icons.lock,
                          color: Colors.amberAccent,
                        ),
                        title: note.isProtected == 1
                            ? const Text("Desproteger")
                            : const Text("Proteger"),
                        onTap: () async {
                          if (note.isProtected == 1) {
                            await PasswordService().removePassword(
                              note.id.toString(),
                            );
                            await UpdateNoteUseCase(
                              NotesRepository(),
                            ).protectNote(note.id);
                          } else {
                            final controller = TextEditingController();
                            final result = await showDialog<String>(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text("Definir senha"),
                                content: TextField(
                                  controller: controller,
                                  obscureText: true,
                                  decoration: const InputDecoration(
                                    hintText: "Digite a senha",
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text("Cancelar"),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context, controller.text);
                                    },
                                    child: const Text("Salvar"),
                                  ),
                                ],
                              ),
                            );

                            if (result != null && result.isNotEmpty) {
                              await PasswordService().setPassword(
                                note.id.toString(),
                                result,
                              );
                              await UpdateNoteUseCase(
                                NotesRepository(),
                              ).protectNote(note.id);
                            }
                          }

                          loadAll();
                        },
                      ),

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
                          // overflow: TextOverflow.ellipsis,
                          softWrap: true,
                        ),
                      ),

                      note.isFavorite ==
                              1 //&& note.folderId != null
                          ? Icon(Icons.favorite, color: Colors.pink, size: 16.0)
                          : Text(""),

                      note.isProtected == 1
                          ? Icon(Icons.lock, color: Colors.amber, size: 16.0)
                          : Text(""),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${date.day}/${date.month}/${date.year}",
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const Divider(),
                  Wrap(
                    spacing: 4,
                    children: countedAttachments.entries.map((entry) {
                      final typ = entry.key;
                      final count = entry.value;
                      var ico = Icons.attach_file;

                      switch (typ) {
                        case AttachmentType.image:
                          ico = Icons.image;
                        case AttachmentType.audio:
                          ico = Icons.audiotrack;
                        case AttachmentType.file:
                          ico = Icons.attach_file;
                        case AttachmentType.video:
                          ico = Icons.videocam;
                      }

                      return Padding(
                        padding: EdgeInsetsGeometry.symmetric(
                          horizontal: 2,
                          vertical: 4,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(ico, size: 16),
                            Text(count.toString()),
                          ],
                        ),
                      );
                    }).toList(),
                  ),

                  Text(
                    contentLimited,
                    style: themeFonts[note.fontIndex].font().copyWith(
                      fontSize: 10,
                    ),
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
