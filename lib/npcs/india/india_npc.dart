import '../../models/npc_model.dart';
import '../../data/locations_room_data.dart';

const List<int> _weekdays = [0, 1, 2, 3, 4];

// Тимчасово: заглушка, доки не буде окремого арту India.
const String kIndiaGalleryPortraitPath = 'lib/assets/npcs/india/india_ava.jpg';
const String kIndiaAvatarPath = 'lib/assets/npcs/india/india.png';

/// India — дружина власника колцентру.
/// Працює 10–17 у кімнаті керівника колцентру, живе в Мажорщині у домі Artur (спальня).
NPCModel createIndiaNpc() {
  return NPCModel(
    id: 'india_summer',
    gender: NpcGender.female,
    name: 'India',
    fullName: 'India',
    status: 'Дружина Артура',
    age: 43,
    galleryPortraitPath: kIndiaGalleryPortraitPath,
    avatarPath: kIndiaAvatarPath,
    schedule: [
      SchedulePoint(
        hourStart: 10,
        hourEnd: 17,
        location: LocationsData.cityBcCallCenterBossOffice,
        actionLabel: 'Працює в колцентрі',
        spritePath: kIndiaAvatarPath,
        days: _weekdays,
      ),
      SchedulePoint(
        hourStart: 0,
        hourEnd: 9,
        location: LocationsData.poorVillageCallCenterBossRoom1,
        actionLabel: 'Вдома (спальня)',
        spritePath: kIndiaAvatarPath,
        days: _weekdays,
      ),
      SchedulePoint(
        hourStart: 18,
        hourEnd: 23,
        location: LocationsData.poorVillageCallCenterBossRoom1,
        actionLabel: 'Вдома (спальня)',
        spritePath: kIndiaAvatarPath,
        days: _weekdays,
      ),
      SchedulePoint(
        hourStart: 0,
        hourEnd: 23,
        location: LocationsData.poorVillageCallCenterBossRoom1,
        actionLabel: 'Вихідні вдома',
        spritePath: kIndiaAvatarPath,
        days: [5, 6],
      ),
    ],
  );
}
