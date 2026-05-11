import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Картинка в картці лівої панелі: масштабується **пропорційно**, повністю вміщується в блок ([BoxFit.contain]).
class LeftPanelCardImage extends StatelessWidget {
  final String assetPath;
  final EdgeInsets padding;
  final Widget Function(BuildContext, Object, StackTrace?)? errorBuilder;

  const LeftPanelCardImage({
    super.key,
    required this.assetPath,
    this.padding = const EdgeInsets.all(6),
    this.errorBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final maxW = math.max(0.0, c.maxWidth - padding.horizontal);
        final maxH = math.max(0.0, c.maxHeight - padding.vertical);
        return Padding(
          padding: padding,
          child: Center(
            child: Image.asset(
              assetPath,
              width: maxW,
              height: maxH,
              fit: BoxFit.contain,
              alignment: Alignment.center,
              filterQuality: FilterQuality.medium,
              errorBuilder: errorBuilder,
            ),
          ),
        );
      },
    );
  }
}
