import '../../../data/locations_room_data.dart';
import '../../../data/shop_products_catalog.dart';
import '../../../widgets/laptop_shop_view.dart';

/// ТРЦ — загальний магазин (`city_mall_shop`). Товари — `assets/data/shop_products.json`.
class MallShop {
  static String get title =>
      ShopProductsCatalog.titleFor(LocationsData.cityMallShop);

  static List<ShopProduct> get products =>
      ShopProductsCatalog.productsFor(LocationsData.cityMallShop);
}
