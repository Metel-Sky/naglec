import '../../models/npc_model.dart';
import '../../data/poor_district/poor_district_house_2.dart';

const String kNikkiGalleryPortraitPath = 'lib/assets/npcs/nikki/nikki.webp';
const String kNikkiAvatarPath = 'lib/assets/npcs/nikki/nikki_ava.png';

/// Nikki — мешканка бідного району, Бандери 2, квартира 3.
/// Найкраща подруга мами. Тимчасовий розклад: постійно у своїй кімнаті.
NPCModel createNikkiNpc() {
  return NPCModel(
    id: 'nikki',
    gender: NpcGender.female,
    name: 'Nikki',
    fullName: 'Nikki',
    status: 'Найкраща подруга мами',
    biographyType:
        'Живе в бідному районі, Бандери 2, квартира 3. Найкраща подруга мами ГG.',
    age: 43,
    galleryPortraitPath: kNikkiGalleryPortraitPath,
    avatarPath: kNikkiAvatarPath,
    schedule: [
      SchedulePoint(
        hourStart: 0,
        hourEnd: 23,
        location: PoorDistrictHouse2.rA3_3,
        actionLabel: 'Вдома',
        spritePath: kNikkiAvatarPath,
      ),
    ],
  );
}
