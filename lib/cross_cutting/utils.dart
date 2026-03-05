import 'package:flutter/material.dart';

String generateTitle() {
  final now = DateTime.now();
  final year = now.year.toString();
  final month = now.month.toString().padLeft(2, '0');
  final day = now.day.toString().padLeft(2, '0');
  final hour = now.hour.toString().padLeft(2, '0');
  final minute = now.minute.toString().padLeft(2, '0');
  final second = now.second.toString().padLeft(2, '0');

  return "$year$month$day$hour$minute$second";
}

String generatePreview(String text, {int limit = 255}) {
  var chars = text.characters;
  if (chars.length <= limit) return text;
  return '${chars.take(limit)}...';
}
