import '../models/room_models.dart';

class LocationsData {
  // --- Home: English id constants ---
  static const String corridor = 'corridor';
  static const String kitchen = 'kitchen';
  static const String roomGg = 'room_gg';
  static const String bathroom = 'bathroom';
  static const String momRoom = 'mom_room';
  static const String kiraRoom = 'kira_room';
  static const String ritaRoom = 'rita_room';
  static const String hall = 'hall';
  static const String yard = 'yard';
  static const String basement = 'basement';

  static const Map<String, RoomData> homeRooms = {
    'corridor': RoomData(
      displayName: "Коридор",
      imagePath: "lib/assets/home_gg/rooms/default.jpg",
      description: "Коридор будинку.",
      isLocked: false,
    ),
    'kitchen': RoomData(
      displayName: "Кухня",
      imagePath: "lib/assets/home_gg/rooms/kitchen.jpg",
      description: "На кухні нікого немає",
      isLocked: false,
    ),
    'room_gg': RoomData(
      displayName: "Кімната гг",
      imagePath: "lib/assets/home_gg/rooms/room_gg.jpg",
      description: "Твоя кімната. Тут панує творчий безлад.",
      isLocked: false,
    ),
    'bathroom': RoomData(
      displayName: "Ванна",
      imagePath: "lib/assets/home_gg/rooms/bathroom.jpg",
      description: "У ванній пахне милом, тут пусто.",
      isLocked: false,
    ),
    'mom_room': RoomData(
      displayName: "Кімната мами",
      imagePath: "lib/assets/home_gg/rooms/mom_room.jpg",
      description: "Кімната мами.",
      isLocked: false,
    ),
    'kira_room': RoomData(
      displayName: "Кімната Кіри",
      imagePath: "lib/assets/home_gg/rooms/kira_room.jpg",
      description: "Кімната Кіри, тут нікого немає.",
      isLocked: false,
    ),
    'rita_room': RoomData(
      displayName: "Кімната Ріти",
      imagePath: "lib/assets/home_gg/rooms/rita_room.jpg",
      description: "Кімната Ріти, тут нікого немає.",
      isLocked: false,
    ),
    'hall': RoomData(
      displayName: "Зал",
      imagePath: "lib/assets/home_gg/rooms/relax_room.jpg",
      description: "Зал.",
      isLocked: false,
    ),
    'yard': RoomData(
      displayName: "Подвірʼя",
      imagePath: "lib/assets/home_gg/rooms/yard.webp",
      description: "Подвірʼя.",
      isLocked: false,
    ),
    'basement': RoomData(
      displayName: "Підвал",
      imagePath: "lib/assets/home_gg/rooms/closed_door.jpg",
      description: "Підвал зараз закритий, ключі у мами.",
      isLocked: true,
    ),
  };

  static const List<String> homeRoomIds = [
    roomGg,
    kitchen,
    bathroom,
    momRoom,
    kiraRoom,
    ritaRoom,
    hall,
    yard,
    basement,
  ];

  // --- College: English id constants ---
  static const String collegeHall = 'college_hall';
  static const String auditorium1 = 'auditorium_1';
  static const String auditorium2 = 'auditorium_2';
  static const String auditorium3 = 'auditorium_3';
  static const String library = 'library';
  static const String directorOffice = 'director_office';
  static const String canteen = 'canteen';
  static const String gym = 'gym';
  static const String collegeYard = 'college_yard';
  static const String toilet = 'toilet';

