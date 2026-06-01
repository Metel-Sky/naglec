import '../../models/npc_model.dart';
import '../../data/poor_district/poor_district_house_2.dart';

const String kZazieGalleryPortraitPath = 'lib/assets/npcs/zazie/zazie.jpg';
const String kZazieAvatarPath = 'lib/assets/npcs/zazie/zazie_ava.png';

/// Zazie — мешканка бідного району, Бандери 2, квартира 2 (спальня).
/// Тимчасовий розклад: постійно у своїй кімнаті (детальний графік — пізніше).
NPCModel createZazieNpc() {
  return NPCModel(
    id: 'zazie',
    gender: NpcGender.female,
    name: 'Zazie',
    fullName: 'Zazie',
    status: 'Мешканка',
    biographyType:
        'Живе з Geisha в бідному районі, Бандери 2, квартира 2. Лесбійка.',
    age: 19,
    galleryPortraitPath: kZazieGalleryPortraitPath,
    avatarPath: kZazieAvatarPath,
    schedule: [
      SchedulePoint(
        hourStart: 0,
        hourEnd: 23,
        location: PoorDistrictHouse2.rA2_4,
        actionLabel: 'Вдома',
        spritePath: kZazieAvatarPath,
      ),
    ],
  );
}
