import 'package:flutter/material.dart';

class SchedulePoint {
  final int hourStart;
  final int hourEnd;
  final String location;
  final String actionLabel;
  final String? spritePath;
  final List<int>? days;

  SchedulePoint({
    required this.hourStart,
    required this.hourEnd,
    required this.location,
    this.actionLabel = "Відпочиває",
    this.spritePath,
    this.days,
  });
}

class NPCAction {
  final String label;
  final VoidCallback onExecute; // Простіший тип для функцій без контексту

  NPCAction({required this.label, required this.onExecute});
}

class NPCModel {
  final String id;
  final String name;
  final List<SchedulePoint> schedule;

  // Характеристики
  double relationship;
  double lust;
  double behavior;

  NPCModel({
    required this.id,
    required this.name,
    required this.schedule,
    this.relationship = 50.0,
    this.lust = 0.0,
    this.behavior = 0.0,
  });

  // Метод, який вирішує, які кнопки показати
  List<NPCAction> getAvailableActions({
    required String location,
    required int hour,
    required VoidCallback onUpdate, // Щоб оновити UI після дії
  }) {
    List<NPCAction> actions = [];

    // 1. Базова дія для всіх
    actions.add(NPCAction(
      label: "Поговорити",
      onExecute: () {
        relationship += 1;
        onUpdate();
      },
    ));

    actions.add(NPCAction(
      label: "Комплімент",
      onExecute: () {
        relationship += 1;
        onUpdate();
      },
    ));

    actions.add(NPCAction(
      label: "Пожартувати",
      onExecute: () {
        relationship += 1;
        onUpdate();
      },
    ));

    // 2. Специфічні дії за ID
    switch (id) {
      case 'mom':
        if (location == 'Кухня' && (hour >= 7 && hour < 9)) {
          actions.add(NPCAction(
            label: "Обійняти",
            onExecute: () {
              relationship += 2;
              behavior += 1;
              onUpdate();
              print("Обійнято");
            },
          ));
        }
        break;

      case 'mom':
        if (location == 'Кухня' && (hour >= 7 && hour < 9)) {
          actions.add(NPCAction(
            label: "Обійняти",
            onExecute: () {
              relationship += 2;
              behavior += 1;
              onUpdate();
            },
          ));
        }
        break;

      case 'kira':
        if (location == 'Кімната Кіри') {
          actions.add(NPCAction(
            label: "Попросити списати",
            onExecute: () {
              lust += 0.5; // Наприклад :)
              onUpdate();
            },
          ));
        }
        break;
    }

    return actions;
  }
}