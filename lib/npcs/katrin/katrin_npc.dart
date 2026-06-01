import '../../models/npc_model.dart';
import '../../data/locations_room_data.dart';
import '../../data/poor_district/poor_district_house_1.dart';

const String kKatrinGalleryPortraitPath = 'lib/assets/npcs/katrin/katrin.jpg';
const String kKatrinAvatarPath = 'lib/assets/npcs/katrin/katrin_ava.png';

/// Katrin — мешканка бідного району, Бандери 1, кв. 2.
/// Тимчасовий розклад: вдень — випадкова кімната; вночі — спальня (детальний графік — пізніше).
NPCModel createKatrinNpc() {
  return NPCModel(
    id: 'katrin',
    gender: NpcGender.female,
    name: 'Katrin',
    fullName: 'Katrin',
    status: 'Мешканка',
    biographyType:
        'Живе в бідному районі, Бандери 1, квартира 2.',
    age: 23,
    galleryPortraitPath: kKatrinGalleryPortraitPath,
    avatarPath: kKatrinAvatarPath,
    schedule: [
      SchedulePoint(
        hourStart: 23,
        hourEnd: 6,
        location: PoorDistrictHouse1.rA2_4,
        actionLabel: 'Спить',
        spritePath: kKatrinAvatarPath,
      ),
      SchedulePoint(
        hourStart: 7,
        hourEnd: 22,
        location: LocationsData.poorDistrictH1Apt2KatrinRoam,
        actionLabel: 'Вдома',
        spritePath: kKatrinAvatarPath,
      ),
    ],
  );
}
