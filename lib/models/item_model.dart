class GameItem {
  final String id;
  final String name;
  final String description;
  /// Шлях до картинки предмета (наприклад lib/assets/items/canon.jpg). Якщо null — у рюкзаку показується іконка.
  final String? imagePath;
  /// Для витратних предметів: скільки разів ще можна використати одну одиницю.
  final int? usesLeft;

  const GameItem({
    required this.id,
    required this.name,
    required this.description,
    this.imagePath,
    this.usesLeft,
  });
}

/// Варіант випадкової знахідки при обшуку кімнати / лута.
/// Або гроші [money], або конкретний предмет [item].
class LootOption {
  final GameItem? item;
  final int money;
  /// Вага для майбутньої системи шансів (чим більше, тим частіше).
  final double weight;

  const LootOption({
    this.item,
    this.money = 0,
    this.weight = 1.0,
  });
}

/// Базові предмети, які використовуються у випадковому луті.
class GameItems {
  static const GameItem energyDrink = GameItem(
    id: 'energy_drink',
    name: 'Пляшка енергетику',
    description: 'Банка дешевого енергетичного напою.',
    imagePath: null,
  );

  /// Як у магазині ТРЦ / ноутбуці (ті самі `id`, що в MallShop).
  static const GameItem shopEnergy = GameItem(
    id: 'energy',
    name: 'Енергетик',
    description: 'Енергетичний напій.',
    imagePath: 'lib/assets/items/energy.jpg',
  );

  static const GameItem shopSnickers = GameItem(
    id: 'snickers',
    name: 'Снікерс',
    description: 'Батончик.',
    imagePath: 'lib/assets/items/snickers.png',
  );

  static const GameItem usbEmpty = GameItem(
    id: 'usb_empty',
    name: 'Пуста флешка',
    description: 'Звичайна USB-флешка без даних.',
    imagePath: 'lib/assets/items/usb.png',
  );

  static const GameItem usbCompromat = GameItem(
    id: 'usb_compromat',
    name: 'Флешка з компроматом',
    description: 'На цій флешці є щось цікаве.',
    imagePath: 'lib/assets/items/usb.png',
  );

  static const GameItem panties = GameItem(
    id: 'panties',
    name: 'Труси',
    description: 'Жіночі трусики, явно не твої.',
    imagePath: null,
  );

  static const GameItem panties1 = GameItem(
    id: 'panties_1',
    name: 'Труси',
    description: 'Жіночі трусики.',
    imagePath: 'lib/assets/items/panties_1.jpg',
  );

  static const GameItem panties2 = GameItem(
    id: 'panties_2',
    name: 'Труси',
    description: 'Жіночі трусики.',
    imagePath: 'lib/assets/items/panties.jpeg',
  );

  static const GameItem bra = GameItem(
    id: 'bra',
    name: 'Ліфчик',
    description: 'Жіночий ліфчик, залишений без нагляду.',
    imagePath: null,
  );

  static const GameItem braBlack = GameItem(
    id: 'bra_black',
    name: 'Ліфчик',
    description: 'Чорний ліфчик.',
    imagePath: 'lib/assets/items/bra_black.webp',
  );

  static const GameItem dildo = GameItem(
    id: 'dildo',
    name: 'Фалоімітатор',
    description: 'Іграшка для дорослих, краще не залишати її на видноті.',
    imagePath: null,
  );

  static const GameItem analPlug = GameItem(
    id: 'anal_plug',
    name: 'Анальна пробка',
    description: 'Дуже особистий аксесуар.',
    imagePath: null,
  );

  static const GameItem vibratorRemote = GameItem(
    id: 'vibrator_remote',
    name: 'Пульт від вібратора',
    description: 'Пульт керування від якоїсь цікавої іграшки.',
    imagePath: null,
  );

  static const GameItem roomKey = GameItem(
    id: 'room_key',
    name: 'Ключ від кімнати',
    description: 'Ключ, який відкриває чиїсь двері.',
    imagePath: null,
  );

