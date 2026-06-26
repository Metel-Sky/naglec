import '../../models/npc_model.dart';
import '../../data/locations_room_data.dart';

const List<int> _weekdays = [0, 1, 2, 3, 4];

/// Галерея «Персонажі».
const String kNicoleGalleryPortraitPath = 'lib/assets/npcs/nicole/img/nicole_ava.jpg';

/// Аватар: коледж, телефон, профіль, смуга NPC, оверлей у коридорі.
const String kNicoleAvatarPath = 'lib/assets/npcs/nicole/nicole.png';

/// Nicole (завуч). У коледжі в будні 9–18: **під час пар** — завжди історія (`auditorium_3`);
/// **на перервах** — коридор або кабінет директора (див. [NPCService.nicoleCollegeRoamingRoom]).
/// Дім: спальня в будинку декана.
/// У [SchedulePoint.location] для коледжу залишено коридор лише для сумісності;
/// позицію в будні 9–18 задає [NPCService.nicoleCollegeRoamingRoom].
NPCModel createNicoleNpc() {
  return NPCModel(
    id: 'nicole',
    name: 'Nicole',
    fullName: 'Nicole',
    status: 'Викладачка історії',
    age: 39,
    galleryPortraitPath: kNicoleGalleryPortraitPath,
    avatarPath: kNicoleAvatarPath,
    schedule: [
      SchedulePoint(
        hourStart: 9,
        hourEnd: 18,
        location: LocationsData.collegeCorridor,
        actionLabel: 'У коледжі',
        spritePath: kNicoleAvatarPath,
        days: _weekdays,
      ),
      SchedulePoint(
        hourStart: 0,
        hourEnd: 8,
        location: LocationsData.poorVillageHeadTeacherBedroom,
        actionLabel: 'Вдома (спальня)',
        spritePath: kNicoleAvatarPath,
        days: _weekdays,
      ),
      SchedulePoint(
        hourStart: 19,
        hourEnd: 23,
        location: LocationsData.poorVillageHeadTeacherBedroom,
        actionLabel: 'Вдома (спальня)',
        spritePath: kNicoleAvatarPath,
        days: _weekdays,
      ),
      SchedulePoint(
        hourStart: 0,
        hourEnd: 23,
        location: LocationsData.poorVillageHeadTeacherBedroom,
        actionLabel: 'Вдома (спальня)',
        spritePath: kNicoleAvatarPath,
        days: [5, 6],
      ),
    ],
  );
}
