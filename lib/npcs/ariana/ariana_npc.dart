import '../../models/npc_model.dart';
import '../../data/locations_room_data.dart';

const List<int> _weekdays = [0, 1, 2, 3, 4];

/// Заглушка: заміни на `lib/assets/npcs/ariana/...` після додавання арту.
const String kArianaGalleryPortraitPath = 'lib/assets/npcs/ariana/ariana.jpg';
const String kArianaAvatarPath = 'lib/assets/npcs/ariana/ariana_ava.png';

/// Ariana Marie — одногрупниця. Сусідський дім, дитяча 1 — «Кімната Ariana».
NPCModel createArianaNpc() {
  return NPCModel(
    id: 'ariana_marie',
    gender: NpcGender.female,
    name: 'Ariana',
    fullName: 'Ariana',
    status: 'Одногрупниця',
    age: 18,
    galleryPortraitPath: kArianaGalleryPortraitPath,
    avatarPath: kArianaAvatarPath,
    schedule: [
      SchedulePoint(
        hourStart: 10,
        hourEnd: 17,
        location: LocationsData.collegeHall,
        actionLabel: 'У коледжі',
        spritePath: kArianaAvatarPath,
        days: _weekdays,
      ),
      SchedulePoint(
        hourStart: 0,
        hourEnd: 9,
        location: LocationsData.neighborChild1,
        actionLabel: 'Вдома (кімната Ariana)',
        spritePath: kArianaAvatarPath,
        days: _weekdays,
      ),
      SchedulePoint(
        hourStart: 18,
        hourEnd: 23,
        location: LocationsData.neighborChild1,
        actionLabel: 'Вдома (кімната Ariana)',
        spritePath: kArianaAvatarPath,
        days: _weekdays,
      ),
      SchedulePoint(
        hourStart: 0,
        hourEnd: 23,
        location: LocationsData.neighborChild1,
        actionLabel: 'Вихідні вдома (кімната Ariana)',
        spritePath: kArianaAvatarPath,
        days: [5, 6],
      ),
    ],
  );
}
