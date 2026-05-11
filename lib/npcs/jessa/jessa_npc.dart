import '../../models/npc_model.dart';
import '../../data/locations_room_data.dart';

const String kJessaGalleryPortraitPath = 'lib/assets/npcs/jessa/jessa_ava.jpg';
const String kJessaAvatarPath = 'lib/assets/npcs/jessa/jessa.png';

/// Jessa — сусідка, працює в стріп-барі у вечірні/нічні зміни.
NPCModel createJessaNpc() {
  return NPCModel(
    id: 'jessa',
    gender: NpcGender.female,
    name: 'Jessa',
    fullName: 'Jessa',
    status: 'Сусідка',
    age: 38,
    galleryPortraitPath: kJessaGalleryPortraitPath,
    avatarPath: kJessaAvatarPath,
    schedule: [
      // Пн/Ср/Пт/Сб вечір у стріп-барі.
      SchedulePoint(
        hourStart: 21,
        hourEnd: 23,
        location: LocationsData.poorDistrictStripBar,
        actionLabel: 'Працює в стріп-барі',
        spritePath: kJessaAvatarPath,
        days: [0, 2, 4, 5],
      ),
      // Нічні години після змін: Вт/Чт/Сб/Нд 00:00–05:59.
      SchedulePoint(
        hourStart: 0,
        hourEnd: 5,
        location: LocationsData.poorDistrictStripBar,
        actionLabel: 'Працює в стріп-барі',
        spritePath: kJessaAvatarPath,
        days: [1, 3, 5, 6],
      ),
      // Вт/Чт/Сб/Нд 06:00–13:59 спить удома (спальня).
      SchedulePoint(
        hourStart: 6,
        hourEnd: 13,
        location: LocationsData.neighborParentsRoom,
        actionLabel: 'Спить',
        spritePath: kJessaAvatarPath,
        days: [1, 3, 5, 6],
      ),
    ],
  );
}
