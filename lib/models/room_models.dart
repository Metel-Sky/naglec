class RoomData {
  final String name;
  final String imagePath;
  final String description;
  final bool isLocked;

  // Додайте слово const перед назвою класу тут:
  const RoomData({
    required this.name,
    required this.imagePath,
    required this.description,
    this.isLocked = false,
  });
}