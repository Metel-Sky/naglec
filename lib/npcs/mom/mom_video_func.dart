import 'dart:math';

/// Заглушка, коли відео з mom_kitch/mom_shower/mom_room відсутні на диску (всі в pubspec).
const String _momVideoFallback = 'lib/assets/npcs/mom/mom_work_place.jpg';

final Random _random = Random();

String _pickRandom(List<String> paths) {
  if (paths.isEmpty) return _momVideoFallback;
  return paths[_random.nextInt(paths.length)];
}

String _pickSeeded(List<String> paths, int seed) {
  if (paths.isEmpty) return _momVideoFallback;
  return paths[Random(seed).nextInt(paths.length)];
}

///==========================================================================================
/// Відео для мами на кухні (7:00–8:00). Порожній список = показуємо заглушку.
const List<String> _momKitchenMorningVideos = [
  "lib/assets/npcs/mom/video/mom_kitch_1.mp4",
  "lib/assets/npcs/mom/video/mom_kitch_red_1.mp4",
  //"lib/assets/npcs/mom/video/mom_kitch_hard_1.mp4",


];

/// Повертає відео/картинку для кухні, коли там мама (7–8 ранку). Без seed — випадково (для сумісності).
String momKitchenMorning() => _pickRandom(_momKitchenMorningVideos);

/// Детермінований вибір за [seed]: однаковий seed = той самий ролик (щоб перебудова не міняла відео).
String momKitchenMorningSeeded(int seed) => _pickSeeded(_momKitchenMorningVideos, seed);

/// Вечір на кухні (готує вечерю) — **окремі** ролики від mom_room / pereodevaetsa.
/// Список можна замінити на окремі файли «вечеря», поки використовуємо ті самі кадри, що й ранкова кухня.
const List<String> _momKitchenEveningVideos = [
  "lib/assets/npcs/mom/video/mom_kitch_1.mp4",
  "lib/assets/npcs/mom/video/mom_kitch_red_1.mp4",
];

String momKitchenEveningSeeded(int seed) => _pickSeeded(_momKitchenEveningVideos, seed);

///==========================================================================================

/// Відео для мами у ванній вранці (8:00–9:00). Порожній = заглушка.
const List<String> _momShowerMorningVideoList = [
  "lib/assets/npcs/mom/video/shower_25_use_1.mp4"
];

String momShowerMorningVideos() => _pickRandom(_momShowerMorningVideoList);

String momShowerMorningVideosSeeded(int seed) => _pickSeeded(_momShowerMorningVideoList, seed);

/// Перевдягання: кімната мами (розклад) і кухня ввечері — один і той самий набір роликів.
const List<String> _momPereodevaetsaVideos = [
  "lib/assets/npcs/mom/video/pereodevaetsa.mp4",
  "lib/assets/npcs/mom/video/pereodevaetsa_1.mp4",
];

/// Мама в своїй кімнаті (розклад «перевдягається» тощо).
String momRoomMorningVideoList() => _pickRandom(_momPereodevaetsaVideos);

String momRoomMorningVideoListSeeded(int seed) => _pickSeeded(_momPereodevaetsaVideos, seed);

const List<String> _momRoomEveningVideoList = [
  "lib/assets/npcs/mom/video/mom_sleep_1.mp4",
  "lib/assets/npcs/mom/video/mom_sleep_2.mp4",
  "lib/assets/npcs/mom/video/mom_sleep_3_gola.mp4",
];

String momRoomEveningVideoList() => _pickRandom(_momRoomEveningVideoList);

String momRoomEveningVideoListSeeded(int seed) => _pickSeeded(_momRoomEveningVideoList, seed);

/// Legacy / випадковий вибір з того ж пулу, що «перевдягання» в кімнаті (якщо десь викликають напряму).
String momRoomMomEveningKitchenList() => _pickRandom(_momPereodevaetsaVideos);

String momRoomMomEveningKitchenListSeeded(int seed) => _pickSeeded(_momPereodevaetsaVideos, seed);
