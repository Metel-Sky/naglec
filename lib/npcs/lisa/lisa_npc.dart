import '../../models/npc_model.dart';
import '../../data/locations_room_data.dart';

const List<int> _weekdays = [0, 1, 2, 3, 4];

const String kLisaGalleryPortraitPath = 'lib/assets/npcs/lisa/lisa_ava.jpg';
const String kLisaAvatarPath = 'lib/assets/npcs/lisa/lisa.png';

/// Lisa — вчителька математики. Тимчасово — дім декана, спальня.
/// У коледжі: під час пар — `auditorium_2`; між парами — одна з 8 кімнат перерви (`collegeTeacherBreakRoomIds`); у вихідні — вдома. Кабінет директора — ні.
NPCModel createLisaNpc() {
  return NPCModel(
    id: 'lisa',
    name: 'Lisa',
    fullName: 'Lisa',
    status: 'Вчителька математики',
    age: 45,
    galleryPortraitPath: kLisaGalleryPortraitPath,
    avatarPath: kLisaAvatarPath,
    schedule: [
      SchedulePoint(
        hourStart: 19,
        hourEnd: 8,
        location: LocationsData.poorVillageHeadTeacherBedroom,
        actionLabel: 'Вдома',
        spritePath: kLisaAvatarPath,
        days: _weekdays,
      ),
      SchedulePoint(
        hourStart: 0,
        hourEnd: 23,
        location: LocationsData.poorVillageHeadTeacherBedroom,
        actionLabel: 'Вдома',
        spritePath: kLisaAvatarPath,
        days: [5, 6],
      ),
      SchedulePoint(
        hourStart: 9,
        hourEnd: 9,
        location: LocationsData.poorVillageHeadTeacherBedroom,
        actionLabel: 'Вдома',
        spritePath: kLisaAvatarPath,
        days: _weekdays,
      ),
      SchedulePoint(
        hourStart: 10,
        hourEnd: 11,
        location: LocationsData.auditorium2,
        actionLabel: 'Урок математики',
        spritePath: kLisaAvatarPath,
        days: _weekdays,
      ),
      SchedulePoint(
        hourStart: 12,
        hourEnd: 12,
        location: LocationsData.poorVillageHeadTeacherBedroom,
        actionLabel: 'Вдома',
        spritePath: kLisaAvatarPath,
        days: _weekdays,
      ),
      SchedulePoint(
        hourStart: 13,
        hourEnd: 14,
        location: LocationsData.auditorium2,
        actionLabel: 'Урок математики',
        spritePath: kLisaAvatarPath,
        days: _weekdays,
      ),
      SchedulePoint(
        hourStart: 15,
        hourEnd: 15,
        location: LocationsData.poorVillageHeadTeacherBedroom,
        actionLabel: 'Вдома',
        spritePath: kLisaAvatarPath,
        days: _weekdays,
      ),
      SchedulePoint(
        hourStart: 16,
        hourEnd: 17,
        location: LocationsData.auditorium2,
        actionLabel: 'Урок математики',
        spritePath: kLisaAvatarPath,
        days: _weekdays,
      ),
      SchedulePoint(
        hourStart: 18,
        hourEnd: 23,
        location: LocationsData.poorVillageHeadTeacherBedroom,
        actionLabel: 'Вдома',
        spritePath: kLisaAvatarPath,
        days: _weekdays,
      ),
    ],
  );
}
