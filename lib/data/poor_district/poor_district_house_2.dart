import '../../models/room_models.dart';

/// Будинок 2 у спальних будинках бідного району: 3 квартири, по 4 кімнати.
class PoorDistrictHouse2 {
  static const String id = 'poor_district_house_2';

  static const String apt1 = 'poor_district_h2_apt_1';
  static const String apt2 = 'poor_district_h2_apt_2';
  static const String apt3 = 'poor_district_h2_apt_3';

  static const List<String> apartmentIds = [apt1, apt2, apt3];

  static const String rA1_1 = 'poor_district_h2_a1_room_1';
  static const String rA1_2 = 'poor_district_h2_a1_room_2';
  static const String rA1_3 = 'poor_district_h2_a1_room_3';
  static const String rA1_4 = 'poor_district_h2_a1_room_4';
  static const String rA2_1 = 'poor_district_h2_a2_room_1';
  static const String rA2_2 = 'poor_district_h2_a2_room_2';
  static const String rA2_3 = 'poor_district_h2_a2_room_3';
  static const String rA2_4 = 'poor_district_h2_a2_room_4';
  static const String rA3_1 = 'poor_district_h2_a3_room_1';
  static const String rA3_2 = 'poor_district_h2_a3_room_2';
  static const String rA3_3 = 'poor_district_h2_a3_room_3';
  static const String rA3_4 = 'poor_district_h2_a3_room_4';

  static List<String> getRoomIdsForApartment(String apartmentId) {
    switch (apartmentId) {
      case apt1:
        return [rA1_1, rA1_2, rA1_3, rA1_4];
      case apt2:
        return [rA2_1, rA2_2, rA2_3, rA2_4];
      case apt3:
        return [rA3_1, rA3_2, rA3_3, rA3_4];
      default:
        return [];
    }
  }

  static const Map<String, RoomData> rooms = {
    id: RoomData(
      displayName: "Бандери 2",
      imagePath: "lib/assets/location/houses/hrushchevki-spb.jpg",
      description: "Будинок 2.",
      isLocked: false,
    ),
    apt1: RoomData(
      displayName: "Кв. 1",
      imagePath: "lib/assets/location/houses/hrushchevki-spb.jpg",
      description: "Квартира 1.",
      isLocked: false,
    ),
    apt2: RoomData(
      displayName: "Кв. 2",
      imagePath: "lib/assets/location/houses/hrushchevki-spb.jpg",
      description: "Квартира 2.",
      isLocked: false,
    ),
    apt3: RoomData(
      displayName: "Кв. 3",
      imagePath: "lib/assets/location/houses/hrushchevki-spb.jpg",
      description: "Квартира 3.",
      isLocked: false,
    ),
    /// Порядок кімнат у кожній квартирі: кухня → ванна → зал → спальня.
    rA1_1: RoomData(displayName: "Кухня", imagePath: "lib/assets/location/home_gg/rooms/kitchen.jpg", description: "Кухня.", isLocked: false),
    rA1_2: RoomData(displayName: "Ванна", imagePath: "lib/assets/location/home_gg/rooms/bathroom.jpg", description: "Ванна.", isLocked: false),
    rA1_3: RoomData(displayName: "Зал", imagePath: "lib/assets/location/home_gg/rooms/relax_room.jpg", description: "Зал.", isLocked: false),
    rA1_4: RoomData(displayName: "Спальня", imagePath: "lib/assets/location/home_gg/rooms/room_gg.jpg", description: "Спальня.", isLocked: false),
    rA2_1: RoomData(displayName: "Кухня", imagePath: "lib/assets/location/home_gg/rooms/kitchen.jpg", description: "Кухня.", isLocked: false),
    rA2_2: RoomData(displayName: "Ванна", imagePath: "lib/assets/location/home_gg/rooms/bathroom.jpg", description: "Ванна.", isLocked: false),
    rA2_3: RoomData(displayName: "Зал", imagePath: "lib/assets/location/home_gg/rooms/relax_room.jpg", description: "Зал.", isLocked: false),
    rA2_4: RoomData(displayName: "Спальня", imagePath: "lib/assets/location/home_gg/rooms/room_gg.jpg", description: "Спальня.", isLocked: false),
    rA3_1: RoomData(displayName: "Кухня", imagePath: "lib/assets/location/home_gg/rooms/kitchen.jpg", description: "Кухня.", isLocked: false),
    rA3_2: RoomData(displayName: "Ванна", imagePath: "lib/assets/location/home_gg/rooms/bathroom.jpg", description: "Ванна.", isLocked: false),
    rA3_3: RoomData(displayName: "Зал", imagePath: "lib/assets/location/home_gg/rooms/relax_room.jpg", description: "Зал.", isLocked: false),
    rA3_4: RoomData(displayName: "Спальня", imagePath: "lib/assets/location/home_gg/rooms/room_gg.jpg", description: "Спальня.", isLocked: false),
  };
}
