abstract class QuestStateRepository {
  int readStep(String questId);

  void writeStep(String questId, int step);

  bool readFlag(String questId, String flagKey, {bool fallback = false});

  void writeFlag(String questId, String flagKey, bool value);

  int readCounter(String questId, String counterKey, {int fallback = 0});

  void writeCounter(String questId, String counterKey, int value);

  String? readText(String questId, String textKey);

  void writeText(String questId, String textKey, String? value);
}
