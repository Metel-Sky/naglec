import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import '../services/service_locator.dart';
import '../services/locale_controller.dart';
import 'unified_video_controls.dart';

/// Відео уроку всередині вікна ноутбука (без нового екрану). [onClose(completed)] — закрити (true якщо перегляд до кінця), [onCompleted] — викликається перед onClose(true).
class EmbeddedLessonVideo extends StatefulWidget {
  final String videoPath;
  final VoidCallback onCompleted;
  final void Function(bool completed) onClose;

  const EmbeddedLessonVideo({
    super.key,
    required this.videoPath,
    required this.onCompleted,
    required this.onClose,
  });

  @override
  State<EmbeddedLessonVideo> createState() => _EmbeddedLessonVideoState();
}

class _EmbeddedLessonVideoState extends State<EmbeddedLessonVideo> {
  late final Player _player = Player();
  late final VideoController _controller = VideoController(_player);
  bool _completed = false;
  bool _hasStartedPlaying = false;
  bool _loadFailed = false;

  @override
  void initState() {
    super.initState();
    _player.setPlaylistMode(PlaylistMode.single);
    // Глобально вимкнено звук у грі.
    _player.setVolume(0);
    _player.stream.playing.listen((playing) {
      if (playing) _hasStartedPlaying = true;
    });
    _player.stream.completed.listen((_) {
      if (!_completed && mounted && _hasStartedPlaying) {
        _completed = true;
        widget.onCompleted();
        widget.onClose(true);
      }
    });
    _player.stream.error.listen((_) {
      if (mounted) {
        setState(() => _loadFailed = true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              sl<LocaleController>().t('video_load_failed').replaceAll('%s', widget.videoPath),
            ),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    });
    // Відкриваємо відео після першого кадру, щоб помилка завантаження не ламала LayoutBuilder.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      try {
        _player.open(Media('asset:///${widget.videoPath}'));
      } catch (e) {
        if (mounted) setState(() => _loadFailed = true);
      }
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loadFailed) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Container(
            color: Colors.black,
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                'Відео не знайдено: ${widget.videoPath}',
                style: const TextStyle(color: Colors.white70, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Positioned(
            top: 8,
            left: 8,
            child: Material(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(8),
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 24),
                onPressed: () => widget.onClose(false),
              ),
            ),
          ),
        ],
      );
    }
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            color: Colors.black,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Video(
                  controller: _controller,
                  fit: BoxFit.contain,
                  controls: NoVideoControls,
                ),
                Positioned.fill(
                  child: UnifiedVideoControls(player: _player),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: 8,
          left: 8,
          child: Material(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(8),
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 24),
              onPressed: () => widget.onClose(false),
            ),
          ),
        ),
      ],
    );
  }
}

/// Повноекранне відео уроку (роут). По завершенні викликає [onCompleted] і закриває екран.
class LessonVideoScreen extends StatefulWidget {
  final String videoPath;
  final VoidCallback onCompleted;

  const LessonVideoScreen({
    super.key,
    required this.videoPath,
    required this.onCompleted,
  });

  @override
  State<LessonVideoScreen> createState() => _LessonVideoScreenState();
}

class _LessonVideoScreenState extends State<LessonVideoScreen> {
  late final Player _player = Player();
  late final VideoController _controller = VideoController(_player);
  bool _completed = false;
  bool _hasStartedPlaying = false;

  @override
  void initState() {
    super.initState();
    _player.setPlaylistMode(PlaylistMode.single);
    // Глобально вимкнено звук у грі.
    _player.setVolume(0);
    final uri = 'asset:///${widget.videoPath}';
    _player.open(Media(uri));
    // Вважаємо перегляд завершеним тільки якщо відео справді відтворилось (не помилка завантаження)
    _player.stream.playing.listen((playing) {
      if (playing) _hasStartedPlaying = true;
    });
    _player.stream.completed.listen((_) {
      if (!_completed && mounted && _hasStartedPlaying) {
        _completed = true;
        widget.onCompleted();
        Navigator.of(context).pop(true); // true = перегляд завершено, показати «завтра наступний урок»
      }
    });
    _player.stream.error.listen((_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              sl<LocaleController>().t('video_load_failed').replaceAll('%s', widget.videoPath),
            ),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Stack(
            fit: StackFit.expand,
            children: [
              Video(
                controller: _controller,
                fit: BoxFit.contain,
                controls: NoVideoControls,
              ),
              Positioned.fill(
                child: UnifiedVideoControls(player: _player),
              ),
            ],
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 28),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
