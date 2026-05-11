import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'unified_video_controls.dart';

class VideoSceneWidget extends StatefulWidget {
  final String videoPath;

  /// Зациклення відтворення. Якщо `null` — для шляхів `lib/assets/npcs/mom/video/` увімкнено автоматично.
  final bool? loop;

  const VideoSceneWidget({
    super.key,
    required this.videoPath,
    this.loop,
  });

  @override
  State<VideoSceneWidget> createState() => _VideoSceneWidgetState();
}

class _VideoSceneWidgetState extends State<VideoSceneWidget> {
  late final Player player = Player();
  late final VideoController controller = VideoController(player);

  @override
  void initState() {
    super.initState();
    player.setVolume(0);
    _openVideo(widget.videoPath);
  }

  @override
  void didUpdateWidget(covariant VideoSceneWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoPath != widget.videoPath) {
      _openVideo(widget.videoPath);
    }
  }

  Future<void> _openVideo(String path) async {
    await player.open(Media('asset:///$path'));
    await player.setPlaylistMode(PlaylistMode.single);
    await player.play();
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Video(
          controller: controller,
          controls: NoVideoControls,
          fill: Colors.transparent,
          fit: BoxFit.cover,
        ),
        Positioned.fill(
          child: UnifiedVideoControls(player: player),
        ),
      ],
    );
  }
}
