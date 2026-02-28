import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'helpers/storage.dart';
import 'pages/new_note_page.dart';
import 'pages/edit_note_page.dart';

void main() => runApp(
  MaterialApp(
    home: HomePage(),
    localizationsDelegates: const [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: const [Locale('en', ''), Locale('pt', '')],

    theme: ThemeData(
      brightness: Brightness.light,
      primarySwatch: Colors.blue,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
    ),
    darkTheme: ThemeData(
      brightness: Brightness.dark,
      primarySwatch: Colors.deepPurple,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      cardColor: Colors.grey[900],
    ),
    themeMode: ThemeMode.system,
  ),
);

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> notes = [];
  String query = "";

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  void _loadNotes() async {
    final data = await DBHelper.getNotes();
    setState(() {
      notes = data;
    });
  }

  void _openNote(Map<String, dynamic> note) async {
    final updated = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditNotePage(note: note)),
    );
    if (updated == true) {
      _loadNotes();
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredNotes = notes.where((n) {
      final name = (n['title'] ?? "").toLowerCase();
      return name.contains(query.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text("Notes"),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () async {
              await showSearch(
                context: context,
                delegate: NotesSearchDelegate(notes, _openNote),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: filteredNotes.isEmpty
            ? Center(
                child: Icon(
                  Icons.description_outlined,
                  size: 96,
                  color: Colors.grey,
                ),
              )
            : Padding(
                padding: const EdgeInsets.all(8.0),
                child: MasonryGridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  itemCount: filteredNotes.length,
                  itemBuilder: (_, i) {
                    final note = filteredNotes[i];
                    final name = note['title'];
                    final date = DateTime.parse(note['createdAt']);

                    return GestureDetector(
                      onTap: () => _openNote(note),
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                name,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                "${date.day}/${date.month}/${date.year}",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => NewNotePage()),
          );
          _loadNotes();
        },
        child: Icon(Icons.edit),
      ),
    );
  }
}

class NotesSearchDelegate extends SearchDelegate<String> {
  final List<Map<String, dynamic>> notes;
  final void Function(Map<String, dynamic>) onOpenNote;

  NotesSearchDelegate(this.notes, this.onOpenNote);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [IconButton(icon: Icon(Icons.clear), onPressed: () => query = "")];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
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
      final name = (n['title'] ?? "").toLowerCase();
      return name.contains(query.toLowerCase());
    }).toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (_, i) {
        final note = suggestions[i];
        final name = note['title'];
        final date = DateTime.parse(note['createdAt']);

        return GestureDetector(
          onTap: () => onOpenNote(note),
          child: Card(
            elevation: 2,
            margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    name,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "${date.day}/${date.month}/${date.year}",
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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
