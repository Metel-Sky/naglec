import '../../models/npc_model.dart';
import '../../data/locations_room_data.dart';

const String kSamanthaGalleryPortraitPath = 'lib/assets/npcs/samantha/samantha.jpg';
const String kSamanthaAvatarPath = 'lib/assets/npcs/samantha/samantha_ava.png';

/// Samantha — мешканка дому шефа колцентру (Мажорщина), кімната 3.
/// Тимчасовий розклад: постійно у своїй кімнаті (детальний графік — пізніше).
NPCModel createSamanthaNpc() {
  return NPCModel(
    id: 'samantha',
    gender: NpcGender.female,
    name: 'Samantha',
    fullName: 'Samantha',
    status: 'Старша донька Індії',
    biographyType:
        'Живе в домі шефа колцентру в Мажорщині, у кімнаті Samantha.',
    age: 21,
    galleryPortraitPath: kSamanthaGalleryPortraitPath,
    avatarPath: kSamanthaAvatarPath,
    schedule: [
      SchedulePoint(
        hourStart: 0,
        hourEnd: 23,
        location: LocationsData.poorVillageCallCenterBossRoom3,
        actionLabel: 'Вдома',
        spritePath: kSamanthaAvatarPath,
      ),
    ],
  );
}
