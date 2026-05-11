/// Контракт екранного флоу NPC у main game: mixins на [MainGameScreenStateBase]
/// реалізують цей інтерфейс і підключаються в [MainGameScreenState] у фіксованому порядку.
///
/// Дані квестів/івентів лишаються в `lib/npcs/<id>/`; тут лише місток UI + події.
abstract interface class NpcScreenFlow {
  /// Стабільний id NPC (`cherie`, `den`, …), узгоджений з [NpcModel.id].
  String get npcScreenFlowId;
}
