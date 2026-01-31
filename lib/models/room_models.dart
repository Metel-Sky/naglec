class RoomData {
  final String name;
  final String imagePath;
  final String description;
  final bool isLocked;

  // Обов'язково const перед RoomData
  const RoomData({
    required this.name,
    required this.imagePath,
    required this.description,
    this.isLocked = false,
  });
}