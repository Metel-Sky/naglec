import '../../models/npc_model.dart';
import '../../data/poor_district/poor_district_house_2.dart';

const String kFoxyGalleryPortraitPath = 'lib/assets/npcs/foxy/foxy.jpeg';
const String kFoxyAvatarPath = 'lib/assets/npcs/foxy/foxy_ava.png';

/// Foxy — мешканка бідного району, Бандери 2, квартира 3.
/// Тимчасовий розклад: постійно у спальні (детальний графік — пізніше).
NPCModel createFoxyNpc() {
  return NPCModel(
    id: 'foxy',
    gender: NpcGender.female,
    name: 'Foxy',
    fullName: 'Foxy',
    status: 'Шукає роботу',
    biographyType:
        'Живе в бідному районі, Бандери 2, квартира 3. Постійно шукає роботу, '
        'грошей не вистачає — за гроші згодна майже на все.',
    age: 19,
    money: -280,
    galleryPortraitPath: kFoxyGalleryPortraitPath,
    avatarPath: kFoxyAvatarPath,
    schedule: [
      SchedulePoint(
        hourStart: 0,
        hourEnd: 23,
        location: PoorDistrictHouse2.rA3_4,
        actionLabel: 'Вдома',
        spritePath: kFoxyAvatarPath,
      ),
    ],
  );
}
