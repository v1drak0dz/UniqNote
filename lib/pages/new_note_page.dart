import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_filex/open_filex.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:uniqnote/helpers/db_helper.dart';
import 'package:uniqnote/helpers/utils.dart';

import 'package:uniqnote/models/attachment.dart';

class NewNotePage extends StatefulWidget {
  const NewNotePage({super.key});

  @override
  _NewNotePageState createState() => _NewNotePageState();
}

class _NewNotePageState extends State<NewNotePage> {
  final titleController = TextEditingController();
  final contentController = TextEditingController();

  // Lista de anexos
  List<Attachment> attachments = [];

  @override
  void initState() {
    super.initState();
    titleController.text = "$generateTitle() - $tr('your_title')";
  }

  void _save() async {
    final title = titleController.text.trim();
    final content = contentController.text;

    await DBHelper.insertNote(title, content, attachments);

    Navigator.pop(context, true);
  }

  // Métodos para adicionar anexos
  Future<void> _addImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        attachments.add(
          Attachment(
            type: AttachmentType.image,
            filePath: picked.path,
            name: picked.name,
          ),
        );
      });
    }
  }

  Future<void> _addVideo() async {
    final picked = await ImagePicker().pickVideo(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        attachments.add(
          Attachment(
            type: AttachmentType.video,
            filePath: picked.path,
            name: picked.name,
          ),
        );
      });
    }
  }

  Future<void> _addFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        attachments.add(
          Attachment(
            type: AttachmentType.file,
            filePath: result.files.first.path!,
            name: result.files.first.name,
          ),
        );
      });
    }
  }

  Future<void> _addAudio() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.audio);
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        attachments.add(
          Attachment(
            type: AttachmentType.audio,
            filePath: result.files.first.path!,
            name: result.files.first.name,
          ),
        );
      });
    }
  }

  Future<void> _openFile(String path) async {
    await OpenFilex.open(path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [IconButton(icon: const Icon(Icons.save), onPressed: _save)],
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
              decoration: const InputDecoration(
                hintText: "Título",
                border: InputBorder.none,
              ),
            ),
          ),
          const Divider(),
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
                              label: attachment.name != 'file'
                                  ? Text(attachment.name)
                                  : Text(tr("audio")),
                              onPressed: () => _openFile(attachment.filePath),
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
                decoration: const InputDecoration(
                  hintText: "Escreva sua nota...",
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: SpeedDial(
        icon: Icons.add,
        activeIcon: Icons.close,
        backgroundColor: Colors.blue,
        children: [
          SpeedDialChild(
            child: const Icon(Icons.image),
            label: tr("image"),
            onTap: _addImage,
          ),
          SpeedDialChild(
            child: const Icon(Icons.videocam),
            label: tr("video"),
            onTap: _addVideo,
          ),
          SpeedDialChild(
            child: const Icon(Icons.mic),
            label: tr("audio"),
            onTap: _addAudio,
          ),
          SpeedDialChild(
            child: const Icon(Icons.attach_file),
            label: tr("file"),
            onTap: _addFile,
          ),
        ],
      ),
    );
  }
}
