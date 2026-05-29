import '../../models/npc_model.dart';
import '../../data/locations_room_data.dart';

const List<int> _weekdays = [0, 1, 2, 3, 4];

const String kAmiaGalleryPortraitPath = 'lib/assets/npcs/amia/amia_ava.jpg';
const String kAmiaAvatarPath = 'lib/assets/npcs/amia/amia.png';

/// Amia Miley — вчителька англійської. Живе в Мажорщині (дім Amia).
/// У коледжі: під час пар — `auditorium_1`; між парами — одна з 8 кімнат перерви (`collegeTeacherBreakRoomIds`); у вихідні — вдома. Кабінет директора — ні.
NPCModel createAmiaNpc() {
  return NPCModel(
    id: 'amia',
    name: 'Amia',
    fullName: 'Amia',
    status: 'Вчителька англійської',
    age: 26,
    galleryPortraitPath: kAmiaGalleryPortraitPath,
    avatarPath: kAmiaAvatarPath,
    schedule: [
      // Ніч / ранок до 9:00 (будні)
      SchedulePoint(
        hourStart: 19,
        hourEnd: 8,
        location: LocationsData.poorVillageEnglishwomanRoom1,
        actionLabel: 'Вдома',
        spritePath: kAmiaAvatarPath,
        days: _weekdays,
      ),
      SchedulePoint(
        hourStart: 0,
        hourEnd: 23,
        location: LocationsData.poorVillageEnglishwomanRoom1,
        actionLabel: 'Вдома',
        spritePath: kAmiaAvatarPath,
        days: [5, 6],
      ),
      SchedulePoint(
        hourStart: 9,
        hourEnd: 9,
        location: LocationsData.poorVillageEnglishwomanRoom1,
        actionLabel: 'Вдома',
        spritePath: kAmiaAvatarPath,
        days: _weekdays,
      ),
      SchedulePoint(
        hourStart: 10,
        hourEnd: 11,
        location: LocationsData.auditorium1,
        actionLabel: 'Урок англійської',
        spritePath: kAmiaAvatarPath,
        days: _weekdays,
      ),
      SchedulePoint(
        hourStart: 12,
        hourEnd: 12,
        location: LocationsData.poorVillageEnglishwomanRoom1,
        actionLabel: 'Вдома',
        spritePath: kAmiaAvatarPath,
        days: _weekdays,
      ),
      SchedulePoint(
        hourStart: 13,
        hourEnd: 14,
        location: LocationsData.auditorium1,
        actionLabel: 'Урок англійської',
        spritePath: kAmiaAvatarPath,
        days: _weekdays,
      ),
      SchedulePoint(
        hourStart: 15,
        hourEnd: 15,
        location: LocationsData.poorVillageEnglishwomanRoom1,
        actionLabel: 'Вдома',
        spritePath: kAmiaAvatarPath,
        days: _weekdays,
      ),
      SchedulePoint(
        hourStart: 16,
        hourEnd: 17,
        location: LocationsData.auditorium1,
        actionLabel: 'Урок англійської',
        spritePath: kAmiaAvatarPath,
        days: _weekdays,
      ),
      SchedulePoint(
        hourStart: 18,
        hourEnd: 23,
        location: LocationsData.poorVillageEnglishwomanRoom1,
        actionLabel: 'Вдома',
        spritePath: kAmiaAvatarPath,
        days: _weekdays,
      ),
    ],
  );
}
