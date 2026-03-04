import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:uniqnote/cross_cutting/consts/themes.dart';
import 'package:uniqnote/repositories/folder_repository.dart';
import 'package:uniqnote/use_cases/folders/insert_folder_use_case.dart';

class CreateFolderModal extends StatefulWidget {
  final VoidCallback onFolderCreated;

  const CreateFolderModal({super.key, required this.onFolderCreated});

  @override
  State<CreateFolderModal> createState() => _CreateFolderModalState();
}

class _CreateFolderModalState extends State<CreateFolderModal> {
  final TextEditingController controller = TextEditingController();
  int selectedColor = 0;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(tr("new_folder")),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(hintText: tr("folder_name")),
          ),

          const SizedBox(height: 16),

          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: List.generate(themeOptions.length, (index) {
              final color = themeOptions[index];
              final isSelected = selectedColor == index;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedColor = index;
                  });
                },
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: color.color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? Theme.of(context).colorScheme.onSurface
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, size: 18, color: Colors.white)
                      : null,
                ),
              );
            }),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(tr("cancel")),
        ),
        ElevatedButton(
          onPressed: () async {
            if (controller.text.trim().isEmpty) return;
            Navigator.pop(context);

            await InsertFolderUseCase(
              FolderRepository(),
            ).createFolder(controller.text.trim(), selectedColor);

            widget.onFolderCreated();
          },
          child: Text(tr("create")),
        ),
      ],
    );
  }
}
