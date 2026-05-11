import '../../../data/locations_room_data.dart';
import '../../../data/shop_products_catalog.dart';
import '../../../widgets/laptop_shop_view.dart';

/// ТРЦ — аптека (`city_mall_pharmacy`). Товари — `assets/data/shop_products.json`.
class MallPharmacy {
  static String get title =>
      ShopProductsCatalog.titleFor(LocationsData.cityMallPharmacy);

  static List<ShopProduct> get products =>
      ShopProductsCatalog.productsFor(LocationsData.cityMallPharmacy);
}
