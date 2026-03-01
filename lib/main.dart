import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:uniqnote/helpers/db_helper.dart';
import 'package:uniqnote/pages/new_note_page.dart';
import 'package:uniqnote/pages/edit_note_page.dart';
import 'package:uniqnote/models/note.dart';
import 'package:uniqnote/models/folder.dart';
import 'package:uniqnote/models/attachment.dart';

//////////////////////////////////////////////////////////////
// APP
//////////////////////////////////////////////////////////////

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

//////////////////////////////////////////////////////////////
// THEME OPTIONS
//////////////////////////////////////////////////////////////

class ThemeOption {
  final String translationKey;
  final Color color;

  const ThemeOption(this.translationKey, this.color);
}

const themeOptions = [
  ThemeOption("color_blue", Colors.blue),
  ThemeOption("color_red", Colors.red),
  ThemeOption("color_green", Colors.green),
  ThemeOption("color_orange", Colors.orange),
  ThemeOption("color_purple", Colors.purple),
  ThemeOption("color_teal", Colors.teal),
  ThemeOption("color_pink", Colors.pink),
];

//////////////////////////////////////////////////////////////
// APP ROOT
//////////////////////////////////////////////////////////////

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static _MyAppState of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>()!;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int themeIndex = 0;

  Color get seedColor => themeOptions[themeIndex].color;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt('theme_index');

    if (index != null && index < themeOptions.length) {
      setState(() {
        themeIndex = index;
      });
    }
  }

  Future<void> changeThemeIndex(int index) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt('theme_index', index);

    setState(() {
      themeIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: context.locale,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      home: HomePage(),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
    );
  }
}

