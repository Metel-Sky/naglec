import 'package:flutter/material.dart';
import '../data/locations_room_data.dart';
import '../data/npc_economy_config.dart';
import '../models/npc_secondary.dart';
import '../data/npc_interactions.dart' as npc_interactions;

/// Стать NPC: для [NpcGender.male] у профілі та телефоні показуються лише відносини та вплив ГГ.
enum NpcGender { male, female }

class NpcOwnedItem {
  final String id;
  final String name;
  final String? imagePath;
  final String? expiresAtIso;

  const NpcOwnedItem({
    required this.id,
    required this.name,
    this.imagePath,
    this.expiresAtIso,
  });

  NpcOwnedItem copyWith({
    String? id,
    String? name,
    String? imagePath,
    String? expiresAtIso,
  }) {
    return NpcOwnedItem(
      id: id ?? this.id,
      name: name ?? this.name,
      imagePath: imagePath ?? this.imagePath,
      expiresAtIso: expiresAtIso ?? this.expiresAtIso,
    );
  }
}

class SchedulePoint {
  final int hourStart;
  final int hourEnd;
  final String location;
  final String actionLabel;
  final String spritePath;

  /// Дні тижня (0–6), null = щодня
  final List<int>? days;

  SchedulePoint({
    required this.hourStart,
    required this.hourEnd,
    required this.location,
    required this.actionLabel,
    required this.spritePath,
    this.days,
  });
}

class NPCAction {
  final String label;
  final VoidCallback onExecute;

  /// Якщо false — для [NpcGender.male] у меню не показується (окрім «Поговорити»).
  /// True для дій із івент/квест-слотів ([NpcInteractionSlot.isEventSlot]), крім придушених (напр. флірт).
  final bool allowExtraActionForMaleNpc;

  NPCAction({
    required this.label,
    required this.onExecute,
    this.allowExtraActionForMaleNpc = false,
  });
}

class NPCModel {
  final String id;
  final String name;
  final List<SchedulePoint> schedule;

  /// Повне ім'я для картки (наприклад "Євгенія Бандерко")
  String fullName;

  /// Статус для картки (наприклад "Молодша сестра", "Старша сестра"). Якщо null — виводиться name.
  final String? status;

  /// Додатковий підстатус під основним (наприклад завуч + «вчителька математики»).
  final String? subStatus;

  /// Текст для профілю: зовнішність (Body).
  final String? bodyDescription;
  /// Текст для профілю: типаж (біографія та характер).
  final String? biographyType;
  /// Текст для профілю: зовнішність у блоці біографії (можна дублювати bodyDescription).
  final String? biographyAppearance;
  /// Слабкості (fetishes/hooks) для профілю.
  final List<String>? weaknesses;
  /// Чекпоінти для профілю.
  final List<String>? checkpoints;
  /// Компромат (proofs) для профілю.
  final List<String>? proofs;
  /// Предмети, що належать NPC (для відображення в картці).
  List<NpcOwnedItem> items;

  /// Вік NPC
  int age;

  /// Шлях до аватара для картки NPC (телефон, профіль, смуга NPC, оверлеї в коледжі тощо).
  /// Зазвичай файл `*_ava.jpg` / `*_ava.png` у папці персонажа.
  final String? avatarPath;

  /// Повноцінний портрет для сітки «Персонажі» (як `den.jpg` у Дена).
  /// Якщо null — у галереї використовується [avatarPath].
  final String? galleryPortraitPath;

  // trust/love — внутрішньо для розрахунку [relationship]; у UI основних NPC не показувати окремо
  // (див. правило в .cursor/rules/npc-stats-and-secondary.mdc та [npc_secondary]).
  double trust;
  double love;
  /// Не виводити в картці NPC; для основних персонажів у UI лише хтивість, відносини, поведінка, збудження, вплив ГГ.
  int corruption;

  /// Хтивість NPC 0–1000, дробове (напр. 25.25)
  double lust;

  /// Поведінка NPC 0–1000, дробове (напр. 205.25)
  double behavior;

  /// Збудження 0–100
  int arousal;

  /// Гроші NPC (як у ГГ), для сюжету / економіки контактів.
  int money;

  // Квестові змінні персонажа
  Map<String, dynamic> variables;

  /// За замовчуванням жіноча — щоб існуючі NPC не змінювали UI без явного [gender].
  final NpcGender gender;

  NPCModel({
    required this.id,
    required this.name,
    required this.schedule,
    String? fullName,
    this.status,
    this.subStatus,
    this.bodyDescription,
    this.biographyType,
    this.biographyAppearance,
    this.weaknesses,
    this.checkpoints,
    this.proofs,
    List<NpcOwnedItem>? items,
    this.age = 0,
    this.avatarPath,
    this.galleryPortraitPath,
    this.trust = 0.0,
    this.love = 40.0,
    this.corruption = 0,
    this.lust = 0.0,
    this.behavior = 0.0,
    this.arousal = 0,
    this.money = 0,
    Map<String, dynamic>? variables,
    this.gender = NpcGender.female,
  }) : fullName = fullName ?? name,
       variables = variables ?? {},
       items = items ?? [];

