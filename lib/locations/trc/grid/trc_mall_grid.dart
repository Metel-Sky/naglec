import 'package:flutter/material.dart';

import '../../../data/locations_room_data.dart';
import '../../../theme/game_theme.dart';

/// Сітка входів у заклади ТРЦ (2×3). Слоти на весь блок.
class TrcMallGrid extends StatelessWidget {
  const TrcMallGrid({super.key, required this.onRoomTap});

  final void Function(String roomId) onRoomTap;

  @override
  Widget build(BuildContext context) {
    final roomIds = LocationsData.cityMallRoomIds;
    const int crossCount = 3;
    final rowCount = (roomIds.length / crossCount).ceil();
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 12.0;
        final cellWidth =
            (constraints.maxWidth - (spacing * (crossCount - 1))) / crossCount;
        final cellHeight =
            (constraints.maxHeight - (spacing * (rowCount - 1))) / rowCount;
        return GridView.count(
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossCount,
          mainAxisSpacing: spacing,
          crossAxisSpacing: spacing,
          childAspectRatio: cellWidth / cellHeight,
          children: roomIds
              .map(
                (roomId) => _TrcMallRoomCard(
                  roomId: roomId,
                  onTap: () => onRoomTap(roomId),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _TrcMallRoomCard extends StatelessWidget {
  const _TrcMallRoomCard({required this.roomId, required this.onTap});

  final String roomId;
  final VoidCallback onTap;

  static const String _mallFallbackImagePath = 'lib/assets/location/trc/shop.jpg';

  @override
  Widget build(BuildContext context) {
    final roomData = LocationsData.cityRooms[roomId];
    final displayName = roomData?.displayName ?? roomId;
    final imagePath = (roomData?.imagePath ?? '').trim();
    final primaryPath = roomId == LocationsData.cityMallGiftShop
        ? LocationsData.cityMallGiftShopImagePath
        : (imagePath.isNotEmpty
            ? imagePath
            : 'lib/assets/location/home_gg/rooms/kitchen.jpg');
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: GameTheme.cardDecoration(radius: 10),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              primaryPath,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Image.asset(
                _mallFallbackImagePath,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) =>
                    Container(color: Colors.grey.shade900),
              ),
            ),
            Container(
              color: Colors.black.withValues(
                alpha: roomId == LocationsData.cityMallGiftShop ? 0.22 : 0.4,
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  displayName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
