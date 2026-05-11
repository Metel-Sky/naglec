import 'package:flutter/material.dart';
import 'company_room_layout.dart';

/// Локація **Rockefeller Group** у БЦ: великий фон ([companyMainHallImagePath]) + вікна «Приймальня» / «Офіс».
/// Повноекранна приймальня — той самий кадр, що превʼю; повноекранний офіс — [cabinetInteriorImagePath] / [cabinetEmptyOfficeImagePath].
class RockefellerCompanyView extends StatelessWidget {
  /// Коли true — Рокфеллер у внутрішньому офісі (`cityBcRockefellerCabinet`, 9–18 у будні); у холі растру не показуємо.
  final bool rockefellerInOffice;
  final String? npcRasterAssetPath;
  final String? npcRasterFallbackPath;
  final VoidCallback? onNpcTap;
  /// Тап по кнопці «Офіс Рокфеллера» — повноекранний офіс (як офіс мами в логістиці).
  final VoidCallback? onCabinetTap;
  /// Тап по вікну «Приймальня» — повноекранний кадр приймальні.
  final VoidCallback? onReceptionTap;

  const RockefellerCompanyView({
    super.key,
    this.rockefellerInOffice = false,
    this.npcRasterAssetPath,
    this.npcRasterFallbackPath,
    this.onNpcTap,
    this.onCabinetTap,
    this.onReceptionTap,
  });

  /// Превʼю вікна «Приймальня» (і той самий кадр у повноекранній приймальні).
  static const String receptionPreviewImagePath =
      'lib/assets/location/biznes_centr/rockffeller_reception.png';

  /// Повноекранна приймальня після тапу — збігається з превʼю.
  static const String receptionInteriorImagePath = receptionPreviewImagePath;

  /// Повноекранний офіс, коли Рокфеллер у `city_bc_rockefeller_cabinet` за розкладом.
  static const String cabinetInteriorImagePath =
      'lib/assets/location/biznes_centr/rokfeller_first.jpg';

  /// Повноекранний офіс без Рокфеллера + превʼю кнопки «Офіс Рокфеллера» у холі.
  static const String cabinetEmptyOfficeImagePath =
      'lib/assets/location/biznes_centr/rockffeller_office.jpg';

  /// Великий фон екрана компанії (хол Rockefeller Group).
  static const String companyMainHallImagePath =
      'lib/assets/location/biznes_centr/rockffeller_reception.jpg';

  Widget? _npcBottomOverlay() {
    final path = npcRasterAssetPath?.trim();
    final onTap = onNpcTap;
    if (path == null || path.isEmpty || onTap == null) return null;
    if (path.endsWith('.webm') || path.endsWith('.mp4')) return null;
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: onTap,
      child: Image.asset(
        path,
        fit: BoxFit.contain,
        alignment: Alignment.bottomCenter,
        errorBuilder: (context, error, stackTrace) {
          final fb = npcRasterFallbackPath?.trim();
          if (fb == null || fb.isEmpty) return const SizedBox.shrink();
          return Image.asset(
            fb,
            fit: BoxFit.contain,
            alignment: Alignment.bottomCenter,
            errorBuilder: (context2, error2, stackTrace2) =>
                const SizedBox.shrink(),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cabinetThumb = cabinetEmptyOfficeImagePath;
    final VoidCallback? bottomTap =
        onCabinetTap ?? (rockefellerInOffice ? onNpcTap : null);

    return CompanyRoomLayout(
      backgroundImagePath: companyMainHallImagePath,
      npcBottomOverlay: rockefellerInOffice ? null : _npcBottomOverlay(),
      onMainBackgroundTap: null,
      topWindow: CompanyWindowButton(
        imagePath: receptionPreviewImagePath,
        label: 'Приймальня',
        onTap: onReceptionTap,
      ),
      bottomWindow: CompanyWindowButton(
        imagePath: cabinetThumb,
        label: 'Офіс Рокфеллера',
        onTap: bottomTap,
      ),
    );
  }
}
