import 'package:flutter/material.dart';
import '../helpers/storage.dart';
import '../helpers/utils.dart';

class NewNotePage extends StatefulWidget {
  const NewNotePage({super.key});

  @override
  _NewNotePageState createState() => _NewNotePageState();
}

class _NewNotePageState extends State<NewNotePage> {
  final titleController = TextEditingController();
  final contentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    titleController.text = generateTitle();
  }

  void _save() async {
    final title = titleController.text.trim();
    final content = contentController.text;

    await DBHelper.insertNote(title, content);

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [IconButton(icon: Icon(Icons.save), onPressed: _save)],
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
              padding: const EdgeInsets.all(16.0),
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
