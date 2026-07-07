import '../data/npc_profile_quests_registry.dart';
import '../npcs/cherie/cherie_quests.dart';
import '../npcs/mom/mom_quest001.dart';
import '../npcs/mom/mom_event002_pool.dart';
import '../npcs/piper/piper_quests.dart';
import '../npcs/den/den_events.dart';
import '../npcs/danielle/danielle_spy_parents_quest.dart';
import '../npcs/sem/sem_events.dart';
import '../npcs/sem/sem_quests.dart';
import '../npcs/juniper/juniper_npc.dart';
import '../npcs/juniper/juniper_quest_001_kompromat.dart';
import '../models/item_model.dart';
import '../models/npc_model.dart';
import '../services/game_world_state.dart';
import '../services/inventory_controller.dart';
import '../services/npc_service.dart';
import '../services/player_stats_controller.dart';
import '../services/service_locator.dart';
import '../services/game_time_controller.dart';

/// Логіка читів для квестів, прив’язаних до NPC / світу (перемикачі в картці NPC).
abstract final class NpcQuestCheats {
  NpcQuestCheats._();

  /// Стати й предмети, яких зазвичай вистачає, щоб пройти cherie_quest_002.
  static void _applyCherieQuest002CheatCompletionPlayerBoost(
    PlayerStatsController stats,
    InventoryController inventory,
  ) {
    final p = stats.player;
    final needStr =
        CherieQuest002.cheatCompletionMinPhysicalFitness - p.physical_fitness;
    if (needStr > 0) stats.changePhysicalFitness(needStr);
    final needFight =
        CherieQuest002.cheatCompletionMinFighting - p.fighting;
    if (needFight > 0) stats.changeFighting(needFight);
    final needMassage = CherieQuest002.cheatCompletionMinMassageExperience -
        p.massage_experience;
    if (needMassage > 0) stats.changeMassageExperience(needMassage);
    if (inventory.count(CherieQuest002.aromaOilItemId) < 1) {
      inventory.addItem(GameItems.massageAromaOil);
    }
  }

  /// Івент «Запитати Sem про батьків» позначити виконаним.
  static void completeSemParentsTalk(NPCModel? sem) {
    if (sem == null || sem.id != kSemNpcId) return;
    SemParentsTalkEvent.markComplete(sem);
  }

  /// Квест spyOnSemParents: повне завершення з тими самими наслідками, що після 3-го відео.
  static void completeSpyOnSemParents(
    GameWorldState world,
    PlayerStatsController stats,
    NPCService npcService,
  ) {
    world.spyOnSemParentsDone = true;
    DanielleSpyParentsQuest.applySpyOnSemParentsTier3Rewards(
      world,
      stats,
      npcService.allNPCs,
    );
  }

  /// Скинути spyOnSemParents і симетрично відкотити нагороди ГГ / Danielle.
  static void resetSpyOnSemParents(
    GameWorldState world,
    PlayerStatsController stats,
    NPCService npcService,
  ) {
    if (world.spyOnSemParentsDone) {
      final d = world.spyOnSemParentsPlayerArousalDeltaApplied;
      if (d != null && d > 0) {
        stats.changeArousal(-d);
      }
      world.spyOnSemParentsPlayerArousalDeltaApplied = null;
      stats.changeStealthMode(-2);
      DanielleSpyParentsQuest.revertDanielleCompletionStatBonuses(
        npcService.allNPCs,
      );
    }
    world.spyOnSemParentsDone = false;
    world.spyOnSemParentsParentsRoomPeekDone = false;
    world.spyOnSemParentsSpottedByDanielle = false;
    world.danielleSpyCaughtConfrontationDone = false;
    world.danielleSpyCaughtConfrontationCount = 0;
  }

  /// Скинути діалог про батьків у Sem.
  static void resetSemParentsTalk(NPCModel? sem) {
    if (sem == null || sem.id != kSemNpcId) return;
    sem.setVar(SemEventVars.talkedAboutParents, false);
  }

