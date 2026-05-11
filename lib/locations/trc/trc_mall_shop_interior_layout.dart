import 'package:flutter/material.dart';

/// Інтер'єр магазину ТРЦ: фото залу на весь блок + легкий градієнт, поверх — [child].
class TrcMallShopInteriorLayout extends StatelessWidget {
  const TrcMallShopInteriorLayout({
    super.key,
    required this.backgroundPath,
    required this.child,
  });

  final String backgroundPath;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(
          child: Image.asset(
            backgroundPath,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            alignment: Alignment.center,
            filterQuality: FilterQuality.medium,
            errorBuilder: (_, _, _) => ColoredBox(
              color: Colors.blueGrey.shade800,
              child: Center(
                child: Icon(
                  Icons.image_not_supported_outlined,
                  size: 56,
                  color: Colors.white.withValues(alpha: 0.35),
                ),
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.12),
                  Colors.black.withValues(alpha: 0.22),
                ],
              ),
            ),
          ),
        ),
        Positioned.fill(child: child),
      ],
    );
  }
}
