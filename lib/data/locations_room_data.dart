import '../models/room_models.dart';


class LocationsData {
  // Бібліотека для твого Дому
  static const Map<String, RoomData> homeRooms = {
    "Кухня": RoomData(
      name: "Кухня",
      imagePath: "lib/assets/home_gg/rooms/kitchen.jpg",
      description: "На кухні нікого немає",
    ),
    "Кімната гг": RoomData(
      name: "Кімната гг",
      imagePath: "lib/assets/home_gg/rooms/room_gg.jpg",
      description: "Твоя кімната. Тут панує творчий безлад.",
    ),
    "Ванна": RoomData(
      name: "Ванна",
      imagePath: "lib/assets/home_gg/rooms/bathroom.jpg",
      description: "У ванній пахне милом, тут пусто.",
    ),
    "Кімната мами": RoomData(
      name: "Кімната мами",
      imagePath: "lib/assets/home_gg/rooms/mom_room.jpg",
      description: "У ванній пахне милом, тут пусто.",
    ),
    "Кімната Кіри": RoomData(
      name: "Кімната Кіри",
      imagePath: "lib/assets/home_gg/rooms/kira_room.jpg",
      description: "У ванній пахне милом, тут пусто.",
    ),
    "Кімната Ріти": RoomData(
      name: "Кімната Ріти",
      imagePath: "lib/assets/home_gg/rooms/rita_room.jpg",
      description: "У ванній пахне милом, тут пусто.",
    ),
    "Зал": RoomData(
      name: "Зал",
      imagePath: "lib/assets/home_gg/rooms/relax_room.jpg",
      description: "У ванній пахне милом, тут пусто.",
    ),
    "Подвірʼя": RoomData(
      name: "Подвірʼя",
      imagePath: "lib/assets/home_gg/rooms/yard.webp",
      description: "У ванній пахне милом, тут пусто.",
    ),
    "Підвал": RoomData(
      name: "Підвал",
      imagePath: "lib/assets/home_gg/rooms/closed_door.jpg",
      description: "Підвал зараз закритий, ключі у мами.",
    ),

  };

  // Тут потім буде бібліотека для іншого будинку
  static const Map<String, RoomData> officeRooms = {
    "Офіс": RoomData(
      name: "Офіс",
      imagePath: "assets/rooms/office.jpg",
      description: "Робочий простір.",
    ),
  };
}