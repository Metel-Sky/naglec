import '../../npcs/cherie/cherie_quests.dart';

abstract final class CherieQuestRuntime {
  CherieQuestRuntime._();

  static List<String> quest003ActionIds({required int step}) {
    switch (step) {
      case 1:
        return <String>['goWork'];
      case 2:
        return <String>['finishWork'];
      case 3:
        return <String>['leave'];
      default:
        return const <String>[];
    }
  }

  static String? quest003ActionL10nKey(String actionId) {
    switch (actionId) {
      case 'goWork':
        return CherieQuest003L10n.btnGoWork;
      case 'finishWork':
        return CherieQuest003L10n.btnFinishWork;
      case 'leave':
        return CherieQuest003L10n.btnLeave;
      default:
        return null;
    }
  }

  static List<String> quest004OfficeActionIds({required int step}) {
    if (step == 1) return <String>['ride'];
    return const <String>[];
  }

  static List<String> quest004BedroomActionIds({
    required int step,
    required int branch,
    required bool legsMassagePhase,
    required int masseur,
  }) {
    if (step == 3) return <String>['ellipsis'];
    if (step == 4) {
      if (!legsMassagePhase) return <String>['offerLegs', 'finish'];
      return <String>['offerTurn', 'finish'];
    }
    if (step == 6) {
      if (masseurSmall(masseur)) return <String>['finish'];
      return <String>['removePanties', 'finish'];
    }
    if (step == 7) return <String>['finish'];
    if (step == 8) {
      if (branch == CherieQuest004Branch.gropeRebuff) return <String>['finish'];
      return <String>['gropeChest', 'finish'];
    }
    if (step == 9) {
      if (branch == CherieQuest004Branch.petRebuff) return <String>['finish'];
      return <String>['petKitty', 'finish'];
    }
    if (step == 10) return <String>['finish'];
    return const <String>[];
  }

  static bool masseurSmall(int m) => m <= 3;

  static List<String> quest004ContractActionIds({required int step}) {
    if (step == 11) return <String>['leave'];
    return const <String>[];
  }

  static String? quest004ActionL10nKey(String actionId) {
    switch (actionId) {
      case 'ride':
        return CherieQuest004L10n.btnRide;
      case 'ellipsis':
        return CherieQuest004L10n.btnEllipsis;
      case 'offerLegs':
        return CherieQuest004L10n.btnOfferLegs;
      case 'offerTurn':
        return CherieQuest004L10n.btnOfferTurn;
      case 'removePanties':
        return CherieQuest004L10n.btnRemovePanties;
      case 'gropeChest':
        return CherieQuest004L10n.btnGropeChest;
      case 'petKitty':
        return CherieQuest004L10n.btnPetKitty;
      case 'leave':
        return CherieQuest004L10n.btnLeave;
      case 'finish':
        return CherieQuest004L10n.btnFinish;
      default:
        return null;
    }
  }

  static List<String> quest005OfficeActionIds({required int step}) {
    if (step == 1) return <String>['ride'];
    return const <String>[];
  }

  static List<String> quest005BedroomActionIds({
    required int step,
    required int lizun,
  }) {
    switch (step) {
      case 2:
        return <String>['gropeChest', 'finish'];
      case 3:
        return <String>['petKitty', 'finish'];
      case 4:
        if (lizun == 1) return <String>['lick', 'leave'];
        if (lizun == 2) return <String>['ellipsis'];
        return <String>['finish'];
      case 5:
        return <String>['leave'];
      case 6:
        return <String>['ellipsis'];
      case 7:
        return <String>['leave'];
      case 8:
        return <String>['agree'];
      case 9:
        return <String>['leave'];
      case 10:
        return <String>['exitPool'];
      case 11:
        return <String>['agree', 'decline'];
      case 12:
        return <String>['leave'];
      case 13:
        return <String>['leave'];
      default:
        return const <String>[];
    }
  }

  static String? quest005ActionL10nKey(String actionId) {
    switch (actionId) {
      case 'ride':
        return CherieQuest005L10n.btnRide;
      case 'gropeChest':
        return CherieQuest005L10n.btnGropeChest;
      case 'petKitty':
        return CherieQuest005L10n.btnPetKitty;
      case 'lick':
        return CherieQuest005L10n.btnLick;
      case 'ellipsis':
        return CherieQuest005L10n.btnEllipsis;
      case 'agree':
        return CherieQuest005L10n.btnAgree;
      case 'decline':
        return CherieQuest005L10n.btnDecline;
      case 'exitPool':
        return CherieQuest005L10n.btnExitPool;
      case 'finish':
        return CherieQuest005L10n.btnFinish;
      case 'leave':
        return CherieQuest005L10n.btnLeave;
      default:
        return null;
    }
  }

  static List<String> quest006ActionIds({required int step}) {
    switch (step) {
      case 1:
        return <String>['oral'];
      case 2:
        return <String>['hair'];
      case 3:
        return <String>['finish'];
      case 4:
        return <String>['leave'];
      default:
        return const <String>[];
    }
  }

  static String? quest006ActionL10nKey(String actionId) {
    switch (actionId) {
      case 'oral':
        return CherieQuest006L10n.btnOral;
      case 'hair':
        return CherieQuest006L10n.btnHair;
      case 'finish':
        return CherieQuest006L10n.btnFinish;
      case 'leave':
        return CherieQuest006L10n.btnLeave;
      default:
        return null;
    }
  }

  static List<String> quest002HomeActionIds({
    required int step,
    required bool finishOnlyWeek,
  }) {
    switch (step) {
      case 5:
        return <String>['offerHelp', 'goLeave'];
      case 6:
        return <String>['followCherie'];
      case 7:
        return <String>['massageEllipsis'];
      case 8:
        if (finishOnlyWeek) {
          return <String>['finishMassage'];
        }
        return <String>['offerLegMassage', 'finishMassage'];
      case 9:
        return <String>['finishFinal'];
      default:
        return const <String>[];
    }
  }

  static List<String> quest002MallActionIds({
    required int step,
    required bool warehouseWhoAsked,
  }) {
    if (step == 4) {
      if (warehouseWhoAsked) return <String>['deliverBoxes'];
      return <String>['deliverBoxes', 'whoAreYou'];
    }
    if (step >= 1 && step <= 3) {
      return <String>['primaryContinue'];
    }
    return const <String>[];
  }

  static String? quest002ActionL10nKey({
    required String actionId,
    required int step,
  }) {
    switch (actionId) {
      case 'offerHelp':
        return CherieQuest002L10n.btnOfferHelp;
      case 'goLeave':
        return CherieQuest002L10n.btnGoLeave;
      case 'followCherie':
        return CherieQuest002L10n.btnFollowCherie;
      case 'massageEllipsis':
        return CherieQuest002L10n.btnMassageEllipsis;
      case 'offerLegMassage':
        return CherieQuest002L10n.btnOfferLegMassage;
      case 'finishMassage':
        return CherieQuest002L10n.btnFinishMassage;
      case 'finishFinal':
        return CherieQuest002L10n.btnFinish;
      case 'deliverBoxes':
        return CherieQuest002L10n.btnDeliverBoxes;
      case 'whoAreYou':
        return CherieQuest002L10n.btnWhoAreYou;
      case 'primaryContinue':
        if (step == 1) return CherieQuest002L10n.btnStep1Leave;
        if (step == 2) return CherieQuest002L10n.btnFinishAnimatorShift;
        if (step == 3) return CherieQuest002L10n.btnGoWarehouse;
        return null;
      default:
        return null;
    }
  }
}
