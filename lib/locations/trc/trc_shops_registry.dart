import '../../data/locations_room_data.dart';
import '../../widgets/laptop_shop_view.dart';
import 'cinema/mall_cinema.dart';
import 'electronics/mall_electronics.dart';
import 'gift_shop/mall_gift_shop.dart';
import 'general_shop/mall_shop.dart';
import 'pharmacy/mall_pharmacy.dart';
import 'sex_shop/mall_sex_shop.dart';

/// Повертає список товарів для магазину ТРЦ за [roomId], або порожній список.
List<ShopProduct> getProductsForMallRoom(String roomId) {
  switch (roomId) {
    case LocationsData.cityMallShop:
      return MallShop.products;
    case LocationsData.cityMallPharmacy:
      return MallPharmacy.products;
    case LocationsData.cityMallGiftShop:
      return MallGiftShop.products;
    case LocationsData.cityMallSexShop:
      return MallSexShop.products;
    case LocationsData.cityMallElectronics:
      return MallElectronics.products;
    case LocationsData.cityMallCinema:
      return MallCinema.products;
    default:
      return [];
  }
}

/// Повертає назву магазину ТРЦ за [roomId].
String getMallShopTitle(String roomId) {
  switch (roomId) {
    case LocationsData.cityMallShop:
      return MallShop.title;
    case LocationsData.cityMallPharmacy:
      return MallPharmacy.title;
    case LocationsData.cityMallGiftShop:
      return MallGiftShop.title;
    case LocationsData.cityMallSexShop:
      return MallSexShop.title;
    case LocationsData.cityMallElectronics:
      return MallElectronics.title;
    case LocationsData.cityMallCinema:
      return MallCinema.title;
    default:
      return '';
  }
}

/// Чи є [roomId] магазином ТРЦ (показувати інтерфейс магазину).
bool isMallShopRoom(String roomId) {
  return LocationsData.cityMallRoomIds.contains(roomId);
}
