import '../../models/npc_model.dart';
import '../../data/locations_room_data.dart';

const List<int> _weekdays = [0, 1, 2, 3, 4];

/// Заглушка: заміни на `lib/assets/npcs/faye/...` після додавання арту.
const String kFayeGalleryPortraitPath = 'lib/assets/npcs/faye/faye.jpg';
const String kFayeAvatarPath = 'lib/assets/npcs/faye/faye_ava.png';

/// Faye Reagan — сестра Дена, одногрупниця. Коледж 10–17 у будні (роумінг — [NPCService]);
/// вдома — будинок начальника логістики, «Кімната Faye».
NPCModel createFayeNpc() {
  return NPCModel(
    id: 'faye_reagan',
    gender: NpcGender.female,
    name: 'Faye',
    fullName: 'Faye',
    status: 'Одногрупниця',
    subStatus: 'Сестра Дена',
    age: 19,
    galleryPortraitPath: kFayeGalleryPortraitPath,
    avatarPath: kFayeAvatarPath,
    schedule: [
      SchedulePoint(
        hourStart: 10,
        hourEnd: 17,
        location: LocationsData.collegeHall,
        actionLabel: 'У коледжі',
        spritePath: kFayeAvatarPath,
        days: _weekdays,
      ),
      SchedulePoint(
        hourStart: 0,
        hourEnd: 9,
        location: LocationsData.poorVillageLogisticsBossRoom2,
        actionLabel: 'Вдома (кімната Faye)',
        spritePath: kFayeAvatarPath,
        days: _weekdays,
      ),
      SchedulePoint(
        hourStart: 18,
        hourEnd: 23,
        location: LocationsData.poorVillageLogisticsBossRoom2,
        actionLabel: 'Вдома (кімната Faye)',
        spritePath: kFayeAvatarPath,
        days: _weekdays,
      ),
      SchedulePoint(
        hourStart: 0,
        hourEnd: 23,
        location: LocationsData.poorVillageLogisticsBossRoom2,
        actionLabel: 'Вихідні вдома (кімната Faye)',
        spritePath: kFayeAvatarPath,
        days: [5, 6],
      ),
    ],
  );
}
