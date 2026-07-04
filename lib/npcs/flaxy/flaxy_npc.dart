import '../../models/npc_model.dart';
import '../../data/locations_room_data.dart';
import '../../data/poor_district/poor_district_house_1.dart';

const String kFlaxyGalleryPortraitPath = 'lib/assets/npcs/flaxy/flaxy.jpg';
const String kFlaxyAvatarPath = 'lib/assets/npcs/flaxy/flaxy_ava.png';

/// Flaxy — донька Alexis, племінниця ГG. Квартира 2, Бандери 1 (бідний район).
/// Тимчасовий розклад: вдень — випадкова кімната; вночі — спальня (детальний графік — пізніше).
NPCModel createFlaxyNpc() {
  return NPCModel(
    id: 'flaxy',
    gender: NpcGender.female,
    name: 'Flaxy',
    fullName: 'Flaxy',
    status: 'Племінниця',
    biographyType:
        'Донька Alexis. Живе окремо в бідному районі, Бандери 1, квартира 2.',
    age: 22,
    galleryPortraitPath: kFlaxyGalleryPortraitPath,
    avatarPath: kFlaxyAvatarPath,
    schedule: [
      SchedulePoint(
        hourStart: 23,
        hourEnd: 6,
        location: PoorDistrictHouse1.rA2_4,
        actionLabel: 'Спить',
        spritePath: kFlaxyAvatarPath,
      ),
      SchedulePoint(
        hourStart: 7,
        hourEnd: 22,
        location: LocationsData.poorDistrictH1Apt2FlaxyRoam,
        actionLabel: 'Вдома',
        spritePath: kFlaxyAvatarPath,
      ),
    ],
  );
}
