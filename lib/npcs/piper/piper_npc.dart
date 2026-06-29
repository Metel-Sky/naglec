import '../../models/npc_model.dart';
import '../../models/item_model.dart';
import '../../data/locations_room_data.dart';

const String kPiperGalleryPortraitPath = 'lib/assets/npcs/piper/piper_ava.jpg';
const String kPiperAvatarPath = 'lib/assets/npcs/piper/piper.png';

/// Особисті речі Piper, які можуть випадати при обшуку її кімнати.
const List<LootOption> piperPersonalLoot = [
  LootOption(item: GameItems.panties, weight: 0.1),
  LootOption(item: GameItems.bra, weight: 0.1),
  LootOption(item: GameItems.dildo, weight: 0.05),
  LootOption(item: GameItems.roomKey, weight: 0.05),
];

const List<NpcOwnedItem> _piperOwnedItems = [
  NpcOwnedItem(
    id: 'piper_old_phone',
    name: 'Старенький телефон',
    imagePath: 'lib/assets/items/old_samsung.jpg',
  ),
  NpcOwnedItem(
    id: 'piper_old_laptop',
    name: 'Старенький ноутбук',
    imagePath: 'lib/assets/items/mac.png',
  ),
];

/// Модель NPC: Piper (статистика, розклад, аватар).
NPCModel createPiperNpc() {
  return NPCModel(
    id: 'piper',
    name: 'Piper',
    fullName: 'Piper',
    status: 'Молодша сестра',
    bodyDescription:
        'Ще одна блондинка в сім\'ї: невисока — метр шістдесят, вредна бунтарка. '
        'Як у Elsa — дуже гарна фігура, але маленькі груди; завжди десь на своїй хвилі.',
    biographyType:
        'Piper — моя молодша сестра, їй шістнадцять. Ще одна блондинка в нашій сім\'ї: '
        'маленька — метр шістдесят зросту — але вредна бунтарка. Як у Elsa, у неї дуже '
        'гарна фігура, але маленькі груди; дуже сподівається, що вони ще виростуть, '
        'хоча більше розраховує на силікон у майбутньому.\n\n'
        'Погано вчиться в школі і постійно отримує зауваження. Хоч їй і шістнадцять, '
        'кажуть, що вона вже курить. Періодично прогулює уроки — тоді її можна знайти '
        'десь у парку або деінде. Завжди літає в хмарах, і ніколи не зрозуміло, про що '
        'вона думає. Подружок і друзів — безліч.\n\n'
        'Дуже хоче здати на права, але грошей немає. Постійно скаржиться на свій '
        'старенький телефон і ноутбук. Мріє про професійний фотоапарат і набір '
        'килимків для йоги.',
    biographyAppearance:
        'Невисока блондинка — метр шістдесят, струнка, з дуже гарною фігурою. '
        'Груди маленькі; на відміну від Elsa, не соромиться бунтувати й дивитися '
        'кудись повз усіх. Зазвичай виглядає так, ніби її думки далеко — '
        'напівусмішка, розпущене або неохайно зібране волосся, одяг «як вийшла».',
    weaknesses: [
      'Маленькі груди: сподівається, що виростуть, але більше — на силікон.',
      'Школа: погано вчиться, зауваження, прогули — часто десь у парку.',
      'Куріння: ходять чутки, що вже курить.',
      'Гроші: права, новий телефон і ноутбук — постійно не вистачає.',
      'Мрія: професійний фотоапарат і набір килимків для йоги.',
    ],
    age: 16,
    items: List<NpcOwnedItem>.from(_piperOwnedItems),
    galleryPortraitPath: kPiperGalleryPortraitPath,
    avatarPath: kPiperAvatarPath,
    schedule: [
      SchedulePoint(
        hourStart: 8,
        hourEnd: 8,
        location: 'bathroom',
        actionLabel: 'Приймає душ',
        spritePath: 'lib/assets/npcs/piper/piper.png',
        days: [0, 1, 2, 3, 4],
      ),
      SchedulePoint(
        hourStart: 9,
        hourEnd: 9,
        location: 'piper_room',
        actionLabel: 'В своїй кімнаті',
        spritePath: 'lib/assets/npcs/piper/piper.png',
        days: [0, 1, 2, 3, 4],
      ),
      SchedulePoint(
        hourStart: 10,
        hourEnd: 17,
        location: LocationsData.collegeHall,
        actionLabel: 'У коледжі',
        spritePath: kPiperAvatarPath,
        days: [0, 1, 2, 3, 4],
      ),
      SchedulePoint(
        hourStart: 17,
        hourEnd: 21,
        location: 'piper_room',
        actionLabel: 'У своїй кімнаті',
        spritePath: 'lib/assets/npcs/piper/piper.png',
        days: [0, 1, 2, 3, 4],
      ),
      SchedulePoint(
        hourStart: 22,
        hourEnd: 6,
        location: 'piper_room',
        actionLabel: 'sleep',
        spritePath: 'lib/assets/npcs/piper/piper.png',
        days: [0, 1, 2, 3, 4],
      ),
      // --- Вихідні (сб–нд) ---
      SchedulePoint(
        hourStart: 9,
        hourEnd: 9,
        location: LocationsData.kitchen,
        actionLabel: 'На кухні',
        spritePath: kPiperAvatarPath,
        days: [5, 6],
      ),
      SchedulePoint(
        hourStart: 10,
        hourEnd: 10,
        location: LocationsData.bathroom,
        actionLabel: 'Приймає душ',
        spritePath: kPiperAvatarPath,
        days: [5, 6],
      ),
      SchedulePoint(
        hourStart: 11,
        hourEnd: 13,
        location: LocationsData.piperRoom,
        actionLabel: 'У своїй кімнаті',
        spritePath: kPiperAvatarPath,
        days: [5, 6],
      ),
      SchedulePoint(
        hourStart: 14,
        hourEnd: 15,
        location: LocationsData.hall,
        actionLabel: 'У залі',
        spritePath: kPiperAvatarPath,
        days: [5, 6],
      ),
      SchedulePoint(
        hourStart: 18,
        hourEnd: 19,
        location: LocationsData.neighborKitchen,
        actionLabel: 'У гостях у Jessa',
        spritePath: kPiperAvatarPath,
        days: [5, 6],
      ),
      SchedulePoint(
        hourStart: 22,
        hourEnd: 6,
        location: LocationsData.piperRoom,
        actionLabel: 'sleep',
        spritePath: kPiperAvatarPath,
        days: [5, 6],
      ),
    ],
  );
}
