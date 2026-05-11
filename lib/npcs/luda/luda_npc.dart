import '../../models/npc_model.dart';
import '../../models/item_model.dart';
import '../../data/poor_district/poor_district_house_1.dart';
import '../../data/locations_room_data.dart';

/// Особисті речі Людмили, які можуть дуже рідко випадати при обшуку її кімнати.
const List<LootOption> ludaPersonalLoot = [
  LootOption(item: GameItems.panties, weight: 0.1),
  LootOption(item: GameItems.bra, weight: 0.1),
  LootOption(item: GameItems.vibratorRemote, weight: 0.05),
  LootOption(item: GameItems.roomKey, weight: 0.05),
];

/// Портрет для сітки галереї «Персонажі» (`galleryPortraitPath`).
const String kLudaGalleryPortraitPath = 'lib/assets/npcs/luda/luda_ava.jpg';
/// Аватар для телефону, профілю, оверлеїв і `spritePath` у розкладі.
const String kLudaAvatarPath = 'lib/assets/npcs/luda/luda.png';

/// NPC: Людмила Бджілка — секретарка логістичної компанії, 37 років, живе в бідному р-ні Бандери 1 кв. 1.
NPCModel createLudaNpc() {
  return NPCModel(
    id: 'luda',
    name: 'Luda',
    fullName: 'Luda',
    status: 'Секретарка',
    age: 37,
    galleryPortraitPath: kLudaGalleryPortraitPath,
    avatarPath: kLudaAvatarPath,
    // Час включно: 7–7 = 7:00–7:59, 10–17 = 10:00–17:59; через північ 22–6 = 22:00–6:59.
    schedule: [
      SchedulePoint(
        hourStart: 7,
        hourEnd: 7,
        location: PoorDistrictHouse1.rA1_2,
        actionLabel: 'Готує',
        spritePath: kLudaAvatarPath,
      ),
      SchedulePoint(
        hourStart: 8,
        hourEnd: 8,
        location: PoorDistrictHouse1.rA1_3,
        actionLabel: 'Миється',
        spritePath: '',
      ),
      SchedulePoint(
        hourStart: 9,
        hourEnd: 12,
        location: LocationsData.cityBcLogistics,
        actionLabel: 'Робота (секретарка)',
        spritePath: '',
        days: [0, 1, 2, 3, 4],
      ),
      SchedulePoint(
        hourStart: 13,
        hourEnd: 13,
        location: LocationsData.cityParkCoffee,
        actionLabel: "Кав'ярня",
        spritePath: kLudaAvatarPath,
        days: [0, 1, 2, 3, 4],
      ),
      SchedulePoint(
        hourStart: 14,
        hourEnd: 17,
        location: LocationsData.cityBcLogistics,
        actionLabel: 'Робота (секретарка)',
        spritePath: '',
        days: [0, 1, 2, 3, 4],
      ),
      SchedulePoint(
        hourStart: 18,
        hourEnd: 19,
        location: PoorDistrictHouse1.rA1_1,
        actionLabel: 'Дивиться фільм',
        spritePath: kLudaAvatarPath,
      ),
      SchedulePoint(
        hourStart: 20,
        hourEnd: 20,
        location: PoorDistrictHouse1.rA1_2,
        actionLabel: 'Готує',
        spritePath: kLudaAvatarPath,
      ),
      SchedulePoint(
        hourStart: 21,
        hourEnd: 21,
        location: PoorDistrictHouse1.rA1_4,
        actionLabel: 'Читає книгу',
        spritePath: kLudaAvatarPath,
      ),
      SchedulePoint(
        hourStart: 22,
        hourEnd: 6,
        location: PoorDistrictHouse1.rA1_4,
        actionLabel: 'sleep',
        spritePath: '',
      ),
    ],
  );
}
