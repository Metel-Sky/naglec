import '../../data/npc_interaction_types.dart';
import '../../services/game_world_state.dart';
import '../../services/npc_service.dart';
import '../../services/service_locator.dart';
import 'juniper_npc.dart';

/// Розмова з Juniper після першого «палива» (palivo ≥ 1).
abstract final class JuniperPalivoApologyTalk {
  JuniperPalivoApologyTalk._();

  static const String l10nBtn = 'juniper_palivo_apology_btn';
  static const String l10nDialogue = 'juniper_palivo_apology_dialogue';

  static const int influenceReward = 10;
  static const int lustReward = 10;
  static const int behaviorReward = 10;
  static const int relationshipReward = 15;
  static const int arousalReward = 15;

  static bool canShowButton(GameWorldState world) =>
      world.palivo >= 1 && !world.juniperPalivoApologyTalkDone;

  static void markDone(GameWorldState world) {
    world.juniperPalivoApologyTalkDone = true;
  }

  static void applyRewards() {
    final npc = sl<NPCService>().npcById(kJuniperNpcId);
    if (npc == null) return;
    npc.changeInfluence(influenceReward);
    npc.changeLust(lustReward);
    npc.changeBehavior(behaviorReward);
    npc.addRelationship(relationshipReward.toDouble());
    npc.changeArousal(arousalReward);
  }
}

/// Стандартні дії без «Подарувати».
const List<NpcActionTemplate> juniperInteractionActions = [
  NpcActionTemplate(
    label: 'Поговорити',
    lust: 0.0,
    relationship: 2.0,
    behavior: 0.0,
    dialogueL10nKey: 'npc_ask_how_are_you_dialogue',
  ),
  NpcActionTemplate(
    label: 'Комплімент',
    lust: 0.0,
    relationship: 3.0,
    behavior: 1.0,
    dialogueL10nKey: 'npc_compliment_dialogue',
  ),
  NpcActionTemplate(
    label: 'Пожартувати',
    relThreshold: 500.0,
    lustIfLow: 1.0,
    lustIfHigh: 1.0,
    relIfLow: 5.0,
    relIfHigh: 3.0,
    behIfLow: 1.0,
    behIfHigh: 1.0,
    dialogueL10nKey: 'npc_joke_dialogue',
  ),
];

/// Взаємодії Juniper — без «Фінанси» та «Подарувати».
List<NpcInteractionSlot> get juniperInteractionSlots => [
      NpcInteractionSlot(
        npcId: 'juniper',
        location: '',
        hourStart: 0,
        hourEnd: 24,
        actions: juniperInteractionActions,
      ),
    ];
