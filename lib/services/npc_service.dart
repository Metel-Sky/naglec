import '../models/npc_model.dart';

class NPCService {
  // Список усіх персонажів гри
  final List<NPCModel> allNPCs = [
    NPCModel(
      id: 'mom',
      name: 'Мати',
      schedule: [
        // БУДНІ (0,1,2,3,4)
        SchedulePoint(
            hourStart: 7, hourEnd: 8, location: 'Кухня', actionLabel: 'Готує сніданок',
            spritePath: 'lib/assets/npcs/mom/video/zavtrak.webm',
            days: [0, 1, 2, 3, 4]),
        //#############################################################################
        SchedulePoint(hourStart: 8, hourEnd: 9, location: 'Ванна', actionLabel: 'Миється',
            spritePath: 'lib/assets/npcs/mom/mom_relax.jpg',
            days: [0, 1, 2, 3, 4]),
        //#############################################################################
        SchedulePoint(hourStart: 10, hourEnd: 18, location: 'Робота', days: [0, 1, 2, 3, 4]),
        //#############################################################################
        SchedulePoint(//19-20 кімната перевдягаеться
            hourStart: 19, hourEnd: 20, location: 'Кімната мами', actionLabel: 'Перевдягається',
            spritePath: 'lib/assets/npcs/mom/video/zavtrak.webm',
            days: [0, 1, 2, 3, 4]),
        //#############################################################################
        SchedulePoint(hourStart: 20, hourEnd: 21, location: 'Кухня', actionLabel: 'Готує вечерю',
            spritePath: 'lib/assets/npcs/mom/mom_relax.jpg',
            days: [0, 1, 2, 3, 4]),
        //#############################################################################

        // СУБОТА (5)
        SchedulePoint(hourStart: 9, hourEnd: 10, location: 'Ванна',
            spritePath: 'lib/assets/npcs/mom/mom_relax.jpg',
            days: [5]),
        //#############################################################################
        SchedulePoint(hourStart: 10, hourEnd: 12, location: 'Кухня',
            spritePath: 'lib/assets/npcs/mom/mom_relax.jpg',
            days: [5]),
        //#############################################################################
        SchedulePoint(hourStart: 21, hourEnd: 23, location: 'Зал', actionLabel: 'Дивиться ТВ',
            spritePath: 'lib/assets/npcs/mom/mom_relax.jpg',
            days: [5]),
        //#############################################################################

        // СПІЛЬНЕ (СОН)
        SchedulePoint(
          hourStart: 23,
          hourEnd: 7,
          location: 'Кімната мами',
          actionLabel: 'Спить',
          spritePath: 'lib/assets/npcs/mom/video/sleep_2.webm',
        ),
      ],
    ),
  ];

  // Логіка: знайти, хто зараз у кімнаті
  List<NPCModel> getNPCsInRoom(String roomName, int hour, int day) {
    // .where фільтрує список усіх NPC
    return allNPCs.where((npc) {
      // Перевіряємо, чи є хоч одна точка в розкладі, що відповідає умовам
      return npc.schedule.any((point) {
        // 1. Перевірка дня (якщо days == null, то NPC там щодня)
        if (point.days != null && !point.days!.contains(day)) {
          return false;
        }

        // 2. Перевірка локації
        if (point.location != roomName) {
          return false;
        }

        // 3. Перевірка часу (з урахуванням переходу через північ)
        bool timeMatches;
        if (point.hourStart <= point.hourEnd) {
          // Звичайний час (наприклад, 7:00 - 8:00)
          timeMatches = hour >= point.hourStart && hour < point.hourEnd;
        } else {
          // Час через північ (наприклад, 23:00 - 7:00)
          timeMatches = hour >= point.hourStart || hour < point.hourEnd;
        }

        return timeMatches;
      });
    }).toList(); // <--- .toList() має бути тут, після закриття .where
  }
}