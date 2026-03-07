import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uniqnote/cross_cutting/consts/themes.dart';

import 'package:uniqnote/services/states/theme/theme_cubit.dart';
import 'package:uniqnote/services/states/theme/theme_state.dart';

class ThemeSelectorSheet extends StatelessWidget {
  const ThemeSelectorSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        return DraggableScrollableSheet(
          initialChildSize: 0.4, // começa com 40% da tela
          minChildSize: 0.2, // mínimo (20%)
          maxChildSize: 0.9, // máximo (90%)
          expand: false, // não força ocupar tudo
          builder: (context, scrollController) {
            return SafeArea(
              child: Scrollbar(
                thumbVisibility: true,
                child: SingleChildScrollView(
                  controller: scrollController, // conecta com o drag
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Indicador visual no topo
                        Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade400,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),

                        Text(
                          tr("theme"),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 12),

                        ...List.generate(themeOptions.length, (index) {
                          final option = themeOptions[index];
                          return RadioListTile<int>(
                            value: index,
                            groupValue: state.themeIndex,
                            onChanged: (value) {
                              if (value == null) return;
                              context.read<ThemeCubit>().setThemeIndex(value);
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

                        SwitchListTile(
                          title: Text(tr("dark_mode")),
                          value: state.isDarkMode,
                          onChanged: (value) {
                            context.read<ThemeCubit>().setThemeMode(value);
                          },
                        ),

                        const SizedBox(height: 8.0),
                        const Divider(),
                        const SizedBox(height: 8),

                        ...List.generate(themeFonts.length, (index) {
                          final option = themeFonts[index];
                          return RadioListTile<int>(
                            value: index,
                            groupValue: state.fontIndex,
                            onChanged: (value) {
                              if (value == null) return;
                              context.read<ThemeCubit>().setFontIndex(value);
                            },
                            title: Text(option.key, style: option.font()),
                          );
                        }),

                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(tr("apply")),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