  /// Встановити квест у стан «виконано» / «не виконано» (профіль NPC, перемикачі при увімкнених читах).
  static void setQuestCompleted(
    String cheatId,
    bool completed,
    GameWorldState world,
    PlayerStatsController stats,
    NPCService npcService,
    NPCModel profileNpc,
  ) {
    switch (cheatId) {
      case NpcProfileQuestCheatId.semParentsTalk:
        final sem =
            profileNpc.id == kSemNpcId ? profileNpc : findSemNpc(npcService.allNPCs);
        if (completed) {
          completeSemParentsTalk(sem);
        } else {
          resetSemParentsTalk(sem);
        }
        break;
      case NpcProfileQuestCheatId.spyParents:
        if (completed) {
          if (!world.spyOnSemParentsDone) {
            completeSpyOnSemParents(world, stats, npcService);
          }
        } else {
          resetSpyOnSemParents(world, stats, npcService);
        }
        break;
      case NpcProfileQuestCheatId.spyCaught:
        world.danielleSpyCaughtConfrontationDone = completed;
        if (!completed) {
          world.danielleSpyCaughtConfrontationCount = 0;
        } else if (world.danielleSpyCaughtConfrontationCount < 1) {
          world.danielleSpyCaughtConfrontationCount = 1;
        }
        break;
      case NpcProfileQuestCheatId.cherieAnimator001:
        if (profileNpc.id != 'cherie') break;
        if (completed) {
          CherieQuest001.applyQuestOneAccepted(
            cherie: profileNpc,
            world: world,
            now: DateTime.now(),
          );
        } else {
          profileNpc.setVar(CherieQuest001.giftShopWorkAnimatorVar, false);
          world.giftShopAnimatorJobOfferPending = false;
          world.giftShopAnimatorPendingFinishDateKey = null;
          world.cherieAnimatorIntroStep = 0;
          world.cherieAnimatorIntroTc2SlotKeyStash = null;
          world.cherieAnimatorIntroTc2TipsStash = null;
          profileNpc.setVar(CherieQuest002.npcVarComplete, false);
          profileNpc.setVar(CherieQuest002.phoneUnlockedVar, false);
          profileNpc.setVar(CherieQuest002.npcVarMassageLegsDone, false);
          profileNpc.setVar(CherieQuest003.npcVarMassageTherapist, false);
          world.cherieQuest002Step = 0;
          world.cherieQuest003Step = 0;
          world.cherieQuest004Step = 0;
          world.cherieQuest004Branch = 0;
          world.cherieQuest004LegsMassagePhase = false;
          CherieQuest005.resetSession(world);
          world.cherieQuest005Actor = 0;
          world.cherieQuest005Lizun = 0;
          world.cherieQuest005Complete = false;
          CherieQuest006.resetSession(world);
          world.cherieQuest006Complete = false;
          world.cherieRelationshipNewStage = false;
          profileNpc.setVar(CherieQuest004.npcVarMasseur, 0);
          profileNpc.setVar(CherieQuest004.npcVarLingerieContract, false);
          world.cherieQuest002WarehouseWhoAsked = false;
          world.cherieQuest002EpilogueWeeksRemaining = 0;
          world.cherieQuest002EpilogueTickDateKey = null;
          world.cherieQuest002SundayBlocked = false;
          world.cherieQuest002MassageFinishOnlyNextHallVisit = false;
          world.cherieQuest002MassageLegsCooldownMondays = 0;
          world.cherieQuest002MassageCooldownMondayTickKey = null;
          world.cherieQuest002MassageLegsReturnPending = false;
        }
        break;
      case NpcProfileQuestCheatId.cherieWarehouse002:
        if (profileNpc.id != 'cherie') break;
        if (completed) {
          _applyCherieQuest002CheatCompletionPlayerBoost(
            stats,
            sl<InventoryController>(),
          );
          profileNpc.setVar(CherieQuest002.npcVarComplete, true);
          profileNpc.setVar(CherieQuest002.phoneUnlockedVar, true);
          world.cherieQuest002Step = 0;
          world.cherieQuest002WarehouseWhoAsked = false;
          world.cherieQuest002EpilogueWeeksRemaining = 0;
          world.cherieQuest002EpilogueTickDateKey = null;
        } else {
          profileNpc.setVar(CherieQuest002.npcVarComplete, false);
          profileNpc.setVar(CherieQuest002.phoneUnlockedVar, false);
          profileNpc.setVar(CherieQuest002.npcVarMassageLegsDone, false);
          profileNpc.setVar(CherieQuest003.npcVarMassageTherapist, false);
          world.cherieQuest002Step = 0;
          world.cherieQuest003Step = 0;
          world.cherieQuest004Step = 0;
          world.cherieQuest004Branch = 0;
          world.cherieQuest004LegsMassagePhase = false;
          CherieQuest005.resetSession(world);
          world.cherieQuest005Actor = 0;
          world.cherieQuest005Lizun = 0;
          world.cherieQuest005Complete = false;
          CherieQuest006.resetSession(world);
          world.cherieQuest006Complete = false;
          world.cherieRelationshipNewStage = false;
          profileNpc.setVar(CherieQuest004.npcVarMasseur, 0);
          profileNpc.setVar(CherieQuest004.npcVarLingerieContract, false);
          world.cherieQuest002WarehouseWhoAsked = false;
          world.cherieQuest002EpilogueWeeksRemaining = 0;
          world.cherieQuest002EpilogueTickDateKey = null;
          world.cherieQuest002SundayBlocked = false;
          world.cherieQuest002MassageFinishOnlyNextHallVisit = false;
          world.cherieQuest002MassageLegsCooldownMondays = 0;
          world.cherieQuest002MassageCooldownMondayTickKey = null;
          world.cherieQuest002MassageLegsReturnPending = false;
        }
        break;
      case NpcProfileQuestCheatId.cherieMassageTherapist003:
        if (profileNpc.id != 'cherie') break;
        if (completed) {
          profileNpc.setVar(CherieQuest003.npcVarMassageTherapist, true);
          world.cherieQuest003Step = 0;
        } else {
          profileNpc.setVar(CherieQuest003.npcVarMassageTherapist, false);
          world.cherieQuest003Step = 0;
          world.cherieQuest004Step = 0;
          world.cherieQuest004Branch = 0;
          world.cherieQuest004LegsMassagePhase = false;
          CherieQuest005.resetSession(world);
          world.cherieQuest005Actor = 0;
          world.cherieQuest005Lizun = 0;
          world.cherieQuest005Complete = false;
          CherieQuest006.resetSession(world);
          world.cherieQuest006Complete = false;
          world.cherieRelationshipNewStage = false;
          profileNpc.setVar(CherieQuest004.npcVarMasseur, 0);
          profileNpc.setVar(CherieQuest004.npcVarLingerieContract, false);
        }
        break;
      case NpcProfileQuestCheatId.cherieMasseurLingerie004:
        if (profileNpc.id != 'cherie') break;
        if (completed) {
          profileNpc.setVar(CherieQuest004.npcVarLingerieContract, true);
          world.cherieQuest004Step = 0;
          world.cherieQuest004Branch = 0;
          world.cherieQuest004LegsMassagePhase = false;
        } else {
          profileNpc.setVar(CherieQuest004.npcVarLingerieContract, false);
          world.cherieQuest004Step = 0;
          world.cherieQuest004Branch = 0;
          world.cherieQuest004LegsMassagePhase = false;
          CherieQuest005.resetSession(world);
          world.cherieQuest005Actor = 0;
          world.cherieQuest005Lizun = 0;
          world.cherieQuest005Complete = false;
          CherieQuest006.resetSession(world);
          world.cherieQuest006Complete = false;
          world.cherieRelationshipNewStage = false;
        }
        break;
      case NpcProfileQuestCheatId.cherieAd005:
        if (profileNpc.id != 'cherie') break;
        if (completed) {
          world.cherieQuest005Actor = CherieQuest005.completeActorThreshold;
          world.cherieQuest005Complete = true;
        } else {
          CherieQuest005.resetSession(world);
          world.cherieQuest005Actor = 0;
          world.cherieQuest005Lizun = 0;
          world.cherieQuest005Complete = false;
          CherieQuest006.resetSession(world);
          world.cherieQuest006Complete = false;
          world.cherieRelationshipNewStage = false;
        }
        break;
      case NpcProfileQuestCheatId.cherieRelationship006:
        if (profileNpc.id != 'cherie') break;
        if (completed) {
          CherieQuest006.resetSession(world);
          world.cherieQuest006Complete = true;
          world.cherieRelationshipNewStage = true;
        } else {
          CherieQuest006.resetSession(world);
          world.cherieQuest006Complete = false;
          world.cherieRelationshipNewStage = false;
        }
        break;
      case NpcProfileQuestCheatId.denHooligan:
        if (profileNpc.id != 'den') break;
        if (completed) {
          profileNpc.setVar(DenEventVars.firstMeetingDone, true);
          profileNpc.setVar(DenEventVars.secondMeeting, true);
          profileNpc.setVar(DenEventVars.thirdMeeting, true);
          profileNpc.setVar(DenEventVars.hooligan, true);
        } else {
          profileNpc.setVar(DenEventVars.firstMeetingDone, false);
          profileNpc.setVar(DenEventVars.introduction, false);
          profileNpc.setVar(DenEventVars.secondMeeting, false);
          profileNpc.setVar(DenEventVars.secondChainDone, false);
          profileNpc.setVar(DenEventVars.thirdMeeting, false);
          profileNpc.setVar(DenEventVars.hooligan, false);
        }
        break;
      case NpcProfileQuestCheatId.momQuest001Beach:
        if (profileNpc.id != 'mom') break;
        if (completed) {
          profileNpc.setVar(MomQuest001.npcVarComplete, true);
          world.momQuest001InvitationAccepted = true;
          world.momQuest001Beach = 4;
          world.momQuest001Step = 0;
          world.momQuest001LastBeachTripWeekKey = null;
        } else {
          profileNpc.setVar(MomQuest001.npcVarComplete, false);
          world.momQuest001InvitationAccepted = false;
          world.momQuest001Beach = 0;
          world.momQuest001Step = 0;
          world.momQuest001LastBeachTripWeekKey = null;
        }
        break;
      case NpcProfileQuestCheatId.momOwesGgService:
        if (profileNpc.id != 'mom') break;
        if (completed) {
          final time = sl<GameTimeController>();
          MomEvent002Pool.applyCheatCleanedMomOwes(
            world: world,
            gameDate: time.dateTime,
            weekdayIndex: time.weekdayIndex,
          );
        } else {
          MomEvent002Pool.resetCheatForFreshOffer(world);
        }
        break;
      case NpcProfileQuestCheatId.piperBadGrades001:
        if (profileNpc.id != 'piper') break;
        if (completed) {
          final time = sl<GameTimeController>();
          PiperQuest001.applyCheatActiveCrisis(
            world: world,
            gameDate: time.dateTime,
          );
        } else {
          PiperQuest001.resetCheat(world);
        }
        break;
      case NpcProfileQuestCheatId.piperPunishment1:
        if (profileNpc.id != 'piper') break;
        if (completed) {
          PiperQuest001.resetCheatGgPunishment(world);
          PiperQuest001.applyCheatPunishment(world: world, crisisN: 1);
        } else {
          PiperQuest001.resetCheatPunishment(world, 1);
        }
        break;
      case NpcProfileQuestCheatId.piperPunishment2:
        if (profileNpc.id != 'piper') break;
        if (completed) {
          PiperQuest001.resetCheatGgPunishment(world);
          PiperQuest001.applyCheatPunishment(world: world, crisisN: 2);
        } else {
          PiperQuest001.resetCheatPunishment(world, 2);
        }
        break;
      case NpcProfileQuestCheatId.piperPunishment3:
        if (profileNpc.id != 'piper') break;
        if (completed) {
          PiperQuest001.resetCheatGgPunishment(world);
          PiperQuest001.applyCheatPunishment(world: world, crisisN: 3);
        } else {
          PiperQuest001.resetCheatPunishment(world, 3);
        }
        break;
      case NpcProfileQuestCheatId.piperGgPunishment:
        if (profileNpc.id != 'piper') break;
        if (completed) {
          PiperQuest001.resetCheatPunishment(world, 1);
          PiperQuest001.resetCheatPunishment(world, 2);
          PiperQuest001.resetCheatPunishment(world, 3);
          PiperQuest001.applyCheatGgPunishment(world: world);
        } else {
          PiperQuest001.resetCheatGgPunishment(world);
        }
        break;
      case NpcProfileQuestCheatId.juniperIntro:
        if (profileNpc.id != kJuniperNpcId) break;
        if (completed) {
          final dateKey = sl<GameTimeController>().onlyDate;
          SemQuest001.applyIntroDebugReady(world, dateKey);
          profileNpc.setVar('phone_unlocked', false);
        } else {
          SemQuest001.resetIntroDebugArc(world);
          profileNpc.setVar('phone_unlocked', false);
        }
        break;
      case NpcProfileQuestCheatId.juniperMet:
        if (profileNpc.id != kJuniperNpcId) break;
        if (completed) {
          JuniperQuest001.applyCheatMet(world);
        } else {
          JuniperQuest001.resetCheatMet(world);
        }
        break;
      case NpcProfileQuestCheatId.juniperLivingAtSem:
        if (profileNpc.id != kJuniperNpcId) break;
        if (completed) {
          JuniperQuest001.applyCheatLivingAtSem(
            world,
            sl<GameTimeController>().onlyDate,
          );
        } else {
          JuniperQuest001.resetCheatLivingAtSem(world);
        }
        break;
      case NpcProfileQuestCheatId.juniperSemRoomWitness:
        if (profileNpc.id != kJuniperNpcId) break;
        if (completed) {
          JuniperQuest001.applyCheatSemRoomWitness(world);
        } else {
          JuniperQuest001.resetCheatSemRoomWitness(world);
        }
        break;
      case NpcProfileQuestCheatId.juniperSemPalivoTalk:
        if (profileNpc.id != kJuniperNpcId) break;
        if (completed) {
          JuniperQuest001.applyCheatSemPalivoTalk(world);
        } else {
          JuniperQuest001.resetCheatSemPalivoTalk(world);
        }
        break;
      case NpcProfileQuestCheatId.juniperPalivoApologyTalk:
        if (profileNpc.id != kJuniperNpcId) break;
        if (completed) {
          JuniperQuest001.applyCheatJuniperPalivoTalk(world);
        } else {
          JuniperQuest001.resetCheatJuniperPalivoTalk(world);
        }
        break;
      case NpcProfileQuestCheatId.juniperKompromatStep1:
        if (profileNpc.id != kJuniperNpcId) break;
        if (completed) {
          JuniperQuest001.applyCheatKompromatStep1Done(
            world: world,
            npcs: npcService.allNPCs,
            gameDateKey: sl<GameTimeController>().onlyDate,
          );
        } else {
          JuniperQuest001.resetCheatKompromatStep1Done(world);
        }
        break;
      case NpcProfileQuestCheatId.juniperKompromatSkipFiveDays:
        if (profileNpc.id != kJuniperNpcId) break;
        if (completed) {
          JuniperQuest001.applyCheatSkipFiveDays(
            world: world,
            gameDateKey: sl<GameTimeController>().onlyDate,
          );
        } else {
          JuniperQuest001.resetCheatSkipFiveDays(world);
        }
        break;
      case NpcProfileQuestCheatId.juniperKompromatStep2:
        if (profileNpc.id != kJuniperNpcId) break;
        if (completed) {
          JuniperQuest001.applyCheatKompromatStep2Done(
            world: world,
            npcs: npcService.allNPCs,
            gameDateKey: sl<GameTimeController>().onlyDate,
          );
        } else {
          JuniperQuest001.resetCheatKompromatStep2Done(world);
        }
        break;
      case NpcProfileQuestCheatId.juniperKompromatSkipFiveDaysStep3:
        if (profileNpc.id != kJuniperNpcId) break;
        if (completed) {
          JuniperQuest001.applyCheatSkipFiveDaysStep3(
            world: world,
            gameDateKey: sl<GameTimeController>().onlyDate,
          );
        } else {
          JuniperQuest001.resetCheatSkipFiveDaysStep3(world);
        }
        break;
      case NpcProfileQuestCheatId.juniperKompromatStep3:
        if (profileNpc.id != kJuniperNpcId) break;
        if (completed) {
          JuniperQuest001.applyCheatKompromatStep3Done(
            world: world,
            npcs: npcService.allNPCs,
            playerStats: sl<PlayerStatsController>(),
            gameDateKey: sl<GameTimeController>().onlyDate,
          );
        } else {
          JuniperQuest001.resetCheatKompromatStep3Done(world);
        }
        break;
      case NpcProfileQuestCheatId.juniperKompromatSkipThreeDaysStep4:
        if (profileNpc.id != kJuniperNpcId) break;
        if (completed) {
          JuniperQuest001.applyCheatSkipThreeDaysStep4(
            world: world,
            gameDateKey: sl<GameTimeController>().onlyDate,
          );
        } else {
          JuniperQuest001.resetCheatSkipThreeDaysStep4(world);
        }
        break;
      case NpcProfileQuestCheatId.juniperKompromatStep4:
        if (profileNpc.id != kJuniperNpcId) break;
        if (completed) {
          JuniperQuest001.applyCheatKompromatStep4Done(
            world: world,
            npcs: npcService.allNPCs,
            playerStats: sl<PlayerStatsController>(),
            gameDateKey: sl<GameTimeController>().onlyDate,
          );
        } else {
          JuniperQuest001.resetCheatKompromatStep4Done(world);
        }
        break;
    }
  }
}
