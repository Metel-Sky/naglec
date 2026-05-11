import 'quest_action.dart';

class QuestDefinition {
  const QuestDefinition({
    required this.questId,
    required this.npcId,
    required this.version,
    required this.steps,
  });

  final String questId;
  final String npcId;
  final int version;
  final List<QuestStepDefinition> steps;
}

class QuestStepDefinition {
  const QuestStepDefinition({
    required this.step,
    required this.locationId,
    this.entryVideoPath,
    this.dialogL10nKey,
    this.availableActions = const <QuestAction>[],
    this.isTerminal = false,
  });

  final int step;
  final String locationId;
  final String? entryVideoPath;
  final String? dialogL10nKey;
  final List<QuestAction> availableActions;
  final bool isTerminal;
}
