import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:easy_localization/easy_localization.dart';

class RecordAudioPage extends StatefulWidget {
  const RecordAudioPage({super.key});

  @override
  State<RecordAudioPage> createState() => _RecordAudioPageState();
}

class _RecordAudioPageState extends State<RecordAudioPage> {
  final recorder = AudioRecorder();
  final player = AudioPlayer();

  late final RecorderController waveController;

  bool isRecording = false;
  bool hasRecording = false;
  bool isPlaying = false;

  String? filePath;

  int seconds = 0;
  Timer? timer;

  final TextEditingController nameController = TextEditingController(
    text: "audio",
  );

  @override
  void initState() {
    super.initState();

    waveController = RecorderController();
  }

  Future<bool> requestMicPermission() async {
    final status = await Permission.microphone.request();

    if (status.isGranted) {
      return true;
    }

    if (status.isPermanentlyDenied) {
      openAppSettings();
    }

    return false;
  }

  Future<String> _generatePath() async {
    final dir = await getApplicationDocumentsDirectory();
    return "${dir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a";
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => seconds++);
    });
  }

  void stopTimer() {
    timer?.cancel();
    timer = null;
  }

  String formatTime() {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return "$m:$s";
  }

  Future<void> startRecording() async {
    if (await recorder.hasPermission()) {
      filePath = await _generatePath();

      await recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 444100,
        ),
        path: filePath!,
      );

      waveController.record();

      setState(() {
        isRecording = true;
        seconds = 0;
      });

      startTimer();
    }
  }

  Future<void> stopRecording() async {
    await recorder.stop();
    await waveController.stop();

    stopTimer();

    setState(() {
      isRecording = false;
      hasRecording = true;
    });
  }

  Future<void> cancelRecording() async {
    await recorder.stop();
    await waveController.stop();

    stopTimer();

    if (filePath != null) {
      final file = File(filePath!);
      if (await file.exists()) {
        await file.delete();
      }
    }

    Navigator.pop(context);
  }

  Future<void> playAudio() async {
    if (filePath == null) return;

    await player.setFilePath(filePath!);
    await player.play();

    setState(() => isPlaying = true);

    player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        setState(() => isPlaying = false);
      }
    });
  }

  Future<void> stopAudio() async {
    await player.stop();
    setState(() => isPlaying = false);
  }

  void saveRecording() {
    Navigator.pop(context, {
      "path": filePath,
      "name": nameController.text.isEmpty
          ? "audio"
          : nameController.text.trim(),
    });
  }

  @override
  void dispose() {
    recorder.dispose();
    player.dispose();
    waveController.dispose();
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gravar áudio"),
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? Theme.of(context).colorScheme.primaryContainer
            : Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).brightness == Brightness.dark
            ? Theme.of(context).colorScheme.onPrimaryContainer
            : Theme.of(context).colorScheme.onPrimary,
        actions: [
          if (hasRecording)
            IconButton(icon: const Icon(Icons.save), onPressed: saveRecording),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// Nome do arquivo
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: tr("audio_name"),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            /// Tempo
            Text(
              formatTime(),
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            /// Waveform
            if (isRecording || hasRecording)
              AudioWaveforms(
                enableGesture: false,
                size: const Size(double.infinity, 100),
                recorderController: waveController,
                waveStyle: const WaveStyle(showMiddleLine: false),
              ),

            const SizedBox(height: 30),

            /// Botões
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                /// CANCELAR
                IconButton(
                  iconSize: 40,
                  icon: const Icon(Icons.close),
                  onPressed: cancelRecording,
                ),

                const SizedBox(width: 20),

                /// GRAVAR / PARAR
                IconButton(
                  iconSize: 70,
                  icon: Icon(
                    isRecording ? Icons.stop_circle : Icons.mic,
                    color: isRecording
                        ? Colors.red
                        : Theme.of(context).colorScheme.primary,
                  ),
                  onPressed: isRecording ? stopRecording : startRecording,
                ),

                const SizedBox(width: 20),

                /// PLAY
                if (hasRecording)
                  IconButton(
                    iconSize: 40,
                    icon: Icon(isPlaying ? Icons.stop : Icons.play_arrow),
                    onPressed: isPlaying ? stopAudio : playAudio,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