//////////////////////////////////////////////////////////////
// HOME
//////////////////////////////////////////////////////////////

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Note> notes = [];
  List<Folder> folders = [];
  String query = "";

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    final notesData = await DBHelper.getNotesWithAttachments();
    final foldersData = await DBHelper.getFolders();

    setState(() {
      notes = notesData;
      folders = foldersData;
    });
  }

  ////////////////////////////////////////////////////////////
  /// LOAD NOTES
  ////////////////////////////////////////////////////////////

  void _loadNotes() async {
    final data = await DBHelper.getNotesWithAttachments();
    setState(() {
      notes = data;
    });
  }

  ////////////////////////////////////////////////////////////
  /// LOAD FOLDERS (IMPLEMENTAR NO DB)
  ////////////////////////////////////////////////////////////

  Future<void> _loadFolders() async {
    final fs = await DBHelper.getFolders();

    // temporário vazio
    setState(() {
      folders = fs;
    });
  }

  ////////////////////////////////////////////////////////////
  /// OPEN NOTE
  ////////////////////////////////////////////////////////////

  void _openNote(Note note) async {
    final updated = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditNotePage(note: note)),
    );

    if (updated == true) {
      _loadFolders();
      _loadNotes();
    }
  }

  ////////////////////////////////////////////////////////////
  /// GRID REUTILIZÁVEL
  ////////////////////////////////////////////////////////////

  Widget _notesGrid(List<Note> list) {
    if (list.isEmpty) return const SizedBox();

    return MasonryGridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      itemCount: list.length,
      itemBuilder: (_, i) {
        final note = list[i];
        final date = note.modifiedAt;

        return GestureDetector(
          onTap: () => _openNote(note),
          onLongPress: () {
            showModalBottomSheet(
              context: context,
              builder: (modalContext) {
                return SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: const Icon(Icons.favorite),
                        title: Text(tr("favorite")),
                        onTap: () async {
                          await DBHelper.favoriteNode(note.id);

                          Navigator.pop(modalContext);
                          _loadFolders();
                          _loadNotes();
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.delete),
                        title: Text(tr("delete")),
                        onTap: () async {
                          await DBHelper.deleteNote(note.id);
                          Navigator.pop(modalContext);
                          _loadFolders();
                          _loadNotes();
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.folder),
                        title: Text(tr("move_to_folder")),
                        onTap: () async {
                          Navigator.pop(modalContext);
                          _openMoveToFolderModal(note);
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
              borderRadius: BorderRadius.circular(8),
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
                      Text(
                        note.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      note.isFavorite == 1 ? Icon(Icons.favorite) : Text(""),
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

  ////////////////////////////////////////////////////////////
  /// MODAL FOLDER
  ////////////////////////////////////////////////////////////

  void _openFolder(Folder folder) {
    final folderNotes = notes.where((n) => n.folderId == folder.id).toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Text(
                    folder.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _notesGrid(folderNotes),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  ////////////////////////////////////////////////////////////
  /// CREATE FOLDER
  ////////////////////////////////////////////////////////////

  void _createFolderModal() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Nova pasta"),
          content: TextField(controller: controller, autofocus: true),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () async {
                await DBHelper.insertFolder(controller.text);

                Navigator.pop(context);
                _loadFolders();
              },
              child: const Text("Criar"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _openMoveToFolderModal(Note note) async {
    final folders = await DBHelper.getFolders();

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      builder: (modalContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text("Sem pasta"),
                leading: const Icon(Icons.folder_off),
                onTap: () async {
                  await DBHelper.moveNoteToFolder(note.id, null);
                  Navigator.pop(modalContext);
                  _loadFolders();
                  _loadNotes();
                },
              ),

              ...folders.map((folder) {
                return ListTile(
                  leading: const Icon(Icons.folder),
                  title: Text(folder.name),
                  onTap: () async {
                    await DBHelper.moveNoteToFolder(note.id, folder.id);
                    Navigator.pop(modalContext);
                    _loadFolders();
                    _loadNotes();
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Future<void> _openThemeSelector() async {
    int selectedIndex = MyApp.of(context).themeIndex;

    await showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      tr("theme"),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    ////////////////////////////////////////////////////
                    /// LISTA DE CORES
                    ////////////////////////////////////////////////////
                    ...List.generate(themeOptions.length, (index) {
                      final option = themeOptions[index];

                      return RadioListTile<int>(
                        value: index,
                        groupValue: selectedIndex,
                        onChanged: (value) {
                          if (value == null) return;

                          setModalState(() {
                            selectedIndex = value;
                          });
                        },
                        title: Row(
                          children: [
                            Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                color: option.color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(tr(option.translationKey)),
                          ],
                        ),
                      );
                    }),

                    const SizedBox(height: 8),

                    ElevatedButton(
                      onPressed: () {
                        MyApp.of(context).changeThemeIndex(selectedIndex);
                        Navigator.pop(context);
                      },
                      child: Text(tr("apply")),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  ////////////////////////////////////////////////////////////
  /// BUILD
  ////////////////////////////////////////////////////////////

  @override
  Widget build(BuildContext context) {
    final filteredNotes = notes
        .where((n) => n.title.toLowerCase().contains(query.toLowerCase()))
        .toList();
    final favorites = filteredNotes.where((n) => n.isFavorite == 1).toList();
    final noFolder = filteredNotes.where((n) => n.folderId == null).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          tr("notes"),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        actions: [
          ////////////////////////////////////////////////////
          /// BOTÃO TEMA
          ////////////////////////////////////////////////////
          IconButton(
            icon: Icon(
              Icons.palette,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
            onPressed: _openThemeSelector,
          ),

          ////////////////////////////////////////////////////
          /// BOTÃO SEARCH
          ////////////////////////////////////////////////////
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

      ////////////////////////////////////////////////////////
      /// BODY
      ////////////////////////////////////////////////////////
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ////////////////////////////////////////////////////
              /// FAVORITES
              ////////////////////////////////////////////////////
              if (favorites.isNotEmpty) ...[
                const Text(
                  "Favoritas",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                _notesGrid(favorites),
                const SizedBox(height: 16),
              ],

              ////////////////////////////////////////////////////
              /// FOLDERS
              ////////////////////////////////////////////////////
              if (folders.isNotEmpty) ...[
                const Text(
                  "Pastas",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 8),

                Wrap(
                  spacing: 8,
                  children: folders.map((folder) {
                    return ActionChip(
                      label: Text(folder.name),
                      onPressed: () => _openFolder(folder),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 16),
              ],

              ////////////////////////////////////////////////////
              /// NO FOLDER
              ////////////////////////////////////////////////////
              if (noFolder.isNotEmpty) ...[
                const Text(
                  "Sem pasta",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                _notesGrid(noFolder),
              ],
            ],
          ),
        ),
      ),

      ////////////////////////////////////////////////////////
      /// FAB STACK
      ////////////////////////////////////////////////////////
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: "folder",
            mini: true,
            onPressed: _createFolderModal,
            child: const Icon(Icons.folder),
          ),

          const SizedBox(height: 10),

          FloatingActionButton(
            heroTag: "note",
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NewNotePage()),
              );

              _loadFolders();
              _loadNotes();
            },
            child: const Icon(Icons.edit),
          ),
        ],
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
