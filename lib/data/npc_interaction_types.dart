/// Спільні типи для взаємодій NPC. Імпортуйте з файлів івентів кожного NPC.
library;

import '../models/npc_model.dart';

/// Слот взаємодії: умови (час, локація, npcId, опційно — стати) + список дій.
/// Якщо задані [minRelationship]/[minInfluence] або [oneTimeVar] — це івент-слот: кнопки зʼявляються лише при виконанні умов.
class NpcInteractionSlot {
  final String? npcId;
  final String location;
  final int hourStart;
  final int hourEnd;
  final List<NpcActionTemplate> actions;

  /// Мінімальне відношення (relationship) для показу слоту (івент).
  final double? minRelationship;

  /// Мінімальний вплив (influence) для показу слоту (івент).
  final double? minInfluence;

  /// Ключ у variables NPC: якщо вже true — слот не показується (одноразовий івент).
  final String? oneTimeVar;

  /// Показувати слот лише коли ці змінні не встановлені (null/false). Для етапованих івентів.
  final List<String>? showOnlyWhenVarNull;

  /// Якщо true — дії цього слоту не додаються до меню чоловіків як «квестові» (наприклад «Флірт»).
  final bool excludeFromMaleMinimalMenu;

  const NpcInteractionSlot({
    this.npcId,
    required this.location,
    required this.hourStart,
    required this.hourEnd,
    required this.actions,
    this.minRelationship,
    this.minInfluence,
    this.oneTimeVar,
    this.showOnlyWhenVarNull,
    this.excludeFromMaleMinimalMenu = false,
  });

  /// Чи це івент-слот (додаткові умови по статах / одноразовість / етапи).
  bool get isEventSlot =>
      minRelationship != null ||
      minInfluence != null ||
      oneTimeVar != null ||
      (showOnlyWhenVarNull != null && showOnlyWhenVarNull!.isNotEmpty);

  /// Порожня location = будь-яка локація; hourStart: 0 та hourEnd: 24 = будь-який час.
  /// Якщо передано [npc], перевіряються також [minRelationship], [minInfluence], [oneTimeVar].
  bool matches(String loc, int hour, String? id, [dynamic npc]) {
    if (location.isNotEmpty && location != loc) return false;
    if (!(hourStart == 0 && hourEnd == 24) &&
        (hour < hourStart || hour >= hourEnd)) {
      return false;
    }
    if (npcId != null && npcId != id) return false;
    if (npc != null && npc is NPCModel) {
      if (minRelationship != null && npc.relationship < minRelationship!) {
        return false;
      }
      if (minInfluence != null && npc.influenceFromGg < minInfluence!) {
        return false;
      }
      if (oneTimeVar != null && npc.getVar(oneTimeVar!) == true) return false;
      if (showOnlyWhenVarNull != null) {
        for (final key in showOnlyWhenVarNull!) {
          final dynamic v = npc.variables[key];
          if (v != null && v != false && v != 0) return false;
        }
      }
    }
    return true;
  }
}

/// Одна дія в шаблоні: лейбл + ефекти (дробові одиниці). Умовні — за relThreshold.
class NpcActionTemplate {
  final String label;
  final double lust;
  final double relationship;
  final double behavior;

  /// Зміна впливу ГГ на NPC (івенти/квести), 0–100.
  final double? influenceDelta;
  final double? lustIfLow;
  final double? lustIfHigh;
  final double? relIfLow;
  final double? relIfHigh;
  final double? behIfLow;
  final double? behIfHigh;
  final double relThreshold;
  final double? relThresholdForRelationship;

  /// Після виконання дії встановити змінні NPC (етап івенту, лічильник тощо).
  final Map<String, dynamic>? setVarOnExecute;

  /// Текст діалогу в [newsMessage] після виконання дії (l10n-ключ).
  final String? dialogueL10nKey;

  const NpcActionTemplate({
    required this.label,
    this.lust = 0.0,
    this.relationship = 0.0,
    this.behavior = 0.0,
    this.influenceDelta,
    this.lustIfLow,
    this.lustIfHigh,
    this.relIfLow,
    this.relIfHigh,
    this.behIfLow,
    this.behIfHigh,
    this.relThreshold = 500.0,
    this.relThresholdForRelationship,
    this.setVarOnExecute,
    this.dialogueL10nKey,
  });
}

/// Базовий набір дій для всіх NPC (Поговорити, Комплімент, Пожартувати, Подарувати). Флірт — окремо при rel >= 500.
const List<NpcActionTemplate> defaultInteractionActions = [
  // Поговорити — м'який діалог (хтивість 0; відношення +2; поведінка 0).
  NpcActionTemplate(
    label: 'Поговорити',
    lust: 0.0,
    relationship: 2.0,
    behavior: 0.0,
    dialogueL10nKey: 'npc_ask_how_are_you_dialogue',
  ),

  // Комплімент — сильніший приріст відношення/поведінки.
  NpcActionTemplate(
    label: 'Комплімент',
    lust: 0.0,
    relationship: 3.0,
    behavior: 1.0,
    dialogueL10nKey: 'npc_compliment_dialogue',
  ),

  // Пожартувати.
  // Якщо відношення >= 500 (id2) — інші значення.
  NpcActionTemplate(
    label: 'Пожартувати',
    relThreshold: 500.0,
    lustIfLow: 1.0,
    lustIfHigh: 1.0,
    relIfLow: 5.0,
    relIfHigh: 3.0,
    behIfLow: 1.0,
    behIfHigh: 1.0,
    dialogueL10nKey: 'npc_joke_dialogue',
  ),

  // Подарувати — базовий приріст статів, лімітовано в меню взаємодій.
  NpcActionTemplate(
    label: 'Подарувати',
    lust: 1.0,
    relationship: 7.0,
    behavior: 1.0,
  ),
];

/// Флірт — тільки при відношенні >= 500 (додається окремим слотом у npc_interactions.dart).
const NpcActionTemplate flirtActionTemplate = NpcActionTemplate(
  label: 'Флірт',
  lustIfLow: -5.0,
  lustIfHigh: 1.0,
  relIfLow: -5.0,
  relIfHigh: 1.0,
  relThreshold: 600.0,
  behIfLow: -10.0,
  behIfHigh: 1.0,
);
