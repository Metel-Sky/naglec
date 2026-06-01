import '../../models/npc_model.dart';
import '../../data/locations_room_data.dart';

const String kBlancheGalleryPortraitPath = 'lib/assets/npcs/blanche/Blanche.jpg';
const String kBlancheAvatarPath = 'lib/assets/npcs/blanche/Blanche_ava.png';

/// Blanche — мешканка колишнього «діму Каті» у Мажорщині.
/// Тимчасовий розклад: постійно у своїй кімнаті (детальний графік — пізніше).
NPCModel createBlancheNpc() {
  return NPCModel(
    id: 'blanche',
    gender: NpcGender.female,
    name: 'Blanche',
    fullName: 'Blanche',
    status: 'Мешканка',
    biographyType:
        'Живе у власному будинку в Мажорщині, у своїй кімнаті.',
    age: 45,
    galleryPortraitPath: kBlancheGalleryPortraitPath,
    avatarPath: kBlancheAvatarPath,
    schedule: [
      SchedulePoint(
        hourStart: 0,
        hourEnd: 23,
        location: LocationsData.poorVillageKatyRoom1,
        actionLabel: 'Вдома',
        spritePath: kBlancheAvatarPath,
      ),
    ],
  );
}
