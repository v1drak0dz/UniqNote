import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:uniqnote/helpers/db_helper.dart';
import 'package:uniqnote/pages/new_note_page.dart';
import 'package:uniqnote/pages/edit_note_page.dart';
import 'package:uniqnote/models/note.dart';
import 'package:uniqnote/models/attachment.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('pt')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
      locale: context.locale,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Note> notes = [];
  String query = "";

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  void _loadNotes() async {
    final data = await DBHelper.getNotesWithAttachments();
    setState(() {
      notes = data;
    });
  }

  void _openNote(Note note) async {
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
      final name = (n.title).toLowerCase();
      return name.contains(query.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "notes".tr(),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        actions: [
          IconButton(
            icon: Icon(
              Icons.search,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
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
                    final date = note.createdAt;

                    return GestureDetector(
                      onTap: () => _openNote(note),
                      onLongPress: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (context) {
                            return SafeArea(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ListTile(
                                    leading: const Icon(Icons.favorite),
                                    title: Text(tr("favorite")),
                                    onTap: () => DBHelper.favoriteNode(note.id),
                                  ),
                                  ListTile(
                                    leading: const Icon(Icons.delete),
                                    title: Text(tr("delete")),
                                    onTap: () => DBHelper.deleteNote(note.id),
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
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    note.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  note.isFavorite == 1
                                      ? Icon(Icons.favorite)
                                      : Text(""),
                                ],
                              ),

                              const SizedBox(height: 4),
                              Text(
                                "${date.day}/${date.month}/${date.year}",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 6),
                              Wrap(
                                spacing: 4,
                                children: note.attachments.map((att) {
                                  switch (att.type) {
                                    case AttachmentType.image:
                                      return const Icon(Icons.image, size: 16);
                                    case AttachmentType.audio:
                                      return const Icon(
                                        Icons.audiotrack,
                                        size: 16,
                                      );
                                    case AttachmentType.file:
                                      return const Icon(
                                        Icons.attach_file,
                                        size: 16,
                                      );
                                    case AttachmentType.video:
                                      return const Icon(
                                        Icons.videocam,
                                        size: 16,
                                      );
                                  }
                                }).toList(),
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
            MaterialPageRoute(builder: (_) => const NewNotePage()),
          );
          _loadNotes();
        },
        child: const Icon(Icons.edit),
      ),
    );
  }
}

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
      final name = (n.title).toLowerCase();
      return name.contains(query.toLowerCase());
    }).toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (_, i) {
        final note = suggestions[i];
        final date = note.createdAt;

        return GestureDetector(
          onTap: () => onOpenNote(note),
          child: Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
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
                    note.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
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
