import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:uniqnote/components/create_folder_modal.dart';
import 'package:uniqnote/components/folder_color_selector.dart';

import 'package:uniqnote/components/home_page_fab.dart';
import 'package:uniqnote/components/move_to_folder_modal.dart';
import 'package:uniqnote/components/notes_grid.dart';
import 'package:uniqnote/components/open_folder_sheet.dart';
import 'package:uniqnote/components/rename_folder_modal.dart';
import 'package:uniqnote/components/search_delegate.dart';
import 'package:uniqnote/components/theme_selection_sheet.dart';

import 'package:uniqnote/cross_cutting/consts/themes.dart';
import 'package:uniqnote/cross_cutting/theme_handler.dart';

import 'package:uniqnote/models/folder.dart';
import 'package:uniqnote/models/note.dart';

import 'package:uniqnote/pages/edit_note_page.dart';
import 'package:uniqnote/repositories/folder_repository.dart';
import 'package:uniqnote/repositories/notes_repository.dart';
import 'package:uniqnote/use_cases/folders/delete_folder_use_case.dart';
import 'package:uniqnote/use_cases/folders/get_folder_use_case.dart';
import 'package:uniqnote/use_cases/notes/get_note_use_case.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

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
    final notesData = await GetNoteUseCase(NotesRepository()).getNotes();
    final foldersData = await GetFolderUseCase(FolderRepository()).getFolders();

    setState(() {
      notes = notesData;
      folders = foldersData;
    });
  }

  void _openNote(Note note) async {
    final updated = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditNotePage(note: note)),
    );

    if (updated == true) {
      _loadAll();
    }
  }

  void _openFolder(Folder folder) {
    final folderNotes = notes.where((n) => n.folderId == folder.id).toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => OpenFolderSheet(
        folder: folder,
        folderNotes: folderNotes,
        openNote: _openNote,
        loadAll: _loadAll,
        openMoveToFolderModal: _openMoveToFolderModal,
      ),
    );
  }

  void _createFolderModal() {
    showDialog(
      context: context,
      builder: (_) => CreateFolderModal(onFolderCreated: _loadAll),
    );
  }

  Future<void> _openMoveToFolderModal(Note note) async {
    final folders = await GetFolderUseCase(FolderRepository()).getFolders();

    if (!mounted) return;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) =>
          MoveToFolderModal(folders: folders, loadAll: _loadAll, note: note),
    );
  }

  Future<void> _openThemeSelector(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => const ThemeSelectorSheet(),
    );
  }

  void _renameFolderModal(Folder folder) {
    final controller = TextEditingController(text: folder.name);

    showDialog(
      context: context,
      builder: (_) => RenameFolderModal(
        loadAll: _loadAll,
        controller: controller,
        folderId: folder.id!,
      ),
    );
  }

  Future<int?> openFolderColorSelector(
    BuildContext context,
    int initialIndex,
    int folderId,
  ) async {
    int selectedIndex = initialIndex;

    return showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      builder: (_) =>
          FolderColorSelector(initialIndex: selectedIndex, folderId: folderId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredNotes = notes
        .where((n) => n.title.toLowerCase().contains(query.toLowerCase()))
        .toList();
    final noFolder = filteredNotes.where((n) => n.folderId == null).toList();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      appBar: AppBar(
        title: Text(
          tr("notes"),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: ThemeHandler.getForegroundColor(context),
          ),
        ),
        backgroundColor: ThemeHandler.getBackgroundColor(context),
        actions: [
          IconButton(
            icon: Icon(
              Icons.palette,
              color: ThemeHandler.getForegroundColor(context),
            ),
            onPressed: () => _openThemeSelector,
          ),

          IconButton(
            icon: Icon(
              Icons.search,
              color: ThemeHandler.getForegroundColor(context),
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (folders.isNotEmpty) ...[
                const SizedBox(height: 8),

                Padding(
                  padding: const EdgeInsets.only(bottom: 8, top: 8),
                  child: Row(
                    children: [
                      Icon(Icons.folder, color: Colors.amber),
                      const SizedBox(width: 6),
                      Text(
                        tr("folders"),
                        style: Theme.of(context).textTheme.titleMedium!
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),

                MasonryGridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  itemCount: folders.length,
                  itemBuilder: (_, i) {
                    final folder = folders[i];
                    final notesInFolder = notes
                        .where((x) => x.folderId == folder.id)
                        .length;
                    final description = notesInFolder == 1
                        ? tr("note")
                        : tr("notes");

                    return GestureDetector(
                      onTap: () => _openFolder(folder),
                      onLongPress: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (folderModalContext) {
                            return SafeArea(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ListTile(
                                    leading: Icon(
                                      Icons.delete,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.error,
                                    ),
                                    title: Text(tr("delete")),
                                    onTap: () async {
                                      Navigator.pop(folderModalContext);
                                      await DeleteFolderUseCase(
                                        folderRepository: FolderRepository(),
                                      ).deleteFolder(folder.id!);
                                      _loadAll();
                                    },
                                  ),
                                  ListTile(
                                    leading: Icon(
                                      Icons.drive_file_rename_outline,
                                      color: Colors.amber,
                                    ),
                                    title: Text(tr("rename")),
                                    onTap: () {
                                      Navigator.pop(folderModalContext);
                                      _renameFolderModal(folder);
                                    },
                                  ),
                                  ListTile(
                                    leading: Icon(Icons.palette),
                                    title: Text(tr("change_color")),
                                    onTap: () {
                                      Navigator.pop(folderModalContext);
                                      openFolderColorSelector(
                                        folderModalContext,
                                        folder.color,
                                        folder.id!,
                                      );
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
                          borderRadius: BorderRadius.circular(14.0),
                        ),
                        surfaceTintColor: themeOptions[folder.color].color,
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.folder,
                                    size: 16,
                                    color: themeOptions[folder.color].color,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    folder.name,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 6.0),
                              Row(
                                children: [
                                  Text(
                                    "$notesInFolder $description",
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 16),
              ],

              if (noFolder.isNotEmpty) ...[
                const SizedBox(height: 8),

                Padding(
                  padding: const EdgeInsets.only(bottom: 8, top: 8),
                  child: Row(
                    children: [
                      Icon(
                        Icons.description,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        tr("notes"),
                        style: Theme.of(context).textTheme.titleMedium!
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),

                NotesGrid(
                  loadAll: _loadAll,
                  notes: noFolder,
                  openMoveToFolder: _openMoveToFolderModal,
                  openNote: _openNote,
                ),
              ],
            ],
          ),
        ),
      ),

      floatingActionButton: HomePageFab(
        createFolderModal: _createFolderModal,
        loadAll: _loadAll,
      ),
    );
  }
}
