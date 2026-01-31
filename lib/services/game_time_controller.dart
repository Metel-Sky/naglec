import 'package:intl/intl.dart';

class GameTimeController {
  DateTime _dateTime = DateTime(2026, 1, 12, 19, 0);

  final List<String> _daysOfWeek = [
    "ПОНЕДІЛОК", "ВІВТОРОК", "СЕРЕДА", "ЧЕТВЕР", "П'ЯТНИЦЯ", "СУБОТА", "НЕДІЛЯ"
  ];

  String get formattedDate => DateFormat('dd.MM.yyyy').format(_dateTime);
  String get formattedTime => DateFormat('HH:mm').format(_dateTime);
  String get dayName => _daysOfWeek[_dateTime.weekday - 1];

  // --- МЕТОДИ ДЛЯ ЧІТІВ ---

  void addDay() => _dateTime = _dateTime.add(const Duration(days: 1));
  void subDay() => _dateTime = _dateTime.subtract(const Duration(days: 1));

  void addHour() => _dateTime = _dateTime.add(const Duration(hours: 1));
  void subHour() => _dateTime = _dateTime.subtract(const Duration(hours: 1));

  void addMinute() => _dateTime = _dateTime.add(const Duration(minutes: 10));
  void subMinute() => _dateTime = _dateTime.subtract(const Duration(minutes: 10));

  // Стандартний ігровий крок
  void addMinutes(int minutes) {
    _dateTime = _dateTime.add(Duration(minutes: minutes));
  }
}