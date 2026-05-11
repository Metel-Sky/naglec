class RoomData {
  /// Назва для відображення в слотах кімнат та в UI (наприклад українською)
  final String displayName;
  /// Англійська назва (з `assets/data/location_display_en.json`), якщо мова EN.
  final String? displayNameEn;
  final String imagePath;
  final String description;
  final bool isLocked;

  const RoomData({
    required this.displayName,
    this.displayNameEn,
    required this.imagePath,
    required this.description,
    this.isLocked = false,
  });
}