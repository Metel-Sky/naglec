import 'package:flutter/material.dart';

import '../../../data/locations_room_data.dart';
import '../../../services/game_world_state.dart';
import '../../../services/service_locator.dart';
import '../laptop_screen_state_base.dart';
import '../laptop_shared_widgets.dart';

mixin LaptopHiddenCamerasMixin on LaptopScreenStateBase {
  @override
  Widget buildHiddenCamerasSubmenu() {
    final rooms = sl<GameWorldState>().installedSpyCameraRooms;
    if (rooms.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            t('laptop_hidden_cameras_empty'),
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9), fontSize: 16),
          ),
        ),
      );
    }
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          laptopBackButtonRow(
            onBack: () =>
                setState(() => showHiddenCamerasSubmenu = false),
            backLabel: t('laptop_study_back'),
          ),
          const SizedBox(height: 24),
          for (final roomId in rooms)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Material(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
                child: InkWell(
                  onTap: () =>
                      setState(() => watchingHiddenCameraRoom = roomId),
                  borderRadius: BorderRadius.circular(10),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        Icon(Icons.videocam,
                            size: 28,
                            color: Colors.white.withValues(alpha: 0.95)),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            LocationsData.getRoomDisplayName(roomId,
                                isCollege: false),
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.95),
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget buildHiddenCameraFeed(String roomId) {
    final displayName =
        LocationsData.getRoomDisplayName(roomId, isCollege: false);
    final roomData =
        LocationsData.homeRooms[roomId] ?? LocationsData.officeRooms[roomId];
    final imagePath =
        roomData?.imagePath ?? 'lib/assets/location/home_gg/rooms/kitchen.jpg';
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset(
            imagePath,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              color: Colors.black,
              child: Center(
                child: Text(
                  t('laptop_hidden_camera_feed').replaceAll('%s', displayName),
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: 8,
          left: 8,
          child: Material(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(8),
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 24),
              onPressed: () =>
                  setState(() => watchingHiddenCameraRoom = null),
            ),
          ),
        ),
        Positioned(
          left: 8,
          right: 8,
          bottom: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              t('laptop_hidden_camera_feed').replaceAll('%s', displayName),
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ),
      ],
    );
  }
}
