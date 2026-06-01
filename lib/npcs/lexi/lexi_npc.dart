import '../../models/npc_model.dart';
import '../../data/locations_room_data.dart';

const String kLexiGalleryPortraitPath = 'lib/assets/npcs/lexi/lexi.jpg';
const String kLexiAvatarPath = 'lib/assets/npcs/lexi/lexi_ava.png';

/// Lexi — мама однокласниці. Будинок на вул. Шевченка.
/// Тимчасовий розклад: випадкова кімната вдома (детальний графік — пізніше).
NPCModel createLexiNpc() {
  return NPCModel(
    id: 'lexi',
    gender: NpcGender.female,
    name: 'Lexi',
    fullName: 'Lexi',
    status: 'Мати однокласниці',
    biographyType:
        'Мати Alyssa. Живе з донькою у будинку на вул. Шевченка, у кімнаті батьків.',
    age: 45,
    galleryPortraitPath: kLexiGalleryPortraitPath,
    avatarPath: kLexiAvatarPath,
    schedule: [
      SchedulePoint(
        hourStart: 0,
        hourEnd: 23,
        location: LocationsData.classmateHomeLexiRoam,
        actionLabel: 'Вдома',
        spritePath: kLexiAvatarPath,
      ),
    ],
  );
}
