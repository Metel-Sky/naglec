// ignore_for_file: public_member_api_docs

import '../../data/locations_room_data.dart';
import '../../models/npc_model.dart';
import '../../services/game_world_state.dart';
import '../../services/npc_service.dart';
import 'mom_quest001.dart';

final class MomEvent002Patch {
  const MomEvent002Patch({
    required this.newsL10nKey,
    this.imagePath,
  });

  final String newsL10nKey;
  final String? imagePath;
}

enum MomEvent002PayVariant { autoCash, choice, noMoney }

/// EVENT: mom_event_002 — «почистити басейн» (багаторазовий івент).
abstract final class MomEvent002Pool {
  MomEvent002Pool._();

  static const String eventId = 'mom_event_002';
  static const String cleanPoolImage = 'lib/assets/gg/clean_pool.jpg';
  static const int paymentAmount = 50;
  static const int minPaidForChoiceUnlock = 5;

  static const String resultPaidL10nKey = 'mom_event_002_step03_result_paid';
  static const String resultDebtL10nKey = 'mom_event_002_step03_result_debt';

  static const int mondayIndex = 0;
  static const int thursdayIndex = 3;

  static const Set<int> eventWeekdays = {mondayIndex, thursdayIndex};

  static bool isEventWeekday(int weekdayIndex) =>
      eventWeekdays.contains(weekdayIndex);

  static bool isKitchenScheduleHour(int hour) => hour == 7 || hour == 21;

  static bool isMomOnKitchen({
    required NPCService npcService,
    required NPCModel mom,
    required int hour,
    required int weekdayIndex,
  }) {
    return npcService.getCurrentLocationId(mom, hour, weekdayIndex) ==
        LocationsData.kitchen;
  }

  static String weekKey(DateTime gameDate) =>
      MomQuest001.gameWeekMondayKey(gameDate);

  static bool slotUsedThisWeek({
    required GameWorldState world,
    required int weekdayIndex,
    required String weekKey,
  }) {
    if (weekdayIndex == mondayIndex) {
      return world.momPoolMonWeekKey == weekKey;
    }
    if (weekdayIndex == thursdayIndex) {
      return world.momPoolThuWeekKey == weekKey;
    }
    return true;
  }

  static void markSlotUsed({
    required GameWorldState world,
    required int weekdayIndex,
    required String weekKey,
  }) {
    if (weekdayIndex == mondayIndex) {
      world.momPoolMonWeekKey = weekKey;
    } else if (weekdayIndex == thursdayIndex) {
      world.momPoolThuWeekKey = weekKey;
    }
  }

  static bool isActiveMidFlow(GameWorldState world) {
    return world.momEvent002Step >= 1 && world.momEvent002Step <= 3;
  }

  static bool hasAcceptedOffer(GameWorldState world) =>
      world.momPoolEventActive;

  static bool hasPendingPay(GameWorldState world) =>
      world.momPoolCleanPendingPay;

  static bool blocksOtherMomFlows(GameWorldState world) =>
      isActiveMidFlow(world) ||
      hasAcceptedOffer(world) ||
      hasPendingPay(world);

  static bool canStartKitchenOffer({
    required GameWorldState world,
    required NPCModel? mom,
    required NPCService npcService,
    required int weekdayIndex,
    required int hour,
    required String currentZone,
    required bool isInsideRoom,
    required String currentRoom,
    required DateTime gameDate,
  }) {
    if (MomQuest001.isActiveMidFlow(world)) return false;
    if (isActiveMidFlow(world)) return false;
    if (hasAcceptedOffer(world)) return false;
    if (hasPendingPay(world)) return false;
    if (!isEventWeekday(weekdayIndex)) return false;
    if (!isKitchenScheduleHour(hour)) return false;
    if (currentZone != 'HOME' || !isInsideRoom) return false;
    if (LocationsData.migrateLegacyRoomId(currentRoom) !=
        LocationsData.kitchen) {
      return false;
    }
    if (mom == null || mom.id != 'mom') return false;
    if (!isMomOnKitchen(
      npcService: npcService,
      mom: mom,
      hour: hour,
      weekdayIndex: weekdayIndex,
    )) {
      return false;
    }
    final wk = weekKey(gameDate);
    if (slotUsedThisWeek(
      world: world,
      weekdayIndex: weekdayIndex,
      weekKey: wk,
    )) {
      return false;
    }
    return true;
  }

  static bool canStartKitchenPayment({
    required GameWorldState world,
    required String currentZone,
    required bool isInsideRoom,
    required String currentRoom,
  }) {
    if (!hasPendingPay(world)) return false;
    if (isActiveMidFlow(world)) return false;
    if (currentZone != 'HOME' || !isInsideRoom) return false;
    return LocationsData.migrateLegacyRoomId(currentRoom) ==
        LocationsData.kitchen;
  }

  static bool canShowYardCleanButton({
    required GameWorldState world,
    required String currentZone,
    required bool isInsideRoom,
    required String currentRoom,
  }) {
    if (!hasAcceptedOffer(world)) return false;
    if (hasPendingPay(world)) return false;
    if (world.momEvent002Step != 0) return false;
    if (currentZone != 'HOME' || !isInsideRoom) return false;
    return LocationsData.migrateLegacyRoomId(currentRoom) ==
        LocationsData.yard;
  }

