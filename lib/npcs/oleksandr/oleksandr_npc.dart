import '../../models/npc_model.dart';
import '../../data/locations_room_data.dart';

const List<int> _weekdays = [0, 1, 2, 3, 4];

const String kOleksandrGalleryPortraitPath =
    'lib/assets/npcs/oleksandr/oleksandr.png';
const String kOleksandrAvatarPath =
    'lib/assets/npcs/oleksandr/oleksandr_ava.png';

/// Oleksandr — начальник логістичної компанії, 47 років.
/// Живе в будинку компанії (Мажорщина), спальня. Будні 9–20 — офіс шефа в БЦ.
NPCModel createOleksandrNpc() {
  return NPCModel(
    id: 'oleksandr',
    gender: NpcGender.male,
    name: 'Oleksandr',
    fullName: 'Oleksandr',
    status: 'Начальник логістичної компанії',
    age: 47,
    galleryPortraitPath: kOleksandrGalleryPortraitPath,
    avatarPath: kOleksandrAvatarPath,
    schedule: [
      SchedulePoint(
        hourStart: 9,
        hourEnd: 20,
        location: LocationsData.cityBcLogisticsBossOffice,
        actionLabel: 'У офісі',
        spritePath: kOleksandrAvatarPath,
        days: _weekdays,
      ),
      SchedulePoint(
        hourStart: 0,
        hourEnd: 8,
        location: LocationsData.poorVillageLogisticsBossRoom1,
        actionLabel: 'Вдома (спальня)',
        spritePath: kOleksandrAvatarPath,
        days: _weekdays,
      ),
      SchedulePoint(
        hourStart: 21,
        hourEnd: 23,
        location: LocationsData.poorVillageLogisticsBossRoom1,
        actionLabel: 'Вдома (спальня)',
        spritePath: kOleksandrAvatarPath,
        days: _weekdays,
      ),
      SchedulePoint(
        hourStart: 0,
        hourEnd: 23,
        location: LocationsData.poorVillageLogisticsBossRoom1,
        actionLabel: 'Вихідні вдома (спальня)',
        spritePath: kOleksandrAvatarPath,
        days: [5, 6],
      ),
    ],
  );
}
