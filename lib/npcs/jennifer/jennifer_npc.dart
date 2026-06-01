import '../../models/npc_model.dart';
import '../../data/locations_room_data.dart';

const String kJenniferGalleryPortraitPath = 'lib/assets/npcs/jennifer/jennifer.jpg';
const String kJenniferAvatarPath = 'lib/assets/npcs/jennifer/jennifer_ava.png';

/// Jennifer — мешканка елітного ЖК, квартира 1.
/// Тимчасовий розклад: постійно у спальні (детальний графік — пізніше).
NPCModel createJenniferNpc() {
  return NPCModel(
    id: 'jennifer',
    gender: NpcGender.female,
    name: 'Jennifer',
    fullName: 'Jennifer',
    status: 'Мешканка',
    biographyType:
        'Живе в елітному житловому комплексі, у квартирі Jennifer.',
    age: 43,
    galleryPortraitPath: kJenniferGalleryPortraitPath,
    avatarPath: kJenniferAvatarPath,
    schedule: [
      SchedulePoint(
        hourStart: 0,
        hourEnd: 23,
        location: LocationsData.cityEliteApartment1Bedroom,
        actionLabel: 'Вдома',
        spritePath: kJenniferAvatarPath,
      ),
    ],
  );
}
