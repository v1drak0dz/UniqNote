import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:uniqnote/cross_cutting/consts/themes.dart';
import 'package:uniqnote/cross_cutting/theme_option.dart';

import 'package:uniqnote/pages/home_page.dart';

import 'package:uniqnote/services/states/theme/theme_cubit.dart';
import 'package:uniqnote/services/states/theme/theme_state.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        return MaterialApp(
          locale: context.locale,
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          home: HomePage(),
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: themeOptions[state.themeIndex].color,
              brightness: Brightness.light,
              contrastLevel: ThemeOption.themeContrast,
            ),
            textTheme: themeFonts[state.fontIndex].theme,
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: themeOptions[state.themeIndex].color,
              brightness: Brightness.dark,
              contrastLevel: ThemeOption.themeContrast,
            ),
            textTheme: themeFonts[state.fontIndex].theme,
            useMaterial3: true,
          ),
          themeMode: state.isDarkMode ? ThemeMode.dark : ThemeMode.light,
        );
      },
    );
  }
}
