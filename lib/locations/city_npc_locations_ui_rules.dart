import '../data/locations_room_data.dart';
import '../models/npc_model.dart';
import 'trc/trc_shops_registry.dart' show isMallShopRoom;

/// Єдине місце з правилами UI для NPC у `CITY`.
///
/// Контракт під твої вимоги:
/// - МАГАЗИНИ (де є сітка айтемів): у лівій панелі NPC є, але не обрані
///   (автопідсвітка вимкнена) і растр/фото NPC в кімнаті не показуємо.
/// - НЕ МАГАЗИНИ: при виборі NPC показуємо і кнопки взаємодії, і фото (растр) поверх фону.
class CityNpcLocationsUiRules {
  const CityNpcLocationsUiRules._();

  /// Локації в `CITY`, де реально є інтерфейс покупки айтемів (сітка).
  ///
  /// Важливо: тут не включаємо `cityMallCinema`, бо там не “ноутбук-магазин”.
  static bool isCityItemShopRoom(String roomId) {
    return roomId == LocationsData.cityMallShop ||
        roomId == LocationsData.cityMallPharmacy ||
        roomId == LocationsData.cityMallGiftShop ||
        roomId == LocationsData.cityMallSexShop ||
        roomId == LocationsData.cityMallElectronics;
  }

  /// Чи показуємо ліву смугу з NPC в поточній кімнаті.
  ///
  /// Магазини: показуємо навіть 1 NPC (щоб гравець міг вибрати, бо растр-фото в кімнаті приглушений).
  /// Не магазини: як і було — тільки якщо 2+ NPC.
  static bool shouldShowNpcAvatarStrip({
    required String roomId,
    required List<NPCModel> activeNPCs,
  }) {
    if (activeNPCs.isEmpty) return false;
    // Офіс Чері: повноекранне відео — без лівої смуги вибору NPC.
    if (roomId == LocationsData.cityMallGiftShopOffice &&
        activeNPCs.any((n) => n.id == 'cherie')) {
      return false;
    }
    if (isCityItemShopRoom(roomId)) return true;
    // Усі “гуляючі” локації міста: показуємо всіх присутніх NPC у лівій панелі,
    // незалежно від кількості.
    return true;
  }

  /// Чи дозволяти “автопідсвітку” першого NPC зеленим, коли нічого не обрано.
  ///
  /// У магазинах — вимкнено (бо ти хочеш “не обраними”).
  static bool shouldAutoSelectNpcInAvatarStrip(String roomId) {
    return !isCityItemShopRoom(roomId);
  }

  /// Пригнічувати растр/фото NPC поверх фону локації.
  ///
  /// У магазинах: завжди `true`, навіть коли NPC обраний — щоб показувались лише кнопки взаємодії.
  static bool shouldSuppressRoomNpcRaster(String roomId) {
    return isCityItemShopRoom(roomId);
  }

  /// Допоміжно: чи це “магазин ТРЦ” за регістром товарів.
  ///
  /// Залишено для місць, де треба узгодити з існуючим магазинним API.
  /// Наразі не використовується в основних правилах UI.
  static bool isTrcShopRoom(String roomId) => isMallShopRoom(roomId);
}

