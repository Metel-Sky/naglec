import '../../models/npc_model.dart';
import '../../data/poor_district/poor_district_house_1.dart';

const String kPetaGalleryPortraitPath = 'lib/assets/npcs/peta/peta.jpg';
const String kPetaAvatarPath = 'lib/assets/npcs/peta/peta_ava.png';

/// Peta — мешканка бідного району, Бандери 1, кв. 3.
/// Тимчасовий розклад: постійно у спальні (детальний графік — пізніше).
NPCModel createPetaNpc() {
  return NPCModel(
    id: 'peta',
    gender: NpcGender.female,
    name: 'Peta',
    fullName: 'Peta',
    status: 'Мешканка',
    biographyType:
        'Живе в бідному районі, Бандери 1, квартира 3. Постійно в боргах.',
    age: 37,
    money: -350,
    galleryPortraitPath: kPetaGalleryPortraitPath,
    avatarPath: kPetaAvatarPath,
    schedule: [
      SchedulePoint(
        hourStart: 0,
        hourEnd: 23,
        location: PoorDistrictHouse1.rA3_4,
        actionLabel: 'Вдома',
        spritePath: kPetaAvatarPath,
      ),
    ],
  );
}
