import '../models/room_models.dart';


class LocationsData {
  // Бібліотека для твого Дому
  static const Map<String, RoomData> homeRooms = {
    "Кухня": const RoomData(
      name: "Кухня",
      imagePath: "lib/assets/home_gg/rooms/kitchen.jpg",
      description: "На кухні нікого немає",
      isLocked: false, // Тепер ми знаємо, що він закритий
    ),
    "Кімната гг": const RoomData(
      name: "Кімната гг",
      imagePath: "lib/assets/home_gg/rooms/room_gg.jpg",
      description: "Твоя кімната. Тут панує творчий безлад.",
      isLocked: false, // Тепер ми знаємо, що він закритий
    ),
    "Ванна": const RoomData(
      name: "Ванна",
      imagePath: "lib/assets/home_gg/rooms/bathroom.jpg",
      description: "У ванній пахне милом, тут пусто.",
      isLocked: false, // Тепер ми знаємо, що він закритий
    ),
    "Кімната мами": const RoomData(
      name: "Кімната мами",
      imagePath: "lib/assets/home_gg/rooms/mom_room.jpg",
      description: "У ванній пахне милом, тут пусто.",
      isLocked: false, // Тепер ми знаємо, що він закритий
    ),
    "Кімната Кіри": const RoomData(
      name: "Кімната Кіри",
      imagePath: "lib/assets/home_gg/rooms/kira_room.jpg",
      description: "Кімната Кіри, тут нікого немає.",
      isLocked: true, // Тепер ми знаємо, що він закритий
    ),
    "Кімната Ріти": const RoomData(
      name: "Кімната Ріти",
      imagePath: "lib/assets/home_gg/rooms/rita_room.jpg",
      description: "Кімната Ріти, тут нікого немає.",
      isLocked: false, // Тепер ми знаємо, що він закритий
    ),
    "Зал": const RoomData(
      name: "Зал",
      imagePath: "lib/assets/home_gg/rooms/relax_room.jpg",
      description: "У ванній пахне милом, тут пусто.",
      isLocked: false, // Тепер ми знаємо, що він закритий
    ),
    "Подвірʼя": const RoomData(
      name: "Подвірʼя",
      imagePath: "lib/assets/home_gg/rooms/yard.webp",
      description: "У ванній пахне милом, тут пусто.",
      isLocked: false, // Тепер ми знаємо, що він закритий
    ),
    "Підвал": const RoomData(
      name: "Підвал",
      imagePath: "lib/assets/home_gg/rooms/closed_door.jpg",
      description: "Підвал зараз закритий, ключі у мами.",
      isLocked: true, // Тепер ми знаємо, що він закритий
    ),

  };

  // Тут потім буде бібліотека для іншого будинку
  static const Map<String, RoomData> officeRooms = {
    "Офіс": const RoomData(
      name: "Офіс",
      imagePath: "assets/rooms/office.jpg",
      description: "Робочий простір.",
      isLocked: false, // Тепер ми знаємо, що він закритий
    ),
  };
}