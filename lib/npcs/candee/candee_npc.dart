import '../../models/npc_model.dart';
import '../../data/locations_room_data.dart';

const String kCandeeGalleryPortraitPath = 'lib/assets/npcs/candee/candee.jpg';
const String kCandeeAvatarPath = 'lib/assets/npcs/candee/candee_ava.png';

/// Candee — сестра Alyssa. Будинок на вул. Шевченка.
/// Тимчасовий розклад: випадкова кімната вдома (детальний графік — пізніше).
NPCModel createCandeeNpc() {
  return NPCModel(
    id: 'candee',
    gender: NpcGender.female,
    name: 'Candee',
    fullName: 'Candee',
    status: 'Сестра Alyssa',
    biographyType:
        'Молодша сестра Alyssa. Живе з мамою Lexi у будинку на вул. Шевченка, у своїй кімнаті.',
    age: 18,
    galleryPortraitPath: kCandeeGalleryPortraitPath,
    avatarPath: kCandeeAvatarPath,
    schedule: [
      SchedulePoint(
        hourStart: 0,
        hourEnd: 23,
        location: LocationsData.classmateHomeCandeeRoam,
        actionLabel: 'Вдома',
        spritePath: kCandeeAvatarPath,
      ),
    ],
  );
}
