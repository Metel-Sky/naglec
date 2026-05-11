import '../../../data/locations_room_data.dart';
import '../../../data/shop_products_catalog.dart';
import '../../../widgets/laptop_shop_view.dart';

/// ТРЦ — секс-шоп (`city_mall_sex_shop`). Товари — `assets/data/shop_products.json`.
class MallSexShop {
  static String get title =>
      ShopProductsCatalog.titleFor(LocationsData.cityMallSexShop);

  static List<ShopProduct> get products =>
      ShopProductsCatalog.productsFor(LocationsData.cityMallSexShop);
}
