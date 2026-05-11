import 'package:flutter/material.dart';

import '../../../data/locations_room_data.dart';
import '../../../widgets/laptop_shop_view.dart';
import '../trc_mall_shop_interior_layout.dart';

/// Секс-шоп у ТРЦ.
class TrcSexShopView extends StatelessWidget {
  const TrcSexShopView({
    super.key,
    required this.products,
    required this.onProductTap,
  });

  final List<ShopProduct> products;
  final void Function(ShopProduct) onProductTap;

  @override
  Widget build(BuildContext context) {
    return TrcMallShopInteriorLayout(
      backgroundPath: LocationsData.cityMallRoomInteriorBackgroundPath(
        LocationsData.cityMallSexShop,
      ),
      child: LaptopShopView(
        products: products,
        onProductTap: onProductTap,
        hideBackButton: true,
      ),
    );
  }
}
