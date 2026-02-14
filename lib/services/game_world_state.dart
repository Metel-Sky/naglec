import '../data/locations_room_data.dart';

class GameWorldState {
  /// Поточна глобальна зона (HOME, CITY, COLLEGE, etc.)
  String currentZone;

  /// Id кімнати (English key: corridor, kitchen, college_hall, etc.)
  String currentRoom;

  /// Чи знаходиться гг всередині кімнати
  bool isInsideRoom;

  /// На вулиці: id будинку (friend_house, aunt_house, …), null = на вулиці, не в будинку
  String? currentStreetHouse;

  GameWorldState({
    this.currentZone = "HOME",
    this.currentRoom = LocationsData.corridor,
    this.isInsideRoom = false,
    this.currentStreetHouse,
  });

  Map<String, dynamic> toJson() => {
        'currentZone': currentZone,
        'currentRoom': currentRoom,
        'isInsideRoom': isInsideRoom,
        'currentStreetHouse': currentStreetHouse,
      };

  void loadFromJson(Map<String, dynamic> json) {
    currentZone = json['currentZone'] ?? currentZone;
    currentRoom = json['currentRoom'] ?? currentRoom;
    isInsideRoom = json['isInsideRoom'] ?? isInsideRoom;
    currentStreetHouse = json['currentStreetHouse'] as String?;
  }

  /// Скидає локацію до початкової для нової гри
  void reset() {
    currentZone = "HOME";
    currentRoom = LocationsData.corridor;
    isInsideRoom = false;
    currentStreetHouse = null;
  }
}

