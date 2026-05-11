const String _elsaAvatarPath = 'lib/assets/npcs/elsa/elsa.png';

/// Повертає аватарку Elsa замість відео.
String elsaRoomVideos() {
  return _elsaAvatarPath;
}

/// Сумісність зі старим API: seed ігнорується, відео вимкнені.
String elsaRoomVideosSeeded(int seed) {
  return _elsaAvatarPath;
}



/// Аватарка для залу замість відео.
String elsaHallVideoList() {
  return _elsaAvatarPath;
}

String elsaHallVideoListSeeded(int seed) {
  return _elsaAvatarPath;
}
