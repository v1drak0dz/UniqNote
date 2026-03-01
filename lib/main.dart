import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:uniqnote/helpers/db_helper.dart';
import 'package:uniqnote/pages/new_note_page.dart';
import 'package:uniqnote/pages/edit_note_page.dart';
import 'package:uniqnote/models/note.dart';
import 'package:uniqnote/models/attachment.dart';
import 'package:uniqnote/services/backup_service.dart';

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
/// MODELO DE OPÇÃO DE TEMA
//////////////////////////////////////////////////////////////

class ThemeOption {
  final String translationKey;
  final Color color;

  const ThemeOption(this.translationKey, this.color);
}

//////////////////////////////////////////////////////////////
/// CORES DISPONÍVEIS
//////////////////////////////////////////////////////////////

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
/// APP ROOT
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
/// HOME PAGE
//////////////////////////////////////////////////////////////

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  List<Note> notes = [];
  String query = "";
  String appVersion = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadNotes();
    _loadVersion();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.paused) {
      await BackupService.autoBackup();
    }
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

  //////////////////////////////////////////////////////////////
  /// MODAL DE SELEÇÃO DE TEMA
  //////////////////////////////////////////////////////////////

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

  //////////////////////////////////////////////////////////////

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      appVersion = info.version;
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredNotes = notes.where((n) {
      return n.title.toLowerCase().contains(query.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Text(
              tr("notes"),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
            Text("v$appVersion", style: TextStyle(fontSize: 8.0)),
          ],
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

      body: SafeArea(
        child: filteredNotes.isEmpty
            ? const Center(
                child: Icon(
                  Icons.description_outlined,
                  size: 96,
                  color: Colors.grey,
                ),
              )
            : Padding(
                padding: const EdgeInsets.all(8),
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
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
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
            MaterialPageRoute(builder: (_) => const NewNotePage()),
          );
          _loadNotes();
        },
        child: const Icon(Icons.edit),
      ),
    );
  }
}

//////////////////////////////////////////////////////////////
/// SEARCH
//////////////////////////////////////////////////////////////

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