  static const Map<String, RoomData> collegeRooms = {
    'college_hall': RoomData(
      displayName: "Хол",
      imagePath: "lib/assets/home_gg/rooms/default.jpg",
      description: "Головний хол коледжу.",
      isLocked: false,
    ),
    'auditorium_1': RoomData(
      displayName: "Англійська",
      imagePath: "lib/assets/college/rooms/audit_1.jpg",
      description: "Лекційна аудиторія.",
      isLocked: false,
    ),
    'auditorium_2': RoomData(
      displayName: "Математика",
      imagePath: "lib/assets/college/rooms/audit_2.jpeg",
      description: "Лекційна аудиторія.",
      isLocked: false,
    ),
    'auditorium_3': RoomData(
      displayName: "Історія",
      imagePath: "lib/assets/college/rooms/audit_3.jpg",
      description: "Лекційна аудиторія.",
      isLocked: false,
    ),
    'library': RoomData(
      displayName: "Бібліотека",
      imagePath: "lib/assets/college/rooms/lib.jpg",
      description: "Коледжна бібліотека.",
      isLocked: false,
    ),
    'director_office': RoomData(
      displayName: "Кабінет директора",
      imagePath: "lib/assets/college/rooms/office.jpg",
      description: "Кабінет директора коледжу.",
      isLocked: false,
    ),
    'canteen': RoomData(
      displayName: "Столова",
      imagePath: "lib/assets/college/rooms/dining_room.jpg",
      description: "Коледжна столова.",
      isLocked: false,
    ),
    'gym': RoomData(
      displayName: "Спортзал",
      imagePath: "lib/assets/college/rooms/gym_room.jpg",
      description: "Спортивний зал.",
      isLocked: false,
    ),
    'college_yard': RoomData(
      displayName: "Двір коледжу",
      imagePath: "lib/assets/college/rooms/stadion.jpg",
      description: "Подвірʼя коледжу.",
      isLocked: false,
    ),
    'toilet': RoomData(
      displayName: "Туалет",
      imagePath: "lib/assets/college/rooms/tualet.jpg",
      description: "Гардеробна.",
      isLocked: false,
    ),
  };

  static const List<String> collegeRoomIds = [
    auditorium1,
    auditorium2,
    auditorium3,
    library,
    directorOffice,
    canteen,
    gym,
    collegeYard,
    toilet,
  ];

  // --- Street: English id constants (4 будинки) ---
  static const String street = 'street';
  static const String friendHouse = 'friend_house';
  static const String auntHouse = 'aunt_house';
  static const String neighborHouse = 'neighbor_house';
  static const String classmateHouse = 'classmate_house';

  // Ключі кімнат будинку кориша (6 кімнат)
  static const String friendCorridor = 'friend_corridor';
  static const String friendKitchen = 'friend_kitchen';
  static const String friendRoom = 'friend_room';
  static const String friendBathroom = 'friend_bathroom';
  static const String friendParentsRoom = 'friend_parents_room';
  static const String friendSisterRoom = 'friend_sister_room';
  static const String friendHall = 'friend_hall';

  // Ключі кімнат будинку тітки (9 кімнат)
  static const String auntCorridor = 'aunt_corridor';
  static const String auntKitchen = 'aunt_kitchen';
  static const String auntRoom = 'aunt_room';
  static const String auntBathroom = 'aunt_bathroom';
  static const String auntGuestRoom = 'aunt_guest_room';
  static const String auntNephewRoom = 'aunt_nephew_room';
  static const String auntNieceRoom = 'aunt_niece_room';
  static const String auntHall = 'aunt_hall';
  static const String auntYard = 'aunt_yard';
  static const String auntBasement = 'aunt_basement';

  // Ключі кімнат сусідського будинку (9 кімнат)
  static const String neighborCorridor = 'neighbor_corridor';
  static const String neighborKitchen = 'neighbor_kitchen';
  static const String neighborRoom = 'neighbor_room';
  static const String neighborBathroom = 'neighbor_bathroom';
  static const String neighborParentsRoom = 'neighbor_parents_room';
  static const String neighborChild1 = 'neighbor_child_1';
  static const String neighborChild2 = 'neighbor_child_2';
  static const String neighborHall = 'neighbor_hall';
  static const String neighborYard = 'neighbor_yard';
  static const String neighborBasement = 'neighbor_basement';

  // Ключі кімнат будинку однокласниці (9 кімнат)
  static const String classmateCorridor = 'classmate_corridor';
  static const String classmateKitchen = 'classmate_kitchen';
  static const String classmateRoom = 'classmate_room';
  static const String classmateBathroom = 'classmate_bathroom';
  static const String classmateParentsRoom = 'classmate_parents_room';
  static const String classmateBrotherRoom = 'classmate_brother_room';
  static const String classmateSisterRoom = 'classmate_sister_room';
  static const String classmateHall = 'classmate_hall';
  static const String classmateYard = 'classmate_yard';
  static const String classmateBasement = 'classmate_basement';

