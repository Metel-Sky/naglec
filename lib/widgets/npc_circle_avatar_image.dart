import 'package:flutter/material.dart';

/// Аватар NPC у круглому кадрі для портретів «майже в повний зріст»:
/// кроп від верху PNG (обличчя), масштаб +40%, вертикаль — [topHeadroomFraction] + [verticalOffsetFraction].
class NpcCircleAvatarImage extends StatelessWidget {
  const NpcCircleAvatarImage({
    super.key,
    required this.size,
    required this.imagePath,
    this.errorBuilder,
  });

  static const double imageScale = 1.7;

  /// Пустота над фото в колі.
  static const double topHeadroomFraction = 0.10;

  /// Додатковий зсув вниз (разом з [topHeadroomFraction]).
  static const double verticalOffsetFraction = 0.0;

  /// Повний зріст: обличчя зверху PNG, не центр тулуба.
  static const Alignment coverAlignment = Alignment.topCenter;

  final double size;
  final String imagePath;
  final ImageErrorWidgetBuilder? errorBuilder;

  @override
  Widget build(BuildContext context) {
    final offsetY = size * (topHeadroomFraction + verticalOffsetFraction);
    return ClipOval(
      clipBehavior: Clip.hardEdge,
      child: SizedBox(
        width: size,
        height: size,
        child: Transform.translate(
          offset: Offset(0, offsetY),
          child: Transform.scale(
            scale: imageScale,
            alignment: Alignment.topCenter,
            child: Image.asset(
              imagePath,
              width: size,
              height: size,
              fit: BoxFit.cover,
              alignment: coverAlignment,
              errorBuilder: errorBuilder,
            ),
          ),
        ),
      ),
    );
  }
}
