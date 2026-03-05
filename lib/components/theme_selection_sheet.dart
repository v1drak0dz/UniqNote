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
        return SafeArea(
          child: SizedBox(
            // height: MediaQuery.of(context).size.height * .4,
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
        );
      },
    );
  }
}
