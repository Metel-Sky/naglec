/// Усі **івенти** NPC Cherie в одному файлі.
///
/// Кожен новий івент — окремий пронумерований блок із id `cherie_event_NNN` (див. `.cursor/rules/event-numbering.mdc`).
///
/// Слоти для `npc_interactions.dart`, одноразові прапорці тощо — сюди; виклики з екранів лише підключають API.
library;

// ═══════════════════════════════════════════════════════════════════════════
// EVENT: cherie_event_001 — зміна аніматором (офіс, вихідні 12–14)
// ═══════════════════════════════════════════════════════════════════════════
//
// EVENT: cherie_event_002 — кінець зміни (2 кроки): «Закінчити працювати» → tc_2 → діалог → «Піти»
// (гроші, час, енергія, лічильник змін, +1 харизми — лише на останньому «Піти»).
//
// EVENT: cherie_event_003 — інтро першої зміни (кроки 1–5), якщо giftShopAnimatorShiftsCompleted == 0.
//
// EVENT: cherie_event_004 — розваги після массажу (багаторазовий; див. `cherie_massage_fun_event.dart`).

abstract final class CherieEvents {
  CherieEvents._();

  static const String tc1Webm = 'lib/assets/npcs/cherie/tc_1.webm';

  static const String tcChangeClothesWebm =
      'lib/assets/npcs/cherie/tc_change_clothes.webm';

  static const String tc3Webm = 'lib/assets/npcs/cherie/tc_3.webm';

  static const String animatorWorkVideoPath =
      'lib/assets/npcs/cherie/animator.webm';

  /// Квест cherie_quest_002 — коробки та масаж (офіс ТРЦ 1–4, дім Cherie 5–9).
  static const String quest002Box1Webm = 'lib/assets/npcs/cherie/box_1.webm';
  static const String quest002Box2Webm = 'lib/assets/npcs/cherie/box_2.webm';
  static const String quest002MassageWebm =
      'lib/assets/npcs/cherie/massage.webm';
  static const String quest002Massage2Webm =
      'lib/assets/npcs/cherie/massage_2.webm';
  static const String quest002Massage3Webm =
      'lib/assets/npcs/cherie/massage_3.webm';

  /// Квест cherie_quest_004 — ланцюжок масажу вдома Чері.
  static const String quest004Massage4Webm =
      'lib/assets/npcs/cherie/massage_4.webm';
  static const String quest004Massage5Webm =
      'lib/assets/npcs/cherie/massage_5.webm';
  static const String quest004Massage6Webm =
      'lib/assets/npcs/cherie/massage_6.webm';
  static const String quest004Massage7Webm =
      'lib/assets/npcs/cherie/massage_7.webm';
  static const String quest004Massage8Webm =
      'lib/assets/npcs/cherie/massage_8.webm';
  static const String quest004Massage9Webm =
      'lib/assets/npcs/cherie/massage_9.webm';
  static const String quest004MassageNo1Webm =
      'lib/assets/npcs/cherie/massage_no_1.webm';
  static const String quest004MassageNo2Webm =
      'lib/assets/npcs/cherie/massage_no_2.webm';
  /// Відбій груди (крок 8 квесту 004) — той самий файл, що [quest004MassageNo2Webm].
  static const String quest004MassageNoWebm = quest004MassageNo2Webm;
  static const String quest004HomeContractTalkWebm =
      'lib/assets/npcs/cherie/home_contract_talk.webm';

  /// Після завершення зміни (кнопка «Закінчити працювати»): сцена з начальницею.
  static const String animatorShiftEndVideoPath =
      'lib/assets/npcs/cherie/tc_2.webm';

  /// Відео повного інтро-ланцюжка першої зміни або фіналу tc_2.
  static bool isAnimatorShiftEventVideoPath(String? path) {
    if (path == null) return false;
    return path == tc1Webm ||
        path == tcChangeClothesWebm ||
        path == tc3Webm ||
        path == animatorWorkVideoPath ||
        path == animatorShiftEndVideoPath;
  }