  static const Map<String, RoomData> streetRooms = {
    'street': RoomData(
      displayName: "Вулиця",
      imagePath: "lib/assets/home_gg/rooms/default.jpg",
      description: "Вулиця.",
      isLocked: false,
    ),
    'friend_house': RoomData(
      displayName: "Дім кориша",
      imagePath: "lib/assets/houses/friend_home.jpg",
      description: "Будинок кориша.",
      isLocked: false,
    ),
    'aunt_house': RoomData(
      displayName: "Дім тітки",
      imagePath: "lib/assets/houses/aunt_home.jpg",
      description: "Будинок тітки.",
      isLocked: false,
    ),
    'neighbor_house': RoomData(
      displayName: "Сусідський дім",
      imagePath: "lib/assets/houses/neighbor.jpg",
      description: "Будинок сусідів.",
      isLocked: false,
    ),
    'classmate_house': RoomData(
      displayName: "Дім однокласниці",
      imagePath: "lib/assets/houses/classmate_home.jpg",
      description: "Будинок однокласниці.",
      isLocked: false,
    ),
  };

  static const List<String> streetRoomIds = [
    friendHouse,
    auntHouse,
    neighborHouse,
    classmateHouse,
  ];

  /// Будинки на вулиці: у кожного свої ключі кімнат (friend_*, aunt_*, neighbor_*, classmate_*).
  static const Map<String, Map<String, RoomData>> streetHouseRooms = {

    ///---------------------Будинок кориша----------------------------------------
    friendHouse: {
      friendCorridor: RoomData(
        displayName: "Коридор",
        imagePath: "lib/assets/houses/friend_home.jpg",
        description: "Коридор будинку кориша.",
        isLocked: false,
      ),
      friendKitchen: RoomData(
        displayName: "Кухня",
        imagePath: "lib/assets/houses/friend_home.jpg",
        description: "Кухня в будинку кориша.",
        isLocked: false,
      ),
      friendRoom: RoomData(
        displayName: "Кімната кориша",
        imagePath: "lib/assets/houses/friend_home.jpg",
        description: "Кімната твого друга.",
        isLocked: false,
      ),
      friendBathroom: RoomData(
        displayName: "Ванна",
        imagePath: "lib/assets/houses/friend_home.jpg",
        description: "Ванна.",
        isLocked: false,
      ),
      friendParentsRoom: RoomData(
        displayName: "Кімната батьків",
        imagePath: "lib/assets/houses/friend_home.jpg",
        description: "Кімната батьків.",
        isLocked: false,
      ),
      friendSisterRoom: RoomData(
        displayName: "Кімната сестри",
        imagePath: "lib/assets/houses/friend_home.jpg",
        description: "Кімната сестри.",
        isLocked: false,
      ),
      friendHall: RoomData(
        displayName: "Зал",
        imagePath: "lib/assets/houses/friend_home.jpg",
        description: "Зал.",
        isLocked: false,
      ),
    },
    ///---------------------Будинок тітки----------------------------------------
    auntHouse: {
      auntCorridor: RoomData(
        displayName: "Коридор",
        imagePath: "lib/assets/houses/aunt_home.jpg",
        description: "Коридор будинку тітки.",
        isLocked: false,
      ),
      auntKitchen: RoomData(
        displayName: "Кухня",
        imagePath: "lib/assets/houses/aunt_home.jpg",
        description: "Кухня в будинку тітки.",
        isLocked: false,
      ),
      auntRoom: RoomData(
        displayName: "Кімната тітки",
        imagePath: "lib/assets/houses/aunt_home.jpg",
        description: "Кімната тітки.",
        isLocked: false,
      ),
      auntBathroom: RoomData(
        displayName: "Ванна",
        imagePath: "lib/assets/houses/aunt_home.jpg",
        description: "Ванна.",
        isLocked: false,
      ),
      auntGuestRoom: RoomData(
        displayName: "Гостьова",
        imagePath: "lib/assets/houses/aunt_home.jpg",
        description: "Гостьова кімната.",
        isLocked: false,
      ),
      auntNephewRoom: RoomData(
        displayName: "Кімната племінника",
        imagePath: "lib/assets/houses/aunt_home.jpg",
        description: "Кімната племінника.",
        isLocked: false,
      ),
      auntNieceRoom: RoomData(
        displayName: "Кімната племінниці",
        imagePath: "lib/assets/houses/aunt_home.jpg",
        description: "Кімната племінниці.",
        isLocked: false,
      ),
      auntHall: RoomData(
        displayName: "Зал",
        imagePath: "lib/assets/houses/aunt_home.jpg",
        description: "Зал.",
        isLocked: false,
      ),
      auntYard: RoomData(
        displayName: "Подвір'я",
        imagePath: "lib/assets/houses/aunt_home.jpg",
        description: "Подвір'я.",
        isLocked: false,
      ),
      auntBasement: RoomData(
        displayName: "Підвал",
        imagePath: "lib/assets/houses/aunt_home.jpg",
        description: "Підвал.",
        isLocked: true,
      ),
    },
    ///---------------------Будинок сусідки----------------------------------------
    neighborHouse: {
      neighborCorridor: RoomData(
        displayName: "Коридор",
        imagePath: "lib/assets/houses/neighbor.jpg",
        description: "Коридор сусідського будинку.",
        isLocked: false,
      ),
      neighborKitchen: RoomData(
        displayName: "Кухня",
        imagePath: "lib/assets/houses/neighbor.jpg",
        description: "Кухня у сусідів.",
        isLocked: false,
      ),
      neighborRoom: RoomData(
        displayName: "Кімната сусіда",
        imagePath: "lib/assets/houses/neighbor.jpg",
        description: "Кімната сусіда.",
        isLocked: false,
      ),
      neighborBathroom: RoomData(
        displayName: "Ванна",
        imagePath: "lib/assets/houses/neighbor.jpg",
        description: "Ванна.",
        isLocked: false,
      ),
      neighborParentsRoom: RoomData(
        displayName: "Кімната батьків",
        imagePath: "lib/assets/houses/neighbor.jpg",
        description: "Кімната батьків.",
        isLocked: false,
      ),
      neighborChild1: RoomData(
        displayName: "Дитяча 1",
        imagePath: "lib/assets/houses/neighbor.jpg",
        description: "Дитяча кімната.",
        isLocked: false,
      ),
      neighborChild2: RoomData(
        displayName: "Дитяча 2",
        imagePath: "lib/assets/houses/neighbor.jpg",
        description: "Дитяча кімната.",
        isLocked: false,
      ),
      neighborHall: RoomData(
        displayName: "Зал",
        imagePath: "lib/assets/houses/neighbor.jpg",
        description: "Зал.",
        isLocked: false,
      ),
      neighborYard: RoomData(
        displayName: "Подвір'я",
        imagePath: "lib/assets/houses/neighbor.jpg",
        description: "Подвір'я.",
        isLocked: false,
      ),
      neighborBasement: RoomData(
        displayName: "Підвал",
        imagePath: "lib/assets/houses/neighbor.jpg",
        description: "Підвал.",
        isLocked: true,
      ),
    },
    ///---------------------Будинок однокласниці----------------------------------------
    classmateHouse: {
      classmateCorridor: RoomData(
        displayName: "Коридор",
        imagePath: "lib/assets/houses/classmate_home.jpg",
        description: "Коридор будинку однокласниці.",
        isLocked: false,
      ),
      classmateKitchen: RoomData(
        displayName: "Кухня",
        imagePath: "lib/assets/houses/classmate_home.jpg",
        description: "Кухня.",
        isLocked: false,
      ),
      classmateRoom: RoomData(
        displayName: "Кімната однокласниці",
        imagePath: "lib/assets/houses/classmate_home.jpg",
        description: "Кімната однокласниці.",
        isLocked: false,
      ),
      classmateBathroom: RoomData(
        displayName: "Ванна",
        imagePath: "lib/assets/houses/classmate_home.jpg",
        description: "Ванна.",
        isLocked: false,
      ),
      classmateParentsRoom: RoomData(
        displayName: "Кімната батьків",
        imagePath: "lib/assets/houses/classmate_home.jpg",
        description: "Кімната батьків.",
        isLocked: false,
      ),
      classmateBrotherRoom: RoomData(
        displayName: "Кімната брата",
        imagePath: "lib/assets/houses/classmate_home.jpg",
        description: "Кімната брата.",
        isLocked: false,
      ),
      classmateSisterRoom: RoomData(
        displayName: "Кімната сестри",
        imagePath: "lib/assets/houses/classmate_home.jpg",
        description: "Кімната сестри.",
        isLocked: false,
      ),
      classmateHall: RoomData(
        displayName: "Зал",
        imagePath: "lib/assets/houses/classmate_home.jpg",
        description: "Зал.",
        isLocked: false,
      ),
      classmateYard: RoomData(
        displayName: "Подвір'я",
        imagePath: "lib/assets/houses/classmate_home.jpg",
        description: "Подвір'я.",
        isLocked: false,
      ),
      classmateBasement: RoomData(
        displayName: "Підвал",
        imagePath: "lib/assets/houses/classmate_home.jpg",
        description: "Підвал.",
        isLocked: true,
      ),
    },
  };

