import '../../models/npc_model.dart';
import '../../data/locations_room_data.dart';

const String kRileyGalleryPortraitPath = 'lib/assets/npcs/riley/Riley.jpg';
const String kRileyAvatarPath = 'lib/assets/npcs/riley/Riley_ava.png';

/// Riley — мешканка елітного ЖК, квартира 2.
/// Тимчасовий розклад: основний час у спальні; вдені — по квартирі (детальний графік — пізніше).
NPCModel createRileyNpc() {
  return NPCModel(
    id: 'riley',
    gender: NpcGender.female,
    name: 'Riley',
    fullName: 'Riley',
    status: 'Мешканка',
    biographyType:
        'Живе в елітному житловому комплексі, у квартирі Riley. Лесбійка.',
    age: 19,
    galleryPortraitPath: kRileyGalleryPortraitPath,
    avatarPath: kRileyAvatarPath,
    schedule: [
      SchedulePoint(
        hourStart: 23,
        hourEnd: 6,
        location: LocationsData.cityEliteApartment2Bedroom,
        actionLabel: 'Спить',
        spritePath: kRileyAvatarPath,
      ),
      SchedulePoint(
        hourStart: 7,
        hourEnd: 16,
        location: LocationsData.cityEliteApt2RileyRoam,
        actionLabel: 'Вдома',
        spritePath: kRileyAvatarPath,
      ),
      SchedulePoint(
        hourStart: 17,
        hourEnd: 22,
        location: LocationsData.cityEliteApartment2Bedroom,
        actionLabel: 'Вдома',
        spritePath: kRileyAvatarPath,
      ),
    ],
  );
}
