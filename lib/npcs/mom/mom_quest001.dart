// ignore_for_file: public_member_api_docs

import '../../data/locations_room_data.dart';
import '../../models/npc_model.dart';
import '../../services/game_world_state.dart';

/// Квест **mom_quest_001** («001 пляж»): зал дому ГГ, вихідні, лічильник beach.
abstract final class MomQuest001 {
  MomQuest001._();

  static const String questId = 'mom_quest_001';
  static const String npcVarComplete = 'mom_quest_001_complete';

  /// Пн / Ср / Пт — [weekdayIndex] 0, 2, 4.
  static const Set<int> inviteWeekdays = {0, 2, 4};

  static const int relTier1 = 500;
  static const int relTier2 = 600;
  static const int relTier3 = 700;
  static const int relTier4 = 800;
  static const int relTier5 = 900;

  static const String zalBookImage = 'lib/assets/npcs/mom/zal_book.png';

  static const String vInvite = 'lib/assets/npcs/mom/video/beach_01_priglos_na_plyazh.webm';
  /// Після кнопки «Йти на пляж» (кроки 5, 10, 15, 20, 27).
  static const String vPrologGoBeach = 'lib/assets/npcs/mom/video/beach_0_prolog.webm';
  /// Інші переходи в ланцюжку (поїздка, «Їхати» → пролог тощо).
  static const String vProlog = 'lib/assets/npcs/mom/video/beach_0_prolog_1.webm';
  static const String vChange02 = 'lib/assets/npcs/mom/video/Beach_02_pereodevalka.webm';
  static const String v03a = 'lib/assets/npcs/mom/video/beach_03_pereodevalka_1.mp4';
  static const String v03b = 'lib/assets/npcs/mom/video/beach_03_pereodevalka_2.mp4';
  static const String v04a = 'lib/assets/npcs/mom/video/beach_04_pereodevalka_1.mp4';
  static const String v04b = 'lib/assets/npcs/mom/video/beach_04_pereodevalka_2.mp4';
  static const String v05a = 'lib/assets/npcs/mom/video/beach_05_pereodevalka_1.mp4';
  static const String v05b = 'lib/assets/npcs/mom/video/beach_05_pereodevalka_2.mp4';
  static const String v06a = 'lib/assets/npcs/mom/video/beach_06_pereodevalka_01.mp4';
  static const String v06b = 'lib/assets/npcs/mom/video/beach_06_pereodevalka_02.mp4';
  static const String v06c = 'lib/assets/npcs/mom/video/Beach_06_pereodevalka_03.webm';
  static const String vFinish = 'lib/assets/npcs/mom/video/Beach_07_finish.webm';

  static bool isComplete(NPCModel? mom) =>
      mom != null && mom.id == 'mom' && mom.getVar(npcVarComplete) == true;

  static bool isActiveMidFlow(GameWorldState world) {
    final s = world.momQuest001Step;
    return s >= 1 && s <= 27;
  }

  /// Найвищий «ярус» відносин 0…5 (5 = ≥900).
  static int tierFromRelationship(double relationship) {
    if (relationship >= relTier5) return 5;
    if (relationship >= relTier4) return 4;
    if (relationship >= relTier3) return 3;
    if (relationship >= relTier2) return 2;
    if (relationship >= relTier1) return 1;
    return 0;
  }

  /// Який ярус сюжету вже відкритий лічильником beach (після запрошення).
  static int maxTierFromBeach(int beach, bool invitationAccepted) {
    if (!invitationAccepted) return 0;
    if (beach <= 0) return 1;
    if (beach == 1) return 2;
    if (beach == 2) return 3;
    if (beach == 3) return 4;
    return 5;
  }

  /// Якщо відносин замало для «верхнього» блоку — грає найвищий блок, на який вистачає і beach, і rel.
  static int effectiveWeekendTier({
    required int beach,
    required bool invitationAccepted,
    required double relationship,
  }) {
    final tr = tierFromRelationship(relationship);
    final tb = maxTierFromBeach(beach, invitationAccepted);
    final m = tr < tb ? tr : tb;
    return m < 0 ? 0 : m;
  }

  /// Перший крок сегмента у залі (вихідні): 2, 6, 11, 16 або 21.
  static int hallWeekendEntryStepForTier(int tier) {
    switch (tier.clamp(0, 5)) {
      case 5:
        return 21;
      case 4:
        return 16;
      case 3:
        return 11;
      case 2:
        return 6;
      case 1:
        return 2;
      default:
        return 0;
    }
  }

  static bool isWeekend(int weekdayIndex) => weekdayIndex == 5 || weekdayIndex == 6;

  /// 0 = понеділок … 6 = неділя (як [GameTimeController.weekdayIndex]), з **календарної** дати.
  /// Якщо гравець міняє лише «день тижня» без дати — використовуйте ручний індекс; для поїздки на пляж беремо дату.
  static int weekdayIndexFromDateTime(DateTime dt) => (dt.weekday + 6) % 7;

