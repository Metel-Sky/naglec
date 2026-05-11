import '../../models/npc_model.dart';
import '../../data/locations_room_data.dart';

const List<int> _weekdays = [0, 1, 2, 3, 4];

/// Заглушка: заміни на `lib/assets/npcs/emily/...` після додавання арту.
const String kEmilyGalleryPortraitPath = 'lib/assets/npcs/emily/emily.jpg';
const String kEmilyAvatarPath = 'lib/assets/npcs/emily/emily_ava.png';

/// Emily Willis — одногрупниця. Дім шефа колцентру (Мажорщина), кімната 2 — «Кімната Emily». Коледж 10–17 у будні (роумінг).
NPCModel createEmilyNpc() {
  return NPCModel(
    id: 'emily_willis',
    gender: NpcGender.female,
    name: 'Emily',
    fullName: 'Emily',
    status: 'Одногрупниця',
    age: 18,
    galleryPortraitPath: kEmilyGalleryPortraitPath,
    avatarPath: kEmilyAvatarPath,
    schedule: [
      SchedulePoint(
        hourStart: 10,
        hourEnd: 17,
        location: LocationsData.collegeHall,
        actionLabel: 'У коледжі',
        spritePath: kEmilyAvatarPath,
        days: _weekdays,
      ),
      SchedulePoint(
        hourStart: 0,
        hourEnd: 9,
        location: LocationsData.poorVillageCallCenterBossRoom2,
        actionLabel: 'Вдома (кімната Emily)',
        spritePath: kEmilyAvatarPath,
        days: _weekdays,
      ),
      SchedulePoint(
        hourStart: 18,
        hourEnd: 23,
        location: LocationsData.poorVillageCallCenterBossRoom2,
        actionLabel: 'Вдома (кімната Emily)',
        spritePath: kEmilyAvatarPath,
        days: _weekdays,
      ),
      SchedulePoint(
        hourStart: 0,
        hourEnd: 23,
        location: LocationsData.poorVillageCallCenterBossRoom2,
        actionLabel: 'Вихідні вдома',
        spritePath: kEmilyAvatarPath,
        days: [5, 6],
      ),
    ],
  );
}
