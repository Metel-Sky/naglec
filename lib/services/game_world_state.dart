import '../data/locations_room_data.dart';

class GameWorldState {
  /// Поточна глобальна зона (HOME, CITY, COLLEGE, etc.)
  String currentZone;

  /// Id кімнати (English key: corridor, kitchen, college_hall, etc.)
  String currentRoom;

  /// Чи знаходиться гг всередині кімнати
  bool isInsideRoom;

  GameWorldState({
    this.currentZone = "HOME",
    this.currentRoom = LocationsData.corridor,
    this.isInsideRoom = false,
  });

  Map<String, dynamic> toJson() => {
        'currentZone': currentZone,
        'currentRoom': currentRoom,
        'isInsideRoom': isInsideRoom,
      };

  void loadFromJson(Map<String, dynamic> json) {
    currentZone = json['currentZone'] ?? currentZone;
    currentRoom = json['currentRoom'] ?? currentRoom;
    isInsideRoom = json['isInsideRoom'] ?? isInsideRoom;
  }

  /// Скидає локацію до початкової для нової гри
  void reset() {
    currentZone = "HOME";
    currentRoom = LocationsData.corridor;
    isInsideRoom = false;
  }
}

