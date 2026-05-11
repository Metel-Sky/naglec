import 'dart:math';

import 'locations_room_data.dart';

/// Розклад пар у коледжі (за цілою годиною [DateTime.hour], як у грі).
///
/// 1-а пара: 10:00–12:00 → години **10–11** у класі.
/// 2-а пара: 13:00–15:00 → **13–14**.
/// 3-я пара: 16:00–18:00 → **16–17**; о **18:00** пара вже закінчилась, у аудиторії нікого.
bool isCollegeLessonHour(int hour) {
  return (hour >= 10 && hour <= 11) ||
      (hour >= 13 && hour <= 14) ||
      (hour >= 16 && hour <= 17);
}

/// Будні коледжу (індекс як у [GameTimeController.weekdayIndex]): пн–пт.
const List<int> collegeWeekdayIndices = [0, 1, 2, 3, 4];

/// Між парами в коледжі: будні, 9–17, не години пар (перерви 9, 12, 15 тощо).
bool isCollegeTeacherBetweenLessons(int hour) {
  if (hour < 9 || hour > 17) return false;
  return !isCollegeLessonHour(hour);
}

/// Кімнати, де вчителі можуть бути **на перервах** (англійська, математика, історія,
/// коридор, бібліотека, спортзал, двір, туалет). Кабінет директора — ні.
const List<String> collegeTeacherBreakRoomIds = [
  LocationsData.auditorium1,
  LocationsData.auditorium2,
  LocationsData.auditorium3,
  LocationsData.collegeCorridor,
  LocationsData.canteen, // у даних — «Бібліотека»
  LocationsData.gym,
  LocationsData.collegeYard,
  LocationsData.toilet,
];

/// Під час перерви вчитель у **будь-якій** з [collegeTeacherBreakRoomIds] (детерміновано).
String collegeTeacherBreakRoom(String npcId, int weekdayIndex, int hour) {
  final seed =
      (weekdayIndex * 24 + hour) * 31 + npcId.hashCode + 'teacher_break'.hashCode;
  final i = Random(seed).nextInt(collegeTeacherBreakRoomIds.length);
  return collegeTeacherBreakRoomIds[i];
}

// --- Студентки + Sem: коледж 10–17, перерви як у вчителів, пари — випадкова з 3 аудиторій ---

/// Дівчата-студентки з роумінгом по коледжу (маркер у розкладі — [LocationsData.collegeHall] 10–17).
const List<String> collegeFemaleStudentNpcIds = [
  'elsa',
  'piper',
  'faye_reagan',
  'emily_willis',
  'ariana_marie',
  'anya',
];

/// Усі студенти з тим самим роумінгом (дівчата + Sem).
const List<String> collegeRoamingStudentNpcIds = [
  ...collegeFemaleStudentNpcIds,
  'sem',
];

/// Будні 10:00–17:59 — на території коледжу (фактична кімната задається роумінгом).
bool isCollegeStudentCampusHour(int hour) => hour >= 10 && hour <= 17;

/// Під час пар — випадкова аудиторія: англійська (1), математика (2), історія (3).
String collegeStudentLessonAuditorium(String npcId, int weekdayIndex, int hour) {
  const rooms = [
    LocationsData.auditorium1,
    LocationsData.auditorium2,
    LocationsData.auditorium3,
  ];
  final seed = (weekdayIndex * 24 + hour) * 31 +
      npcId.hashCode +
      'student_lesson_aud'.hashCode;
  return rooms[Random(seed).nextInt(rooms.length)];
}

/// На перервах (10–17, не години пар) — ті самі кімнати, що й у вчителів, інший seed.
String collegeStudentBreakRoom(String npcId, int weekdayIndex, int hour) {
  final seed = (weekdayIndex * 24 + hour) * 31 +
      npcId.hashCode +
      'student_break_room'.hashCode;
  final i = Random(seed).nextInt(collegeTeacherBreakRoomIds.length);
  return collegeTeacherBreakRoomIds[i];
}
