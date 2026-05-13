import '../models/npc_model.dart';
import '../services/game_world_state.dart';
import '../npcs/cherie/cherie_quests.dart';
import '../npcs/mom/mom_quest001.dart';
import '../npcs/den/den_events.dart';
import '../npcs/sem/sem_events.dart';

/// Ідентифікатори для [NpcProfileQuestLine.cheatId] і [NpcQuestCheats.setQuestCompleted].
abstract final class NpcProfileQuestCheatId {
  NpcProfileQuestCheatId._();

  static const semParentsTalk = 'sem_parents_talk';
  static const spyParents = 'spy_parents';
  static const spyCaught = 'spy_caught';
  static const cherieAnimator001 = 'cherie_animator_001';
  static const cherieWarehouse002 = 'cherie_warehouse_002';
  static const cherieMassageTherapist003 = 'cherie_massage_therapist_003';
  static const cherieMasseurLingerie004 = 'cherie_masseur_lingerie_004';
  static const cherieAd005 = 'cherie_ad_005';
  static const cherieRelationship006 = 'cherie_relationship_006';
  static const denHooligan = 'den_hooligan';
  static const momQuest001Beach = 'mom_quest_001_beach';
}

/// Рядок «квест у картці NPC»: заголовок l10n [titleKey] і перевірка виконання.
final class NpcProfileQuestLine {
  const NpcProfileQuestLine({
    required this.titleKey,
    required this.isDone,
    this.cheatId,
    this.counterLineKey,
    this.counterValue,
    this.secondaryCounterLineKey,
    this.secondaryCounterValue,
  });

  final String titleKey;
  final bool Function(GameWorldState world, NPCModel npc) isDone;

  /// Якщо задано — у картці показується перемикач; зміна стану дозволена лише при увімкнених читах.
  final String? cheatId;

  /// Додатковий рядок під статусом (l10n; підставляється `%s` через [counterValue]).
  final String? counterLineKey;
  final int Function(GameWorldState world, NPCModel npc)? counterValue;

  /// Другий лічильник (той самий формат `%s`), наприклад lizun поруч із actor.
  final String? secondaryCounterLineKey;
  final int Function(GameWorldState world, NPCModel npc)? secondaryCounterValue;
}

/// Квести, що показуються в профілі конкретного NPC (перемикач активний лише при увімкнених читах).
List<NpcProfileQuestLine> npcProfileQuestLinesFor(String npcId) {
  switch (npcId) {
    case kSemNpcId:
      return [
        NpcProfileQuestLine(
          titleKey: 'npc_quest_sem_parents_talk',
          isDone: (_, npc) => SemParentsTalkEvent.isComplete(npc),
          cheatId: NpcProfileQuestCheatId.semParentsTalk,
        ),
        NpcProfileQuestLine(
          titleKey: 'npc_quest_spy_parents',
          isDone: (w, _) => w.spyOnSemParentsDone,
          cheatId: NpcProfileQuestCheatId.spyParents,
        ),
        NpcProfileQuestLine(
          titleKey: 'npc_quest_spy_caught',
          isDone: (w, _) => w.danielleSpyCaughtConfrontationDone,
          cheatId: NpcProfileQuestCheatId.spyCaught,
        ),
      ];
    case 'danielle':
    case 'korish_father':
      return [
        NpcProfileQuestLine(
          titleKey: 'npc_quest_spy_parents',
          isDone: (w, _) => w.spyOnSemParentsDone,
          cheatId: NpcProfileQuestCheatId.spyParents,
        ),
        NpcProfileQuestLine(
          titleKey: 'npc_quest_spy_caught',
          isDone: (w, _) => w.danielleSpyCaughtConfrontationDone,
          cheatId: NpcProfileQuestCheatId.spyCaught,
        ),
      ];
    case 'cherie':
      return [
        NpcProfileQuestLine(
          titleKey: 'npc_quest_cherie_animator_001',
          isDone: (_, npc) =>
              npc.id == 'cherie' &&
              npc.getVar(CherieQuest001.giftShopWorkAnimatorVar) == true,
          cheatId: NpcProfileQuestCheatId.cherieAnimator001,
          counterLineKey: 'profile_cherie_animator_shifts_count',
          counterValue: (w, _) => w.giftShopAnimatorShiftsCompleted,
        ),
        NpcProfileQuestLine(
          titleKey: 'npc_quest_cherie_warehouse_002',
          isDone: (_, npc) =>
              npc.id == 'cherie' &&
              npc.getVar(CherieQuest002.npcVarComplete) == true,
          cheatId: NpcProfileQuestCheatId.cherieWarehouse002,
        ),
        NpcProfileQuestLine(
          titleKey: 'npc_quest_cherie_massage_003',
          isDone: (_, npc) =>
              npc.id == 'cherie' && CherieQuest003.isUnlocked(npc),
          cheatId: NpcProfileQuestCheatId.cherieMassageTherapist003,
        ),
        NpcProfileQuestLine(
          titleKey: 'npc_quest_cherie_masseur_004',
          isDone: (_, npc) =>
              npc.id == 'cherie' &&
              CherieQuest004.isLingerieContractDone(npc),
          cheatId: NpcProfileQuestCheatId.cherieMasseurLingerie004,
          counterLineKey: 'profile_cherie_masseur_counter',
          counterValue: (_, npc) => CherieQuest004.readMasseur(npc),
        ),
        NpcProfileQuestLine(
          titleKey: 'npc_quest_cherie_ad_005',
          isDone: (w, _) =>
              w.cherieQuest005Actor >= CherieQuest005.completeActorThreshold,
          cheatId: NpcProfileQuestCheatId.cherieAd005,
          counterLineKey: 'profile_cherie_quest005_actor',
          counterValue: (w, _) => w.cherieQuest005Actor,
          secondaryCounterLineKey: 'profile_cherie_quest005_lizun',
          secondaryCounterValue: (w, _) => w.cherieQuest005Lizun,
        ),
        NpcProfileQuestLine(
          titleKey: 'npc_quest_cherie_relationship_006',
          isDone: (w, _) => w.cherieQuest006Complete,
          cheatId: NpcProfileQuestCheatId.cherieRelationship006,
        ),
      ];
    case 'den':
      return [
        NpcProfileQuestLine(
          titleKey: 'npc_quest_den_hooligan',
          isDone: (_, npc) => isDenHooliganQuestComplete(npc),
          cheatId: NpcProfileQuestCheatId.denHooligan,
        ),
      ];
    case 'mom':
      return [
        NpcProfileQuestLine(
          titleKey: 'npc_quest_mom_beach_001',
          isDone: (_, npc) =>
              npc.id == 'mom' && MomQuest001.isComplete(npc),
          cheatId: NpcProfileQuestCheatId.momQuest001Beach,
          counterLineKey: 'profile_mom_quest001_beach',
          counterValue: (w, _) => w.momQuest001Beach,
        ),
      ];
    default:
      return const [];
  }
}
