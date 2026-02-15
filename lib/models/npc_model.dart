import 'package:flutter/material.dart';

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

  NPCAction({required this.label, required this.onExecute});
}

class NPCModel {
  final String id;
  final String name;
  final List<SchedulePoint> schedule;

  /// Повне ім'я для картки (наприклад "Євгенія Бандерко")
  String fullName;

  /// Вік NPC
  int age;

  /// Шлях до аватара для картки NPC (телефон, діалоги). Якщо null — береться перше .jpg/.png з schedule.
  final String? avatarPath;

  // Статистика стосунків
  int trust;
  int love;
  int corruption;

  /// Хтивість NPC 0–1000 (шкала: Скромна → Вавилонська блудниця)
  int lust;

  /// Поведінка NPC 0–1000 (шкала: Високомірна → Покірна)
  int behavior;

  /// Збудження 0–100
  int arousal;

  // Квестові змінні персонажа
  Map<String, dynamic> variables;

  NPCModel({
    required this.id,
    required this.name,
    required this.schedule,
    String? fullName,
    this.age = 0,
    this.avatarPath,
    this.trust = 0,
    this.love = 40,
    this.corruption = 0,
    this.lust = 0,
    this.behavior = 0,
    this.arousal = 0,
    Map<String, dynamic>? variables,
  }) : fullName = fullName ?? name,
       variables = variables ?? {};

  /// Відношення до ГГ 0–1000 (обчислюється з trust + love)
  int get relationship =>
      ((trust.clamp(0, 100) + love.clamp(0, 100)) * 5).clamp(0, 1000);

  /// Вплив ГГ на NPC 0–1000 (обчислюється з trust)
  int get influenceFromGg => (trust.clamp(0, 100) * 10).clamp(0, 1000);

  void addTrust(int value) => trust = (trust + value).clamp(0, 100);

  void addLove(int value) => love = (love + value).clamp(0, 100);

  /// Зміна статів для картки/чітів (з clamp).
  void changeLust(int d) => lust = (lust + d).clamp(0, 1000);

  void changeBehavior(int d) => behavior = (behavior + d).clamp(0, 1000);

  void changeArousal(int d) => arousal = (arousal + d).clamp(0, 100);

  void changeTrust(int d) => trust = (trust + d).clamp(0, 100);

  void changeLove(int d) => love = (love + d).clamp(0, 100);

  // Метод для перевірки квестових етапів
  bool getVar(String key) => variables[key] ?? false;

  void setVar(String key, dynamic value) => variables[key] = value;

  /// Дії, доступні в цій локації та час (для кнопок у грі)
  List<NPCAction> getAvailableActions({
    required String location,
    required int hour,
    required VoidCallback onUpdate,
  }) {
    final actions = <NPCAction>[
      NPCAction(
        label: "Поговорити",
        onExecute: () {
          addTrust(1);
          onUpdate();
        },
      ),
      NPCAction(
        label: "Комплімент",
        onExecute: () {
          addTrust(1);
          addLove(1);
          onUpdate();
        },
      ),
      NPCAction(
        label: "Пожартувати",
        onExecute: () {
          addTrust(1);
          onUpdate();
        },
      ),
    ];

    if (location == 'kitchen' && hour >= 7 && hour < 9 && id == 'mom') {
      actions.add(
        NPCAction(
          label: "Обійняти",
          onExecute: () {
            addTrust(2);
            addLove(1);
            onUpdate();
          },
        ),
      );
    }

    return actions;
  }

  // Метод для швидкої перевірки прапорців
  bool hasMet(String eventId) => variables[eventId] == true;

  // Позначити, що подія відбулася
  void markEvent(String eventId) {
    variables[eventId] = true;
  }
}
