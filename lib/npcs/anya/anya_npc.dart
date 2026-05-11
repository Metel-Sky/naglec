import '../../models/npc_model.dart';
import '../../data/locations_room_data.dart';

const List<int> _weekdays = [0, 1, 2, 3, 4];

const String kAnyaGalleryPortraitPath = 'lib/assets/npcs/anya/anya_ava.jpg';
const String kAnyaAvatarPath = 'lib/assets/npcs/anya/anya.png';

/// Anya — двоюрідна сестра. Коледж 10–17 у будні (роумінг); «Кімната Ані» в Home Cherie (Мажорщина).
NPCModel createAnyaNpc() {
  return NPCModel(
    id: 'anya',
    gender: NpcGender.female,
    name: 'Anya',
    fullName: 'Anya',
    status: 'Двоюрідна сестра',
    age: 19,
    galleryPortraitPath: kAnyaGalleryPortraitPath,
    avatarPath: kAnyaAvatarPath,
    schedule: [
      SchedulePoint(
        hourStart: 10,
        hourEnd: 17,
        location: LocationsData.collegeHall,
        actionLabel: 'У коледжі',
        spritePath: kAnyaAvatarPath,
        days: _weekdays,
      ),
      SchedulePoint(
        hourStart: 0,
        hourEnd: 9,
        location: LocationsData.poorVillageGiftShopOwnerRoom2,
        actionLabel: 'Удома (Home Cherie)',
        spritePath: kAnyaAvatarPath,
        days: _weekdays,
      ),
      SchedulePoint(
        hourStart: 18,
        hourEnd: 23,
        location: LocationsData.poorVillageGiftShopOwnerRoom2,
        actionLabel: 'Удома (Home Cherie)',
        spritePath: kAnyaAvatarPath,
        days: _weekdays,
      ),
      SchedulePoint(
        hourStart: 0,
        hourEnd: 23,
        location: LocationsData.poorVillageGiftShopOwnerRoom2,
        actionLabel: 'Вихідні вдома',
        spritePath: kAnyaAvatarPath,
        days: [5, 6],
      ),
    ],
  );
}
