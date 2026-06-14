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
/// [minWatchDuration] — після старту відтворення через цей час один раз викликати [onMinWatchReached].
/// [fit] — як масштабувати кадр; для повного блоку з обрізанням країв використовуй [BoxFit.cover].
class MasturbateVideoOverlay extends StatefulWidget {
  final String videoPath;
  final VoidCallback onClose;
  final bool showControls;
  final bool closeWhenCompleted;
  final bool loop;
  final bool muted;
  final Duration? minWatchDuration;
  final VoidCallback? onMinWatchReached;
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
    this.minWatchDuration,
    this.onMinWatchReached,
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
  Timer? _minWatchTimer;
  bool _hasStartedPlaying = false;
  bool _minWatchReached = false;
  bool _alreadyClosed = false;

  void _cancelMinWatchTimer() {
    _minWatchTimer?.cancel();
    _minWatchTimer = null;
  }

  void _scheduleMinWatchTimerIfNeeded() {
    _cancelMinWatchTimer();
    if (_minWatchReached || widget.minWatchDuration == null) return;
    if (widget.onMinWatchReached == null) return;
    final duration = widget.minWatchDuration!;
    if (duration <= Duration.zero) {
      _fireMinWatchReached();
      return;
    }
    _minWatchTimer = Timer(duration, _fireMinWatchReached);
  }

  void _fireMinWatchReached() {
    if (_minWatchReached || !mounted) return;
    _minWatchReached = true;
    _cancelMinWatchTimer();
    widget.onMinWatchReached?.call();
  }

  void _onVideoCompleted() {
    if (_alreadyClosed || !mounted) return;
    if (!_hasStartedPlaying) return; // Щоб не закрити, якщо completed спрацював до старту відтворення
    _manualClose();
  }

  void _manualClose() {
    if (_alreadyClosed || !mounted) return;
    _alreadyClosed = true;
    _cancelMinWatchTimer();
    _playingSubscription?.cancel();
    _completedSubscription?.cancel();
    _playingSubscription = null;
    _completedSubscription = null;
    widget.onClose();
  }

  @override
  void initState() {
    super.initState();
    _applyPlaylistMode();
    // Глобально вимкнено звук у грі.
    _player.setVolume(0);
    _playingSubscription = _player.stream.playing.listen((playing) {
      if (!playing) return;
      if (!_hasStartedPlaying) {
        _hasStartedPlaying = true;
        _scheduleMinWatchTimerIfNeeded();
      }
    });
    if (widget.closeWhenCompleted) {
      _completedSubscription = _player.stream.completed.listen((_) {
        _onVideoCompleted();
      });
    }
    _player.stream.error.listen((_) {
      if (mounted) setState(() {});
    });
    _scheduleOpenAndPlay();
  }

  void _applyPlaylistMode() {
    _player.setPlaylistMode(
      widget.loop ? PlaylistMode.loop : PlaylistMode.single,
    );
  }

  @override
  void didUpdateWidget(covariant MasturbateVideoOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoPath != widget.videoPath ||
        oldWidget.loop != widget.loop ||
        oldWidget.minWatchDuration != widget.minWatchDuration) {
      _alreadyClosed = false;
      _hasStartedPlaying = false;
      _minWatchReached = false;
      _cancelMinWatchTimer();
      _applyPlaylistMode();
      _scheduleOpenAndPlay();
    }
  }

  Future<void> _openAndPlay() async {
    try {
      await _player.open(Media('asset:///${widget.videoPath}'));
      await _player.setPlaylistMode(
        widget.loop ? PlaylistMode.loop : PlaylistMode.single,
      );
      await _player.play();
    } catch (_) {
      if (mounted) setState(() {});
    }
  }

  void _scheduleOpenAndPlay() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _alreadyClosed) return;
      _openAndPlay();
    });
  }

  @override
  void dispose() {
    _cancelMinWatchTimer();
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
                fill: Colors.transparent,
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
