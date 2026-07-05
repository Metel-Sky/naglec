import 'package:flutter/material.dart';
import '../data/npc_profile_display.dart';
import '../data/npc_economy_config.dart';
import '../data/npc_gallery_residence.dart';
import '../models/npc_model.dart';
import '../services/game_time_controller.dart';
import '../services/game_world_state.dart';
import '../services/service_locator.dart';
import '../theme/game_theme.dart';
import '../utils/npc_portrait_paths.dart';

/// [Image.asset] з послідовним fallback, якщо файл не в bundle або пошкоджений.
class _ChainedAssetPortrait extends StatelessWidget {
  const _ChainedAssetPortrait({
    required this.paths,
    required this.fit,
    this.alignment = Alignment.center,
  });

  final List<String> paths;
  final BoxFit fit;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    if (paths.isEmpty) {
      return const Center(
        child: Icon(Icons.person, color: Colors.white54, size: 48),
      );
    }
    return Image.asset(
      paths.first,
      fit: fit,
      alignment: alignment,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (_, __, ___) => _ChainedAssetPortrait(
        paths: paths.sublist(1),
        fit: fit,
        alignment: alignment,
      ),
    );
  }
}

/// Головне вікно з сіткою карток усіх NPC (аватар, ім'я, роль). Показується при натисканні блоку «Персонажі» в лівій панелі.
class NpcGalleryView extends StatelessWidget {
  final List<NPCModel> npcs;
  final GameTimeController timeController;
  final VoidCallback onBack;
  final void Function(NPCModel npc)? onNpcCardTap;

  static const List<String> _dayNames = [
    'Понеділок', 'Вівторок', 'Середа', 'Четвер', "П'ятниця", 'Субота', 'Неділя'
  ];

  /// Перші картки — родина ГG і Juniper (4-та); решта — за будинком проживання, у групі — за віком.
  static List<NPCModel> sortedForGallery(List<NPCModel> npcs) =>
      NpcGalleryResidence.sortForGallery(npcs);

  const NpcGalleryView({
    super.key,
    required this.npcs,
    required this.timeController,
    required this.onBack,
    this.onNpcCardTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: timeController,
      builder: (context, _) {
        final orderedNpcs = sortedForGallery(npcs);
        final dt = timeController.dateTime;
        final dateStr = '${dt.day.toString().padLeft(2, '0')} . ${dt.month.toString().padLeft(2, '0')} . ${dt.year}';
        final dayName = timeController.weekdayIndex >= 0 && timeController.weekdayIndex < _dayNames.length
            ? _dayNames[timeController.weekdayIndex]
            : '';
        final timeStr = '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Хедер: дата, день, час, назва локації
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Дата: $dateStr',
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        dayName,
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'Час: $timeStr',
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ],
                  ),
                  const Text(
                    'Дім',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
            ),
            // Сітка карток NPC
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.only(bottom: 8),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  childAspectRatio: 0.72,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: orderedNpcs.length,
                itemBuilder: (context, index) {
                  final npc = orderedNpcs[index];
                  final portraitPaths = npcGalleryPortraitCandidates(npc);
                  final cardContent = Container(
                    decoration: BoxDecoration(
                      color: GameTheme.bgDark.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white24, width: 1),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final h = constraints.maxHeight;
                          final imageH = h * 0.8;
                          final captionH = h * 0.2;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              SizedBox(
                                height: imageH,
                                width: double.infinity,
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  fit: StackFit.expand,
                                  children: [
                                    if (portraitPaths.isEmpty)
                                      const Center(
                                        child: Icon(Icons.person, color: Colors.white54, size: 48),
                                      )
                                    else
                                      ClipRect(
                                        child: _ChainedAssetPortrait(
                                          paths: portraitPaths,
                                          fit: BoxFit.cover,
                                          alignment: Alignment.topCenter,
                                        ),
                                      ),
                                    Positioned(
                                      top: 4,
                                      right: 4,
                                      child: Icon(
                                        Icons.attach_money,
                                        size: 22,
                                        color: NpcEconomyConfig.moneyTierColor(npc.money),
                                        shadows: const [
                                          Shadow(color: Colors.black54, blurRadius: 4),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: captionH,
                                child: ClipRect(
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    color: Colors.grey.shade300,
                                    alignment: Alignment.center,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          npc.fullName,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Colors.grey.shade800,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          NpcProfileDisplay.profileStatus(
                                            npc,
                                            world: sl<GameWorldState>(),
                                          ),
                                          textAlign: TextAlign.center,
                                          style: TextStyle(color: Colors.grey.shade700, fontSize: 11),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        if (npc.subStatus != null) ...[
                                          const SizedBox(height: 1),
                                          Text(
                                            npc.subStatus!,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(color: Colors.grey.shade600, fontSize: 10),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  );
                  if (onNpcCardTap == null) return cardContent;
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => onNpcCardTap!(npc),
                      borderRadius: BorderRadius.circular(12),
                      child: cardContent,
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
