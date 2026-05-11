import 'package:flutter/material.dart';

import '../../../data/locations_room_data.dart';
import '../../../widgets/laptop_shop_view.dart';
import '../../company/company_room_layout.dart';
import '../trc_mall_shop_interior_layout.dart';

/// Магазин подарунків у ТРЦ: зліва сітка товарів, справа два вікна-проходи (офіс, склад), як у логістиці.
class TrcGiftShopView extends StatelessWidget {
  const TrcGiftShopView({
    super.key,
    required this.products,
    required this.onProductTap,
    required this.onOfficeTap,
    required this.onWarehouseTap,
  });

  final List<ShopProduct> products;
  final void Function(ShopProduct) onProductTap;
  final VoidCallback onOfficeTap;
  final VoidCallback onWarehouseTap;

  static const String _officePreviewPath = 'lib/assets/location/college/rooms/office.jpg';
  static const String _warehousePreviewPath = 'lib/assets/location/trc/shop.jpg';

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final mqH = MediaQuery.sizeOf(context).height;
        final h = constraints.maxHeight.isFinite && constraints.maxHeight > 0
            ? constraints.maxHeight
            : mqH * 0.55;
        final windowHeight = (h * 0.38).clamp(80.0, 280.0);
        final gap = ((h - 2 * windowHeight) / 3).clamp(8.0, 48.0);
        return TrcMallShopInteriorLayout(
          backgroundPath: LocationsData.cityMallGiftShopImagePath,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 7,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(8, gap, 8, 8),
                  child: ShopProductGrid(
                    products: products,
                    onProductTap: onProductTap,
                    padding: EdgeInsets.zero,
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.only(left: 6, right: 10, bottom: 8),
                  child: Column(
                    children: [
                      SizedBox(height: gap),
                      SizedBox(
                        height: windowHeight,
                        child: CompanyWindowButton(
                          imagePath: _officePreviewPath,
                              label: 'Office Cherie',
                          onTap: onOfficeTap,
                        ),
                      ),
                      SizedBox(height: gap),
                      SizedBox(
                        height: windowHeight,
                        child: CompanyWindowButton(
                          imagePath: _warehousePreviewPath,
                          label: 'Склад',
                          onTap: onWarehouseTap,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
