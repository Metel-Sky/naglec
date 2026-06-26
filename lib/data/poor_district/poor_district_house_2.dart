import '../../models/room_models.dart';

/// Будинок 2 у спальних будинках бідного району: 4 квартири, по 4 кімнати.
class PoorDistrictHouse2 {
  static const String id = 'poor_district_house_2';

  static const String apt1 = 'poor_district_h2_apt_1';
  static const String apt2 = 'poor_district_h2_apt_2';
  static const String apt3 = 'poor_district_h2_apt_3';
  static const String apt4 = 'poor_district_h2_apt_4';

  static const List<String> apartmentIds = [apt1, apt2, apt3, apt4];

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
  static const String rA4_1 = 'poor_district_h2_a4_room_1';
  static const String rA4_2 = 'poor_district_h2_a4_room_2';
  static const String rA4_3 = 'poor_district_h2_a4_room_3';
  static const String rA4_4 = 'poor_district_h2_a4_room_4';

  static List<String> getRoomIdsForApartment(String apartmentId) {
    switch (apartmentId) {
      case apt1:
        return [rA1_1, rA1_2, rA1_3, rA1_4];
      case apt2:
        return [rA2_1, rA2_2, rA2_3, rA2_4];
      case apt3:
        return [rA3_1, rA3_2, rA3_3, rA3_4];
      case apt4:
        return [rA4_1, rA4_2, rA4_3, rA4_4];
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
      displayName: "Квартира 1 — Kyler",
      imagePath: "lib/assets/location/houses/hrushchevki-spb.jpg",
      description: "Квартира 1, Бандери 2. Тут живе Kyler.",
      isLocked: false,
    ),
    apt2: RoomData(
      displayName: "Квартира 2 — Zazie, Geisha",
      imagePath: "lib/assets/location/houses/hrushchevki-spb.jpg",
      description: "Квартира 2, Бандери 2. Тут живуть Zazie та Geisha.",
      isLocked: false,
    ),
    apt3: RoomData(
      displayName: "Квартира 3 — Foxy, Nikki",
      imagePath: "lib/assets/location/houses/hrushchevki-spb.jpg",
      description: "Квартира 3, Бандери 2. Тут живуть Foxy та Nikki.",
      isLocked: false,
    ),
    apt4: RoomData(
      displayName: "Квартира 4",
      imagePath: "lib/assets/location/houses/hrushchevki-spb.jpg",
      description: "Квартира 4, Бандери 2.",
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
    rA2_4: RoomData(displayName: "Кімната Zazie", imagePath: "lib/assets/location/home_gg/rooms/room_gg.jpg", description: "Спальня квартири 2, Бандери 2. Тут живуть Zazie та Geisha.", isLocked: false),
    rA3_1: RoomData(displayName: "Кухня", imagePath: "lib/assets/location/home_gg/rooms/kitchen.jpg", description: "Кухня.", isLocked: false),
    rA3_2: RoomData(displayName: "Ванна", imagePath: "lib/assets/location/home_gg/rooms/bathroom.jpg", description: "Ванна.", isLocked: false),
    rA3_3: RoomData(displayName: "Кімната Nikki", imagePath: "lib/assets/location/houses/rooms/nikki_room.jpg", description: "Кімната Nikki, квартира 3, Бандери 2.", isLocked: false),
    rA3_4: RoomData(displayName: "Кімната Foxy", imagePath: "lib/assets/location/home_gg/rooms/room_gg.jpg", description: "Спальня квартири 3, Бандери 2. Тут живе Foxy.", isLocked: false),
    rA4_1: RoomData(displayName: "Кухня", imagePath: "lib/assets/location/home_gg/rooms/kitchen.jpg", description: "Кухня.", isLocked: false),
    rA4_2: RoomData(displayName: "Ванна", imagePath: "lib/assets/location/home_gg/rooms/bathroom.jpg", description: "Ванна.", isLocked: false),
    rA4_3: RoomData(displayName: "Зал", imagePath: "lib/assets/location/home_gg/rooms/relax_room.jpg", description: "Зал.", isLocked: false),
    rA4_4: RoomData(displayName: "Спальня", imagePath: "lib/assets/location/home_gg/rooms/room_gg.jpg", description: "Спальня.", isLocked: false),
  };
}
