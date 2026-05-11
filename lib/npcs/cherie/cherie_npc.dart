import '../../models/npc_model.dart';
import '../../data/locations_room_data.dart';

const List<int> _weekdays = [0, 1, 2, 3, 4];

const String kCherieGalleryPortraitPath = 'lib/assets/npcs/cherie/cherie_ava.jpg';
const String kCherieAvatarPath = 'lib/assets/npcs/cherie/cherie_ava.png';

/// Cherie — власниця магазину подарунків у ТРЦ; живе в Home Cherie, Мажорщина (спальня Cherie).
NPCModel createCherieNpc() {
  return NPCModel(
    id: 'cherie',
    gender: NpcGender.female,
    name: 'Cherie',
    fullName: 'Cherie',
    status: 'Тітка, офіс магазину подарунків (ТРЦ)',
    age: 41,
    galleryPortraitPath: kCherieGalleryPortraitPath,
    avatarPath: kCherieAvatarPath,
    schedule: [
      // --- Будні ---
      SchedulePoint(
        hourStart: 23,
        hourEnd: 6,
        location: LocationsData.poorVillageGiftShopOwnerRoom1,
        actionLabel: 'Спить у своїй спальні',
        spritePath: kCherieAvatarPath,
        days: _weekdays,
      ),
      SchedulePoint(
        hourStart: 7,
        hourEnd: 8,
        location: LocationsData.poorVillageGiftShopOwnerKitchen,
        actionLabel: 'На кухні',
        spritePath: kCherieAvatarPath,
        days: _weekdays,
      ),
      SchedulePoint(
        hourStart: 9,
        hourEnd: 9,
        location: LocationsData.poorVillageGiftShopOwnerBathroom,
        actionLabel: 'У ванній',
        spritePath: kCherieAvatarPath,
        days: _weekdays,
      ),
      SchedulePoint(
        hourStart: 10,
        hourEnd: 18,
        location: LocationsData.cityMallGiftShopOffice,
        actionLabel: 'Офіс магазину подарунків (ТРЦ)',
        spritePath: kCherieAvatarPath,
        days: _weekdays,
      ),
      SchedulePoint(
        hourStart: 19,
        hourEnd: 22,
        location: LocationsData.cherieWeekdayEveningHomeRoam,
        actionLabel: 'Усе одна вдома',
        spritePath: kCherieAvatarPath,
        days: _weekdays,
      ),

      // --- Вихідні ---
      SchedulePoint(
        hourStart: 11,
        hourEnd: 15,
        location: LocationsData.cityMallGiftShopOffice,
        actionLabel: 'Офіс магазину подарунків (ТРЦ)',
        spritePath: kCherieAvatarPath,
        days: [5, 6],
      ),
      SchedulePoint(
        hourStart: 0,
        hourEnd: 23,
        location: LocationsData.poorVillageGiftShopOwnerRoom1,
        actionLabel: 'Вихідні вдома',
        spritePath: kCherieAvatarPath,
        days: [5, 6],
      ),
      SchedulePoint(
        hourStart: 19,
        hourEnd: 20,
        location: LocationsData.poorVillageGiftShopOwnerKitchen,
        actionLabel: 'На кухні',
        spritePath: kCherieAvatarPath,
        days: [5],
      ),
    ],
  );
}
