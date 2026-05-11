import '../../quests/contracts/quest_action.dart';
import '../../quests/contracts/quest_definition.dart';
import 'sasha_events.dart';

abstract final class SashaQuestDefinitions {
  SashaQuestDefinitions._();

  static const String hallEventId = 'sasha_event_001';
  static const String morningRunEventId = SashaEvents.morningRunEventId;

  static const QuestDefinition hallEvent = QuestDefinition(
    questId: hallEventId,
    npcId: 'sasha',
    version: 1,
    steps: <QuestStepDefinition>[
      QuestStepDefinition(
        step: 1,
        locationId: 'friend_hall',
        dialogL10nKey: null,
        availableActions: <QuestAction>[
          QuestAction(id: 'approach', label: 'Підійти до Саши'),
          QuestAction(id: 'leave', label: 'Піти...'),
        ],
      ),
      QuestStepDefinition(
        step: 2,
        locationId: 'friend_hall',
        entryVideoPath: SashaEvents.comunicateSashaInHallVideoPath,
        availableActions: <QuestAction>[
          QuestAction(id: 'continueToMoneyChoice', label: 'ну і вали'),
        ],
      ),
      QuestStepDefinition(
        step: 3,
        locationId: 'friend_hall',
        entryVideoPath: SashaEvents.comunicateSashaInHallVideoPath,
        availableActions: <QuestAction>[
          QuestAction(id: 'giveMoney', label: 'Дать 3\$ і піти'),
          QuestAction(id: 'giveEnergyDrink', label: 'грошей нема, на редбул і я пішов'),
          QuestAction(id: 'sendAway', label: 'Послать і піти'),
        ],
      ),
    ],
  );

  static const QuestDefinition morningRunEvent = QuestDefinition(
    questId: morningRunEventId,
    npcId: 'sasha',
    version: 1,
    steps: <QuestStepDefinition>[
      QuestStepDefinition(
        step: 1,
        locationId: 'street_overview',
        entryVideoPath: SashaEvents.morningRunVideoRun1Path,
        availableActions: <QuestAction>[
          QuestAction(id: 'approach', label: 'Підійти'),
          QuestAction(id: 'leave', label: 'залишити в спокої'),
        ],
      ),
      QuestStepDefinition(
        step: 2,
        locationId: 'street_overview',
        entryVideoPath: SashaEvents.morningRunVideoRun2Path,
        availableActions: <QuestAction>[
          QuestAction(id: 'continueToPayOffer', label: 'ну і вали'),
        ],
      ),
      QuestStepDefinition(
        step: 3,
        locationId: 'street_overview',
        entryVideoPath: SashaEvents.morningRunVideoRun2Path,
        availableActions: <QuestAction>[
          QuestAction(id: 'giveMoney', label: 'дати гроші'),
          QuestAction(id: 'sendAway', label: 'Послать'),
        ],
      ),
      QuestStepDefinition(
        step: 4,
        locationId: 'street_overview',
        entryVideoPath: SashaEvents.morningRunVideoRun2Path,
        availableActions: <QuestAction>[
          QuestAction(id: 'leave', label: 'піти'),
        ],
      ),
    ],
  );

  static const List<QuestDefinition> all = <QuestDefinition>[
    hallEvent,
    morningRunEvent,
  ];
}
