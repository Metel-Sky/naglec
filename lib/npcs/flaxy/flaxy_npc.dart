import '../../models/npc_model.dart';
import '../../data/locations_room_data.dart';

const String kFlaxyGalleryPortraitPath = 'lib/assets/npcs/flaxy/flaxy.jpg';
const String kFlaxyAvatarPath = 'lib/assets/npcs/flaxy/flaxy_ava.png';

/// Flaxy — донька Alexis, племінниця ГG. Будинок тітки на вул. Шевченка.
/// Тимчасовий розклад: випадкова кімната вдома (детальний графік — пізніше).
NPCModel createFlaxyNpc() {
  return NPCModel(
    id: 'flaxy',
    gender: NpcGender.female,
    name: 'Flaxy',
    fullName: 'Flaxy',
    status: 'Племінниця',
    biographyType:
        'Донька Alexis. Живе з мамою у будинку на вул. Шевченка, у своїй кімнаті.',
    age: 22,
    galleryPortraitPath: kFlaxyGalleryPortraitPath,
    avatarPath: kFlaxyAvatarPath,
    schedule: [
      SchedulePoint(
        hourStart: 0,
        hourEnd: 23,
        location: LocationsData.auntHomeFlaxyRoam,
        actionLabel: 'Вдома',
        spritePath: kFlaxyAvatarPath,
      ),
    ],
  );
}
