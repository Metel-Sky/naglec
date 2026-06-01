import '../../models/npc_model.dart';
import '../../data/locations_room_data.dart';

const String kCapriceGalleryPortraitPath = 'lib/assets/npcs/caprice/Caprice.webp';
const String kCapriceAvatarPath = 'lib/assets/npcs/caprice/caprice_ava.png';

/// Caprice — мешканка дому Blanche (Мажорщина).
/// Тимчасовий розклад: постійно у своїй кімнаті (детальний графік — пізніше).
NPCModel createCapriceNpc() {
  return NPCModel(
    id: 'caprice',
    gender: NpcGender.female,
    name: 'Caprice',
    fullName: 'Caprice',
    status: 'Мешканка',
    biographyType:
        'Живе у домі Blanche в Мажорщині, у своїй кімнаті. Поки що ніде не працює.',
    age: 25,
    galleryPortraitPath: kCapriceGalleryPortraitPath,
    avatarPath: kCapriceAvatarPath,
    schedule: [
      SchedulePoint(
        hourStart: 0,
        hourEnd: 23,
        location: LocationsData.poorVillageKatyRoom2,
        actionLabel: 'Вдома',
        spritePath: kCapriceAvatarPath,
      ),
    ],
  );
}
