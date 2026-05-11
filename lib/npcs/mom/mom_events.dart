import '../../data/npc_interaction_types.dart';

/// Івенти та взаємодії для Мами. За замовчуванням — загальний набір дій для всіх локацій і часу.
List<NpcInteractionSlot> get momInteractionSlots => [
      // Базовий слот: стандартні кнопки (Поговорити, Комплімент, …) скрізь.
      NpcInteractionSlot(
        npcId: 'mom',
        location: '',
        hourStart: 0,
        hourEnd: 24,
        actions: defaultInteractionActions,
      ),
    ];
