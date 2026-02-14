import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/service_locator.dart';
import '../services/save_service.dart';

class GameTimeController with ChangeNotifier {
  DateTime _dateTime = DateTime(2026, 1, 12, 6, 0);
  int _manualWeekdayIndex = 0;

  final List<String> _daysOfWeek = [
    "ПОНЕДІЛОК", "ВІВТОРОК", "СЕРЕДА", "ЧЕТВЕР", "П'ЯТНИЦЯ", "СУБОТА", "НЕДІЛЯ"
  ];

  DateTime get dateTime => _dateTime;
  int get weekdayIndex => _manualWeekdayIndex;
  String get onlyDate => DateFormat('dd.MM.yyyy').format(_dateTime);
  String get formattedTime => DateFormat('HH:mm').format(_dateTime);
  String get dayName => _daysOfWeek[_manualWeekdayIndex].substring(0, 3);

  set dateTime(DateTime value) {
    _dateTime = value;
    notifyListeners();
  }

  void loadManualWeekday(int index) {
    _manualWeekdayIndex = index;
    notifyListeners();
  }

  void updateUI() {
    notifyListeners(); // Цей рядок змушує всі віджети, що залежать від часу, оновитися
  }

  void addMinutes(int minutes) {
    int oldHour = _dateTime.hour;
    int oldDay = _dateTime.day;

    _dateTime = _dateTime.add(Duration(minutes: minutes));

    // AUTO SAVE о 6 ранку
    if (oldHour < 6 && _dateTime.hour >= 6) {
      sl<SaveService>().saveGame(0);
    }

    if (_dateTime.day != oldDay) {
      _manualWeekdayIndex = (_manualWeekdayIndex + 1) % 7;
    }
    notifyListeners();
  }

  void nextDayName() { _manualWeekdayIndex = (_manualWeekdayIndex + 1) % 7; notifyListeners(); }

  /// Скидає час до початкового для нової гри
  void reset() {
    _dateTime = DateTime(2026, 1, 12, 6, 0);
    _manualWeekdayIndex = 0;
    notifyListeners();
  }
  void prevDayName() { _manualWeekdayIndex = (_manualWeekdayIndex - 1 < 0) ? 6 : _manualWeekdayIndex - 1; notifyListeners(); }
  void addDay() { _dateTime = _dateTime.add(const Duration(days: 1)); _manualWeekdayIndex = (_manualWeekdayIndex + 1) % 7; notifyListeners(); }
  void subDay() { _dateTime = _dateTime.subtract(const Duration(days: 1)); _manualWeekdayIndex = (_manualWeekdayIndex - 1 < 0) ? 6 : _manualWeekdayIndex - 1; notifyListeners(); }
  void addHour() => addMinutes(60);
  void subHour() => addMinutes(-60);
  void subMinute() => addMinutes(-5);
}