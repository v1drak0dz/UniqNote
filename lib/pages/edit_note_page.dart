import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_filex/open_filex.dart';

import 'package:uniqnote/helpers/storage.dart';
import 'package:uniqnote/models/attachment.dart';
import 'package:uniqnote/models/note.dart';

class EditNotePage extends StatefulWidget {
  final Note note;

  const EditNotePage({required this.note});

  @override
  _EditNotePageState createState() => _EditNotePageState();
}

class _EditNotePageState extends State<EditNotePage> {
  late TextEditingController titleController;
  late TextEditingController contentController;

  // Lista de anexos da nota
  late List<Attachment> attachments;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.note.title);
    contentController = TextEditingController(text: widget.note.content);
    attachments = List<Attachment>.from(widget.note.attachments);
  }

  void _save() async {
    final id = widget.note.id;
    final title = titleController.text.trim();
    final content = contentController.text;

    await DBHelper.updateNote(id, title, content, attachments);

    Navigator.pop(context, true);
  }

  void _delete() async {
    final id = widget.note.id;
    await DBHelper.deleteNote(id);
    Navigator.pop(context, true);
  }

  // Métodos para adicionar anexos
  Future<void> _addImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        attachments.add(
          Attachment(type: AttachmentType.image, filePath: picked.path),
        );
      });
    }
  }

  Future<void> _addVideo() async {
    final picked = await ImagePicker().pickVideo(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        attachments.add(
          Attachment(type: AttachmentType.video, filePath: picked.path),
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
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: _save),
          IconButton(icon: const Icon(Icons.delete), onPressed: _delete),
        ],
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
          SizedBox(
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
                        label: const Text("Áudio"),
                        onPressed: () => _openFile(attachment.filePath),
                      ),
                    );
                  case AttachmentType.file:
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ActionChip(
                        label: const Text("Arquivo"),
                        onPressed: () => _openFile(attachment.filePath),
                      ),
                    );
                  case AttachmentType.video:
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ActionChip(
                        label: const Text("Vídeo"),
                        onPressed: () => _openFile(attachment.filePath),
                      ),
                    );
                }
              },
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
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
            label: "Imagem",
            onTap: _addImage,
          ),
          SpeedDialChild(
            child: const Icon(Icons.videocam),
            label: "Vídeo",
            onTap: _addVideo,
          ),
          SpeedDialChild(
            child: const Icon(Icons.mic),
            label: "Áudio",
            onTap: _addAudio,
          ),
          SpeedDialChild(
            child: const Icon(Icons.attach_file),
            label: "Arquivo",
            onTap: _addFile,
          ),
        ],
      ),
    );
  }
}
