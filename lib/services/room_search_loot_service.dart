import 'dart:math';

import '../data/locations_room_data.dart';
import '../models/item_model.dart';
import 'game_world_state.dart';

/// Випадковий лут для кнопки «Обшукати кімнату» (локаційне меню) у кімнатах дому ГГ.
class RoomSearchLootService {
  RoomSearchLootService._();

  static const double _roomKeyDropChance = 0.03;
  static const double _elsaLoginDropChance = 0.03;

  static const List<LootOption> _baseLoot = [
    LootOption(money: 10, weight: 50),
    LootOption(item: GameItems.journalWomen, weight: 20),
    LootOption(item: GameItems.playboyMagazine, weight: 20),
    LootOption(item: GameItems.panties1, weight: 10),
    LootOption(item: GameItems.panties2, weight: 10),
    LootOption(item: GameItems.braBlack, weight: 10),
  ];

  static const List<LootOption> _elsaExtra = [
    LootOption(item: GameItems.eroBook, weight: 10),
  ];

  static const List<LootOption> _piperExtra = [
    LootOption(item: GameItems.pornMagazine, weight: 10),
  ];

  static const List<LootOption> _momExtra = [
    LootOption(item: GameItems.dildoPhoto, weight: 5),
    LootOption(item: GameItems.condom, weight: 10),
  ];

  /// Кімнати з окремими таблицями лута. Для інших `null` — обшук без дропу з цього сервісу.
  /// [world] — прапорці одноразового випадіння ключів кімнат.
  static LootOption? rollHomeFamilyBedroom(
    String roomId,
    Random rng,
    GameWorldState world,
  ) {
    if (roomId == LocationsData.elsaRoom &&
        rng.nextDouble() < _elsaLoginDropChance) {
      return const LootOption(item: GameItems.elsaLogin);
    }

    final GameItem? roomKeyItem = switch (roomId) {
      LocationsData.elsaRoom => GameItems.keyElsaRoom,
      LocationsData.piperRoom => GameItems.keyPiperRoom,
      LocationsData.momRoom => GameItems.keyMomRoom,
      _ => null,
    };
    if (roomKeyItem == null) return null;

    final bool keyAlreadyGranted = switch (roomId) {
      LocationsData.elsaRoom => world.homeRoomSearchKeyElsaGranted,
      LocationsData.piperRoom => world.homeRoomSearchKeyPiperGranted,
      LocationsData.momRoom => world.homeRoomSearchKeyMomGranted,
      _ => true,
    };
    if (!keyAlreadyGranted && rng.nextDouble() < _roomKeyDropChance) {
      return LootOption(item: roomKeyItem);
    }

    final pool = <LootOption>[..._baseLoot];
    switch (roomId) {
      case LocationsData.elsaRoom:
        pool.addAll(_elsaExtra);
        break;
      case LocationsData.piperRoom:
        pool.addAll(_piperExtra);
        break;
      case LocationsData.momRoom:
        pool.addAll(_momExtra);
        break;
    }
    // «Нічого не знайдено»: 50% проти суми всіх інших варіантів у цьому пулі.
    final sumOtherWeights = pool.fold<double>(0, (s, o) => s + o.weight);
    pool.add(LootOption(weight: sumOtherWeights));
    final rolled = _rollWeighted(pool, rng);
    final ownedItem = _markOwnerIfUnderwear(rolled.item, roomId);
    if (ownedItem == null || identical(ownedItem, rolled.item)) {
      return rolled;
    }
    return LootOption(item: ownedItem, money: rolled.money, weight: rolled.weight);
  }

  static GameItem? _markOwnerIfUnderwear(GameItem? item, String roomId) {
    if (item == null) return null;
    final owner = switch (roomId) {
      LocationsData.elsaRoom => (id: 'elsa', genitive: 'Ельзи'),
      LocationsData.piperRoom => (id: 'piper', genitive: 'Пайпер'),
      LocationsData.momRoom => (id: 'mom', genitive: 'мами'),
      _ => null,
    };
    if (owner == null) return item;

    final isPanties = item.id == 'panties' ||
        item.id == 'panties_1' ||
        item.id == 'panties_2';
    final isBra = item.id == 'bra' || item.id == 'bra_black';
    if (!isPanties && !isBra) return item;

    final itemKind = isPanties ? 'Труси' : 'Ліфчик';
    return GameItem(
      id: '${item.id}_${owner.id}',
      name: '$itemKind ${owner.genitive}',
      description: '${item.description} Власниця: ${owner.genitive}.',
      imagePath: item.imagePath,
      usesLeft: item.usesLeft,
    );
  }

  static LootOption _rollWeighted(List<LootOption> pool, Random rng) {
    final totalWeight = pool.fold<double>(0, (sum, e) => sum + e.weight);
    if (totalWeight <= 0) return pool.first;

    var roll = rng.nextDouble() * totalWeight;
    for (final option in pool) {
      roll -= option.weight;
      if (roll <= 0) return option;
    }
    return pool.last;
  }
}
