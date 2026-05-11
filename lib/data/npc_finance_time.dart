/// Ігрова «доба» для лімітів фінансів: змінюється о 06:00 (як автозбереження в [GameTimeController]).
String npcFinanceGameDayKey(DateTime dt) {
  final shifted = dt.hour < 6 ? dt.subtract(const Duration(days: 1)) : dt;
  final y = shifted.year;
  final m = shifted.month.toString().padLeft(2, '0');
  final d = shifted.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}

/// Календарні дні між двома мітками часу (лише дата, без годин).
int npcFinanceCalendarDaysBetween(DateTime from, DateTime to) {
  final a = DateTime(from.year, from.month, from.day);
  final b = DateTime(to.year, to.month, to.day);
  return b.difference(a).inDays;
}
