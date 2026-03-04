class ThemeState {
  final bool isDarkMode;
  final int themeIndex;

  ThemeState({required this.isDarkMode, required this.themeIndex});

  ThemeState copyWith({bool? isDarkMode, int? themeIndex}) {
    return ThemeState(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      themeIndex: themeIndex ?? this.themeIndex,
    );
  }
}