  /// Відношення до ГГ 0–1000 (дробове, напр. 205.25 після компліменту)
  double get relationship =>
      ((trust.clamp(0.0, 100.0) + love.clamp(0.0, 100.0)) * 5).clamp(0.0, 1000.0);

  /// Вплив ГГ на NPC 0–100 (наростає з івентів/квестів).
  double influence = 0.0;

  /// Поточне значення впливу (для UI, 0–100).
  int get influenceFromGg => influence.clamp(0.0, 100.0).round();

  void addTrust(num value) => trust = (trust + value).clamp(0.0, 100.0);

  void addLove(num value) => love = (love + value).clamp(0.0, 100.0);

  /// Зміна статів для картки/чітів (з clamp).
  void changeLust(num d) => lust = (lust + d).clamp(0.0, 1000.0);

  void changeBehavior(num d) => behavior = (behavior + d).clamp(0.0, 1000.0);

  void changeArousal(int d) => arousal = (arousal + d).clamp(0, 100);

  void changeMoney(int amount) {
    if (isSecondaryNpc(this)) {
      money = 0;
      return;
    }
    money = NpcEconomyConfig.clampNpcMoney(id, money + amount);
  }

  void changeTrust(num d) => trust = (trust + d).clamp(0.0, 100.0);

  void changeLove(num d) => love = (love + d).clamp(0.0, 100.0);

  /// Зміна впливу ГГ на NPC (івенти/квести), 0–100.
  void changeInfluence(num d) => influence = (influence + d).clamp(0.0, 100.0);

  /// Додає до відношення дробовий крок (напр. 0.25 → 205 стає 205.25). relationship = (trust+love)*5.
  void addRelationship(double delta) {
    final half = delta / 5 / 2; // (trust+love) += delta/5, розподіляємо порівну
    trust = (trust + half).clamp(0.0, 100.0);
    love = (love + half).clamp(0.0, 100.0);
  }

  // Метод для перевірки квестових етапів
  bool getVar(String key) => variables[key] ?? false;

  void setVar(String key, dynamic value) => variables[key] = value;

  /// Дії, доступні в цій локації та час (для кнопок у грі).
  /// Якщо є шаблон взаємодій для цього слота (data/npc_interactions.dart) — використовується він,
  /// інакше — стандартний набір дій за замовчуванням.

  List<NPCAction> getAvailableActions({
    required String location,
    required int hour,
    required VoidCallback onUpdate,
  }) {
    // Office Cherie (ТРЦ): без стандартного меню жіночого NPC — лише івент-слоти з `npc_interactions.dart`.
    if (id == 'cherie' && location == LocationsData.cityMallGiftShopOffice) {
      return npc_interactions.buildEventSlotActionsOnly(this, location, hour, onUpdate);
    }

    // 1. Спочатку пробуємо знайти спеціальний слот взаємодій (івенти для конкретного NPC/локації/часу).
    final fromTemplate = _buildActionsFromTemplate(location, hour, onUpdate);
    var actions = fromTemplate.isNotEmpty
        ? fromTemplate
        : npc_interactions.buildDefaultActions(this, onUpdate);

    // Чоловіки: лише «Поговорити» + дії з квестів/івентів (див. [NPCAction.allowExtraActionForMaleNpc]).
    // Окремі NPC (Ден, Лошок тощо) мають власні кнопки в main_game_screen_state.
    if (gender == NpcGender.male && actions.isNotEmpty) {
      const talk = 'Поговорити';
      actions = actions
          .where(
            (a) =>
                a.label == talk || a.allowExtraActionForMaleNpc,
          )
          .toList();
    }

    // 3. Глобальні винятки: у ванній/туалеті та вночі кнопки ховаємо лише для чоловіків.
    //    Для жіночих NPC стандартні кнопки мають залишатися доступними поза івентами/квестами.
    final doorSummon = location == LocationsData.friendHouseDoorSummon;
    if (gender == NpcGender.male) {
      if (!doorSummon && (hour >= 22 || hour < 7)) return [];
      if (!doorSummon && _isBathroomLocation(location)) return [];
    }

    return actions;
  }

  bool _isBathroomLocation(String location) {
    final lower = location.toLowerCase();
    return lower.contains('bathroom') || lower.contains('toilet');
  }

  List<NPCAction> _buildActionsFromTemplate(String location, int hour, VoidCallback onUpdate) {
    try {
      return npc_interactions.buildActionsFromTemplate(this, location, hour, onUpdate);
    } catch (_) {
      return [];
    }
  }

  // Метод для швидкої перевірки прапорців
  bool hasMet(String eventId) => variables[eventId] == true;

  // Позначити, що подія відбулася
  void markEvent(String eventId) {
    variables[eventId] = true;
  }
}
