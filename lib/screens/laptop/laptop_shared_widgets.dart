import 'package:flutter/material.dart';
import '../../services/inventory_controller.dart';
import '../../services/game_world_state.dart';
import '../../services/service_locator.dart';

/// Кнопка «Назад» з підписом (як у розділах ноутбука).
Widget laptopBackButtonRow({
  required VoidCallback onBack,
  required String backLabel,
}) {
  return Row(
    children: [
      Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onBack,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.arrow_back,
                    color: Colors.white.withValues(alpha: 0.95), size: 20),
                const SizedBox(width: 8),
                Text(
                  backLabel,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.95),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ],
  );
}

void showLaptopWarning(BuildContext context, String message) {
  showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      content: Text(message),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: Text(MaterialLocalizations.of(ctx).okButtonLabel),
        ),
      ],
    ),
  );
}

/// Рядок меню навчання / серфінгу (великий тап).
Widget laptopStudyOptionTile(
  String label,
  IconData icon,
  VoidCallback onTap,
) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Material(
      color: Colors.white.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon, size: 28, color: Colors.white),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.95),
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget laptopDesktopShortcut(
  BuildContext context, {
  required String label,
  required IconData icon,
  required VoidCallback onTap,
}) {
  return Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 32, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.95),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

/// Ярлики робочого столу ноутбука.
Widget laptopDesktopShortcutsGrid({
  required BuildContext context,
  required String Function(String key) t,
  required VoidCallback openStudy,
  required VoidCallback openSurf,
  required VoidCallback openShop,
  required VoidCallback openPorn,
  required VoidCallback openHiddenCameras,
  required VoidCallback openCompromat,
  required VoidCallback openUsbCompromat,
}) {
  final world = sl<GameWorldState>();
  final hasCameras = world.installedSpyCameraRooms.isNotEmpty;
  final hasCompromat =
      world.hasMomOfficeCompromatVideo3 || world.compromatNpcIds.isNotEmpty;
  final hasUsb = sl<InventoryController>().count('usb_compromat') > 0;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 24),
      Wrap(
        spacing: 20,
        runSpacing: 20,
        children: [
          laptopDesktopShortcut(
            context,
            label: t('laptop_study'),
            icon: Icons.school_outlined,
            onTap: openStudy,
          ),
          laptopDesktopShortcut(
            context,
            label: t('laptop_surf'),
            icon: Icons.language,
            onTap: openSurf,
          ),
          laptopDesktopShortcut(
            context,
            label: t('laptop_shop'),
            icon: Icons.shopping_cart_outlined,
            onTap: openShop,
          ),
          laptopDesktopShortcut(
            context,
            label: t('laptop_porn'),
            icon: Icons.play_circle_outline,
            onTap: openPorn,
          ),
          if (hasCameras)
            laptopDesktopShortcut(
              context,
              label: t('laptop_hidden_cameras'),
              icon: Icons.videocam_outlined,
              onTap: openHiddenCameras,
            ),
          if (hasCompromat)
            laptopDesktopShortcut(
              context,
              label: 'Компромат',
              icon: Icons.video_library_outlined,
              onTap: openCompromat,
            ),
          if (hasUsb)
            laptopDesktopShortcut(
              context,
              label: 'USB-компромат',
              icon: Icons.usb,
              onTap: openUsbCompromat,
            ),
        ],
      ),
    ],
  );
}
