import '../../models/npc_model.dart';
import '../../models/item_model.dart';
import '../../data/locations_room_data.dart';

/// Повноцінний портрет (`den.jpg`) — **лише** картка в галереї «Персонажі».
const String kDenGalleryPortraitPath = 'lib/assets/npcs/den/den.jpg';

/// Аватар/спрайт (`den_ava.png`) — скрізь, окрім сітки галереї (телефон, профіль, коридор коледжу, смуга NPC).
const String kDenAvatarAssetPath = 'lib/assets/npcs/den/den_ava.png';

/// Особисті речі Дена, які можуть випадати при обшуку.
const List<LootOption> denPersonalLoot = [
  LootOption(item: GameItems.roomKey, weight: 0.05),
  LootOption(item: GameItems.panties, weight: 0.1),
];

/// Модель NPC: Ден.
NPCModel createDenNpc() {
  return NPCModel(
    id: 'den',
    name: 'Den',
    fullName: 'Den',
    status: 'Одногрупник',
    age: 20,
    gender: NpcGender.male,
    galleryPortraitPath: kDenGalleryPortraitPath,
    avatarPath: kDenAvatarAssetPath,
    schedule: [
      // Коледж у будні.
      SchedulePoint(
        hourStart: 10,
        hourEnd: 17,
        location: LocationsData.collegeCorridor,
        actionLabel: 'Читає',
        // Потрібен spritePath, щоб Ден потрапляв у список NPC-кандидатів
        // (ліва аватарка в GameScreen). Фон кімнати не змінюється, бо
        // `college_view.dart` для den підставляє ден-оверлей окремо.
        spritePath: kDenAvatarAssetPath,
        days: const [0, 1, 2, 3, 4],
      ),
      // Вдома: будинок начальника логістичної компанії, «Кімната Den».
      SchedulePoint(
        hourStart: 0,
        hourEnd: 9,
        location: LocationsData.poorVillageLogisticsBossRoom3,
        actionLabel: 'Вдома (кімната Den)',
        spritePath: kDenAvatarAssetPath,
        days: const [0, 1, 2, 3, 4],
      ),
      SchedulePoint(
        hourStart: 18,
        hourEnd: 23,
        location: LocationsData.poorVillageLogisticsBossRoom3,
        actionLabel: 'Вдома (кімната Den)',
        spritePath: kDenAvatarAssetPath,
        days: const [0, 1, 2, 3, 4],
      ),
      SchedulePoint(
        hourStart: 0,
        hourEnd: 23,
        location: LocationsData.poorVillageLogisticsBossRoom3,
        actionLabel: 'Вихідні вдома (кімната Den)',
        spritePath: kDenAvatarAssetPath,
        days: const [5, 6],
      ),
    ],
  );
}

