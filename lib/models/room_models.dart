class RoomData {
  /// Назва для відображення в слотах кімнат та в UI (наприклад українською)
  final String displayName;
  final String imagePath;
  final String description;
  final bool isLocked;

  const RoomData({
    required this.displayName,
    required this.imagePath,
    required this.description,
    this.isLocked = false,
  });
}