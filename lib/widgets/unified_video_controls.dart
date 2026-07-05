import 'dart:math' as math;
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';

/// Єдині контролли для всіх відео в грі:
/// - кнопка пауза/відтворення
/// - шкала прогресу
class UnifiedVideoControls extends StatelessWidget {
  const UnifiedVideoControls({
    super.key,
    required this.player,
    this.onSeek,
  });

  final Player player;
  final VoidCallback? onSeek;

  @override
  Widget build(BuildContext context) {
    return _UnifiedVideoControlsBody(player: player, onSeek: onSeek);
  }
}

class _UnifiedVideoControlsBody extends StatefulWidget {
  const _UnifiedVideoControlsBody({
    required this.player,
    this.onSeek,
  });

  final Player player;
  final VoidCallback? onSeek;

  @override
  State<_UnifiedVideoControlsBody> createState() =>
      _UnifiedVideoControlsBodyState();
}

class _UnifiedVideoControlsBodyState extends State<_UnifiedVideoControlsBody> {
  static const _hideDelay = Duration(seconds: 2);
  Timer? _hideTimer;
  bool _visible = true;

  @override
  void initState() {
    super.initState();
    _restartHideTimer();
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  void _restartHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(_hideDelay, () {
      if (!mounted) return;
      setState(() => _visible = false);
    });
  }

  void _showControlsTemporarily() {
    if (!_visible) {
      setState(() => _visible = true);
    }
    _restartHideTimer();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: _showControlsTemporarily,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: IgnorePointer(
              ignoring: !_visible,
              child: AnimatedOpacity(
                opacity: _visible ? 1 : 0,
                duration: const Duration(milliseconds: 200),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  color: Colors.transparent,
                  child: Row(
                    children: [
                      StreamBuilder<bool>(
                        stream: widget.player.stream.playing,
                        initialData: false,
                        builder: (context, snapshot) {
                          final isPlaying = snapshot.data ?? false;
                          return IconButton(
                            icon: Icon(
                              isPlaying ? Icons.pause : Icons.play_arrow,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              _showControlsTemporarily();
                              if (isPlaying) {
                                widget.player.pause();
                              } else {
                                widget.player.play();
                              }
                            },
                          );
                        },
                      ),
                      Expanded(
                        child: StreamBuilder<Duration>(
                          stream: widget.player.stream.position,
                          initialData: Duration.zero,
                          builder: (context, posSnap) {
                            return StreamBuilder<Duration>(
                              stream: widget.player.stream.duration,
                              initialData: Duration.zero,
                              builder: (context, durSnap) {
                                final position = posSnap.data ?? Duration.zero;
                                final duration = durSnap.data ?? Duration.zero;
                                final maxMs = math
                                    .max(duration.inMilliseconds, 1)
                                    .toDouble();
                                final valueMs = position.inMilliseconds
                                    .clamp(0, maxMs.toInt())
                                    .toDouble();
                                return Slider(
                                  value: valueMs,
                                  max: maxMs,
                                  onChanged: (v) {
                                    _showControlsTemporarily();
                                    widget.player.seek(
                                      Duration(milliseconds: v.round()),
                                    );
                                    widget.onSeek?.call();
                                  },
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
