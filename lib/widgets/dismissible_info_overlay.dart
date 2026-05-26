import 'package:flutter/material.dart';

import '../theme/game_theme.dart';

/// Коротке інфо-повідомлення внизу екрана: тап **поза** смужкою з текстом закриває його.
class DismissibleInfoOverlay {
  DismissibleInfoOverlay._();

  static void show(BuildContext context, String message) {
    final overlayState = Overlay.maybeOf(context);
    if (overlayState == null) return;

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (ctx) => Material(
        type: MaterialType.transparency,
        child: Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  if (entry.mounted) entry.remove();
                },
                child: const ColoredBox(color: Colors.transparent),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: MediaQuery.paddingOf(ctx).bottom + 16,
              child: Center(
                child: SizedBox(
                  width: MediaQuery.sizeOf(ctx).width / 3,
                  child: Material(
                    elevation: 6,
                    borderRadius: BorderRadius.circular(8),
                    color: GameTheme.mainGrey,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 16,
                      ),
                      child: Text(
                        message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: GameTheme.textBlack,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    overlayState.insert(entry);
    Future<void>.delayed(const Duration(seconds: 6), () {
      if (entry.mounted) entry.remove();
    });
  }
}
