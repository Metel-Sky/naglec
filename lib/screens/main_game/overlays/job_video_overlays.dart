import 'package:flutter/material.dart';
import '../../../widgets/masturbate_video_overlay.dart';

class FlyersVideoOverlay extends StatelessWidget {
  final double maxWidth;
  final double maxHeight;
  final VoidCallback onClose;

  const FlyersVideoOverlay({
    super.key,
    required this.maxWidth,
    required this.maxHeight,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return _JobVideoOverlayBase(
      maxWidth: maxWidth,
      maxHeight: maxHeight,
      videoPath: 'lib/assets/laptop/flyers.webm',
      onClose: onClose,
    );
  }
}

class ConstructionVideoOverlay extends StatelessWidget {
  final double maxWidth;
  final double maxHeight;
  final VoidCallback onClose;

  const ConstructionVideoOverlay({
    super.key,
    required this.maxWidth,
    required this.maxHeight,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return _JobVideoOverlayBase(
      maxWidth: maxWidth,
      maxHeight: maxHeight,
      videoPath: 'lib/assets/laptop/work_building.webm',
      onClose: onClose,
    );
  }
}

class _JobVideoOverlayBase extends StatelessWidget {
  final double maxWidth;
  final double maxHeight;
  final String videoPath;
  final VoidCallback onClose;

  const _JobVideoOverlayBase({
    required this.maxWidth,
    required this.maxHeight,
    required this.videoPath,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Container(color: Colors.black54),
        ),
        Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: maxWidth,
              maxHeight: maxHeight,
            ),
            child: MasturbateVideoOverlay(
              videoPath: videoPath,
              showControls: true,
              closeWhenCompleted: true,
              onClose: onClose,
            ),
          ),
        ),
      ],
    );
  }
}
