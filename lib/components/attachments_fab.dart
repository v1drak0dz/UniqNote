import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:uniqnote/cross_cutting/theme_handler.dart';
import 'package:uniqnote/models/attachment.dart';

class AttachmentsFab extends StatelessWidget {
  final void Function(AttachmentType type) onAddAttach;
  final VoidCallback onAddAudio;

  const AttachmentsFab({
    super.key,
    required this.onAddAttach,
    required this.onAddAudio,
  });

  @override
  Widget build(BuildContext context) {
    return SpeedDial(
      icon: Icons.add,
      activeIcon: Icons.close,
      backgroundColor: ThemeHandler.getBackgroundColor(context),
      foregroundColor: ThemeHandler.getForegroundColor(context),
      children: [
        SpeedDialChild(
          child: const Icon(Icons.image),
          label: tr("image"),
          onTap: () => onAddAttach(AttachmentType.image),
          backgroundColor: ThemeHandler.getBackgroundColorSecondary(context),
          foregroundColor: ThemeHandler.getForegroundColorSecondary(context),
        ),
        SpeedDialChild(
          child: const Icon(Icons.videocam),
          label: tr("video"),
          onTap: () => onAddAttach(AttachmentType.video),
          backgroundColor: ThemeHandler.getBackgroundColorSecondary(context),
          foregroundColor: ThemeHandler.getForegroundColorSecondary(context),
        ),
        SpeedDialChild(
          child: const Icon(Icons.mic),
          label: tr("audio"),
          onTap: onAddAudio,
          backgroundColor: ThemeHandler.getBackgroundColorSecondary(context),
          foregroundColor: ThemeHandler.getForegroundColorSecondary(context),
        ),
        SpeedDialChild(
          child: const Icon(Icons.attach_file),
          label: tr("file"),
          onTap: () => onAddAttach(AttachmentType.file),
          backgroundColor: ThemeHandler.getBackgroundColorSecondary(context),
          foregroundColor: ThemeHandler.getForegroundColorSecondary(context),
        ),
      ],
    );
  }
}
