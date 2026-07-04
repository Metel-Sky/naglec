import '../../models/npc_model.dart';
import '../../data/locations_room_data.dart';

const String kAlexisGalleryPortraitPath = 'lib/assets/npcs/alexis/alexis.jpg';
const String kAlexisAvatarPath = 'lib/assets/npcs/alexis/alexis_ava.png';

/// Alexis — тітка ГG, старша сестра Cory. Будинок на вул. Шевченка.
/// Тимчасовий розклад: випадкова кімната вдома (детальний графік — пізніше).
NPCModel createAlexisNpc() {
  return NPCModel(
    id: 'alexis',
    gender: NpcGender.female,
    name: 'Alexis',
    fullName: 'Alexis',
    status: 'Тітка',
    biographyType:
        'Старша сестра Cory, мамина тітка для ГG. Живе у власному будинку на вул. Шевченка.',
    age: 42,
    galleryPortraitPath: kAlexisGalleryPortraitPath,
    avatarPath: kAlexisAvatarPath,
    schedule: [
      SchedulePoint(
        hourStart: 0,
        hourEnd: 23,
        location: LocationsData.auntHomeAlexisRoam,
        actionLabel: 'Вдома',
        spritePath: kAlexisAvatarPath,
      ),
    ],
  );
}
