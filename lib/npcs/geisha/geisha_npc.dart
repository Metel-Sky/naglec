import '../../models/npc_model.dart';
import '../../data/poor_district/poor_district_house_2.dart';

const String kGeishaGalleryPortraitPath = 'lib/assets/npcs/geisha/geisha.jpg';
const String kGeishaAvatarPath = 'lib/assets/npcs/geisha/geisha_ava.png';

/// Geisha — живе з Zazie в бідному районі, Бандери 2, квартира 2 (спальня).
/// Тимчасовий розклад: постійно у своїй кімнаті (детальний графік — пізніше).
NPCModel createGeishaNpc() {
  return NPCModel(
    id: 'geisha',
    gender: NpcGender.female,
    name: 'Geisha',
    fullName: 'Geisha',
    status: 'Партнерка Zazie',
    biographyType:
        'Живе з Zazie в бідному районі, Бандери 2, у спальні квартири 2. Лесбійка.',
    age: 24,
    galleryPortraitPath: kGeishaGalleryPortraitPath,
    avatarPath: kGeishaAvatarPath,
    schedule: [
      SchedulePoint(
        hourStart: 0,
        hourEnd: 23,
        location: PoorDistrictHouse2.rA2_4,
        actionLabel: 'Вдома',
        spritePath: kGeishaAvatarPath,
      ),
    ],
  );
}
