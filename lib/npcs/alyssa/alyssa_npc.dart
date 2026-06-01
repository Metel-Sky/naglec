import '../../models/npc_model.dart';
import '../../data/locations_room_data.dart';

const String kAlyssaGalleryPortraitPath = 'lib/assets/npcs/alyssa/alyssa.jpg';
const String kAlyssaAvatarPath = 'lib/assets/npcs/alyssa/alyssa_ava.png';

/// Alyssa — однокласниця ГG. Будинок на вул. Шевченка.
/// Тимчасовий розклад: випадкова кімната вдома (детальний графік — пізніше).
NPCModel createAlyssaNpc() {
  return NPCModel(
    id: 'alyssa',
    gender: NpcGender.female,
    name: 'Alyssa',
    fullName: 'Alyssa',
    status: 'Одногрупниця',
    biographyType:
        'Одногрупниця ГG. Живе з мамою Lexi у будинку на вул. Шевченка, у своїй кімнаті.',
    age: 18,
    galleryPortraitPath: kAlyssaGalleryPortraitPath,
    avatarPath: kAlyssaAvatarPath,
    schedule: [
      SchedulePoint(
        hourStart: 0,
        hourEnd: 23,
        location: LocationsData.classmateHomeAlyssaRoam,
        actionLabel: 'Вдома',
        spritePath: kAlyssaAvatarPath,
      ),
    ],
  );
}
