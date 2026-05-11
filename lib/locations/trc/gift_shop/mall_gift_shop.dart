import '../../../data/locations_room_data.dart';
import '../../../data/shop_products_catalog.dart';
import '../../../widgets/laptop_shop_view.dart';

/// ТРЦ — магазин подарунків (`city_mall_gift_shop`). Товари — `assets/data/shop_products.json`.
class MallGiftShop {
  static String get title =>
      ShopProductsCatalog.titleFor(LocationsData.cityMallGiftShop);

  static List<ShopProduct> get products =>
      ShopProductsCatalog.productsFor(LocationsData.cityMallGiftShop);
}
