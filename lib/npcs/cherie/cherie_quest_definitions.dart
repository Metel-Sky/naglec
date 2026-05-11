import '../../quests/contracts/quest_action.dart';
import '../../quests/contracts/quest_definition.dart';

abstract final class CherieQuestDefinitions {
  CherieQuestDefinitions._();

  static const QuestDefinition quest003 = QuestDefinition(
    questId: 'cherie_quest_003',
    npcId: 'cherie',
    version: 1,
    steps: <QuestStepDefinition>[
      QuestStepDefinition(
        step: 1,
        locationId: 'city_mall_gift_shop_office',
        availableActions: <QuestAction>[
          QuestAction(id: 'goWork', label: 'go_work'),
        ],
      ),
      QuestStepDefinition(
        step: 2,
        locationId: 'city_mall_gift_shop_office',
        availableActions: <QuestAction>[
          QuestAction(id: 'finishWork', label: 'finish_work'),
        ],
      ),
      QuestStepDefinition(
        step: 3,
        locationId: 'city_mall_gift_shop_office',
        availableActions: <QuestAction>[
          QuestAction(id: 'leaveFinale', label: 'leave'),
        ],
      ),
    ],
  );

  static const QuestDefinition quest004 = QuestDefinition(
    questId: 'cherie_quest_004',
    npcId: 'cherie',
    version: 1,
    steps: <QuestStepDefinition>[
      QuestStepDefinition(step: 1, locationId: 'city_mall_gift_shop_office'),
      QuestStepDefinition(step: 3, locationId: 'home_cherie_bedroom'),
      QuestStepDefinition(step: 4, locationId: 'home_cherie_bedroom'),
      QuestStepDefinition(step: 5, locationId: 'home_cherie_bedroom'),
      QuestStepDefinition(step: 6, locationId: 'home_cherie_bedroom'),
      QuestStepDefinition(step: 7, locationId: 'home_cherie_bedroom'),
      QuestStepDefinition(step: 8, locationId: 'home_cherie_bedroom'),
      QuestStepDefinition(step: 9, locationId: 'home_cherie_bedroom'),
      QuestStepDefinition(step: 10, locationId: 'home_cherie_bedroom'),
      QuestStepDefinition(step: 11, locationId: 'home_cherie_hall'),
    ],
  );

  static const QuestDefinition quest005 = QuestDefinition(
    questId: 'cherie_quest_005',
    npcId: 'cherie',
    version: 1,
    steps: <QuestStepDefinition>[
      QuestStepDefinition(step: 1, locationId: 'city_mall_gift_shop_office'),
      QuestStepDefinition(step: 2, locationId: 'home_cherie_bedroom'),
      QuestStepDefinition(step: 3, locationId: 'home_cherie_bedroom'),
      QuestStepDefinition(step: 4, locationId: 'home_cherie_bedroom'),
      QuestStepDefinition(step: 5, locationId: 'home_cherie_bedroom'),
      QuestStepDefinition(step: 6, locationId: 'home_cherie_bedroom'),
      QuestStepDefinition(step: 7, locationId: 'home_cherie_bedroom'),
      QuestStepDefinition(step: 8, locationId: 'home_cherie_bedroom'),
      QuestStepDefinition(step: 9, locationId: 'home_cherie_bedroom'),
      QuestStepDefinition(step: 10, locationId: 'home_cherie_bedroom'),
      QuestStepDefinition(step: 11, locationId: 'home_cherie_bedroom'),
      QuestStepDefinition(step: 12, locationId: 'home_cherie_bedroom'),
      QuestStepDefinition(step: 13, locationId: 'home_cherie_bedroom'),
    ],
  );

  static const QuestDefinition quest006 = QuestDefinition(
    questId: 'cherie_quest_006',
    npcId: 'cherie',
    version: 1,
    steps: <QuestStepDefinition>[
      QuestStepDefinition(step: 1, locationId: 'city_mall_gift_shop_office'),
      QuestStepDefinition(step: 2, locationId: 'city_mall_gift_shop_office'),
      QuestStepDefinition(step: 3, locationId: 'city_mall_gift_shop_office'),
    ],
  );

  static const List<QuestDefinition> all = <QuestDefinition>[
    quest003,
    quest004,
    quest005,
    quest006,
  ];
}
//kukg