  /// Субота/неділя за реальною датою [dt] (узгоджено з [gameWeekMondayKey]).
  static bool isWeekendDateTime(DateTime dt) =>
      dt.weekday == DateTime.saturday || dt.weekday == DateTime.sunday;

  static bool isHallWeekendWindow(int hour) => hour >= 12 && hour <= 14;

  /// Понеділок поточного ігрового тижня `yyyy-MM-dd` (як нічні двері в [HomeDoorAccess]).
  static String gameWeekMondayKey(DateTime gameDate) {
    final daysFromMonday = gameDate.weekday - 1;
    final monday = gameDate.subtract(Duration(days: daysFromMonday));
    return '${monday.year}-${monday.month.toString().padLeft(2, '0')}-${monday.day.toString().padLeft(2, '0')}';
  }

  static bool canStartStep1Weekday({
    required GameWorldState world,
    required NPCModel? mom,
    required int weekdayIndex,
    required int hour,
    required String currentZone,
    required bool isInsideRoom,
    required String currentRoom,
  }) {
    if (mom == null || mom.id != 'mom') return false;
    if (world.momQuest001Step != 0) return false;
    if (world.momQuest001Beach != 0) return false;
    if (world.momQuest001InvitationAccepted) return false;
    if (mom.relationship < relTier1) return false;
    if (!inviteWeekdays.contains(weekdayIndex)) return false;
    if (hour != 20) return false;
    if (currentZone != 'HOME' || !isInsideRoom) return false;
    if (LocationsData.migrateLegacyRoomId(currentRoom) != LocationsData.hall) {
      return false;
    }
    return true;
  }

  static bool shouldPinMomToHallWeekends(GameWorldState world) =>
      world.momQuest001InvitationAccepted;

  static bool isLocationValidMidFlow({
    required GameWorldState world,
    required String currentZone,
  }) {
    if (!isActiveMidFlow(world)) return true;
    return currentZone == 'HOME';
  }

