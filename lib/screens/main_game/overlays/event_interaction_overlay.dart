import 'package:flutter/material.dart';
import 'package:naglec/theme/game_theme.dart';
import 'package:naglec/services/locale_controller.dart';
import 'package:naglec/services/service_locator.dart';
import '../../../widgets/masturbate_video_overlay.dart';

class EventInteractionOverlay extends StatelessWidget {
  final String? eventVideoPath;
  final bool eventVideoMuted;
  final bool eventVideoFullScreen;
  final bool eventVideoCloseWhenCompleted;
  final bool eventVideoLoop;
  final VoidCallback? eventVideoOnComplete;
  
  final String? eventVideoPendingButton;
  final VoidCallback? eventVideoOnButtonPressed;
  
  final String? eventImagePath;

  const EventInteractionOverlay({
    super.key,
    this.eventVideoPath,
    this.eventVideoMuted = false,
    this.eventVideoFullScreen = false,
    this.eventVideoCloseWhenCompleted = true,
    this.eventVideoLoop = false,
    this.eventVideoOnComplete,
    this.eventVideoPendingButton,
    this.eventVideoOnButtonPressed,
    this.eventImagePath,
  });

  @override
  Widget build(BuildContext context) {
    if (eventVideoPath == null && eventVideoPendingButton == null && eventImagePath == null) {
      return const SizedBox.shrink();
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        if (eventVideoPath != null)
          Positioned.fill(
            child: MasturbateVideoOverlay(
              key: ValueKey<String>(eventVideoPath!),
              videoPath: eventVideoPath!,
              // Повноекранне відео + кнопки в GameDialogPanel: інакше AdaptiveVideoControls дає другі «…».
              showControls:
                  eventVideoPendingButton == null && !eventVideoFullScreen,
              closeWhenCompleted: eventVideoPendingButton == null && eventVideoCloseWhenCompleted,
              loop: eventVideoLoop,
              onClose: eventVideoPendingButton == null
                  ? () => eventVideoOnComplete?.call()
                  : () {},
              muted: eventVideoMuted,
              borderRadius: eventVideoFullScreen ? 0 : 12,
              fit: eventVideoFullScreen ? BoxFit.cover : BoxFit.contain,
            ),
          ),
        
        if (eventVideoPath == null && eventVideoPendingButton != null)
          Positioned.fill(
            child: Container(color: Colors.black),
          ),
          
        if (eventVideoPendingButton != null)
          Center(
            child: SizedBox(
              width: 260,
              height: 56,
              child: ElevatedButton(
                style: GameTheme.actionButtonStyle(),
                onPressed: eventVideoOnButtonPressed,
                child: Text(
                  eventVideoPendingButton!,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          
        if (eventImagePath != null)
          Positioned.fill(
            child: Image.asset(
              eventImagePath!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: Colors.black45,
                alignment: Alignment.center,
                padding: const EdgeInsets.all(12),
                child: Text(
                  sl<LocaleController>()
                      .t('asset_load_failed_short')
                      .replaceAll('%s', eventImagePath!),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
