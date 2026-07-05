import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/service_locator.dart';
import '../services/save_service.dart';

class GameTimeController with ChangeNotifier {
  /// Календарний перший день нової гри (для лічильника «день N»).
  static const String defaultGameStartDateKey = '25.08.2025';

  static final DateTime defaultGameStartDateTime = DateTime(2025, 8, 25, 6, 0);

  static final DateFormat _dateKeyFormat = DateFormat('dd.MM.yyyy');

  DateTime _dateTime = defaultGameStartDateTime;
  int _manualWeekdayIndex = 0; // 25.08.2025 — понеділок

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
      sl<SaveService>().autosave();
    }

    if (_dateTime.day != oldDay) {
      _manualWeekdayIndex = (_manualWeekdayIndex + 1) % 7;
    }
    notifyListeners();
  }

  void nextDayName() { _manualWeekdayIndex = (_manualWeekdayIndex + 1) % 7; notifyListeners(); }

  /// Скільки повних календарних днів між двома ключами `dd.MM.yyyy`.
  static int daysSinceDateKey(String? fromKey, String toKey) {
    if (fromKey == null || fromKey.isEmpty) return 0;
    try {
      final from = _dateKeyFormat.parse(fromKey);
      final to = _dateKeyFormat.parse(toKey);
      return to.difference(from).inDays;
    } catch (_) {
      return 0;
    }
  }

  /// Номер ігрового дня від старту (1 = перший день, 25.08.2025).
  static int gameDayNumber({
    required String gameStartDateKey,
    required String currentDateKey,
  }) =>
      daysSinceDateKey(gameStartDateKey, currentDateKey) + 1;

  /// Скидає час до початкового для нової гри (25.08.2025 6:00)
  void reset() {
    _dateTime = defaultGameStartDateTime;
    _manualWeekdayIndex = 0; // понеділок
    notifyListeners();
  }
  void prevDayName() { _manualWeekdayIndex = (_manualWeekdayIndex - 1 < 0) ? 6 : _manualWeekdayIndex - 1; notifyListeners(); }
  void addDay() { _dateTime = _dateTime.add(const Duration(days: 1)); _manualWeekdayIndex = (_manualWeekdayIndex + 1) % 7; notifyListeners(); }
  void subDay() { _dateTime = _dateTime.subtract(const Duration(days: 1)); _manualWeekdayIndex = (_manualWeekdayIndex - 1 < 0) ? 6 : _manualWeekdayIndex - 1; notifyListeners(); }
  void addHour() => addMinutes(60);
  void subHour() => addMinutes(-60);
  void subMinute() => addMinutes(-5);
}