  /// Вихідні, той самий інтервал, що офіс Чері у [createCherieNpc]: 11:00–15:59.
  /// (Раніше було 12–13; через це при 11:00 чи після 13:59 гравець бачив Чері в офісі, але зміна/квест 2 не запускались.)
  static bool isAnimatorShiftTimeWindow({
    required int weekdayIndex,
    required int hour,
  }) {
    return weekdayIndex >= 5 && hour >= 11 && hour <= 15;
  }

  /// Вихідні 12:00–15:59 — старт cherie_quest_003 з кнопки «Працювати аніматором».
  static bool isCherieQuest003OfferWindow({
    required int weekdayIndex,
    required int hour,
  }) {
    return weekdayIndex >= 5 && hour >= 12 && hour <= 15;
  }

  /// Пн / Ср / Пт, офіс або магазин ТРЦ 10:00–18:59 — cherie_quest_004.
  static bool isCherieQuest004ScheduleWindow({
    required int weekdayIndex,
    required int hour,
  }) {
    if (weekdayIndex != 0 && weekdayIndex != 2 && weekdayIndex != 4) {
      return false;
    }
    return hour >= 10 && hour <= 18;
  }

  /// Пн / Ср / Пт 10:00–18:59 — cherie_quest_005 (після контракту з квесту 4).
  static bool isCherieQuest005ScheduleWindow({
    required int weekdayIndex,
    required int hour,
  }) {
    return isCherieQuest004ScheduleWindow(
      weekdayIndex: weekdayIndex,
      hour: hour,
    );
  }

  /// Будні (пн–пт): 0–4, 10:00–18:59 — cherie_quest_006.
  static bool isCherieQuest006ScheduleWindow({
    required int weekdayIndex,
    required int hour,
  }) {
    if (weekdayIndex < 0 || weekdayIndex > 4) return false;
    return hour >= 10 && hour <= 18;
  }

  /// QUEST: cherie_quest_005 — реклама (асети спільні з попередньою логікою).
  static const String quest005LickWebm =
      'lib/assets/npcs/cherie/lick.webm';
  static const String quest005PantsStoyakWatchWebm =
      'lib/assets/npcs/cherie/pants_stoyak_watch.webm';
  static const String quest005SwimmingWebm =
      'lib/assets/npcs/cherie/swimming.webm';
  static const String quest005Pants1StoyakJpg =
      'lib/assets/npcs/cherie/pants_1_stoyak.jpg';
  static const String quest005PantsJpg =
      'lib/assets/npcs/cherie/pants_1_stoyak.jpg';
  static const String quest005PantsRekJpg =
      'lib/assets/npcs/cherie/pants_rek.jpg';
  static const String quest005AfterSwimmingJpg =
      'lib/assets/npcs/cherie/after_swimming.jpg';

  /// QUEST: cherie_quest_006 (той самий файл, що кінець зміни — tc_2).
  static const String quest006OfficeTc2Webm = animatorShiftEndVideoPath;

  static const String quest006WorkAnimContract1Webm =
      'lib/assets/npcs/cherie/work_anim_contract_1.webm';
  static const String quest006WorkAnimContract2Webm =
      'lib/assets/npcs/cherie/work_anim_contract_2.webm';
  static const String quest006WorkSexRiserEndWebm =
      'lib/assets/npcs/cherie/work_sex_riser_end.webm';

  /// EVENT cherie_event_004 — після массажу (кроки 5–8).
  static const String massageFunAfter1Webm =
      'lib/assets/npcs/cherie/after_massage_1.webm';
  static const String massageFunAfter2Webm =
      'lib/assets/npcs/cherie/after_massage_2.webm';
  static const String massageFunFuckWebm =
      'lib/assets/npcs/cherie/after_massage_fuck.webm';
  static const String massageFunFuck2EndWebm =
      'lib/assets/npcs/cherie/after_massage_fuck_2_end_2.webm';
}
