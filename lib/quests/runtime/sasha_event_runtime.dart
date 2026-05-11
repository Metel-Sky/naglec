import '../../npcs/sasha/sasha_events.dart';
import '../contracts/quest_action.dart';

class SashaEventRuntime {
  const SashaEventRuntime();

  /// Pilot migration helper for `sasha_event_001` (hall communicate).
  List<QuestAction> hallActions(ComunicateSashaInHallPhase phase) {
    switch (phase) {
      case ComunicateSashaInHallPhase.intro:
        return const <QuestAction>[
          QuestAction(id: 'approach', label: 'Підійти до Саши'),
          QuestAction(id: 'leave', label: 'Піти...'),
        ];
      case ComunicateSashaInHallPhase.videoAndTalk:
        return const <QuestAction>[
          QuestAction(id: 'continueToMoneyChoice', label: 'ну і вали'),
        ];
      case ComunicateSashaInHallPhase.moneyChoice:
        return const <QuestAction>[
          QuestAction(id: 'giveMoney', label: 'Дать 3\$ і піти'),
          QuestAction(id: 'giveEnergyDrink', label: 'грошей нема, на редбул і я пішов'),
          QuestAction(id: 'sendAway', label: 'Послать і піти', isDestructive: true),
        ];
    }
  }

  /// Pilot migration helper for `sasha_event_002` (morning run).
  List<QuestAction> morningRunActions(SashaMorningRunPhase phase) {
    switch (phase) {
      case SashaMorningRunPhase.intro:
        return const <QuestAction>[
          QuestAction(id: 'approach', label: 'Підійти'),
          QuestAction(id: 'leave', label: 'залишити в спокої'),
        ];
      case SashaMorningRunPhase.video2:
        return const <QuestAction>[
          QuestAction(id: 'continueToPayOffer', label: 'ну і вали'),
        ];
      case SashaMorningRunPhase.payOffer:
        return const <QuestAction>[
          QuestAction(id: 'giveMoney', label: 'дати гроші'),
          QuestAction(id: 'sendAway', label: 'Послать', isDestructive: true),
        ];
      case SashaMorningRunPhase.afterPaid:
        return const <QuestAction>[
          QuestAction(id: 'leave', label: 'піти'),
        ];
    }
  }
}
