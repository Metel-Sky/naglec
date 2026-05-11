import '../../data/npc_interaction_types.dart';

/// Івенти та взаємодії для Elsa.
List<NpcInteractionSlot> get elsaInteractionSlots => [
      NpcInteractionSlot(
        npcId: 'elsa',
        location: '',
        hourStart: 0,
        hourEnd: 24,
        actions: defaultInteractionActions,
      ),
    ];
