import '../../data/npc_interaction_types.dart';

/// Івенти та взаємодії для Мами. За замовчуванням — загальний набір дій для всіх локацій і часу.
/// EVENT: mom_event_002 — логіка в [MomEvent002Pool] (`mom_event002_pool.dart`).
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
