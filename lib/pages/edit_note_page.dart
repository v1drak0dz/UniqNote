import 'package:flutter/material.dart';
import '../helpers/storage.dart';

class EditNotePage extends StatefulWidget {
  final Map<String, dynamic> note;

  const EditNotePage({required this.note});

  @override
  _EditNotePageState createState() => _EditNotePageState();
}

class _EditNotePageState extends State<EditNotePage> {
  late TextEditingController titleController;
  late TextEditingController contentController;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.note['title']);
    contentController = TextEditingController(text: widget.note['content']);
  }

  void _save() async {
    final id = widget.note['id'] as int;
    final title = titleController.text.trim();
    final content = contentController.text;

    await DBHelper.updateNote(id, title, content);

    Navigator.pop(context, true);
  }

  void _delete() async {
    final id = widget.note['id'] as int;
    await DBHelper.deleteNote(id);
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(icon: Icon(Icons.save), onPressed: _save),
          IconButton(icon: Icon(Icons.delete), onPressed: _delete),
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
              decoration: InputDecoration(
                hintText: "Título",
                border: InputBorder.none,
              ),
            ),
          ),
          Divider(),
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
                decoration: InputDecoration(
                  hintText: "Escreva sua nota...",
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
