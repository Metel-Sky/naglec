import '../../models/npc_model.dart';
import '../../data/locations_room_data.dart';

const List<int> _weekdays = [0, 1, 2, 3, 4];

const String kDekanGalleryPortraitPath = 'lib/assets/npcs/dekan/dekan.png';
const String kDekanAvatarPath = 'lib/assets/npcs/dekan/dekan_ava.png';

/// Декан. У будні 9–18 — **кабінет директора** коледжу (разом із Nicole може бути лише вони).
/// Поза роботою — у спальні власного дому (Мажорщина).
NPCModel createDekanNpc() {
  return NPCModel(
    id: 'dekan',
    name: 'Dekan',
    fullName: 'Dekan',
    status: 'Декан',
    age: 46,
    gender: NpcGender.male,
    galleryPortraitPath: kDekanGalleryPortraitPath,
    avatarPath: kDekanAvatarPath,
    schedule: [
      SchedulePoint(
        hourStart: 9,
        hourEnd: 18,
        location: LocationsData.directorOffice,
        actionLabel: 'У кабінеті директора',
        spritePath: kDekanAvatarPath,
        days: _weekdays,
      ),
      SchedulePoint(
        hourStart: 19,
        hourEnd: 8,
        location: LocationsData.poorVillageHeadTeacherBedroom,
        actionLabel: 'Вдома (спальня)',
        spritePath: kDekanAvatarPath,
        days: _weekdays,
      ),
      SchedulePoint(
        hourStart: 0,
        hourEnd: 23,
        location: LocationsData.poorVillageHeadTeacherBedroom,
        actionLabel: 'Вдома (спальня)',
        spritePath: kDekanAvatarPath,
        days: [5, 6],
      ),
    ],
  );
}
