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

  // Статистика стосунків
  int trust;
  int love;
  int corruption; // Додаємо рівень розпусності, якщо потрібно за сюжетом

  // Квестові змінні персонажа (наприклад: {"has_gift": true, "met_at_night": false})
  Map<String, dynamic> variables;

  NPCModel({
    required this.id,
    required this.name,
    required this.schedule,
    this.trust = 0,
    this.love = 0,
    this.corruption = 0,
    Map<String, dynamic>? variables,
  }) : this.variables = variables ?? {};

  // Зручні методи для зміни статів
  void addTrust(int value) => trust += value;
  void addLove(int value) => love += value;

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

    if (location == 'Кухня' && hour >= 7 && hour < 9 && id == 'mom') {
      actions.add(NPCAction(
        label: "Обійняти",
        onExecute: () {
          addTrust(2);
          addLove(1);
          onUpdate();
        },
      ));
    }

    return actions;
  }
}