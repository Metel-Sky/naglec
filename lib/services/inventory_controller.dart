import '../models/item_model.dart';

class InventoryController {
  static const String sondoxItemId = 'hypnotic';
  static const int sondoxMaxUses = 10;

  // Список речей, які зараз у гравця
  final List<GameItem> items = [];

  // Додати річ у рюкзак (можна кілька однакових, макс. 5 на тип)
  void addItem(GameItem item) {
    if (item.id == sondoxItemId && item.usesLeft == null) {
      items.add(GameItem(
        id: item.id,
        name: item.name,
        description: item.description,
        imagePath: item.imagePath,
        usesLeft: sondoxMaxUses,
      ));
      return;
    }
    items.add(item);
  }

  /// Видалити одну штуку предмета з заданим [id].
  void removeItem(String id) {
    final idx = items.indexWhere((item) => item.id == id);
    if (idx >= 0) items.removeAt(idx);
  }

  /// Кількість предметів з заданим [id].
  int count(String id) {
    return items.where((item) => item.id == id).length;
  }

  int get sondoxUsesLeft {
    var total = 0;
    for (final item in items) {
      if (item.id != sondoxItemId) continue;
      total += item.usesLeft ?? sondoxMaxUses;
    }
    return total;
  }

  bool get hasUsableSondox => sondoxUsesLeft > 0;

  bool consumeSondoxUse() {
    final idx = items.indexWhere((item) =>
        item.id == sondoxItemId && (item.usesLeft ?? sondoxMaxUses) > 0);
    if (idx < 0) return false;
    final item = items[idx];
    final nextUses = (item.usesLeft ?? sondoxMaxUses) - 1;
    if (nextUses <= 0) {
      items.removeAt(idx);
    } else {
      items[idx] = GameItem(
        id: item.id,
        name: item.name,
        description: item.description,
        imagePath: item.imagePath,
        usesLeft: nextUses,
      );
    }
    return true;
  }

  /// Унікальні предмети з кількістю: [(перший GameItem, кількість), ...].
  List<(GameItem, int)> get uniqueItemsWithCount {
    final map = <String, List<GameItem>>{};
    for (final item in items) {
      map.putIfAbsent(item.id, () => []).add(item);
    }
    return map.entries.map((e) => (e.value.first, e.value.length)).toList();
  }

  /// Очищає рюкзак і додає стартовий набір для нової гри.
  void reset() {
    items.clear();
    addItem(GameItems.shopEnergy);
    addItem(GameItems.shopEnergy);
    addItem(GameItems.shopSnickers);
  }
}