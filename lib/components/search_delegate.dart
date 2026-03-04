import 'package:flutter/material.dart';
import 'package:uniqnote/models/note.dart';

class NotesSearchDelegate extends SearchDelegate<String> {
  final List<Note> notes;
  final void Function(Note) onOpenNote;

  NotesSearchDelegate(this.notes, this.onOpenNote);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ""),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, ""),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    close(context, query);
    return Container();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = notes.where((n) {
      return n.title.toLowerCase().contains(query.toLowerCase());
    }).toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (_, i) {
        final note = suggestions[i];

        return ListTile(title: Text(note.title), onTap: () => onOpenNote(note));
      },
    );
  }
}
