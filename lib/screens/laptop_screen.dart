import 'package:flutter/material.dart';

import 'laptop/compromat/laptop_compromat_mixin.dart';
import 'laptop/hidden_cameras/laptop_hidden_cameras_mixin.dart';
import 'laptop/laptop_screen_state_base.dart';
import 'laptop/porn/laptop_porn_mixin.dart';
import 'laptop/shop/laptop_shop_mixin.dart';
import 'laptop/study/laptop_study_mixin.dart';
import 'laptop/surf/laptop_surf_mixin.dart';

void _laptopNoOp() {}

/// Віджет ноутбука: робочий стіл у стилі Windows і локаційне меню.
/// Показується у вікні кімнати (onClose закриває його).
/// [bottomRightOverlay] — якщо задано, показується у правому нижньому куті екрану ноутбука (наприклад вікно з відео).
///
/// Логіка розбита по папці [laptop/]: порно, навчання, магазин, серфінг, компромат, приховані камери.
class LaptopScreen extends StatefulWidget {
  final VoidCallback onClose;
  /// Викликається при вході/виході з перегляду порно (щоб у локаційному меню показати кнопки «Вздрочнуть» / «Закрити ноут»).
  final void Function(bool isWatchingPorn)? onWatchingPornChanged;
  /// Викликається, коли відтворюється відео video_elsa (для кнопки «Зберегти компромат» при наявності USB).
  final void Function(bool isWatchingElsa)? onElsaVideoWatchingChanged;
  /// Віджет поверх екрану ноутбука у правому нижньому куті (30%×30%).
  final Widget? bottomRightOverlay;

  const LaptopScreen({
    super.key,
    VoidCallback? onClose,
    this.onWatchingPornChanged,
    this.onElsaVideoWatchingChanged,
    this.bottomRightOverlay,
  }) : onClose = onClose ?? _laptopNoOp;

  @override
  State<LaptopScreen> createState() => _LaptopScreenState();
}

class _LaptopScreenState extends LaptopScreenStateBase
    with
        LaptopCompromatMixin,
        LaptopPornMixin,
        LaptopStudyMixin,
        LaptopShopMixin,
        LaptopSurfMixin,
        LaptopHiddenCamerasMixin {}
