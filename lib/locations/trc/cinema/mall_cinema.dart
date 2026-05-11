import '../../../data/locations_room_data.dart';
import '../../../data/shop_products_catalog.dart';
import '../../../widgets/laptop_shop_view.dart';

/// ТРЦ — кінотеатр / ресторан (`city_mall_cinema`). Товари — `assets/data/shop_products.json` (поки порожньо).
class MallCinema {
  static String get title =>
      ShopProductsCatalog.titleFor(LocationsData.cityMallCinema);

  static List<ShopProduct> get products =>
      ShopProductsCatalog.productsFor(LocationsData.cityMallCinema);
}
