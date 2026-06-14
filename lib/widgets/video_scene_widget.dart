import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'unified_video_controls.dart';

class VideoSceneWidget extends StatefulWidget {
  final String videoPath;

  /// Зациклення відтворення. Якщо `null` — для шляхів `lib/assets/npcs/mom/video/` увімкнено автоматично.
  final bool? loop;

  /// Якщо відео не відкрилось (наприклад Git LFS-заглушка замість файлу) — показати цей кадр замість чорного екрану.
  /// Під час завантаження відео не показується (лише чорний фон).
  final String? fallbackImagePath;

  const VideoSceneWidget({
    super.key,
    required this.videoPath,
    this.loop,
    this.fallbackImagePath,
  });

  @override
  State<VideoSceneWidget> createState() => _VideoSceneWidgetState();
}

class _VideoSceneWidgetState extends State<VideoSceneWidget> {
  late final Player player = Player();
  late final VideoController controller = VideoController(player);
  bool _loadFailed = false;

  @override
  void initState() {
    super.initState();
    player.setVolume(0);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _openVideo(widget.videoPath);
    });
  }

  @override
  void didUpdateWidget(covariant VideoSceneWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoPath != widget.videoPath) {
      _loadFailed = false;
      _openVideo(widget.videoPath);
    }
  }

  Future<void> _openVideo(String path) async {
    try {
      await player.open(Media('asset:///$path'));
      final lower = path.toLowerCase();
      final autoLoop = lower.contains('lib/assets/npcs/mom/video/') ||
          lower.contains('lib/assets/npcs/piper/video/');
      final loop = widget.loop ?? autoLoop;
      await player.setPlaylistMode(loop ? PlaylistMode.loop : PlaylistMode.single);
      await player.play();
      if (mounted && _loadFailed) {
        setState(() => _loadFailed = false);
      }
    } catch (_) {
      if (mounted) setState(() => _loadFailed = true);
    }
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fallback = widget.fallbackImagePath?.trim();
    if (_loadFailed && fallback != null && fallback.isNotEmpty) {
      return Image.asset(
        fallback,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (_, __, ___) => Container(color: Colors.grey[900]),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        const ColoredBox(color: Colors.black),
        if (!_loadFailed)
          Video(
            controller: controller,
            controls: NoVideoControls,
            fill: Colors.transparent,
            fit: BoxFit.cover,
          ),
        if (!_loadFailed)
          Positioned.fill(
            child: UnifiedVideoControls(player: player),
          ),
      ],
    );
  }
}
