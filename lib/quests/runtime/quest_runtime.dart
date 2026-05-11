import '../contracts/quest_definition.dart';
import 'quest_state_repository.dart';

class QuestRuntime {
  QuestRuntime({
    required QuestStateRepository stateRepository,
    Map<String, QuestDefinition> registry = const <String, QuestDefinition>{},
  })  : _state = stateRepository,
        _registry = Map<String, QuestDefinition>.from(registry);

  final QuestStateRepository _state;
  final Map<String, QuestDefinition> _registry;

  void register(QuestDefinition definition) {
    _registry[definition.questId] = definition;
  }

  QuestDefinition? definition(String questId) => _registry[questId];

  int step(String questId) => _state.readStep(questId);

  void setStep(String questId, int step) => _state.writeStep(questId, step);

  bool flag(String questId, String key, {bool fallback = false}) =>
      _state.readFlag(questId, key, fallback: fallback);

  void setFlag(String questId, String key, bool value) =>
      _state.writeFlag(questId, key, value);

  int counter(String questId, String key, {int fallback = 0}) =>
      _state.readCounter(questId, key, fallback: fallback);

  void setCounter(String questId, String key, int value) =>
      _state.writeCounter(questId, key, value);

  String? text(String questId, String key) => _state.readText(questId, key);

  void setText(String questId, String key, String? value) =>
      _state.writeText(questId, key, value);
}
