import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

class VideoSceneWidget extends StatefulWidget {
  final String videoPath;
  const VideoSceneWidget({super.key, required this.videoPath});

  @override
  State<VideoSceneWidget> createState() => _VideoSceneWidgetState();
}

class _VideoSceneWidgetState extends State<VideoSceneWidget> {
  late final Player player = Player();
  late final VideoController controller = VideoController(player);

  @override
  void initState() {
    super.initState();
    // Налаштовуємо плеєр: автоповтор, без звуку, запуск
    player.setPlaylistMode(PlaylistMode.none);
    player.setVolume(0);
    player.open(Media('asset:///${widget.videoPath}'));
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Video(
      controller: controller,
      fill: Colors.transparent, // Щоб не було чорних рамок
      fit: BoxFit.cover,       // Розтягуємо на весь екран
    );
  }
}