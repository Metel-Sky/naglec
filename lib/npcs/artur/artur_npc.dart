import '../../models/npc_model.dart';
import '../../data/locations_room_data.dart';

const List<int> _weekdays = [0, 1, 2, 3, 4];

const String kArturGalleryPortraitPath = 'lib/assets/npcs/artur/artur.png';
const String kArturAvatarPath = 'lib/assets/npcs/artur/artur_ava.png';

/// Artur — начальник колл-центру, 47 років. Дім Артура (Мажорщина), спальня.
/// Дуже багатий, власник декількох фірм; основна — кол-центр. Періодично літає по світу.
NPCModel createArturNpc() {
  return NPCModel(
    id: 'artur',
    gender: NpcGender.male,
    name: 'Artur',
    fullName: 'Artur',
    status: 'Начальник колл-центру',
    biographyType:
        'Дуже багатий власник декількох фірм; основна — кол-центр. Періодично літає по всьому світу.',
    age: 47,
    galleryPortraitPath: kArturGalleryPortraitPath,
    avatarPath: kArturAvatarPath,
    schedule: [
      SchedulePoint(
        hourStart: 9,
        hourEnd: 18,
        location: LocationsData.cityBcCallCenterBossOffice,
        actionLabel: 'У колл-центрі',
        spritePath: kArturAvatarPath,
        days: _weekdays,
      ),
      SchedulePoint(
        hourStart: 0,
        hourEnd: 8,
        location: LocationsData.poorVillageCallCenterBossRoom1,
        actionLabel: 'Вдома (спальня)',
        spritePath: kArturAvatarPath,
        days: _weekdays,
      ),
      SchedulePoint(
        hourStart: 19,
        hourEnd: 23,
        location: LocationsData.poorVillageCallCenterBossRoom1,
        actionLabel: 'Вдома (спальня)',
        spritePath: kArturAvatarPath,
        days: _weekdays,
      ),
      SchedulePoint(
        hourStart: 0,
        hourEnd: 23,
        location: LocationsData.poorVillageCallCenterBossRoom1,
        actionLabel: 'Вихідні вдома',
        spritePath: kArturAvatarPath,
        days: [5, 6],
      ),
    ],
  );
}
