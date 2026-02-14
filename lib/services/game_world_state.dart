class GameWorldState {
  /// Поточна глобальна зона (наприклад: HOME, CITY і т.д.)
  String currentZone;

  /// Поточна кімната всередині зони (наприклад: Коридор, Кухня і т.д.)
  String currentRoom;

  /// Чи знаходиться гг всередині кімнати (true) або у "загальній" зоні (false)
  bool isInsideRoom;

  GameWorldState({
    this.currentZone = "HOME",
    this.currentRoom = "Коридор",
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
    currentRoom = "Коридор";
    isInsideRoom = false;
  }
}

