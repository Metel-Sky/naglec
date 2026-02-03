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
            hourStart: 7,
            hourEnd: 8,
            location: 'Кухня',
            actionLabel: 'Готує сніданок',
            spritePath: 'lib/assets/npcs/mom/video/zavtrak.webm', // Специфічне фото
            days: [0,1,2,3,4]),
        SchedulePoint(hourStart: 8, hourEnd: 9, location: 'Ванна', actionLabel: 'Миється', days: [0,1,2,3,4]),
        SchedulePoint(hourStart: 10, hourEnd: 18, location: 'Робота', days: [0,1,2,3,4]),
        SchedulePoint(hourStart: 19, hourEnd: 20, location: 'Кімната мами', actionLabel: 'Перевдягається', days: [0,1,2,3,4]),
        SchedulePoint(hourStart: 20, hourEnd: 21, location: 'Кухня', actionLabel: 'Готує вечерю', days: [0,1,2,3,4]),

        // СУБОТА (5)
        SchedulePoint(hourStart: 9, hourEnd: 10, location: 'Ванна', days: [5]),
        SchedulePoint(hourStart: 10, hourEnd: 12, location: 'Кухня', days: [5]),
        SchedulePoint(hourStart: 21, hourEnd: 23, location: 'Зал', actionLabel: 'Дивиться ТВ', days: [5]),

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
    // Сюди потім просто додаси NPCModel(id: 'sister', ...)
  ];

  // Логіка: знайти, хто зараз у кімнаті
  List<NPCModel> getNPCsInRoom(String roomName, int hour, int weekday) {
    return allNPCs.where((npc) {
      for (var point in npc.schedule) {
        bool dayMatches = point.days == null || point.days!.contains(weekday);
        // Обробка нічного часу (наприклад, з 23 до 7)
        bool timeMatches;
        if (point.hourStart > point.hourEnd) {
          timeMatches = hour >= point.hourStart || hour < point.hourEnd;
        } else {
          timeMatches = hour >= point.hourStart && hour < point.hourEnd;
        }

        if (dayMatches && timeMatches && point.location == roomName) {
          return true;
        }
      }
      return false;
    }).toList();
  }
}