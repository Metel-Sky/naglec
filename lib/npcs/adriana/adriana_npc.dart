import '../../models/npc_model.dart';
import '../../data/locations_room_data.dart';

const String kAdrianaGalleryPortraitPath = 'lib/assets/npcs/adriana/adriana.jpg';
const String kAdrianaAvatarPath = 'lib/assets/npcs/adriana/adriana_ava.png';

/// Adriana — мешканка будинку Cherie (Мажорщина), кімната 3.
/// Тимчасовий розклад: постійно у своїй кімнаті (детальний графік — пізніше).
NPCModel createAdrianaNpc() {
  return NPCModel(
    id: 'adriana',
    gender: NpcGender.female,
    name: 'Adriana',
    fullName: 'Adriana',
    status: 'Двоюрідна сестра',
    biographyType:
        'Живе в будинку Cherie в Мажорщині, у кімнаті Adriana.',
    age: 22,
    galleryPortraitPath: kAdrianaGalleryPortraitPath,
    avatarPath: kAdrianaAvatarPath,
    schedule: [
      SchedulePoint(
        hourStart: 0,
        hourEnd: 23,
        location: LocationsData.poorVillageGiftShopOwnerRoom3,
        actionLabel: 'Вдома',
        spritePath: kAdrianaAvatarPath,
      ),
    ],
  );
}
