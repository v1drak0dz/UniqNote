import 'package:flutter/material.dart';
import 'package:uniqnote/cross_cutting/theme_option.dart';
import 'package:google_fonts/google_fonts.dart';

const themeOptions = [
  // STANDARD
  ThemeOption("color_grey", Colors.grey),
  ThemeOption("color_blue", Colors.blue),
  ThemeOption("color_red", Colors.red),
  ThemeOption("color_green", Colors.green),
  ThemeOption("color_orange", Colors.orange),
  ThemeOption("color_purple", Color(0xFFBD93F9)),
  ThemeOption("color_teal", Colors.teal),
  ThemeOption("color_pink", Color.fromARGB(255, 255, 0, 255)),
];

final themeFonts = [
  ThemeFontOption('Roboto', GoogleFonts.robotoTextTheme(), GoogleFonts.roboto),
  ThemeFontOption(
    'RobotoMono',
    GoogleFonts.robotoMonoTextTheme(),
    GoogleFonts.robotoMono,
  ),
  ThemeFontOption(
    'RobotoSerif',
    GoogleFonts.robotoSerifTextTheme(),
    GoogleFonts.robotoSerif,
  ),

  ThemeFontOption(
    'JosefinSans',
    GoogleFonts.josefinSansTextTheme(),
    GoogleFonts.josefinSans,
  ),
  ThemeFontOption('Inter', GoogleFonts.interTextTheme(), GoogleFonts.inter),
  ThemeFontOption('Lato', GoogleFonts.latoTextTheme(), GoogleFonts.lato),
  ThemeFontOption(
    'Quicksand',
    GoogleFonts.quicksandTextTheme(),
    GoogleFonts.quicksand,
  ),
  ThemeFontOption(
    'Comfortaa',
    GoogleFonts.comfortaaTextTheme(),
    GoogleFonts.comfortaa,
  ),
  ThemeFontOption('Caveat', GoogleFonts.caveatTextTheme(), GoogleFonts.caveat),
  ThemeFontOption(
    'Lobster',
    GoogleFonts.lobsterTextTheme(),
    GoogleFonts.lobster,
  ),

  // novas fontes adicionadas
  ThemeFontOption(
    'Merriweather',
    GoogleFonts.merriweatherTextTheme(),
    GoogleFonts.merriweather,
  ),
  ThemeFontOption(
    'Pacifico',
    GoogleFonts.pacificoTextTheme(),
    GoogleFonts.pacifico,
  ),
  ThemeFontOption(
    'Raleway',
    GoogleFonts.ralewayTextTheme(),
    GoogleFonts.raleway,
  ),
  ThemeFontOption(
    'PlayfairDisplay',
    GoogleFonts.playfairDisplayTextTheme(),
    GoogleFonts.playfairDisplay,
  ),
  ThemeFontOption('Oswald', GoogleFonts.oswaldTextTheme(), GoogleFonts.oswald),
];
