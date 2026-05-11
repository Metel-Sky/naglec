import '../../services/game_world_state.dart';
import 'quest_state_repository.dart';

/// Quest state adapter that keeps backward compatibility with legacy fields in
/// [GameWorldState].
class LegacyWorldQuestStateRepository implements QuestStateRepository {
  LegacyWorldQuestStateRepository(this._world);

  final GameWorldState _world;
  final Map<String, dynamic> _ephemeral = <String, dynamic>{};

  String _k(String questId, String key) => '$questId::$key';

  @override
  int readStep(String questId) {
    switch (questId) {
      case 'cherie_quest_002':
        return _world.cherieQuest002Step;
      case 'cherie_quest_003':
        return _world.cherieQuest003Step;
      case 'cherie_quest_004':
        return _world.cherieQuest004Step;
      case 'cherie_quest_005':
        return _world.cherieQuest005Step;
      case 'cherie_quest_006':
        return _world.cherieQuest006Step;
      case 'cherie_event_004':
        return _world.cherieMassageFunEventStep;
      case 'rockefeller_quest_001':
        return _world.rockefellerNikeOfficeStep;
      default:
        return (_ephemeral[_k(questId, 'step')] as int?) ?? 0;
    }
  }

  @override
  void writeStep(String questId, int step) {
    switch (questId) {
      case 'cherie_quest_002':
        _world.cherieQuest002Step = step;
        return;
      case 'cherie_quest_003':
        _world.cherieQuest003Step = step;
        return;
      case 'cherie_quest_004':
        _world.cherieQuest004Step = step;
        return;
      case 'cherie_quest_005':
        _world.cherieQuest005Step = step;
        return;
      case 'cherie_quest_006':
        _world.cherieQuest006Step = step;
        return;
      case 'cherie_event_004':
        _world.cherieMassageFunEventStep = step;
        return;
      case 'rockefeller_quest_001':
        _world.rockefellerNikeOfficeStep = step;
        return;
      default:
        _ephemeral[_k(questId, 'step')] = step;
    }
  }

  @override
  bool readFlag(String questId, String flagKey, {bool fallback = false}) {
    if (questId == 'cherie_quest_002' && flagKey == 'warehouseWhoAsked') {
      return _world.cherieQuest002WarehouseWhoAsked;
    }
    if (questId == 'cherie_quest_002' && flagKey == 'sundayBlocked') {
      return _world.cherieQuest002SundayBlocked;
    }
    if (questId == 'cherie_quest_004' && flagKey == 'legsMassagePhase') {
      return _world.cherieQuest004LegsMassagePhase;
    }
    if (questId == 'cherie_quest_005' && flagKey == 'complete') {
      return _world.cherieQuest005Complete;
    }
    if (questId == 'cherie_quest_006' && flagKey == 'complete') {
      return _world.cherieQuest006Complete;
    }
    if (questId == 'rockefeller_quest_001' && flagKey == 'workStarted') {
      return _world.rockefellerNikeWorkStarted;
    }
    if (questId == 'rockefeller_quest_001' &&
        flagKey == 'shootingInProgress') {
      return _world.rockefellerNikeShootingInProgress;
    }
    if (questId == 'rockefeller_quest_001' &&
        flagKey == 'finalReviewInProgress') {
      return _world.rockefellerNikeFinalReviewInProgress;
    }
    if (questId == 'rockefeller_quest_001' && flagKey == 'adCompleted') {
      return _world.rockefellerNikeAdCompleted;
    }
    return (_ephemeral[_k(questId, 'flag:$flagKey')] as bool?) ?? fallback;
  }