  static const GameItem journalWomen = GameItem(
    id: 'journal_wom',
    name: 'Журнал',
    description: 'Журнал для дорослих.',
    imagePath: 'lib/assets/items/journal_wom.jpg',
  );

  static const GameItem playboyMagazine = GameItem(
    id: 'playboy',
    name: 'Журнал Playboy',
    description: 'Глянцевий журнал Playboy.',
    imagePath: 'lib/assets/items/playboy.png',
  );

  static const GameItem eroBook = GameItem(
    id: 'ero_book',
    name: 'Еротичний роман',
    description: 'Відвертий роман.',
    imagePath: 'lib/assets/items/ero_book.jpg',
  );

  static const GameItem pornMagazine = GameItem(
    id: 'porn_jur',
    name: 'Порно журнал',
    description: 'Глянцевий журнал 18+.',
    imagePath: 'lib/assets/items/porn_jur.png',
  );

  static const GameItem condom = GameItem(
    id: 'condom',
    name: 'Презерватив',
    description: 'Захист на всяк випадок.',
    imagePath: 'lib/assets/items/condom.jpg',
  );

  static const GameItem dildoPhoto = GameItem(
    id: 'dildo_room',
    name: 'Ділдо',
    description: 'Інтимна іграшка.',
    imagePath: 'lib/assets/items/dildo.jpg',
  );

  static const GameItem keyElsaRoom = GameItem(
    id: 'key_elsa_room',
    name: 'Ключ від кімнати Ельзи',
    description: 'Ключ, що відкриває кімнату Ельзи.',
    imagePath: 'lib/assets/items/key_elsa_room.webp',
  );

  static const GameItem keyPiperRoom = GameItem(
    id: 'key_piper_room',
    name: 'Ключ від кімнати Пайпер',
    description: 'Ключ, що відкриває кімнату Пайпер.',
    imagePath: 'lib/assets/items/key_piper_room.jpeg',
  );

  static const GameItem keyMomRoom = GameItem(
    id: 'keys_mom_room',
    name: 'Ключ від кімнати мами',
    description: 'Ключ, що відкриває мамину кімнату.',
    imagePath: 'lib/assets/items/keys_mom_room.jpg',
  );

  static const GameItem elsaLogin = GameItem(
    id: 'elsa_login',
    name: 'Логін Ельзи',
    description: 'Записка з логіном Ельзи.',
    imagePath: 'lib/assets/items/elsa_login.png',
  );

  /// ТРЦ general shop, `id: oil` — умова старту cherie_quest_002.
  static const GameItem massageAromaOil = GameItem(
    id: 'oil',
    name: 'Массажне арома масло',
    description: 'Ароматичне масло для масажу.',
    imagePath: 'lib/assets/items/maslo.jpg',
  );

  static const GameItem sondox = GameItem(
    id: 'hypnotic',
    name: 'Сондокс',
    description: 'Снодійне.',
    imagePath: 'lib/assets/items/hypnotic.jpg',
    usesLeft: 10,
  );
}

/// Загальний список лута, який може випадати при обшуку кімнат (без привʼязки до NPC).
class LootTables {
  /// Базовий пул випадкових знахідок.
  static const List<LootOption> commonSearchLoot = [
    // Гроші
    LootOption(money: 5),
    LootOption(money: 10),
    LootOption(money: 15),
    // Предмети
    LootOption(item: GameItems.energyDrink),
    LootOption(item: GameItems.usbEmpty),
    LootOption(item: GameItems.usbCompromat),
    LootOption(item: GameItems.panties),
    LootOption(item: GameItems.bra),
    LootOption(item: GameItems.dildo),
    LootOption(item: GameItems.analPlug),
    LootOption(item: GameItems.vibratorRemote),
    LootOption(item: GameItems.roomKey),
  ];
}