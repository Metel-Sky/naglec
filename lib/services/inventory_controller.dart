import '../models/item_model.dart';

class InventoryController {
  // Список речей, які зараз у гравця
  final List<GameItem> items = [];

  // Додати річ у рюкзак
  void addItem(GameItem item) {
    // Перевірка, щоб не було двох однакових ключів, наприклад
    if (!items.any((element) => element.id == item.id)) {
      items.add(item);
    }
  }

  // Видалити річ
  void removeItem(String id) {
    items.removeWhere((item) => item.id == id);
  }
}