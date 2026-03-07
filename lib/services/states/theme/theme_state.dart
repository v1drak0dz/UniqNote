class ThemeState {
  final bool isDarkMode;
  final int themeIndex;
  final int fontIndex;

  ThemeState({
    required this.isDarkMode,
    required this.themeIndex,
    required this.fontIndex,
  });

  ThemeState copyWith({bool? isDarkMode, int? themeIndex, int? fontIndex}) {
    return ThemeState(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      themeIndex: themeIndex ?? this.themeIndex,
      fontIndex: fontIndex ?? this.fontIndex,
    );
  }
}
