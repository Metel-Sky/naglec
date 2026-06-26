import '../../models/npc_model.dart';
import '../../models/item_model.dart';
import '../../data/locations_room_data.dart';
import 'mom_video_func.dart';

/// Портрет для галереї «Персонажі»; аватар для телефону, профілю, смуги NPC.
const String kMomGalleryPortraitPath = 'lib/assets/npcs/mom/mom.jpg';
const String kMomAvatarPath = 'lib/assets/npcs/mom/mom_ava.png';

/// Заглушка офісу / work slot — не показувати як силует NPC у домі (кухня тощо).
const String kMomWorkplacePlaceholderPath =
    'lib/assets/npcs/mom/mom_work_place.jpg';

/// Особисті речі мами, які можуть дуже рідко випадати при обшуку її кімнати.
const List<LootOption> momPersonalLoot = [
  LootOption(item: GameItems.panties, weight: 0.1),
  LootOption(item: GameItems.bra, weight: 0.1),
  LootOption(item: GameItems.dildo, weight: 0.05),
  LootOption(item: GameItems.analPlug, weight: 0.03),
  LootOption(item: GameItems.vibratorRemote, weight: 0.03),
  LootOption(item: GameItems.roomKey, weight: 0.05),
];

/// Модель NPC: Мама (статистика, розклад, аватар).
NPCModel createMomNpc() {
  return NPCModel(
    id: 'mom',
    name: 'Cory',
    fullName: 'Cory',
    status: 'Mother',
    bodyDescription: 'Зовнішність: Класична "MILF" - доглянута, віддає перевагу офісному стилю або облягаючим сукням. У залі ввечері розслабляється у домашньому халаті або легінсах для йоги.',
    biographyType: 'Сувора, але турботлива бізнес-леді. Вона вдова, яка сама тягне будинок і двох доньок (Ріту та Кіру). Вона звикла все контролювати.',
    biographyAppearance: 'Класична "MILF" - доглянута, віддає перевагу офісному стилю або облягаючим сукням. У залі ввечері розслабляється у домашньому халаті або легінсах для йоги.',
    weaknesses: [
      'Втома: Після роботи в бізнес-центрі у неї дуже болять плечі та спина.',
      'Тайні забави: Любить дивитися мелодрами з келихом вина, коли діти сплять.',
      'Контроль: їй важко визнати, що син став дорослим чоловіком.',
    ],
    checkpoints: const [],
    age: 37,
    galleryPortraitPath: kMomGalleryPortraitPath,
    avatarPath: kMomAvatarPath,
    // Час включно: 7–7 = 7:00–7:59, 10–17 = 10:00–17:59; через північ 23–6 = 23:00–6:59.
    schedule: [
      SchedulePoint(
        hourStart: 7,
        hourEnd: 7,
        location: 'kitchen',
        actionLabel: 'Готує сніданок',
        spritePath: momKitchenMorning(),
        days: [0, 1, 2, 3, 4],
      ),
      SchedulePoint(
        hourStart: 8,
        hourEnd: 8,
        location: 'mom_room',
        actionLabel: 'Перевдягається',
        // Ввечері в залі — без відео, статичний кадр.
        spritePath: 'lib/assets/npcs/mom/mom_work_place.jpg',
        days: [0, 1, 2, 3, 4],
      ),
      SchedulePoint(
        hourStart: 9,
        hourEnd: 9,
        location: 'bathroom',
        actionLabel: 'Миється',
        spritePath: momShowerMorningVideos(),
        days: [0, 1, 2, 3, 4],
      ),

      SchedulePoint(
        hourStart: 10,
        hourEnd: 13,
        location: LocationsData.cityBcLogisticsMomOffice,
        actionLabel: 'Робота',
        spritePath: '',
        days: [0, 1, 2, 3, 4],
      ),

      SchedulePoint(
        hourStart: 14,
        hourEnd: 14,
        location: LocationsData.cityParkCoffee,
        actionLabel: "Кав'ярня",
        spritePath: "lib/assets/npcs/mom/mom.jpg",
        days: [0, 1, 2, 3, 4],
      ),

      SchedulePoint(
        hourStart: 15,
        hourEnd: 17,
        location: LocationsData.cityBcLogisticsMomOffice,
        actionLabel: 'Робота',
        spritePath: '',
        days: [0, 1, 2, 3, 4],
      ),
      SchedulePoint(
        hourStart: 18,
        hourEnd: 19,
        // Маркер: фактична кімната обирається через NpcCityRoamingService.
        location: LocationsData.cityOverview,
        actionLabel: 'Гуляє по місту',
        spritePath: '',
        days: [1, 3, 4],
      ),
      SchedulePoint(
        hourStart: 18,
        hourEnd: 19,
        // Понеділок: VIP тренажерка (рандом hall/spa/sauna/massage у NPCService).
        location: LocationsData.cityVipGym,
        actionLabel: 'VIP тренажерка',
        spritePath: kMomAvatarPath,
        days: [0],
      ),
      SchedulePoint(
        hourStart: 18,
        hourEnd: 19,
        // Середа: VIP тренажерка (рандом hall/spa/sauna/massage у NPCService).
        location: LocationsData.cityVipGym,
        actionLabel: 'VIP тренажерка',
        spritePath: kMomAvatarPath,
        days: [2],
      ),
      SchedulePoint(
        hourStart: 20,
        hourEnd: 20,
        location: 'hall',
        actionLabel: 'Відпочиває',
        // Ввечері в залі — без відео, статичний кадр.
        spritePath: 'lib/assets/npcs/mom/mom_work_place.jpg',
        days: [0, 1, 2, 3, 4],
      ),
      SchedulePoint(
        hourStart: 21,
        hourEnd: 21,
        location: 'kitchen',
        actionLabel: 'Готує вечерю',
        // Фон-відео задає HomeView — momKitchenEveningSeeded (ролики кухні, не mom_room).
        spritePath: '',
        days: [0, 1, 2, 3, 4],
      ),
      SchedulePoint(
        hourStart: 22,
        hourEnd: 22,
        location: 'mom_room',
        actionLabel: 'Відпочиває',
        // Відео обирає HomeView за добовим seed (3 варіанти).
        spritePath: '',
        days: [0, 1, 2, 3, 4],
      ),

      ///#######################################################################
      SchedulePoint(
        hourStart: 9,
        hourEnd: 9,
        location: 'bathroom',
        actionLabel: 'Миється',
        spritePath: momShowerMorningVideos(),
        days: [5, 6],
      ),
      SchedulePoint(
        hourStart: 10,
        hourEnd: 11,
        location: 'kitchen',
        spritePath: kMomAvatarPath,
        days: [5, 6],
        actionLabel: '',
      ),
      SchedulePoint(
        hourStart: 12,
        hourEnd: 14,
        // Маркер: фактична кімната обирається через NpcCityRoamingService.
        location: LocationsData.cityOverview,
        actionLabel: 'Гуляє по місту',
        spritePath: '',
        days: [5, 6],
      ),
      SchedulePoint(
        hourStart: 15,
        hourEnd: 17,
        // Субота: VIP тренажерка, фактична кімната обирається в NPCService
        // з [hall, spa, sauna, massage].
        location: LocationsData.cityVipGym,
        actionLabel: 'VIP тренажерка',
        spritePath: kMomAvatarPath,
        days: [5],
      ),
      SchedulePoint(
        hourStart: 18,
        hourEnd: 20,
        location: LocationsData.poorVillageGiftShopOwnerKitchen,
        actionLabel: 'У Cherie на кухні',
        spritePath: kMomAvatarPath,
        days: [5],
      ),
      SchedulePoint(
        hourStart: 15,
        hourEnd: 17,
        location: LocationsData.yard,
        actionLabel: 'Відпочиває у басейна',
        spritePath: kMomAvatarPath,
        days: [6],
      ),
      SchedulePoint(
        hourStart: 18,
        hourEnd: 20,
        location: LocationsData.cityMallRestaurantHall,
        actionLabel: 'У ресторані (зал)',
        spritePath: kMomAvatarPath,
        days: [6],
      ),
      SchedulePoint(
        hourStart: 21,
        hourEnd: 22,
        location: 'hall',
        actionLabel: 'Дивиться ТВ',
        spritePath: 'lib/assets/npcs/mom/mom_work_place.jpg',
        days: [5, 6],
      ),
      ///#######################################################################
      SchedulePoint(
        hourStart: 23,
        hourEnd: 6,
        location: 'mom_room',
        actionLabel: 'sleep',
        // Те саме, що о 22: три sleep-відео — динамічно в HomeView.
        spritePath: '',
      ),
    ],
  );
}
