import '../../models/npc_model.dart';
import '../../models/item_model.dart';
import '../../data/locations_room_data.dart';

/// Особисті речі Лошка, які можуть випадати при обшуку.
const List<LootOption> loshokPersonalLoot = [
  LootOption(item: GameItems.roomKey, weight: 0.05),
  LootOption(item: GameItems.bra, weight: 0.05),
];

const String kLoshokGalleryPortraitPath = 'lib/assets/npcs/loh/loshok.png';
const String kLoshokAvatarPath = 'lib/assets/npcs/loh/loshok_ava.png';

/// Модель NPC: Лошок.
NPCModel createLoshokNpc() {
  return NPCModel(
    id: 'loshok',
    name: 'Лошок',
    fullName: 'Лошок',
    status: 'Новий персонаж',
    age: 20,
    gender: NpcGender.male,
    galleryPortraitPath: kLoshokGalleryPortraitPath,
    avatarPath: kLoshokAvatarPath,
    schedule: [
      SchedulePoint(
        hourStart: 9,
        hourEnd: 19,
        location: LocationsData.collegeCorridor,
        actionLabel: 'Читає',
        // SpritePath потрібен для відображення Лошка в лівих колах.
        // Сам оверлей показуємо окремо в `college_view.dart`.
        spritePath: kLoshokAvatarPath,
      ),
    ],
  );
}

