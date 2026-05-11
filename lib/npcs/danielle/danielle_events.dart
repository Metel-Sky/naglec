import '../../data/npc_interaction_types.dart';

/// Івенти та квест Danielle (мати Semа).
///
/// Етапи квесту зберігаю в [NPCModel.variables] під ключами [DanielleEventVars].
/// Додаткові кнопки — через [NpcInteractionSlot] нижче (локація, час, [minRelationship],
/// [oneTimeVar], [showOnlyWhenVarNull] для ланцюжка).
///
/// Складні діалоги з відео/фазами, за потреби — за зразком Дена у `main_game_screen_state`
/// та `den_events.dart`.

abstract final class DanielleEventVars {
  DanielleEventVars._();

  /// Див. [GameWorldState.spyOnSemParentsDone] (івент `spyOnSemParents`).

  // TODO: ключі етапів квесту, на-prokladка:
  // static const String questOfferSeen = 'danielleQuestOfferSeen';
  // static const String questStep1Done = 'danielleQuestStep1Done';
}

/// Слоти взаємодій Danielle (+ квестові, коли додаси шаблони).
List<NpcInteractionSlot> get danielleInteractionSlots => [
      NpcInteractionSlot(
        npcId: 'danielle',
        location: '',
        hourStart: 0,
        hourEnd: 24,
        actions: defaultInteractionActions,
      ),
      // Приклад одноразової дії в певній кімнаті (розкоментуй і підстав текст/умови):
      // NpcInteractionSlot(
      //   npcId: 'danielle',
      //   location: LocationsData.friendParentsRoom,
      //   hourStart: 0,
      //   hourEnd: 24,
      //   minRelationship: 300,
      //   oneTimeVar: DanielleEventVars.questStep1Done,
      //   actions: [
      //     const NpcActionTemplate(
      //       label: '…',
      //       relationship: 1,
      //       behavior: 0.5,
      //       influenceDelta: 2,
      //       setVarOnExecute: {DanielleEventVars.questStep1Done: true},
      //     ),
      //   ],
      // ),
    ];
