import 'package:flutter/material.dart';
import 'package:naglec/theme/game_theme.dart';

class ExhaustionDialogOverlay extends StatelessWidget {
  final VoidCallback onGoHome;

  const ExhaustionDialogOverlay({
    super.key,
    required this.onGoHome,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {}, // Prevent taps from dismissing
        child: Container(
          color: Colors.black.withValues(alpha: 0.7),
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(16),
              constraints: const BoxConstraints(maxWidth: 420),
              decoration: BoxDecoration(
                color: GameTheme.bgDark,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.6),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    "Ви сильно втомились",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "У вас майже не залишилось сил. Вам треба повернутися додому в свою кімнату і відпочити.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 42,
                    child: ElevatedButton(
                      style: GameTheme.actionButtonStyle(color: GameTheme.textBlack),
                      onPressed: onGoHome,
                      child: const Text(
                        "ДОДОМУ В СВОЮ КІМНАТУ",
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
