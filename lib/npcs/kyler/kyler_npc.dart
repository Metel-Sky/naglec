import '../../models/npc_model.dart';
import '../../data/locations_room_data.dart';
import '../../data/poor_district/poor_district_house_2.dart';

const String kKylerGalleryPortraitPath = 'lib/assets/npcs/kyler/kyler.jpg';
const String kKylerAvatarPath = 'lib/assets/npcs/kyler/kyler_ava.png';

/// Kyler — мешканка бідного району, Бандери 2, кв. 1.
/// Тимчасовий розклад: вдень — випадкова кімната; вночі — спальня (детальний графік — пізніше).
NPCModel createKylerNpc() {
  return NPCModel(
    id: 'kyler',
    gender: NpcGender.female,
    name: 'Kyler',
    fullName: 'Kyler',
    status: 'Мешканка',
    biographyType:
        'Живе в бідному районі, Бандери 2, квартира 1.',
    age: 18,
    galleryPortraitPath: kKylerGalleryPortraitPath,
    avatarPath: kKylerAvatarPath,
    schedule: [
      SchedulePoint(
        hourStart: 23,
        hourEnd: 6,
        location: PoorDistrictHouse2.rA1_4,
        actionLabel: 'Спить',
        spritePath: kKylerAvatarPath,
      ),
      SchedulePoint(
        hourStart: 7,
        hourEnd: 22,
        location: LocationsData.poorDistrictH2Apt1KylerRoam,
        actionLabel: 'Вдома',
        spritePath: kKylerAvatarPath,
      ),
    ],
  );
}
