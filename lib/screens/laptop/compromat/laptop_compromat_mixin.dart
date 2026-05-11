import 'package:flutter/material.dart';

import '../../../services/game_world_state.dart';
import '../../../services/inventory_controller.dart';
import '../../../services/save_service.dart';
import '../../../services/service_locator.dart';
import '../../../widgets/lesson_video_screen.dart';
import '../laptop_screen_state_base.dart';
import '../laptop_shared_widgets.dart';
import 'laptop_compromat_data.dart';

mixin LaptopCompromatMixin on LaptopScreenStateBase {
  void onCompromatVideoCompleted() {
    if (currentCompromatSource == 'usb' && currentCompromatNpcId != null) {
      final inventory = sl<InventoryController>();
      if (inventory.count('usb_compromat') > 0) {
        inventory.removeItem('usb_compromat');
      }
      final world = sl<GameWorldState>();
      if (!world.compromatNpcIds.contains(currentCompromatNpcId)) {
        world.compromatNpcIds.add(currentCompromatNpcId!);
      }
      sl<SaveService>().autosave();
    }
    currentCompromatSource = null;
    currentCompromatNpcId = null;
  }

  String compromatVideoPathForNpc(String npcId) {
    switch (npcId) {
      case 'piper':
        return laptopElsaCompromatVideoPath;
      default:
        return laptopGenericCompromatVideoPath;
    }
  }

  String npcNameForCompromat(String npcId) {
    switch (npcId) {
      case 'elsa':
        return 'Компромат на Piper';
      case 'piper':
        return 'Компромат на Elsa';
      case 'luda':
        return 'Компромат на Люду';
      default:
        return 'Компромат';
    }
  }

  @override
  Widget buildCompromatSubmenu() {
    final world = sl<GameWorldState>();
    final List<Widget> items = [];

    for (final npcId in world.compromatNpcIds) {
      final label = npcNameForCompromat(npcId);
      items.add(
        Material(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            onTap: () => setState(() {
              currentCompromatVideoPath = compromatVideoPathForNpc(npcId);
              currentCompromatNpcId = npcId;
              currentCompromatSource = 'stored';
              watchingCompromatVideo = true;
            }),
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Icon(Icons.play_circle_filled,
                      size: 28,
                      color: Colors.white.withValues(alpha: 0.95)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.95),
                          fontSize: 15,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      items.add(const SizedBox(height: 12));
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          laptopBackButtonRow(
            onBack: () => setState(() => showCompromatSubmenu = false),
            backLabel: t('laptop_study_back'),
          ),
          const SizedBox(height: 24),
          if (items.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Поки що у вас немає збереженого компромату.',
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 15),
                ),
              ),
            )
          else
            ...items,
        ],
      ),
    );
  }

  @override
  Widget buildCompromatVideo() {
    final videoPath =
        currentCompromatVideoPath ?? laptopGenericCompromatVideoPath;
    return EmbeddedLessonVideo(
      videoPath: videoPath,
      onCompleted: onCompromatVideoCompleted,
      onClose: (completed) {
        if (completed == true) {
          onCompromatVideoCompleted();
        }
        setState(() => watchingCompromatVideo = false);
      },
    );
  }

  @override
  Widget buildUsbCompromatSubmenu() {
    final inventory = sl<InventoryController>();
    final hasUsb = inventory.count('usb_compromat') > 0;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          laptopBackButtonRow(
            onBack: () => setState(() => showUsbCompromatSubmenu = false),
            backLabel: t('laptop_study_back'),
          ),
          const SizedBox(height: 24),
          if (!hasUsb)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'У рюкзаку немає флешки з компроматом.',
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 15),
                ),
              ),
            )
          else
            Material(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
              child: InkWell(
                onTap: () => setState(() {
                  currentCompromatVideoPath = laptopGenericCompromatVideoPath;
                  currentCompromatNpcId = 'mom';
                  currentCompromatSource = 'usb';
                  watchingCompromatVideo = true;
                }),
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      Icon(Icons.play_circle_filled,
                          size: 28,
                          color: Colors.white.withValues(alpha: 0.95)),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'Переглянути відео з флешки',
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
        ],
      ),
    );
  }
}
