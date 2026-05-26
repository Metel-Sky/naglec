import '../../models/npc_model.dart';
import '../../models/item_model.dart';
import '../../data/locations_room_data.dart';

const String kPiperGalleryPortraitPath = 'lib/assets/npcs/piper/piper_ava.jpg';
const String kPiperAvatarPath = 'lib/assets/npcs/piper/piper.png';

/// Особисті речі Piper, які можуть дуже рідко випадати при обшуку її кімнати.
const List<LootOption> piperPersonalLoot = [
  LootOption(item: GameItems.panties, weight: 0.1),
  LootOption(item: GameItems.bra, weight: 0.1),
  LootOption(item: GameItems.dildo, weight: 0.05),
  LootOption(item: GameItems.roomKey, weight: 0.05),
];

/// Модель NPC: Piper (статистика, розклад, аватар).
NPCModel createPiperNpc() {
  return NPCModel(
    id: 'piper',
    name: 'Piper',
    fullName: 'Piper',
    status: 'Молодша сестра',
    age: 16,
    galleryPortraitPath: kPiperGalleryPortraitPath,
    avatarPath: kPiperAvatarPath,
    schedule: [
      SchedulePoint(
        hourStart: 8,
        hourEnd: 8,
        location: 'bathroom',
        actionLabel: 'Приймає душ',
        spritePath: 'lib/assets/npcs/piper/piper.png',
        days: [0, 1, 2, 3, 4],
      ),
      SchedulePoint(
        hourStart: 9,
        hourEnd: 9,
        location: 'piper_room',
        actionLabel: 'В своїй кімнаті',
        spritePath: 'lib/assets/npcs/piper/piper.png',
        days: [0, 1, 2, 3, 4],
      ),
      SchedulePoint(
        hourStart: 10,
        hourEnd: 17,
        location: LocationsData.collegeHall,
        actionLabel: 'У коледжі',
        spritePath: kPiperAvatarPath,
        days: [0, 1, 2, 3, 4],
      ),
      SchedulePoint(
        hourStart: 17,
        hourEnd: 21,
        location: 'piper_room',
        actionLabel: 'У своїй кімнаті',
        spritePath: 'lib/assets/npcs/piper/piper.png',
        days: [0, 1, 2, 3, 4],
      ),
      SchedulePoint(
        hourStart: 22,
        hourEnd: 6,
        location: 'piper_room',
        actionLabel: 'sleep',
        spritePath: 'lib/assets/npcs/piper/piper.png',
        days: [0, 1, 2, 3, 4],
      ),
      // --- Вихідні (сб–нд) ---
      SchedulePoint(
        hourStart: 9,
        hourEnd: 9,
        location: LocationsData.kitchen,
        actionLabel: 'На кухні',
        spritePath: kPiperAvatarPath,
        days: [5, 6],
      ),
      SchedulePoint(
        hourStart: 10,
        hourEnd: 10,
        location: LocationsData.bathroom,
        actionLabel: 'Приймає душ',
        spritePath: kPiperAvatarPath,
        days: [5, 6],
      ),
      SchedulePoint(
        hourStart: 11,
        hourEnd: 13,
        location: LocationsData.piperRoom,
        actionLabel: 'У своїй кімнаті',
        spritePath: kPiperAvatarPath,
        days: [5, 6],
      ),
      SchedulePoint(
        hourStart: 14,
        hourEnd: 15,
        location: LocationsData.hall,
        actionLabel: 'У залі',
        spritePath: kPiperAvatarPath,
        days: [5, 6],
      ),
      SchedulePoint(
        hourStart: 18,
        hourEnd: 19,
        location: LocationsData.neighborKitchen,
        actionLabel: 'У гостях у Jessa',
        spritePath: kPiperAvatarPath,
        days: [5, 6],
      ),
      SchedulePoint(
        hourStart: 22,
        hourEnd: 6,
        location: LocationsData.piperRoom,
        actionLabel: 'sleep',
        spritePath: kPiperAvatarPath,
        days: [5, 6],
      ),
    ],
  );
}
