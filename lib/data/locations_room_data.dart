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
    roomGg, kitchen, bathroom,
    momRoom, kiraRoom, ritaRoom,
    hall, yard, basement,
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
    auditorium1, auditorium2, auditorium3,
    library, directorOffice, canteen,
    gym, collegeYard, toilet,
  ];

  // --- Street: English id constants (4 будинки)#######################################
  static const String street = 'street';
  static const String friendHouse = 'friend_house';
  static const String auntHouse = 'aunt_house';
  static const String neighborHouse = 'neighbor_house';
  static const String classmateHouse = 'classmate_house';

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
    friendHouse, auntHouse, neighborHouse, classmateHouse,
  ];

  /// Назва кімнати для відображення в слотах та заголовку
  static String getRoomDisplayName(String roomId, {bool isCollege = false, bool isStreet = false}) {
    if (isCollege) return collegeRooms[roomId]?.displayName ?? roomId;
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
