import '../../models/npc_model.dart';
import '../../data/locations_room_data.dart';

const String kTiffanyGalleryPortraitPath = 'lib/assets/npcs/tiffany/tiffany.jpg';
const String kTiffanyAvatarPath = 'lib/assets/npcs/tiffany/tiffany_ava.png';

/// Tiffany — мешканка дому Amia (Мажорщина), кімната 3.
/// Тимчасовий розклад: постійно у своїй кімнаті (детальний графік — пізніше).
NPCModel createTiffanyNpc() {
  return NPCModel(
    id: 'tiffany',
    gender: NpcGender.female,
    name: 'Tiffany',
    fullName: 'Tiffany',
    status: 'Знімає кімнату в Amia',
    biographyType: 'Знімає кімнату в Amia в Мажорщині. Поки що ніде не працює.',
    age: 20,
    galleryPortraitPath: kTiffanyGalleryPortraitPath,
    avatarPath: kTiffanyAvatarPath,
    schedule: [
      SchedulePoint(
        hourStart: 0,
        hourEnd: 23,
        location: LocationsData.poorVillageEnglishwomanRoom3,
        actionLabel: 'Вдома',
        spritePath: kTiffanyAvatarPath,
      ),
    ],
  );
}
