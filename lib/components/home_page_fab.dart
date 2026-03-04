import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:uniqnote/cross_cutting/theme_handler.dart';
import 'package:uniqnote/pages/new_note_page.dart';

class HomePageFab extends StatelessWidget {
  final VoidCallback createFolderModal;
  final VoidCallback loadAll;

  const HomePageFab({
    super.key,
    required this.createFolderModal,
    required this.loadAll,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton(
          heroTag: tr("folder"),
          mini: true,
          onPressed: createFolderModal,
          backgroundColor: ThemeHandler.getBackgroundColor(context),
          foregroundColor: ThemeHandler.getForegroundColor(context),
          child: const Icon(Icons.folder),
        ),

        const SizedBox(height: 10),

        FloatingActionButton(
          heroTag: tr("note"),
          backgroundColor: ThemeHandler.getBackgroundColor(context),
          foregroundColor: ThemeHandler.getForegroundColor(context),
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NewNotePage()),
            );

            loadAll();
          },
          child: const Icon(Icons.edit),
        ),
      ],
    );
  }
}
