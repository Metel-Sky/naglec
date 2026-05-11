import 'package:flutter/material.dart';
import '../../models/npc_model.dart';
import '../../theme/game_theme.dart';

/// Круглі аватари NPC зліва для вибору активного персонажа в кімнаті.
class MainGameNpcAvatarStrip extends StatelessWidget {
  const MainGameNpcAvatarStrip({
    super.key,
    required this.activeNPCs,
    required this.selectedNpcIdInRoom,
    required this.currentZone,
    required this.currentRoom,
    required this.onNpcTap,
    this.selectionHighlightEnabled = true,
    this.selectionAutoSelectEnabled = true,
  });

  final List<NPCModel> activeNPCs;
  final String? selectedNpcIdInRoom;
  final String currentZone;
  final String currentRoom;
  final void Function(NPCModel npc) onNpcTap;

  /// Якщо false — усі аватари з тонкою рамкою (ніхто не «обраний»), без реакції на тап.
  final bool selectionHighlightEnabled;
  /// Якщо false — коли `selectedNpcIdInRoom == null`, ніхто не підсвічується зеленим
  /// (але тап по аватару все одно може обрати NPC).
  final bool selectionAutoSelectEnabled;

  Widget _avatarPlaceholder() {
    return Container(
      color: GameTheme.mainGrey,
      child: const Icon(Icons.person, color: Colors.white54, size: 28),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: activeNPCs.map((npc) {
              final bool singleCandidate = activeNPCs.length == 1;

              final NPCModel firstCandidate = activeNPCs.first;
              final NPCModel effectiveFirstCandidate = firstCandidate;

              final isSelected = selectionHighlightEnabled &&
                  (selectedNpcIdInRoom == npc.id ||
                      (selectedNpcIdInRoom == null &&
                          selectionAutoSelectEnabled &&
                          (singleCandidate ||
                              npc.id == effectiveFirstCandidate.id)));
              final child = Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: GestureDetector(
                  onTap: selectionHighlightEnabled ? () => onNpcTap(npc) : null,
                  child: Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? GameTheme.textGreen : Colors.white24,
                        width: isSelected ? 3 : 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.4),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: npc.avatarPath != null
                          ? Image.asset(
                              npc.avatarPath!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _avatarPlaceholder(),
                            )
                          : _avatarPlaceholder(),
                    ),
                  ),
                ),
              );
              return selectionHighlightEnabled ? child : IgnorePointer(child: child);
            }).toList(),
          ),
        ),
      ),
    );
  }
}
