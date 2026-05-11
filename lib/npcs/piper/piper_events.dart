import '../../data/npc_interaction_types.dart';

/// Івенти та взаємодії для Piper.
List<NpcInteractionSlot> get piperInteractionSlots => [
      NpcInteractionSlot(
        npcId: 'piper',
        location: '',
        hourStart: 0,
        hourEnd: 24,
        actions: defaultInteractionActions,
      ),
    ];