  static bool isScriptedDialogActive({
    required GameWorldState world,
    required String currentZone,
    required bool isInsideRoom,
    required String currentRoom,
  }) {
    final s = world.momEvent002Step;
    if (s <= 0) return false;
    if (currentZone != 'HOME' || !isInsideRoom) return false;
    final r = LocationsData.migrateLegacyRoomId(currentRoom);
    if (s == 1 || s == 3) return r == LocationsData.kitchen;
    if (s == 2) return r == LocationsData.yard;
    return false;
  }

  static bool isLocationValidForActiveStep({
    required GameWorldState world,
    required String currentZone,
    required bool isInsideRoom,
    required String currentRoom,
  }) {
    return isScriptedDialogActive(
      world: world,
      currentZone: currentZone,
      isInsideRoom: isInsideRoom,
      currentRoom: currentRoom,
    );
  }

  static MomEvent002PayVariant payVariant({
    required NPCModel mom,
    required GameWorldState world,
  }) {
    if (mom.money >= paymentAmount) {
      if (world.momPoolPayOrDebtChoiceUnlocked) {
        return MomEvent002PayVariant.choice;
      }
      return MomEvent002PayVariant.autoCash;
    }
    return MomEvent002PayVariant.noMoney;
  }

  static String payNewsL10nKey(MomEvent002PayVariant variant) {
    switch (variant) {
      case MomEvent002PayVariant.autoCash:
        return 'mom_event_002_step03_pay_news';
      case MomEvent002PayVariant.choice:
        return 'mom_event_002_step03_choice_news';
      case MomEvent002PayVariant.noMoney:
        return 'mom_event_002_step03_no_money_news';
    }
  }

  static MomEvent002Patch patchForPresentationStep(int step) {
    switch (step) {
      case 1:
        return const MomEvent002Patch(
          newsL10nKey: 'mom_event_002_step01_news',
        );
      case 2:
        return const MomEvent002Patch(
          newsL10nKey: 'mom_event_002_step02_news',
          imagePath: cleanPoolImage,
        );
      case 3:
        return const MomEvent002Patch(
          newsL10nKey: 'mom_event_002_step03_pay_news',
        );
      default:
        return const MomEvent002Patch(
          newsL10nKey: 'mom_event_002_step01_news',
        );
    }
  }

  static MomEvent002Patch patchForPaymentStep(MomEvent002PayVariant variant) {
    return MomEvent002Patch(
      newsL10nKey: payNewsL10nKey(variant),
    );
  }

  static void applyCashPayment({
    required NPCModel mom,
    required GameWorldState world,
    required void Function(int amount) changePlayerMoney,
  }) {
    if (mom.money < paymentAmount) return;
    mom.changeMoney(-paymentAmount);
    changePlayerMoney(paymentAmount);
    world.momPoolCleanPaidCount++;
    if (world.momPoolCleanPaidCount >= minPaidForChoiceUnlock) {
      world.momPoolPayOrDebtChoiceUnlocked = true;
    }
  }

  static void applyDebt(GameWorldState world) {
    world.momOwesGgCount++;
  }

  static void closeCurrentSlot({
    required GameWorldState world,
    required int weekdayIndex,
    required String weekKey,
  }) {
    markSlotUsed(
      world: world,
      weekdayIndex: weekdayIndex,
      weekKey: weekKey,
    );
    world.momPoolCleanPendingPay = false;
    world.momPoolEventActive = false;
    world.momPoolEventSlotWeekday = -1;
    world.momPoolEventSlotWeekKey = null;
    world.momEvent002Step = 0;
  }

  static void abortAbandoned(GameWorldState world) {
    world.momEvent002Step = 0;
  }

  /// Чит «винна послугу»: ГG уже почистив, на кухні — оплата / борг.
  static bool isCheatOwesPendingPay(GameWorldState world) =>
      world.momPoolCleanPendingPay;

  static void applyCheatCleanedMomOwes({
    required GameWorldState world,
    required DateTime gameDate,
    required int weekdayIndex,
  }) {
    world.momPoolCleanPendingPay = true;
    world.momPoolEventActive = false;
    world.momEvent002Step = 0;
    world.momPoolEventSlotWeekday =
        eventWeekdays.contains(weekdayIndex) ? weekdayIndex : mondayIndex;
    world.momPoolEventSlotWeekKey = weekKey(gameDate);
    world.momEvent002PendingKitchenRecheck = true;
  }

  /// Чит «невинна»: скидання для нової пропозиції в Пн/Чт.
  static void resetCheatForFreshOffer(GameWorldState world) {
    world.momPoolCleanPendingPay = false;
    world.momPoolEventActive = false;
    world.momEvent002Step = 0;
    world.momPoolEventSlotWeekday = -1;
    world.momPoolEventSlotWeekKey = null;
    world.momPoolMonWeekKey = null;
    world.momPoolThuWeekKey = null;
    world.momEvent002PendingKitchenRecheck = true;
  }
}
