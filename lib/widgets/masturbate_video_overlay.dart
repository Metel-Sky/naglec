import 'dart:async';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'unified_video_controls.dart';

/// Невелике вікно з відео поверх екрану (наприклад поверх ноутбука).
/// Відео підключається через [videoPath] — передається з батька (main_game_screen.dart,
/// пошук: MasturbateVideoOverlay(videoPath: ...)). Там же можна змінити файл відео.
/// [onClose] — закрити вікно.
/// [showControls] — якщо true, показувати стандартні кнопки керування (play/pause, прогрес тощо).
/// [closeWhenCompleted] — якщо true, при завершенні відтворення автоматично викликати onClose.
/// [loop] — якщо true, повторювати поточний ролик (для loop [closeWhenCompleted] зазвичай false).
/// [fit] — як масштабувати кадр; для повного блоку з обрізанням країв використовуй [BoxFit.cover].
class MasturbateVideoOverlay extends StatefulWidget {
  final String videoPath;
  final VoidCallback onClose;
  final bool showControls;
  final bool closeWhenCompleted;
  final bool loop;
  final bool muted;
  final double borderRadius;
  final BoxFit fit;

  const MasturbateVideoOverlay({
    super.key,
    required this.videoPath,
    required this.onClose,
    this.showControls = false,
    this.closeWhenCompleted = false,
    this.loop = false,
    this.muted = false,
    this.borderRadius = 12,
    this.fit = BoxFit.contain,
  });

  @override
  State<MasturbateVideoOverlay> createState() => _MasturbateVideoOverlayState();
}

class _MasturbateVideoOverlayState extends State<MasturbateVideoOverlay> {
  late final Player _player = Player();
  late final VideoController _controller = VideoController(_player);
  StreamSubscription? _completedSubscription;
  StreamSubscription? _playingSubscription;
  bool _hasStartedPlaying = false;
  bool _alreadyClosed = false;

  void _onVideoCompleted() {
    if (_alreadyClosed || !mounted) return;
    if (!_hasStartedPlaying) return; // Щоб не закрити, якщо completed спрацював до старту відтворення
    _manualClose();
  }

  void _manualClose() {
    if (_alreadyClosed || !mounted) return;
    _alreadyClosed = true;
    _playingSubscription?.cancel();
    _completedSubscription?.cancel();
    _playingSubscription = null;
    _completedSubscription = null;
    widget.onClose();
  }

  @override
  void initState() {
    super.initState();
    _player.setPlaylistMode(PlaylistMode.single);
    // Глобально вимкнено звук у грі.
    _player.setVolume(0);
    if (widget.closeWhenCompleted) {
      _playingSubscription = _player.stream.playing.listen((playing) {
        if (playing) _hasStartedPlaying = true;
      });
      _completedSubscription = _player.stream.completed.listen((_) {
        _onVideoCompleted();
      });
    }
    _openAndPlay();
  }

  Future<void> _openAndPlay() async {
    await _player.open(Media('asset:///${widget.videoPath}'));
    await _player.play();
  }

  @override
  void dispose() {
    _playingSubscription?.cancel();
    _completedSubscription?.cancel();
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(widget.borderRadius),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        child: Container(
          color: Colors.black,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Video(
                controller: _controller,
                fit: widget.fit,
                controls: NoVideoControls,
              ),
              Positioned.fill(
                child: UnifiedVideoControls(player: _player),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
