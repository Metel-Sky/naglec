import 'dart:math';

// Відео Пайпер у ванні під час «душу» — один рандомний при вході ГГ (seed у GameWorldState).

/// Шляхи до роликів (розклад bathroom у piper_npc.dart: будні 8:00, вихідні 10:00).
const List<String> piperShowerVideoPaths = [
  'lib/assets/npcs/piper/video/shower.webm',
  'lib/assets/npcs/piper/video/shower2.webm',
  'lib/assets/npcs/piper/video/shaves_pussy1.webm',
  'lib/assets/npcs/piper/video/shaves_pussy.webm',
];

/// Час слоту «Пайпер у ванні / душ»: будні — 8:00, вихідні — 10:00 (після кухні о 9).
bool piperShowerScheduleHour(int hour, int weekdayIndex) {
  final weekend = weekdayIndex == 5 || weekdayIndex == 6;
  if (weekend) return hour == 10;
  return hour == 8;
}

String piperShowerVideoSeeded(int seed) {
  if (piperShowerVideoPaths.isEmpty) {
    return 'lib/assets/npcs/piper/video/shower.webm';
  }
  return piperShowerVideoPaths[Random(seed).nextInt(piperShowerVideoPaths.length)];
}
