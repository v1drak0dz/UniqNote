import 'dart:io';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:open_filex/open_filex.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:uniqnote/components/attachments_fab.dart';
import 'package:uniqnote/cross_cutting/theme_handler.dart';
import 'package:uniqnote/cross_cutting/utils.dart';

import 'package:uniqnote/models/attachment.dart';
import 'package:uniqnote/pages/audio_record_page.dart';
import 'package:uniqnote/strategies/attachmentStrategy/attachment_context.dart';

import 'package:uniqnote/repositories/attachments_repository.dart';
import 'package:uniqnote/repositories/notes_repository.dart';

import 'package:uniqnote/use_cases/attachments/insert_attachments_use_case.dart';
import 'package:uniqnote/use_cases/notes/insert_note_use_case.dart';

class NewNotePage extends StatefulWidget {
  const NewNotePage({super.key});

  @override
  State<NewNotePage> createState() => _NewNotePageState();
}

class _NewNotePageState extends State<NewNotePage> {
  final titleController = TextEditingController();
  final contentController = TextEditingController();
  final dummyTitle = tr("your_title");
  final timestampTitle = generateTitle();
  final AudioPlayer player = AudioPlayer();
  bool isPlaying = false;

  List<Attachment> attachments = [];

  @override
  void initState() {
    super.initState();
    player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        setState(() => isPlaying = false);
      }
    });
  }

  void _save() async {
    final title = titleController.text.trim();
    final content = contentController.text;

    final noteId = await InsertNoteUseCase(
      NotesRepository(),
    ).insertNote(title, content, attachments);

    InsertAttachmentsUseCase(
      AttachmentsRepository(),
    ).insertAttachments(attachments, noteId);

    Navigator.pop(context, true);
  }

  Future<void> _addAttach(AttachmentType attachType) async {
    final attachmentService = AttachmentContext(attachType);
    final attach = await attachmentService.addAttachment();

    if (attach != null) {
      setState(() {
        attachments.add(attach);
      });
    }
  }

  Future<void> _playAudio(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Arquivo de áudio não encontrado"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    await player.setFilePath(path);
    setState(() => isPlaying = true);
    await player.play();
  }

  Future<void> _addAudio() async {
    final result = await showModalBottomSheet<Map<String, String>>(
      context: context,
      isScrollControlled: true,
      builder: (context) => const RecordAudioSheet(),
    );

    if (result != null) {
      setState(() {
        attachments.add(
          Attachment(
            type: AttachmentType.audio,
            filePath: result['path']!,
            name: result['name']!,
          ),
        );
      });
    }
  }

  Future<void> _stopAudio() async {
    setState(() => isPlaying = false);
    await player.stop();
  }

  Future<void> _openFile(String path) async {
    await OpenFilex.open(path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: _save),
          IconButton(
            icon: const Icon(Icons.auto_awesome),
            onPressed: () => titleController.text = generateTitle(),
          ),
        ],
        backgroundColor: ThemeHandler.getBackgroundColor(context),
        foregroundColor: ThemeHandler.getForegroundColor(context),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: TextField(
              controller: titleController,
              decoration: InputDecoration(
                hintText: tr("Título"),
                border: InputBorder.none,
              ),
            ),
          ),
          Divider(
            indent: 24.0,
            endIndent: 24.0,
            radius: BorderRadiusGeometry.circular(12.0),
          ),
          attachments.isEmpty
              ? const SizedBox.shrink()
              : SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: attachments.length,
                    itemBuilder: (context, index) {
                      final attachment = attachments[index];
                      switch (attachment.type) {
                        case AttachmentType.image:
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Image.file(File(attachment.filePath)),
                          );
                        case AttachmentType.audio:
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ActionChip(
                              label: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    attachment.name != 'file'
                                        ? attachment.name
                                        : tr("audio"),
                                    style: const TextStyle(fontSize: 16),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(width: 6),
                                  Icon(
                                    isPlaying ? Icons.stop : Icons.play_arrow,
                                    size: 22,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                ],
                              ),
                              onPressed: () {
                                if (isPlaying) {
                                  _stopAudio();
                                } else {
                                  _playAudio(attachment.filePath);
                                }
                              },
                            ),
                          );

                        case AttachmentType.file:
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ActionChip(
                              label: attachment.name != 'file'
                                  ? Text(attachment.name)
                                  : Text(tr("file")),
                              onPressed: () => _openFile(attachment.filePath),
                            ),
                          );
                        case AttachmentType.video:
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ActionChip(
                              label: attachment.name != 'file'
                                  ? Text(attachment.name)
                                  : Text(tr("video")),
                              onPressed: () => _openFile(attachment.filePath),
                            ),
                          );
                      }
                    },
                  ),
                ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: contentController,
                maxLines: null,
                expands: true,
                decoration: InputDecoration(
                  hintText: tr("Escreva sua nota..."),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: AttachmentsFab(
        onAddAttach: _addAttach,
        onAddAudio: _addAudio,
      ),
    );
  }
}