  /// Список id кімнат для сітки будинку (коридор не показується як слот — це опціональна вхідна локація).
  static List<String> getRoomIdsForStreetHouse(String? houseId) {
    if (houseId == friendHouse) {
      return [
        friendKitchen,
        friendRoom,
        friendBathroom,
        friendParentsRoom,
        friendSisterRoom,
        friendHall,
      ];
    }
    if (houseId == auntHouse) {
      return [
        auntKitchen,
        auntRoom,
        auntBathroom,
        auntGuestRoom,
        auntNephewRoom,
        auntNieceRoom,
        auntHall,
        auntYard,
        auntBasement,
      ];
    }
    if (houseId == neighborHouse) {
      return [
        neighborKitchen,
        neighborRoom,
        neighborBathroom,
        neighborParentsRoom,
        neighborChild1,
        neighborChild2,
        neighborHall,
        neighborYard,
        neighborBasement,
      ];
    }
    if (houseId == classmateHouse) {
      return [
        classmateKitchen,
        classmateRoom,
        classmateBathroom,
        classmateParentsRoom,
        classmateBrotherRoom,
        classmateSisterRoom,
        classmateHall,
        classmateYard,
        classmateBasement,
      ];
    }
    return [];
  }

  /// Вхідна локація будинку (коридор) — не слот, лише стан при заході та при «назад».
  static String? getFirstRoomIdForStreetHouse(String? houseId) {
    if (houseId == friendHouse) return friendCorridor;
    if (houseId == auntHouse) return auntCorridor;
    if (houseId == neighborHouse) return neighborCorridor;
    if (houseId == classmateHouse) return classmateCorridor;
    return null;
  }

  /// Кімнати будинку на вулиці.
  static Map<String, RoomData>? getRoomsForStreetHouse(String? houseId) {
    if (houseId == null) return null;
    return streetHouseRooms[houseId];
  }

  /// Назва кімнати для відображення в слотах та заголовку.
  /// Якщо [streetHouseId] задано, пошук у кімнатах цього будинку (friend_kitchen тощо).
  static String getRoomDisplayName(
    String roomId, {
    bool isCollege = false,
    bool isStreet = false,
    String? streetHouseId,
  }) {
    if (isCollege) return collegeRooms[roomId]?.displayName ?? roomId;
    if (streetHouseId != null) {
      final name = streetHouseRooms[streetHouseId]?[roomId]?.displayName;
      if (name != null) return name;
    }
    if (isStreet) return streetRooms[roomId]?.displayName ?? roomId;
    return homeRooms[roomId]?.displayName ?? roomId;
  }

  static const Map<String, RoomData> officeRooms = {
    "office": RoomData(
      displayName: "Офіс",
      imagePath: "assets/rooms/office.jpg",
      description: "Робочий простір.",
      isLocked: false,
    ),
  };
}
