import '../../models/npc_model.dart';
import '../../data/locations_room_data.dart';

const String kCeciliaGalleryPortraitPath = 'lib/assets/npcs/cecilia/cecilia.jpg';
const String kCeciliaAvatarPath = 'lib/assets/npcs/cecilia/cecilia_ava.png';

/// Cecilia — мешканка дому Amia (Мажорщина), кімната 2.
/// Тимчасовий розклад: постійно у своїй кімнаті (детальний графік — пізніше).
NPCModel createCeciliaNpc() {
  return NPCModel(
    id: 'cecilia',
    gender: NpcGender.female,
    name: 'Cecilia',
    fullName: 'Cecilia',
    status: 'Знімає кімнату в Amia',
    biographyType: 'Знімає кімнату в Amia в Мажорщині. Поки що ніде не працює.',
    age: 19,
    galleryPortraitPath: kCeciliaGalleryPortraitPath,
    avatarPath: kCeciliaAvatarPath,
    schedule: [
      SchedulePoint(
        hourStart: 0,
        hourEnd: 23,
        location: LocationsData.poorVillageEnglishwomanRoom2,
        actionLabel: 'Вдома',
        spritePath: kCeciliaAvatarPath,
      ),
    ],
  );
}
