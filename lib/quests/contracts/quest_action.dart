typedef QuestActionId = String;

class QuestAction {
  const QuestAction({
    required this.id,
    required this.label,
    this.l10nKey,
    this.isDestructive = false,
  });

  final QuestActionId id;
  final String label;
  final String? l10nKey;
  final bool isDestructive;
}
