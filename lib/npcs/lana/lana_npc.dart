import '../../models/npc_model.dart';
import '../../data/locations_room_data.dart';

const String kLanaGalleryPortraitPath = 'lib/assets/npcs/lana/Lana.jpg';
const String kLanaAvatarPath = 'lib/assets/npcs/lana/Lana_ava.png';

/// Lana — живе з Riley в елітному ЖК, квартира Riley, спальня.
/// Тимчасовий розклад: постійно у спальні (детальний графік — пізніше).
NPCModel createLanaNpc() {
  return NPCModel(
    id: 'lana',
    gender: NpcGender.female,
    name: 'Lana',
    fullName: 'Lana',
    status: 'Партнерка Riley',
    biographyType:
        'Живе з Riley в елітному житловому комплексі, у спальні квартири Riley. Лесбійка.',
    age: 27,
    galleryPortraitPath: kLanaGalleryPortraitPath,
    avatarPath: kLanaAvatarPath,
    schedule: [
      SchedulePoint(
        hourStart: 0,
        hourEnd: 23,
        location: LocationsData.cityEliteApartment2Bedroom,
        actionLabel: 'Вдома',
        spritePath: kLanaAvatarPath,
      ),
    ],
  );
}
