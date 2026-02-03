import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class GameTimeController with ChangeNotifier {
  DateTime _dateTime = DateTime(2026, 1, 12, 19, 0);
  int _manualWeekdayIndex = 0; // 0 = ПОНЕДІЛОК
  int get weekdayIndex => _manualWeekdayIndex;

  final List<String> _daysOfWeek = [
    "ПОНЕДІЛОК", "ВІВТОРОК", "СЕРЕДА", "ЧЕТВЕР", "П'ЯТНИЦЯ", "СУБОТА", "НЕДІЛЯ"
  ];

  // --- ГЕТТЕРИ (ВИРІШУЮТЬ ПОМИЛКУ) ---
  DateTime get dateTime => _dateTime; // Тепер MainGameScreen бачить дату
  //String get dayName => _daysOfWeek[_manualWeekdayIndex];
  String get onlyDate => DateFormat('dd.MM.yyyy').format(_dateTime);
  String get formattedTime => DateFormat('HH:mm').format(_dateTime);
  String get dayName => _daysOfWeek[_manualWeekdayIndex].substring(0, 3);

  // --- ЛОГІКА ЧАСУ ---

  void addMinutes(int minutes) {
    int oldDay = _dateTime.day;
    _dateTime = _dateTime.add(Duration(minutes: minutes));

    // Якщо при додаванні часу змінилася доба — перемикаємо день тижня
    if (_dateTime.day != oldDay) {
      _nextDayCycle();
    }
    notifyListeners();
  }

  void addHour() => addMinutes(60);
  void subHour() => addMinutes(-60);
  void subMinute() => addMinutes(-5); // Твої -5 хв

  // --- ЛОГІКА ПЕРЕМИКАННЯ ДНІВ ---

  void _nextDayCycle() {
    _manualWeekdayIndex = (_manualWeekdayIndex + 1) % 7;
  }

  void _prevDayCycle() {
    _manualWeekdayIndex = (_manualWeekdayIndex - 1 < 0) ? 6 : _manualWeekdayIndex - 1;
  }

  // Методи для кнопок у хедері (Ручне керування)
  void nextDayName() { _nextDayCycle(); notifyListeners(); }
  void prevDayName() { _prevDayCycle(); notifyListeners(); }

  void addDay() { _dateTime = _dateTime.add(const Duration(days: 1)); notifyListeners(); }
  void subDay() { _dateTime = _dateTime.subtract(const Duration(days: 1)); notifyListeners(); }


}