  static MomQuest001Patch patchForPresentationStep(int step) {
    switch (step) {
      case 1:
        return MomQuest001Patch(
          newsL10nKey: 'mom_quest_001_step01_news',
          videoPath: vInvite,
          loopVideo: true,
          closeWhenCompleted: false,
          fullScreen: true,
          imagePath: null,
        );
      case 2:
        return MomQuest001Patch(
          newsL10nKey: 'mom_quest_001_step02_news',
          videoPath: null,
          loopVideo: false,
          closeWhenCompleted: true,
          fullScreen: false,
          imagePath: zalBookImage,
        );
      case 3:
        return MomQuest001Patch(
          newsL10nKey: 'mom_quest_001_step03_news',
          videoPath: vProlog,
          loopVideo: false,
          closeWhenCompleted: false,
          fullScreen: true,
          imagePath: null,
        );
      case 4:
        return MomQuest001Patch(
          newsL10nKey: 'mom_quest_001_step04_news',
          videoPath: vChange02,
          loopVideo: true,
          closeWhenCompleted: false,
          fullScreen: true,
          imagePath: null,
        );
      case 5:
        return MomQuest001Patch(
          newsL10nKey: 'mom_quest_001_step05_news',
          videoPath: vPrologGoBeach,
          loopVideo: false,
          closeWhenCompleted: false,
          fullScreen: true,
          imagePath: null,
        );
      case 6:
        return MomQuest001Patch(
          newsL10nKey: 'mom_quest_001_step06_news',
          videoPath: null,
          loopVideo: false,
          closeWhenCompleted: true,
          fullScreen: false,
          imagePath: zalBookImage,
        );
      case 7:
        return MomQuest001Patch(
          newsL10nKey: 'mom_quest_001_step07_news',
          videoPath: v03a,
          loopVideo: true,
          closeWhenCompleted: false,
          fullScreen: true,
          imagePath: null,
        );
      case 8:
        return MomQuest001Patch(
          newsL10nKey: 'mom_quest_001_step08_news',
          videoPath: vProlog,
          loopVideo: false,
          closeWhenCompleted: false,
          fullScreen: true,
          imagePath: null,
        );
      case 9:
        return MomQuest001Patch(
          newsL10nKey: 'mom_quest_001_step09_news',
          videoPath: v03b,
          loopVideo: true,
          closeWhenCompleted: false,
          fullScreen: true,
          imagePath: null,
        );
      case 10:
        return MomQuest001Patch(
          newsL10nKey: 'mom_quest_001_step10_news',
          videoPath: vPrologGoBeach,
          loopVideo: false,
          closeWhenCompleted: false,
          fullScreen: true,
          imagePath: null,
        );
      case 11:
        return MomQuest001Patch(
          newsL10nKey: 'mom_quest_001_step11_news',
          videoPath: null,
          loopVideo: false,
          closeWhenCompleted: true,
          fullScreen: false,
          imagePath: zalBookImage,
        );
      case 12:
        return MomQuest001Patch(
          newsL10nKey: 'mom_quest_001_step12_news',
          videoPath: v04a,
          loopVideo: true,
          closeWhenCompleted: false,
          fullScreen: true,
          imagePath: null,
        );
      case 13:
        return MomQuest001Patch(
          newsL10nKey: 'mom_quest_001_step13_news',
          videoPath: vProlog,
          loopVideo: false,
          closeWhenCompleted: false,
          fullScreen: true,
          imagePath: null,
        );
      case 14:
        return MomQuest001Patch(
          newsL10nKey: 'mom_quest_001_step14_news',
          videoPath: v04b,
          loopVideo: true,
          closeWhenCompleted: false,
          fullScreen: true,
          imagePath: null,
        );
      case 15:
        return MomQuest001Patch(
          newsL10nKey: 'mom_quest_001_step15_news',
          videoPath: vPrologGoBeach,
          loopVideo: false,
          closeWhenCompleted: false,
          fullScreen: true,
          imagePath: null,
        );
      case 16:
        return MomQuest001Patch(
          newsL10nKey: 'mom_quest_001_step16_news',
          videoPath: null,
          loopVideo: false,
          closeWhenCompleted: true,
          fullScreen: false,
          imagePath: zalBookImage,
        );
      case 17:
        return MomQuest001Patch(
          newsL10nKey: 'mom_quest_001_step17_news',
          videoPath: v05a,
          loopVideo: true,
          closeWhenCompleted: false,
          fullScreen: true,
          imagePath: null,
        );
      case 18:
        return MomQuest001Patch(
          newsL10nKey: 'mom_quest_001_step18_news',
          videoPath: vProlog,
          loopVideo: false,
          closeWhenCompleted: false,
          fullScreen: true,
          imagePath: null,
        );
      case 19:
        return MomQuest001Patch(
          newsL10nKey: 'mom_quest_001_step19_news',
          videoPath: v05b,
          loopVideo: true,
          closeWhenCompleted: false,
          fullScreen: true,
          imagePath: null,
        );
      case 20:
        return MomQuest001Patch(
          newsL10nKey: 'mom_quest_001_step20_news',
          videoPath: vPrologGoBeach,
          loopVideo: false,
          closeWhenCompleted: false,
          fullScreen: true,
          imagePath: null,
        );
      case 21:
        return MomQuest001Patch(
          newsL10nKey: 'mom_quest_001_step21_news',
          videoPath: null,
          loopVideo: false,
          closeWhenCompleted: true,
          fullScreen: false,
          imagePath: zalBookImage,
        );
      case 22:
        return MomQuest001Patch(
          newsL10nKey: 'mom_quest_001_step22_news',
          videoPath: v06a,
          loopVideo: true,
          closeWhenCompleted: false,
          fullScreen: true,
          imagePath: null,
        );
      case 23:
        return MomQuest001Patch(
          newsL10nKey: 'mom_quest_001_step23_news',
          videoPath: vProlog,
          loopVideo: false,
          closeWhenCompleted: false,
          fullScreen: true,
          imagePath: null,
        );
      case 24:
        return MomQuest001Patch(
          newsL10nKey: 'mom_quest_001_step24_news',
          videoPath: v06b,
          loopVideo: true,
          closeWhenCompleted: false,
          fullScreen: true,
          imagePath: null,
        );
      case 25:
        return MomQuest001Patch(
          newsL10nKey: 'mom_quest_001_step25_news',
          videoPath: v06c,
          loopVideo: true,
          closeWhenCompleted: false,
          fullScreen: true,
          imagePath: null,
        );
      case 26:
        return MomQuest001Patch(
          newsL10nKey: 'mom_quest_001_step26_news',
          videoPath: vFinish,
          loopVideo: false,
          closeWhenCompleted: false,
          fullScreen: true,
          imagePath: null,
        );
      case 27:
        return MomQuest001Patch(
          newsL10nKey: 'mom_quest_001_step27_news',
          videoPath: vPrologGoBeach,
          loopVideo: false,
          closeWhenCompleted: false,
          fullScreen: true,
          imagePath: null,
        );
      default:
        return MomQuest001Patch(
          newsL10nKey: 'mom_quest_001_step01_news',
          videoPath: null,
          loopVideo: false,
          closeWhenCompleted: true,
          fullScreen: false,
          imagePath: null,
        );
    }
  }

  static void abortAbandoned(GameWorldState world) {
    world.momQuest001Step = 0;
  }

  static void applyStep5Rewards(NPCModel mom) {
    mom.addRelationship(25);
    mom.changeBehavior(25);
    mom.changeArousal(25);
  }

  static void applyLaterTripRewards(NPCModel mom) {
    mom.addRelationship(25);
    mom.changeBehavior(25);
    mom.changeArousal(35);
  }
}

final class MomQuest001Patch {
  const MomQuest001Patch({
    required this.newsL10nKey,
    required this.videoPath,
    required this.loopVideo,
    required this.closeWhenCompleted,
    required this.fullScreen,
    required this.imagePath,
  });

  final String newsL10nKey;
  final String? videoPath;
  final bool loopVideo;
  final bool closeWhenCompleted;
  final bool fullScreen;
  final String? imagePath;
}