  @override
  void writeFlag(String questId, String flagKey, bool value) {
    if (questId == 'cherie_quest_002' && flagKey == 'warehouseWhoAsked') {
      _world.cherieQuest002WarehouseWhoAsked = value;
      return;
    }
    if (questId == 'cherie_quest_002' && flagKey == 'sundayBlocked') {
      _world.cherieQuest002SundayBlocked = value;
      return;
    }
    if (questId == 'cherie_quest_004' && flagKey == 'legsMassagePhase') {
      _world.cherieQuest004LegsMassagePhase = value;
      return;
    }
    if (questId == 'cherie_quest_005' && flagKey == 'complete') {
      _world.cherieQuest005Complete = value;
      return;
    }
    if (questId == 'cherie_quest_006' && flagKey == 'complete') {
      _world.cherieQuest006Complete = value;
      return;
    }
    if (questId == 'rockefeller_quest_001' && flagKey == 'workStarted') {
      _world.rockefellerNikeWorkStarted = value;
      return;
    }
    if (questId == 'rockefeller_quest_001' &&
        flagKey == 'shootingInProgress') {
      _world.rockefellerNikeShootingInProgress = value;
      return;
    }
    if (questId == 'rockefeller_quest_001' &&
        flagKey == 'finalReviewInProgress') {
      _world.rockefellerNikeFinalReviewInProgress = value;
      return;
    }
    if (questId == 'rockefeller_quest_001' && flagKey == 'adCompleted') {
      _world.rockefellerNikeAdCompleted = value;
      return;
    }
    _ephemeral[_k(questId, 'flag:$flagKey')] = value;
  }

  @override
  int readCounter(String questId, String counterKey, {int fallback = 0}) {
    if (questId == 'cherie_quest_004' && counterKey == 'branch') {
      return _world.cherieQuest004Branch;
    }
    if (questId == 'cherie_quest_005' && counterKey == 'actorCounter') {
      return _world.cherieQuest005Actor;
    }
    if (questId == 'cherie_quest_005' && counterKey == 'lizunCounter') {
      return _world.cherieQuest005Lizun;
    }
    if (questId == 'cherie_quest_005' && counterKey == 'step42PantsPick') {
      return _world.cherieQuest005Step42PantsPick;
    }
    if (questId == 'cherie_event_004' && counterKey == 'completions') {
      return _world.cherieMassageFunCompletions;
    }
    if (questId == 'rockefeller_quest_001' && counterKey == 'shootingDays') {
      return _world.rockefellerNikeShootingDays;
    }
    return (_ephemeral[_k(questId, 'counter:$counterKey')] as int?) ?? fallback;
  }

  @override
  void writeCounter(String questId, String counterKey, int value) {
    if (questId == 'cherie_quest_004' && counterKey == 'branch') {
      _world.cherieQuest004Branch = value;
      return;
    }
    if (questId == 'cherie_quest_005' && counterKey == 'actorCounter') {
      _world.cherieQuest005Actor = value;
      return;
    }
    if (questId == 'cherie_quest_005' && counterKey == 'lizunCounter') {
      _world.cherieQuest005Lizun = value;
      return;
    }
    if (questId == 'cherie_quest_005' && counterKey == 'step42PantsPick') {
      _world.cherieQuest005Step42PantsPick = value;
      return;
    }
    if (questId == 'cherie_event_004' && counterKey == 'completions') {
      _world.cherieMassageFunCompletions = value;
      return;
    }
    if (questId == 'rockefeller_quest_001' && counterKey == 'shootingDays') {
      _world.rockefellerNikeShootingDays = value;
      return;
    }
    _ephemeral[_k(questId, 'counter:$counterKey')] = value;
  }

  @override
  String? readText(String questId, String textKey) {
    if (questId == 'rockefeller_quest_001' &&
        textKey == 'cherie005IncompleteAskLastDateKey') {
      return _world.rockefellerCherie005IncompleteAskLastDateKey;
    }
    return _ephemeral[_k(questId, 'text:$textKey')] as String?;
  }

  @override
  void writeText(String questId, String textKey, String? value) {
    if (questId == 'rockefeller_quest_001' &&
        textKey == 'cherie005IncompleteAskLastDateKey') {
      _world.rockefellerCherie005IncompleteAskLastDateKey = value;
      return;
    }
    _ephemeral[_k(questId, 'text:$textKey')] = value;
  }
}
