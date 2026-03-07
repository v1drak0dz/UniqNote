import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uniqnote/services/states/theme/theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit()
    : super(ThemeState(isDarkMode: false, themeIndex: 0, fontIndex: 0)) {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final mode = prefs.getBool('theme_mode') ?? false;
    final index = prefs.getInt('theme_index') ?? 0;
    final font = prefs.getInt('font_index') ?? 0;

    emit(ThemeState(isDarkMode: mode, themeIndex: index, fontIndex: font));
  }

  Future<void> setThemeMode(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('theme_mode', isDark);
    emit(state.copyWith(isDarkMode: isDark));
  }

  Future<void> setThemeIndex(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme_index', index);
    emit(state.copyWith(themeIndex: index));
  }

  Future<void> setFontIndex(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('font_index', index);
    emit(state.copyWith(fontIndex: index));
  }
}
