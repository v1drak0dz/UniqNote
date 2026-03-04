import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:uniqnote/cross_cutting/consts/themes.dart';
import 'package:uniqnote/repositories/folder_repository.dart';
import 'package:uniqnote/use_cases/folders/update_folder_use_case.dart';

class FolderColorSelector extends StatefulWidget {
  final int initialIndex;
  final int folderId;
  final void Function(int selectedIndex)? onApply;

  const FolderColorSelector({
    super.key,
    required this.initialIndex,
    required this.folderId,
    this.onApply,
  });

  @override
  State<FolderColorSelector> createState() => _FolderColorSelectorState();
}

class _FolderColorSelectorState extends State<FolderColorSelector> {
  late int selectedIndex;

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Selecionar cor da pasta",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            // LISTA DE CORES
            ...List.generate(themeOptions.length, (index) {
              final option = themeOptions[index];

              return RadioListTile<int>(
                value: index,
                groupValue: selectedIndex,
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
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
              onPressed: () async {
                Navigator.pop(context, selectedIndex);

                await UpdateFolderUseCase(
                  FolderRepository(),
                ).updateFolderColor(widget.folderId, selectedIndex);

                widget.onApply?.call(selectedIndex);
              },
              child: const Text("Aplicar"),
            ),
          ],
        ),
      ),
    );
  }
}
