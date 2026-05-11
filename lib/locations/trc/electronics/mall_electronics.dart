import '../../../data/locations_room_data.dart';
import '../../../data/shop_products_catalog.dart';
import '../../../widgets/laptop_shop_view.dart';

/// ТРЦ — магазин електроніки (`city_mall_electronics`). Товари — `assets/data/shop_products.json`.
class MallElectronics {
  static String get title =>
      ShopProductsCatalog.titleFor(LocationsData.cityMallElectronics);

  static List<ShopProduct> get products =>
      ShopProductsCatalog.productsFor(LocationsData.cityMallElectronics);
}
