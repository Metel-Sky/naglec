import '../models/item_model.dart';

class InventoryController {
  // Список речей, які зараз у гравця
  final List<GameItem> items = [];

  // Додати річ у рюкзак (можна кілька однакових, макс. 5 на тип)
  void addItem(GameItem item) {
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