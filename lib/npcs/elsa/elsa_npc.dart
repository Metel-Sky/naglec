import '../../models/npc_model.dart';
import '../../models/item_model.dart';
import '../../data/locations_room_data.dart';

const String kElsaGalleryPortraitPath = 'lib/assets/npcs/elsa/elsa_ava.jpg';
const String kElsaAvatarPath = 'lib/assets/npcs/elsa/elsa.png';
const List<int> _weekdays = [0, 1, 2, 3, 4];
const List<int> _weekend = [5, 6];
/// Будні без вівторня та середи — слот 18:00 у кімнаті (вів 18–19 Emily; сер 18–19 місто).
const List<int> _weekdaysElsaRoomAt18 = [0, 3, 4];

/// Особисті речі Elsa, які можуть випадати при обшуку її кімнати.
const List<LootOption> elsaPersonalLoot = [
  LootOption(item: GameItems.panties, weight: 0.1),
  LootOption(item: GameItems.bra, weight: 0.1),
  LootOption(item: GameItems.roomKey, weight: 0.05),
];

const List<NpcOwnedItem> _elsaOwnedItems = [
  NpcOwnedItem(
    id: 'elsa_old_phone',
    name: 'Старенький телефон',
    imagePath: 'lib/assets/items/old_samsung.jpg',
  ),
];

