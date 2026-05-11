import '../../models/npc_model.dart';
import '../../data/locations_room_data.dart';

const List<int> _weekdays = [0, 1, 2, 3, 4];

const String kKorishFatherGalleryPortraitPath =
    'lib/assets/npcs/korish_father/korish_father.webp';//галерея
const String kKorishFatherAvatarPath =
    'lib/assets/npcs/korish_father/korish_father_ava.png';

/// Батько Semа — у профілі лише відносини та вплив; працює лише в автомайстерні (не в торговому залі).
NPCModel createKorishFatherNpc() {
  return NPCModel(
    id: 'korish_father',
    gender: NpcGender.male,
    name: 'Manuel ',
    fullName: 'Manuel ',
    status: 'Батько Semа',
    age: 40,
    galleryPortraitPath: kKorishFatherGalleryPortraitPath,
    avatarPath: kKorishFatherAvatarPath,
    schedule: [
      SchedulePoint(
        hourStart: 9,
        hourEnd: 18,
        location: LocationsData.cityCarDealershipWorkshop,
        actionLabel: 'У автомайстерні',
        spritePath: kKorishFatherAvatarPath,
        days: _weekdays,
      ),
      SchedulePoint(
        hourStart: 20,
        hourEnd: 23,
        location: LocationsData.friendParentsRoom,
        actionLabel: 'Вдома',
        spritePath: kKorishFatherAvatarPath,
        days: _weekdays,
      ),
      SchedulePoint(
        hourStart: 0,
        hourEnd: 9,
        location: LocationsData.friendParentsRoom,
        actionLabel: 'Спить',
        spritePath: kKorishFatherAvatarPath,
        days: _weekdays,
      ),
      //=================ВИХІДНІ=====================
      SchedulePoint(
        hourStart: 0,
        hourEnd: 23,
        location: LocationsData.friendParentsRoom,
        actionLabel: 'Вихідні вдома',
        spritePath: kKorishFatherAvatarPath,
        days: [5, 6],
      ),
    ],
  );
}
