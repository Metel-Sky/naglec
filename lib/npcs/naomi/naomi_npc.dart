import '../../models/npc_model.dart';
import '../../data/locations_room_data.dart';

const String kNaomiGalleryPortraitPath = 'lib/assets/npcs/naomi/naomi.jpg';
const String kNaomiAvatarPath = 'lib/assets/npcs/naomi/naomi_ava.png';

/// Naomi — донька декана, 19 років. Живе в будинку декана (Мажорщина), кімната Naomi.
/// Тимчасовий розклад: постійно у своїй кімнаті (детальний графік — пізніше).
NPCModel createNaomiNpc() {
  return NPCModel(
    id: 'naomi',
    gender: NpcGender.female,
    name: 'Naomi',
    fullName: 'Naomi',
    status: 'Донька декана',
    biographyType:
        'Донька декана. Живе в будинку декана в Мажорщині, у кімнаті Naomi.',
    age: 19,
    galleryPortraitPath: kNaomiGalleryPortraitPath,
    avatarPath: kNaomiAvatarPath,
    schedule: [
      SchedulePoint(
        hourStart: 0,
        hourEnd: 23,
        location: LocationsData.poorVillageHeadTeacherRoom,
        actionLabel: 'Вдома',
        spritePath: kNaomiAvatarPath,
      ),
    ],
  );
}