/// Модель NPC: Elsa (статистика, розклад, аватар).
NPCModel createElsaNpc() {
  return NPCModel(
    id: 'elsa',
    name: 'Elsa',
    fullName: 'Elsa',
    status: 'Старша сестра',
    bodyDescription:
        'Дуже гарненька блондинка, сором\'язлива, але стійка — майже завжди з посмішкою. '
        'Маленькі груди, чудова фігура й спокусливий прес; займається фітнесом і йогою вдома.',
    biographyType:
        'Elsa — моя старша сестра. Дуже гарненька блондинка: сором\'язлива, але внутрішньо '
        'стійка — завжди посміхається і рідко буває без гарного настрою. Вчиться зі мною в одному '
        'коледжі, але в групі на два роки старше; вчиться відмінно, і на неї ніколи не '
        'скаржилися вчителі.\n\n'
        'У неї багато подружок — часто ходять до нас у гості, а вона сама обожнює сходити '
        'до когось або на вечірку. Мати постійно хвалить Elsa і ставить її прикладом для Piper — '
        'від чого Piper періодично дуже злиться.\n\n'
        'У Elsa старенький телефон; вона постійно просить у мами або в мене грошей на олію '
        'для масажу. Мріє про масажний стіл і набір косметики. Вміє робити масаж і іноді '
        'підпрацьовує; ще інколи за гроші робить домашку одногрупникам. Хоче ходити в зал, '
        'але поки не вистачає грошей — тому займається фітнесом і йогою вдома.',
    biographyAppearance:
        'Дуже гарненька блондинка з чудовою фігурою. Груди маленькі — через це трохи '
        'комплексує і мріє зробити силіконові, як у мами. Дуже красивий животик '
        'зі спокусливим пресом — результат домашніх тренувань і йоги. Зазвичай '
        'виглядає свіжо й радісно, з тією самою посмішкою, яку рідко знімає з обличчя.',
    weaknesses: [
      'Маленькі груди: трохи комплексує, мріє про силікон, як у мами.',
      'Гроші: старий телефон, постійно просить на олію для масажу, не вистачає на зал.',
      'Мрія: масажний стіл і набір косметики.',
      'Підробіток: масажі та домашка одногрупникам за гроші.',
    ],
    age: 18,
    items: List<NpcOwnedItem>.from(_elsaOwnedItems),
    galleryPortraitPath: kElsaGalleryPortraitPath,
    avatarPath: kElsaAvatarPath,
    schedule: [
      SchedulePoint(
        hourStart: 23,
        hourEnd: 6,
        location: LocationsData.elsaRoom,
        actionLabel: 'Спить',
        spritePath: kElsaAvatarPath,
      ),
      SchedulePoint(
        hourStart: 7,
        hourEnd: 7,
        location: LocationsData.bathroom,
        actionLabel: 'Приймає душ',
        spritePath: kElsaAvatarPath,
        days: _weekdays,
      ),
      SchedulePoint(
        hourStart: 8,
        hourEnd: 8,
        location: LocationsData.kitchen,
        actionLabel: 'Снідає',
        spritePath: kElsaAvatarPath,
        days: _weekdays,
      ),
      SchedulePoint(
        hourStart: 9,
        hourEnd: 9,
        location: LocationsData.hall,
        actionLabel: 'Фітнес',
        spritePath: kElsaAvatarPath,
        days: _weekdays,
      ),
      SchedulePoint(
        hourStart: 10,
        hourEnd: 17,
        location: LocationsData.collegeHall,
        days: _weekdays,
        actionLabel: 'У коледжі',
        spritePath: kElsaAvatarPath,
      ),
      SchedulePoint(
        hourStart: 18,
        hourEnd: 18,
        location: LocationsData.elsaRoom,
        actionLabel: 'Займається своїми справами',
        spritePath: kElsaAvatarPath,
        days: _weekdaysElsaRoomAt18,
      ),
      SchedulePoint(
        hourStart: 18,
        hourEnd: 19,
        location: LocationsData.poorVillageCallCenterBossRoom2,
        actionLabel: 'У гостях у Emily',
        spritePath: kElsaAvatarPath,
        days: [1],
      ),
      SchedulePoint(
        hourStart: 18,
        hourEnd: 19,
        location: LocationsData.cityOverview,
        actionLabel: 'Гуляє по місту',
        spritePath: '',
        days: [2],
      ),
      SchedulePoint(
        hourStart: 19,
        hourEnd: 19,
        location: LocationsData.hall,
        actionLabel: 'Дивиться телевізор',
        spritePath: kElsaAvatarPath,
        days: _weekdaysElsaRoomAt18,
      ),
      SchedulePoint(
        hourStart: 20,
        hourEnd: 22,
        location: LocationsData.elsaRoom,
        actionLabel: 'Робить уроки',
        spritePath: kElsaAvatarPath,
        days: _weekdays,
      ),
      SchedulePoint(
        hourStart: 8,
        hourEnd: 8,
        location: LocationsData.bathroom,
        spritePath: kElsaAvatarPath,
        days: _weekend,
        actionLabel: 'Приймає душ',
      ),
      SchedulePoint(
        hourStart: 9,
        hourEnd: 9,
        location: LocationsData.kitchen,
        actionLabel: 'Снідає',
        spritePath: kElsaAvatarPath,
        days: _weekend,
      ),
      SchedulePoint(
        hourStart: 10,
        hourEnd: 12,
        location: LocationsData.kitchen,
        spritePath: kElsaAvatarPath,
        days: _weekend,
        actionLabel: 'Снідає',
      ),
      SchedulePoint(
        hourStart: 13,
        hourEnd: 15,
        location: LocationsData.hall,
        actionLabel: 'Відпочиває вдома',
        spritePath: kElsaAvatarPath,
        days: _weekend,
      ),
      SchedulePoint(
        hourStart: 16,
        hourEnd: 20,
        location: LocationsData.poorVillageCallCenterBossRoom2,
        actionLabel: 'У гостях у Emily',
        spritePath: kElsaAvatarPath,
        days: [5],
      ),
      SchedulePoint(
        hourStart: 16,
        hourEnd: 20,
        location: LocationsData.cityOverview,
        actionLabel: 'Гуляє по місту',
        spritePath: '',
        days: [6],
      ),
      SchedulePoint(
        hourStart: 21,
        hourEnd: 21,
        location: LocationsData.elsaRoom,
        actionLabel: 'У своїй кімнаті',
        spritePath: kElsaAvatarPath,
        days: [5],
      ),
      SchedulePoint(
        hourStart: 21,
        hourEnd: 22,
        location: LocationsData.elsaRoom,
        actionLabel: 'У своїй кімнаті',
        spritePath: kElsaAvatarPath,
        days: [6],
      ),
    ],
  );
}
